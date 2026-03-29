import asyncio
import docker
import random
import re
import string
import time
import logging
from dataclasses import dataclass, field
from typing import Optional

logger = logging.getLogger(__name__)

ROOM_LIFETIME = 30 * 60
MAX_ROOMS = 5
BASE_PORT = 27016
GMOD_IMAGE = "gmod-server:latest"

_LOG_NOISE = re.compile(
    r'(^\s*$'
    r'|^\s*\d+\.\d+\s+fps'
    r'|^ConVarRef\s'
    r'|^maxplayers is'
    r'|^Running a listen'
    r'|^Logging to file'
    r'|^Network: IP'
    r'|^Connecting to VAC'
    r'|^VAC secure mode'
    r')',
    re.IGNORECASE
)


@dataclass
class Room:
    room_id: str
    password: str
    port: int
    container_id: str
    owner_steamid: str
    created_at: float = field(default_factory=time.time)
    log_task: Optional[asyncio.Task] = field(default=None, repr=False)

    @property
    def ip_port(self) -> str:
        return f"127.0.0.1:{self.port}"

    @property
    def age(self) -> float:
        return time.time() - self.created_at

    @property
    def time_left(self) -> int:
        return max(0, int(ROOM_LIFETIME - self.age))


class RoomManager:
    def __init__(self, gmod_connector, server_ip: str = "127.0.0.1"):
        self.gmod = gmod_connector
        self.server_ip = server_ip
        self.rooms: dict[str, Room] = {}
        self.rooms_by_owner: dict[str, str] = {}
        self._docker = docker.from_env()
        self._cleanup_task: Optional[asyncio.Task] = None

    def start(self):
        self._cleanup_task = asyncio.create_task(self._cleanup_loop())
        logger.info("RoomManager started")

    def stop(self):
        if self._cleanup_task:
            self._cleanup_task.cancel()
        for room in list(self.rooms.values()):
            if room.log_task:
                room.log_task.cancel()
            self._kill_container(room.container_id)
        logger.info("RoomManager stopped, all rooms killed")

    async def create_room(self, owner_steamid: str) -> dict:
        if owner_steamid in self.rooms_by_owner:
            room_id = self.rooms_by_owner[owner_steamid]
            room = self.rooms[room_id]
            return {
                "status": "already_exists",
                "ip": self.server_ip,
                "port": room.port,
                "password": room.password,
                "time_left": room.time_left,
            }

        if len(self.rooms) >= MAX_ROOMS:
            return {"status": "limit_reached", "max": MAX_ROOMS}

        port = self._find_free_port()
        if port is None:
            return {"status": "no_ports"}

        password = self._generate_password()
        room_id = self._generate_id()

        try:
            container_id = await asyncio.get_event_loop().run_in_executor(
                None, self._start_container, room_id, port, password,
            )
        except Exception as e:
            logger.error(f"Failed to start container: {e}")
            return {"status": "docker_error", "error": str(e)}

        room = Room(
            room_id=room_id,
            password=password,
            port=port,
            container_id=container_id,
            owner_steamid=owner_steamid,
        )
        self.rooms[room_id] = room
        self.rooms_by_owner[owner_steamid] = room_id

        room.log_task = asyncio.create_task(
            self._stream_logs(room),
            name=f"logs-{room_id}"
        )

        logger.info(f"Room {room_id} created for {owner_steamid} on port {port}")

        return {
            "status": "created",
            "ip": self.server_ip,
            "port": port,
            "password": password,
            "lifetime": ROOM_LIFETIME,
        }

    async def delete_room(self, owner_steamid: str) -> dict:
        if owner_steamid not in self.rooms_by_owner:
            return {"status": "not_found"}
        room_id = self.rooms_by_owner[owner_steamid]
        await self._remove_room(room_id)
        return {"status": "deleted"}

    def get_room_info(self, owner_steamid: str) -> dict:
        if owner_steamid not in self.rooms_by_owner:
            return {"status": "not_found"}
        room = self.rooms[self.rooms_by_owner[owner_steamid]]
        return {
            "status": "ok",
            "ip": self.server_ip,
            "port": room.port,
            "password": room.password,
            "time_left": room.time_left,
        }

    def get_stats(self) -> dict:
        return {
            "active_rooms": len(self.rooms),
            "max_rooms": MAX_ROOMS,
            "rooms": [
                {
                    "room_id": r.room_id,
                    "owner": r.owner_steamid,
                    "port": r.port,
                    "time_left": r.time_left,
                }
                for r in self.rooms.values()
            ],
        }

    async def _stream_logs(self, room: Room):

        loop = asyncio.get_event_loop()
        try:
            container = await loop.run_in_executor(
                None, self._docker.containers.get, room.container_id
            )
        except Exception as e:
            logger.error(f"[logs:{room.room_id}] Can't get container: {e}")
            return

        logger.info(f"[logs:{room.room_id}] Started streaming")

        try:
            log_gen = await loop.run_in_executor(
                None,
                lambda: container.logs(stream=True, follow=True, stdout=True, stderr=True)
            )

            for raw_line in log_gen:
                if room.room_id not in self.rooms:
                    break

                line = raw_line.decode("utf-8", errors="replace").rstrip()

                if not line or _LOG_NOISE.search(line):
                    continue

                self.gmod.send("SVRoomLog", {
                    "room_id": room.room_id,
                    "owner": room.owner_steamid,
                    "line": line,
                })

                await asyncio.sleep(0)  

        except asyncio.CancelledError:
            pass
        except Exception as e:
            logger.error(f"[logs:{room.room_id}] Stream error: {e}")

        logger.info(f"[logs:{room.room_id}] Stream ended")

    def _start_container(self, room_id: str, port: int, password: str) -> str:
        container = self._docker.containers.run(
            GMOD_IMAGE,
            detach=True,
            name=f"gmod-room-{room_id}",
            ports={
                f"{port}/udp": port,
                f"{port}/tcp": port,
            },
            environment={
                "GMOD_PASSWORD": password,
                "GMOD_PORT": str(port),
                "GMOD_MAP": "gm_flatgrass",
                "GMOD_MAXPLAYERS": "16",
                "GMOD_GAMEMODE": "sandbox",
            },
            volumes={
                "/gmodserver": {"bind": "/gmodserver", "mode": "ro"}
            },
            mem_limit="1400m",
            restart_policy={"Name": "no"},
            log_config={"type": "json-file", "config": {"max-size": "10m", "max-file": "1"}},
        )
        return container.id

    def _kill_container(self, container_id: str):
        try:
            container = self._docker.containers.get(container_id)
            container.stop(timeout=5)
            container.remove(force=True)
        except docker.errors.NotFound:
            pass
        except Exception as e:
            logger.error(f"Error killing container {container_id}: {e}")

    def _find_free_port(self) -> Optional[int]:
        used_ports = {r.port for r in self.rooms.values()}
        for port in range(BASE_PORT, BASE_PORT + MAX_ROOMS):
            if port not in used_ports:
                return port
        return None

    def _generate_password(self, length: int = 8) -> str:
        chars = string.ascii_uppercase + string.digits
        chars = chars.replace("0", "").replace("O", "").replace("I", "").replace("1", "")
        return "".join(random.choices(chars, k=length))

    def _generate_id(self, length: int = 8) -> str:
        return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))

    async def _remove_room(self, room_id: str):
        room = self.rooms.pop(room_id, None)
        if room is None:
            return
        self.rooms_by_owner.pop(room.owner_steamid, None)

        if room.log_task:
            room.log_task.cancel()

        await asyncio.get_event_loop().run_in_executor(
            None, self._kill_container, room.container_id
        )
        logger.info(f"Room {room_id} removed")
        self.gmod.send("SVRoomClosed", {"room_id": room_id, "owner": room.owner_steamid})

    async def _cleanup_loop(self):
        while True:
            try:
                await asyncio.sleep(60)
                expired = [
                    room_id for room_id, room in self.rooms.items()
                    if room.age >= ROOM_LIFETIME
                ]
                for room_id in expired:
                    logger.info(f"Room {room_id} expired, removing")
                    await self._remove_room(room_id)
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Cleanup loop error: {e}")
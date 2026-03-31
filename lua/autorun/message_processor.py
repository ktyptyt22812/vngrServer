# process messages from gmod
# Copyright (C) 2026 ktypt, selyodka

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
import asyncio
import json
from room_manager import RoomManager
#KE 6.3.5
class MessageProcessor:
    def __init__(self, gmod_connector, config):
        self.gmod = gmod_connector
        self.config = config
        self.queue = asyncio.Queue()
        self.discord_bot = None
        self.telegram_bot = None
        self.room_manager = None
        self.stop_event = asyncio.Event()
    def set_bots(self, discord_bot, telegram_bot):
        self.discord_bot = discord_bot
        self.telegram_bot = telegram_bot
    def set_room_manager(self, room_manager):
        self.room_manager = room_manager
    async def process_messages(self):
        print("Message processor started")
        await asyncio.sleep(5)
        while not self.stop_event.is_set():
            try:
                msg_data = await asyncio.wait_for(self.queue.get(), timeout=0.1)
                await self._process_message(msg_data)
            except asyncio.TimeoutError:
                continue
            except Exception as e:
                print(f"Error processing message: {e}")
        print("Message processor stopped")
    async def _process_message(self, msg_data):
        channel = msg_data['channel']
        raw_message = msg_data['message']
        try:
            data = json.loads(raw_message)
        except json.JSONDecodeError:
            await self._send_to_platforms(f"[{channel}]: {raw_message}")
            return
        handlers = {
            'SVcounter': self._handle_player_count,
            'SVGetGroups': self._handle_get_groups,
            'SVMessage': self._handle_sv_message,
            'SVMessageReply': self._handle_sv_message,
            'SVCreateRoom':  self._handle_create_room,
            'SVDeleteRoom':  self._handle_delete_room,
            'SVRoomInfo':    self._handle_room_info,
            'SVRoomStats':   self._handle_room_stats,
        }
        handler = handlers.get(channel)
        if handler:
            await handler(data)
        else:
            print(f"Unknown channel: {channel}")
            if self.config.Debug:
                print(f"[{channel}]: {raw_message}")
    async def _handle_player_count(self, data):
        if isinstance(data, list) and len(data) > 0:
            player_count = data[0]
            if self.discord_bot:
                await self.discord_bot.update_status(player_count)
            if self.config.Debug:
                print(f"Player count updated: {player_count}")
    async def _handle_get_groups(self, data):
        if isinstance(data, dict) and 'recvid' in data:
            recv_id = data['recvid']
            groups_data = {
                "admin": {"name": "Администратор", "color": [255, 0, 0], "order": 1},
                "vip": {"name": "VIP", "color": [0, 255, 0], "order": 2}#хуйня нерабочая
            }
            response_data = {
                "1": groups_data,
                "2": {},
                "recvid": recv_id
            }
            self.gmod.send('SVSyncGroups', response_data)
            print(f"Sent group data (recvid: {recv_id})")
    async def _handle_sv_message(self, data):
        if isinstance(data, dict) and 'embed' in data:
            embed_data = data['embed']
            if self.discord_bot:
                await self.discord_bot.send_embed(embed_data)
            if self.telegram_bot:
                text = self.telegram_bot.embed_to_text(embed_data)
                await self.telegram_bot.send_message(text)
            print("Sent embed to platforms")

        elif isinstance(data, dict) and 'body' in data:
            await self._handle_error_forwarder(data)

        elif isinstance(data, list) and len(data) > 0:
            message_text = data[0]
            await self._send_to_platforms(message_text)
    async def _send_to_platforms(self, text):
        tasks = []
        if self.discord_bot:
            tasks.append(self.discord_bot.send_message(text))
        if self.telegram_bot:
            tasks.append(self.telegram_bot.send_message(text))
        if tasks:
            await asyncio.gather(*tasks, return_exceptions=True)
            print(f"Sent to platforms: {text[:50]}...")
    async def forward_to_discord(self, text):
        if self.discord_bot:
            await self.discord_bot.send_message(text)
    async def forward_to_telegram(self, text):
        if self.telegram_bot:
            await self.telegram_bot.send_message(text)
    async def _handle_create_room(self, data: dict):
        if not self.room_manager:
            return

        steamid = data.get("steamid") or (data.get("2") or {}).get("steamid")
        recv_id = data.get("recvid")

        if not steamid or not recv_id:
            return

        result = await self.room_manager.create_room(steamid)
        result["recvid"] = recv_id

        self.gmod.send("SVCreateRoom", result)

        if self.config.Debug:
            print(f"[Rooms] CreateRoom for {steamid}: {result['status']}")


    async def _handle_delete_room(self, data: dict):
        if not self.room_manager:
            return

        steamid = data.get("steamid")
        recv_id = data.get("recvid")

        if not steamid or not recv_id:
            return

        result = await self.room_manager.delete_room(steamid)
        result["recvid"] = recv_id

        self.gmod.send("SVDeleteRoom", result)


    async def _handle_room_info(self, data: dict):
        if not self.room_manager:
            return

        steamid = data.get("steamid")
        recv_id = data.get("recvid")

        if not steamid or not recv_id:
            return

        result = self.room_manager.get_room_info(steamid)
        result["recvid"] = recv_id

        self.gmod.send("SVRoomInfo", result)


    async def _handle_room_stats(self, data: dict):
        if not self.room_manager:
            return

        recv_id = data.get("recvid")
        if not recv_id:
            return

        result = self.room_manager.get_stats()
        result["recvid"] = recv_id

        self.gmod.send("SVRoomStats", result)
    async def _handle_error_forwarder(self, data):
        is_clientside = data.get('isClientside', False)
        body = data.get('body')  

        if not body:
            return

        webhook_url = (
            self.config.DISCORD_WEBHOOK_CLIENT
            if is_clientside
            else self.config.DISCORD_WEBHOOK_SERVER
        )

        if not webhook_url:
            print(f"Missing webhook URL for {'client' if is_clientside else 'server'} realm")
            return

        try:
            import aiohttp
            async with aiohttp.ClientSession() as session:
                async with session.post(
                    webhook_url,
                    data={'payload_json': body},
                    headers={'User-Agent': 'CFC Error Forwarder v1'},
                    timeout=aiohttp.ClientTimeout(total=25)
                ) as response:
                    if response.status == 429:
                        resp_body = await response.text()
                        import json
                        retry_data = json.loads(resp_body)
                        retry_after = retry_data.get('retry_after', 5)
                        print(f"Rate limited, retry after {retry_after}s")
                    elif response.status >= 400:
                        resp_body = await response.text()
                        print(f"Webhook error {response.status}: {resp_body}")
                    else:
                        print(f"Webhook delivered ({'client' if is_clientside else 'server'})")

            self.gmod.send('SVMessageReply', {'status': 'ok'})

        except Exception as e:
            print(f"[ErrorForwarder] Failed to send webhook: {e}")
    def stop(self):
        self.stop_event.set()

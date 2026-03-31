# connector module for bot
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
import socket
import threading
import select
import time
import json
import asyncio
class GModConnector:
    def __init__(self, config):
        self.config = config
        self.socket_send = None
        self.socket_recv = None
        self.recv_thread = None
        self.stop_event = threading.Event()
        self.message_queue = None
        self.loop = None
        
    def setup(self):

        try:

            self.socket_send = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            print(f"GMod send socket: {self.config.GMOD_HOST}:{self.config.GMOD_SEND_PORT}")

            self.socket_recv = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.socket_recv.bind(("0.0.0.0", self.config.GMOD_PORT))
            self.socket_recv.setblocking(False)
            print(f"GMod receive socket: 0.0.0.0:{self.config.GMOD_PORT}")
            
            return True
        except Exception as e:
            print(f"Error setting up GMod connection: {e}")
            return False
    
    def send(self, channel_name, message_data):

        if self.socket_send is None:
            print("GMod send socket not initialized")
            return False
        
        try:
            message_json = json.dumps(message_data, ensure_ascii=False)
            message_bytes = message_json.encode('utf-8')
            name_bytes = channel_name.encode('utf-8')
            
            packet = bytes([len(name_bytes)]) + name_bytes + message_bytes
            
            self.socket_send.sendto(packet, (self.config.GMOD_HOST, self.config.GMOD_SEND_PORT))
            print(f"GMod: {channel_name} -> {message_json[:100]}...")
            
            return True
        except Exception as e:
            print(f"Error sending to GMod: {e}")
            return False
    
    def start_receive_thread(self, message_queue):

        self.message_queue = message_queue
        self.loop = asyncio.get_event_loop()
        
        self.recv_thread = threading.Thread(
            target=self._receive_loop,
            daemon=True,
            name="GMod-Receiver"
        )
        self.recv_thread.start()
    
    def _receive_loop(self):

        print("GMod receive thread started")
        
        while not self.stop_event.is_set():
            try:
                ready = select.select([self.socket_recv], [], [], 0.1)
                
                if ready[0]:
                    data, addr = self.socket_recv.recvfrom(1024 * 1024)
                    
                    if data:
                        name_len = data[0]
                        channel = data[1:1 + name_len].decode('utf-8', errors='ignore')
                        message = data[1 + name_len:].decode('utf-8', errors='ignore')
                        
                        print(f"GMod ({addr[0]}:{addr[1]}): {channel} -> {message[:100]}...")
                        

                        if self.message_queue and self.loop:
                            asyncio.run_coroutine_threadsafe(
                                self.message_queue.put({
                                    'channel': channel,
                                    'message': message
                                }),
                                self.loop
                            )
                            
            except socket.error as e:
                if e.errno not in [11, 35]:  # EAGAIN, EWOULDBLOCK
                    print(f"GMod receive socket error: {e}")
            except Exception as e:
                print(f"Error in GMod receive loop: {e}")
            
            time.sleep(0.01)
        
        print("GMod receive thread stopped")
    
    def stop(self):

        self.stop_event.set()
        
        if self.recv_thread and self.recv_thread.is_alive():
            self.recv_thread.join(timeout=2)
        
        if self.socket_send:
            self.socket_send.close()
        
        if self.socket_recv:
            self.socket_recv.close()

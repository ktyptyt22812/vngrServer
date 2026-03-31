# tg bot for tgdsbot
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
import aiohttp
import asyncio
import re

class TelegramBot:
    def __init__(self, config, gmod_connector, message_processor):
        self.config = config
        self.gmod = gmod_connector
        self.message_processor = message_processor
        self.session = None
        self.offset = 0
        self.is_running = False
        self.stop_event = asyncio.Event()
        
    async def initialize(self):
        self.session = aiohttp.ClientSession()
        print("Telegram session initialized")
    
    async def start_polling(self):
        self.is_running = True
        print("Starting Telegram polling...")
        while not self.stop_event.is_set():
            try:
                updates = await self._get_updates()
                
                for update in updates:
                    if "message" in update:
                        await self._handle_message(update["message"])
                
                if not updates:
                    await asyncio.sleep(1)
            except Exception as e:
                print(f"Telegram polling error: {e}")
                await asyncio.sleep(5)
        print("Telegram polling stopped")
    async def _get_updates(self):
        try:
            url = f"https://api.telegram.org/bot{self.config.TELEGRAM_BOT_TOKEN}/getUpdates"
            params = {
                "offset": self.offset,
                "timeout": 2,
                "limit": 100
            }
            async with self.session.get(url, params=params) as response:
                if response.status == 200:
                    data = await response.json()
                    if data.get("ok"):
                        updates = data.get("result", [])
                        if updates:
                            self.offset = updates[-1]["update_id"] + 1
                        return updates
                else:
                    error_text = await response.text()
                    print(f"❌ Telegram getUpdates error: {response.status} - {error_text}")
        except Exception as e:
            print(f"Error getting Telegram updates: {e}")
        return []
    async def _handle_message(self, message):
        if "text" not in message or "from" not in message:
            return
        try:
            user = message["from"]
            text_content = message["text"]
            urls = re.findall(r'https?://\S+', text_content)
            user_name = user.get("first_name", "Unknown")
            if user.get("last_name"):
                user_name += f" {user['last_name']}"
            self.gmod.send('TGMessage', [
                str(user["id"]),
                user_name,
                text_content,
                urls,
                None,
                bool(urls)
            ])
            await self.message_processor.forward_to_discord(
                f"[Telegram] {user_name}: {text_content}"
            )
            print(f"Telegram message from {user_name}: {text_content[:50]}...")
        except Exception as e:
            print(f"Error processing Telegram message: {e}")
    async def send_message(self, text, chat_id=None):
        if not self.session:
            print("Telegram session not initialized")
            return False
        if chat_id is None:
            chat_id = self.config.TELEGRAM_TARGET_CHAT_ID
        try:
            url = f"https://api.telegram.org/bot{self.config.TELEGRAM_BOT_TOKEN}/sendMessage"
            data = {
                "chat_id": chat_id,
                "text": text,
                "parse_mode": "HTML"
            }
            async with self.session.post(url, json=data) as response:
                if response.status == 200:
                    return True
                else:
                    error_text = await response.text()
                    print(f"Telegram send error: {response.status} - {error_text}")
                    return False
        except Exception as e:
            print(f"Error sending Telegram message: {e}")
            return False
    async def send_photo(self, filepath, caption=""):
        if not self.session:
            print("Telegram session not initialized")
            return False
        try:
            url = f"https://api.telegram.org/bot{self.config.TELEGRAM_BOT_TOKEN}/sendPhoto"
            with open(filepath, 'rb') as photo:
                data = aiohttp.FormData()
                data.add_field('chat_id', str(self.config.TELEGRAM_TARGET_CHAT_ID))
                data.add_field('caption', caption)
                data.add_field('photo', photo, filename='screenshot.jpg', content_type='image/jpeg')
                async with self.session.post(url, data=data) as response:
                    if response.status == 200:
                        print("Photo sent to Telegram")
                        return True
                    else:
                        error_text = await response.text()
                        print(f"Telegram photo error: {response.status} - {error_text}")
                        return False
        except Exception as e:
            print(f"Error sending Telegram photo: {e}")
            return False
    def embed_to_text(self, embed_data):
        parts = []
        if author := embed_data.get("author", {}).get("name"):
            parts.append(f"<i>{author}</i>")
        title = embed_data.get("title")
        url = embed_data.get("url")
        if title:
            if url:
                parts.append(f"<b><a href=\"{url}\">{title}</a></b>")
            else:
                parts.append(f"<b>{title}</b>")
        if desc := embed_data.get("description"):
            parts.append(desc)
        if fields := embed_data.get("fields"):
            for field in fields:
                name = field.get("name", "")
                value = field.get("value", "")
                parts.append(f"\n<b>{name}:</b> {value}")
        if image := embed_data.get("image", {}).get("url"):
            parts.append(f"\n[Изображение]({image})")
        elif thumb := embed_data.get("thumbnail", {}).get("url"):
            parts.append(f"\n[Миниатюра]({thumb})")
        footer = embed_data.get("footer", {}).get("text")
        timestamp = embed_data.get("timestamp")
        if footer or timestamp:
            footer_line = []
            if footer:
                footer_line.append(footer)
            if timestamp:
                footer_line.append(f"({timestamp})")
            parts.append("\n— " + " ".join(footer_line))

        return "\n".join(parts).strip()
    async def stop(self):
        self.stop_event.set()
        self.is_running = False
        if self.session:
            await self.session.close()
            print("Telegram session closed")
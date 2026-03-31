# config for dstgbod
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
import os
class Config:
    def __init__(self):
        self.DISABLE_DISCORD = os.environ.get('DISABLE_DISCORD', 'false').lower() == 'true'
        self.DISCORD_BOT_TOKEN = "---" # do not add sensitive information in github version 
        self.DISCORD_TARGET_CHANNEL_ID = 000 # do not add sensitive information in github version
        self.TELEGRAM_BOT_TOKEN = "---" # do not add sensitive information in github version
        self.TELEGRAM_TARGET_CHAT_ID = 000 # do not add sensitive information in github version
        self.GMOD_HOST = "192.168.31.116"
        self.GMOD_PORT = 12350
        self.GMOD_SEND_PORT = 12351
        self.SCREENSHOTS_DIR = "/gmodserver/garrysmod/addons/kot/lua/autorun/screensh"
        self.HTTP_PORT = 8083
        self.Debug = True
        self.Debug_GAPI = True
        os.makedirs(self.SCREENSHOTS_DIR, exist_ok=True)
    def validate(self):
        errors = []
        if not self.DISABLE_DISCORD and not self.DISCORD_BOT_TOKEN:
            errors.append("Discord bot token is missing")
        if not self.TELEGRAM_BOT_TOKEN:
            errors.append("Telegram bot token is missing")
        if not self.GMOD_HOST:
            errors.append("GMod host is missing")
        if errors:
            raise ValueError(f"Configuration errors: {', '.join(errors)}")
        return True

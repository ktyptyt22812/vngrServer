import os

class Config:
    def __init__(self):
        self.DISABLE_DISCORD = os.environ.get('DISABLE_DISCORD', 'false').lower() == 'true'
        self.DISCORD_BOT_TOKEN = "---"
        self.DISCORD_TARGET_CHANNEL_ID = 000
        self.TELEGRAM_BOT_TOKEN = "---"
        self.TELEGRAM_TARGET_CHAT_ID = 000
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

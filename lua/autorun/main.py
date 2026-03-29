import asyncio
import os
from config import Config
from gmod_connector import GModConnector
from discord_bot import DiscordBot
from telegram_bot import TelegramBot
from screenshot_server import ScreenshotServer
from message_processor import MessageProcessor
from gmod_api import GAPI
#KE 6.3.5
#пояснение к версиям
#KE это энвайромент для работы некоторых служб
# первая цифра это номер глобального обновления
# вторая цифра это номер версии дополнительных служб
# третья цифра это номер обновления
# четвертая цифра это номер тестового обновления
# пожалуйста не трогай и не копируй код для своих целей
class BotOrchestrator:
    def __init__(self):
        self.config = Config()
        self.gmod_connector = GModConnector(self.config)
        self.message_processor = None
        self.discord_bot = None
        self.telegram_bot = None
        self.screenshot_server = None
        self.stop_event = asyncio.Event()
        
    async def start(self):

        print("=" * 50)
        print("Starting...")
        print("=" * 50)

        if not self.gmod_connector.setup():
            print("Failed to initialize GMod connection. Exiting.")
            return
        
        print("GMod connection established")

        self.message_processor = MessageProcessor(
            self.gmod_connector,
            self.config
        )
        
        tasks = []
      
        if not self.config.DISABLE_DISCORD:
            try:
                self.discord_bot = DiscordBot(
                    self.config,
                    self.gmod_connector,
                    self.message_processor
                )
                tasks.append(asyncio.create_task(
                    self._run_discord_safe(),
                    name="discord_bot"
                ))
                print("Discord bot module loaded")
            except Exception as e:
                print(f"Discord bot failed to load: {e}")
        else:
            print("Discord bot disabled via DISABLE_DISCORD")

        try:
            self.telegram_bot = TelegramBot(
                self.config,
                self.gmod_connector,
                self.message_processor
            )
            await self.telegram_bot.initialize()
            tasks.append(asyncio.create_task(
                self._run_telegram_safe(),
                name="telegram_bot"
            ))
            print("Telegram bot module loaded")
        except Exception as e:
            print(f"Telegram bot failed to load: {e}")
        

        try:
            self.screenshot_server = ScreenshotServer(
                self.config,
                self.discord_bot,
                self.telegram_bot
            )
            tasks.append(asyncio.create_task(
                self._run_screenshot_server(),
                name="screenshot_server"
            ))
            print("Screenshot server module loaded")
        except Exception as e:
            print(f"Screenshot server failed to load: {e}")
        
        self.message_processor.set_bots(self.discord_bot, self.telegram_bot)
        from room_manager import RoomManager
        room_manager = RoomManager(self.gmod_connector, server_ip="твой_IP")
        room_manager.start()
        self.message_processor.set_room_manager(room_manager)
        self.room_manager = room_manager  
        tasks.append(asyncio.create_task(
            self._run_message_processor(),
            name="message_processor"
        ))
        print("Message processor loaded")
        
        self.gmod_connector.start_receive_thread(self.message_processor.queue)
        self.gmod_api = GAPI(self.gmod_connector)
        self.gmod_api.load_modules()
        print("GMod receive thread started")
        print("=" * 50)
        print("started successfully!")
        print("=" * 50)
        await asyncio.sleep(5)
        if self.telegram_bot:
            await self.telegram_bot.send_message("🔄 Бот запущен")
        try:
            await asyncio.gather(*tasks, return_exceptions=True)
        except Exception as e:
            print(f"Error in task execution: {e}")
    async def _run_discord_safe(self):
        try:
            await self.discord_bot.start()
        except asyncio.TimeoutError:
            print("Connection timeout. Discord module stopped.")
        except Exception as e:
            print(f"error: {e}")
    async def _run_telegram_safe(self):
        try:
            await self.telegram_bot.start_polling()
        except Exception as e:
            print(f"error: {e}")
            await asyncio.sleep(10)
            if not self.stop_event.is_set():
                print("Attempting to restart Telegram bot...")
                await self._run_telegram_safe()
    async def _run_screenshot_server(self):
        try:
            await self.screenshot_server.start()
        except Exception as e:
            print(f"error: {e}")
    async def _run_message_processor(self):
        try:
            await self.message_processor.process_messages()
        except Exception as e:
            print(f"Message processor: Critical error: {e}")
    async def stop(self):
        print("\n" + "=" * 50)
        print("Shutting down")
        print("=" * 50)
        self.stop_event.set()
        if self.discord_bot:
            await self.discord_bot.stop()
            print("Discord bot stopped")
        if self.telegram_bot:
            await self.telegram_bot.stop()
            print("Telegram bot stopped")
        if self.screenshot_server:
            await self.screenshot_server.stop()
            print("Screenshot server stopped")
        if self.message_processor:
            self.message_processor.stop()
            print("Message processor stopped")
        self.gmod_connector.stop()
        print("GMod connector stopped")
        print("=" * 50)
        print("Shutdown complete!")
        print("=" * 50)
async def main():
    orchestrator = BotOrchestrator()
    try:
        await orchestrator.start()
    except KeyboardInterrupt:
        print("\nInterrupted by user")
    finally:
        await orchestrator.stop()
if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nexit")
from aiohttp import web
import base64
import os
import asyncio
from datetime import datetime

class ScreenshotServer:
    def __init__(self, config, discord_bot, telegram_bot):
        self.config = config
        self.discord_bot = discord_bot
        self.telegram_bot = telegram_bot
        self.app = None
        self.runner = None
        self.site = None
        
    async def start(self):
        self.app = web.Application()
        
        # Регистрируем маршруты
        self.app.router.add_post('/upload', self._handle_upload)
        self.app.router.add_get('/health', self._handle_health)
        
        # Запускаем сервер
        self.runner = web.AppRunner(self.app)
        await self.runner.setup()
        
        self.site = web.TCPSite(
            self.runner,
            '0.0.0.0',
            self.config.HTTP_PORT
        )
        await self.site.start()
        
        print(f"   Screenshot server started on port {self.config.HTTP_PORT}")
        print(f"   Upload URL: http://localhost:{self.config.HTTP_PORT}/upload")
    
    async def _handle_health(self, request):

        return web.Response(text="Screenshot server is running")
    
    async def _handle_upload(self, request):
        try:

            ts = request.query.get('ts', str(int(datetime.now().timestamp())))
            
            # Читаем POST данные
            data = await request.post()
            if 'i' not in data:
                return web.Response(text="Missing image data", status=400)
            try:
                image_data = base64.b64decode(data['i'])
            except Exception as e:
                print(f"Error decoding base64 image: {e}")
                return web.Response(text="Invalid base64 data", status=400)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"screenshot_{timestamp}_{ts}.jpg"
            filepath = os.path.join(self.config.SCREENSHOTS_DIR, filename)
            
            with open(filepath, 'wb') as f:
                f.write(image_data)

            print(f"Screenshot saved: {filename} ({len(image_data)} bytes)")
            await self._send_to_platforms(filepath, filename)
            
            return web.Response(text="Screenshot uploaded successfully", status=200)
            
        except Exception as e:
            print(f"Error handling screenshot upload: {e}")
            return web.Response(text="Internal server error", status=500)
    
    async def _send_to_platforms(self, filepath, filename):
        tasks = []
        
        if self.discord_bot and self.discord_bot.is_ready:
            task = asyncio.create_task(self.discord_bot.send_file(filepath, filename))
            tasks.append(task)
        
        if self.telegram_bot and self.telegram_bot.is_running:
            task = asyncio.create_task(self.telegram_bot.send_photo(filepath, " "))
            tasks.append(task)
        
        if tasks:
            results = await asyncio.gather(*tasks, return_exceptions=True)
            
            success_count = sum(1 for r in results if r is True)
            print(f"Screenshot sent to {success_count}/{len(tasks)} platforms")
        # try:
        #     os.remove(filepath)
        # except:
        #     pass
    async def stop(self):
        if self.site:
            await self.site.stop()
        if self.runner:
            await self.runner.cleanup()
        print("Screenshot server stopped")
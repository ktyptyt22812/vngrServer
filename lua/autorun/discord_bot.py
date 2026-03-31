# ds module for bot
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
import discord 
import re
import asyncio
#параша, не закрывать код а то яйца отпадут
class DiscordBot:
    def __init__(self, config, gmod_connector, message_processor):
        self.config = config
        self.gmod = gmod_connector
        self.message_processor = message_processor
        self.client = None
        self.pending_key_requests = {}
        self.is_ready = False
        
    async def start(self):
        if self.config.DISABLE_DISCORD:
            print("Discord is disabled")
            return
        
        try:
            intents = discord.Intents.default()
            intents.message_content = True
            intents.guilds = True
            intents.members = True
            
            self.client = discord.Client(intents=intents)
            self.client.event(self.on_ready)
            self.client.event(self.on_message)
            
            print("Starting Discord bot...")
            await self.client.start(self.config.DISCORD_BOT_TOKEN)
            
        except Exception as e:
            print(f"Discord bot error: {e}")
            raise
    
    async def on_ready(self):
        self.is_ready = True
        print(f'Discord logged in as {self.client.user}!')
    
        channel = self.client.get_channel(self.config.DISCORD_TARGET_CHANNEL_ID)
        if channel:
            await channel.send("🔄 бот перезагружен")
        self.gmod.send('BOTMessage', [
            "1",
            "♦",
            "бот перезагружен",
            [],
            None,
            False
        ])
    async def on_message(self, message):
        if message.author == self.client.user:
            return
        if isinstance(message.channel, discord.DMChannel):
            await self._handle_dm_verification(message)
            return
        if message.channel.id == self.config.DISCORD_TARGET_CHANNEL_ID:
            await self._handle_channel_message(message)
    async def _handle_dm_verification(self, message):
        for recv_id, steam_id in list(self.pending_key_requests.items()):
            if message.content:
                response_data = {
                    "1": "Success",
                    "2": steam_id,
                    "recvid": recv_id
                }
                self.gmod.send('SVChatVerify', response_data)
                print(f"Verification successful for {steam_id}")
                del self.pending_key_requests[recv_id]
                return
    async def _handle_channel_message(self, message):
        if message.content.startswith("[Telegram]"):
            return
        try:
            text_content = message.content
            urls = re.findall(r'https?://\S+', text_content)
            self.gmod.send('DSMessage', [
                str(message.author.id),
                f"{message.author.display_name}",
                text_content,
                urls,
                None,
                bool(urls)
            ])
            await self.message_processor.forward_to_telegram(
                f"[Discord] {message.author.display_name}: {text_content}"
            )
            
        except Exception as e:
            print(f"Error processing Discord message: {e}")
    
    async def send_message(self, text):
        if not self.is_ready or not self.client:
            print("Discord bot not ready")
            return False
        try:
            channel = self.client.get_channel(self.config.DISCORD_TARGET_CHANNEL_ID)
            if channel:
                await channel.send(text)
                return True
            else:
                print(f"Discord channel {self.config.DISCORD_TARGET_CHANNEL_ID} not found")
                return False
        except Exception as e:
            print(f"Error sending Discord message: {e}")
            return False
    
    async def send_embed(self, embed_data):
        if not self.is_ready or not self.client:
            print("Discord bot not ready")
            return False
        try:
            channel = self.client.get_channel(self.config.DISCORD_TARGET_CHANNEL_ID)
            if not channel:
                return False
            embed = discord.Embed(
                title=embed_data.get('title'),
                description=embed_data.get('description'),
                color=embed_data.get('color'),
                url=embed_data.get('url')
            )
            if 'thumbnail' in embed_data and embed_data['thumbnail'].get('url'):
                embed.set_thumbnail(url=embed_data['thumbnail']['url'])
            if 'fields' in embed_data and isinstance(embed_data['fields'], list):
                for field in embed_data['fields']:
                    embed.add_field(
                        name=field.get('name'),
                        value=field.get('value'),
                        inline=field.get('inline', False)
                    )
            await channel.send(embed=embed)
            return True
        except Exception as e:
            print(f"Error sending Discord embed: {e}")
            return False
    
    async def update_status(self, player_count):
        if not self.is_ready or not self.client:
            return False
        
        try:
            activity = discord.Game(name=f"Игроков: {player_count}")
            await self.client.change_presence(activity=activity)
            return True
        except Exception as e:
            print(f"Error updating Discord status: {e}")
            return False
    
    async def send_file(self, filepath, filename):
        if not self.is_ready or not self.client:
            return False
        try:
            channel = self.client.get_channel(self.config.DISCORD_TARGET_CHANNEL_ID)
            if channel:
                with open(filepath, 'rb') as f:
                    file = discord.File(f, filename)
                    await channel.send("", file=file)
                return True
        except Exception as e:
            print(f"Error sending Discord file: {e}")
            return False
    async def stop(self):
        if self.client:
            await self.client.close()
            self.is_ready = False

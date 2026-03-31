# gmod bot
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
import asyncio
import socket
import threading
import select
import time
import json
import re
import aiohttp
from urllib.parse import quote
import logging
from aiohttp import web, MultipartWriter
import base64
import os
from datetime import datetime
z9=os.environ.get('DISABLE_DISCORD','false').lower()=='true'
if z9:
 print("ds func disabled")
t1="=" # 123
t2="=" # 123
g1="192.168.31.116"
g2=12350
g3=12351
d1=123
t3=12321
s1=None
s2=None
c1=None
s3=None
o1=0
q1=asyncio.Queue()
e1=asyncio.Event()
r1={}
a1=None
r2={}
d2="/gmodserver/garrysmod/addons/kot/lua/autorun/screensh"
p1=8083
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',level=logging.INFO)
os.makedirs(d2,exist_ok=True)
def f1(e):
 p=[]
 if a:=e.get("author",{}).get("name"):
  p.append(f"<i>{a}</i>")
 t=e.get("title")
 u=e.get("url")
 if t:
  if u:
   p.append(f"<b><a href=\"{u}\">{t}</a></b>")
  else:
   p.append(f"<b>{t}</b>")
 if d:=e.get("description"):
  p.append(d)
 if f:=e.get("fields"):
  for x in f:
   n=x.get("name","")
   v=x.get("value","")
   i=x.get("inline",False)
   p.append(f"\n<b>{n}:</b> {v}")
 if i:=e.get("image",{}).get("url"):
  p.append(f"\n[Изображение]({i})")
 elif th:=e.get("thumbnail",{}).get("url"):
  p.append(f"\n[Миниатюра]({th})")
 ft=e.get("footer",{}).get("text")
 ts=e.get("timestamp")
 if ft or ts:
  fl=[]
  if ft:
   fl.append(ft)
  if ts:
   fl.append(f"({ts})")
  p.append("\n— "+" ".join(fl))
 m="\n".join(p).strip()
 return m
def f2():
 global s1,s2
 try:
  s1=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
  print(f"GMod send socket created for sending to {g1}:{g3}")
  s2=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
  s2.bind(("0.0.0.0",g2))
  s2.setblocking(False)
  print(f"GMod receive socket bound to 0.0.0.0:{g2}")
  return True
 except Exception as e:
  print(f"Error setting up GMod connection: {e}")
  return False
def f3(c,m):
 if s1 is None:
  print("GMod send socket not initialized.")
  return
 try:
  mj=json.dumps(m,ensure_ascii=False)
  mb=mj.encode('utf-8')
  nb=c.encode('utf-8')
  pk=bytes([len(nb)])+nb+mb
  s1.sendto(pk,(g1,g3))
  print(f"Sent to GMod: Channel='{c}', Message='{mj}'")
 except Exception as e:
  print(f"Error sending to GMod: {e}")
def f4():
 global s2
 while not e1.is_set():
  try:
   rd=select.select([s2],[],[],0.1)
   if rd[0]:
    d,a=s2.recvfrom(1024*1024)
    if d:
     nl=d[0]
     n=d[1:1+nl].decode('utf-8',errors='ignore')
     mj=d[1+nl:].decode('utf-8',errors='ignore')
     print(f"Received from GMod ({a[0]}:{a[1]}): Channel='{n}', RawMessage='{mj}'")
     if c1 and hasattr(c1,'loop')and c1.loop:
      asyncio.run_coroutine_threadsafe(q1.put({'channel':n,'message':mj}),c1.loop)
  except socket.error as e:
   if e.errno!=11 and e.errno!=35:
    print(f"GMod receive socket error: {e}")
  except Exception as e:
   print(f"Error in GMod receive thread: {e}")
  time.sleep(0.01)
 if s2:
  s2.close()
 print("GMod receive thread stopped.")
async def f5(r):
 try:
  ts=r.query.get('ts',str(int(time.time())))
  d=await r.post()
  if 'i' not in d:
   return web.Response(text="Missing image data",status=400)
  try:
   id=base64.b64decode(d['i'])
  except Exception as e:
   print(f"Error decoding base64 image: {e}")
   return web.Response(text="Invalid base64 data",status=400)
  tm=datetime.now().strftime("%Y%m%d_%H%M%S")
  fn=f"screenshot_{tm}_{ts}.jpg"
  fp=os.path.join(d2,fn)
  with open(fp,'wb')as f:
   f.write(id)
  print(f"Screenshot saved: {fn} ({len(id)} bytes)")
  await f6(fp,fn)
  return web.Response(text="Screenshot uploaded successfully",status=200)
 except Exception as e:
  print(f"Error handling screenshot upload: {e}")
  return web.Response(text="Internal server error",status=500)
async def f6(fp,fn):
 try:
  if c1:
   ch=c1.get_channel(d1)
   if ch:
    with open(fp,'rb')as f:
     fl=discord.File(f,fn)
     await ch.send("",file=fl)
  if s3:
   await f7(fp)
  print(f"Screenshot {fn} sent to platforms")
 except Exception as e:
  print(f"Error sending screenshot to platforms: {e}")
async def f7(fp):
 try:
  u=f"https://api.telegram.org/bot{t2}/sendPhoto"
  with open(fp,'rb')as ph:
   d=aiohttp.FormData()
   d.add_field('chat_id',str(t3))
   d.add_field('caption',' ')
   d.add_field('photo',ph,filename='screenshot.jpg',content_type='image/jpeg')
   async with s3.post(u,data=d)as rs:
    if rs.status!=200:
     et=await rs.text()
     print(f"Telegram photo upload error: {rs.status} - {et}")
    else:
     print("Screenshot sent to Telegram successfully")
 except Exception as e:
  print(f"Error sending photo to Telegram: {e}")
async def f8():
 global a1
 a1=web.Application()
 a1.router.add_post('/upload',f5)
 async def hc(r):
  return web.Response(text="Screenshot server is running")
 a1.router.add_get('/health',hc)
 return a1
async def f9(tx,ci=t3):
 if not t2 or t2=="YOUR_TELEGRAM_BOT_TOKEN_HERE":
  return False
 try:
  u=f"https://api.telegram.org/bot{t2}/sendMessage"
  d={"chat_id":ci,"text":tx,"parse_mode":"HTML"}
  async with s3.post(u,json=d)as rs:
   if rs.status==200:
    return True
   else:
    et=await rs.text()
    print(f"Telegram API error: {rs.status} - {et}")
    return False
 except Exception as e:
  print(f"Error sending message to Telegram: {e}")
  return False
async def f10():
 global o1
 if not t2 or t2=="YOUR_TELEGRAM_BOT_TOKEN_HERE":
  return[]
 try:
  u=f"https://api.telegram.org/bot{t2}/getUpdates"
  pr={"offset":o1,"timeout":2,"limit":100}
  async with s3.get(u,params=pr)as rs:
   if rs.status==200:
    d=await rs.json()
    if d.get("ok"):
     up=d.get("result",[])
     if up:
      o1=up[-1]["update_id"]+1
     return up
   else:
    et=await rs.text()
    print(f"Telegram getUpdates error: {rs.status} - {et}")
 except Exception as e:
  print(f"Error getting Telegram updates: {e}")
 return[]
async def f11():
 print("Starting Telegram polling...")
 while not e1.is_set():
  try:
   up=await f10()
   for u in up:
    if"message"in u:
     m=u["message"]
     if"text"in m and"from"in m:
      us=m["from"]
      tc=m["text"]
      await f12(us,tc)
   if not up:
    await asyncio.sleep(1)
  except Exception as e:
   print(f"Error in Telegram polling: {e}")
   await asyncio.sleep(5)
 print("Telegram polling stopped.")
async def f12(u,tc):
 try:
  ur=re.findall(r'https?://\S+',tc)
  un=u.get("first_name","Unknown")
  if u.get("last_name"):
   un+=f" {u['last_name']}"
  p=2
  if bool(ur):
   p=1
  ds=[str(u["id"]),f"{un}",tc,ur,None,bool(ur)]
  f3('TGMessage',ds)
  if c1:
   try:
    ch=c1.get_channel(d1)
    if ch:
     dm=f"[Telegram] {un}: {tc}"
     await ch.send(dm)
   except Exception as e:
    print(f"Error sending Telegram message to Discord: {e}")
  print(f"Processed Telegram message from {un}: {tc}")
 except Exception as e:
  print(f"Error processing Telegram message: {e}")
class MyClient(discord.Client):
 def __init__(self,*args,**kwargs):
  super().__init__(*args,**kwargs)
  self.gmod_recv_thread=None
  self.channel_id=d1
 async def setup_hook(self):
  print("Setting up Discord client hook...")
  self.gmod_recv_thread=threading.Thread(target=f4,daemon=True)
  self.gmod_recv_thread.start()
  print("GMod receive thread started.")
 async def on_ready(self):
  print(f'Discord logged on as {self.user}!')
  ch=self.get_channel(self.channel_id)
  await ch.send("🔄 Discord бот перезагружен")
  tc="Discord бот перезагружен"
  ur=re.findall(r'https?://\S+',tc)
  ds=[str("1"),str("♦"),tc,ur,None,bool(ur)]
  f3('BOTMessage',ds)
 async def on_message(self,m):
  if m.author==self.user:
   return
  if isinstance(m.channel,discord.DMChannel):
   for ri,si in list(r1.items()):
    if m.content:
     rd={"1":"Success","2":si,"recvid":ri}
     f3('SVChatVerify',rd)
     print(f"Verification successful for {si}. Notifying GMod.")
     del r1[ri]
     return
  if m.channel.id!=d1 or m.content.startswith("[Telegram]"):
   return
  try:
   tc=m.content
   ur=re.findall(r'https?://\S+',tc)
   ds=[str(m.author.id),f"{m.author}",tc,ur,None,bool(ur)]
   f3('DSMessage',ds)
   tm=f"[Discord] {m.author}: {tc}"
   await f9(tm)
  except Exception as e:
   print(f"Error processing Discord message: {e}")
async def f13():
 await asyncio.sleep(9)
 dc=c1.get_channel(d1)if c1 else None
 while not e1.is_set():
  try:
   md=await asyncio.wait_for(q1.get(),timeout=0.1)
   cn=md['channel']
   rm=md['message']
   d=None
   try:
    d=json.loads(rm)
   except json.JSONDecodeError:
    fm=f"[{cn}]: {rm}"
    if dc:
     await dc.send(fm)
    await f9(fm)
    print(f"Sent raw message to platforms: {fm}")
    continue
   if cn=='SVcounter':
    if isinstance(d,list)and len(d)>0 and isinstance(d[0],str):
     pc=d[0]
     if c1:
      ac=discord.Game(name=f"Игроков: {pc}")
      await c1.change_presence(activity=ac)
     print(f"Updated bot status: 'Игроков: {pc}'")
   elif cn=='SVGetGroups':
    if isinstance(d,dict)and'recvid'in d:
     ri=d['recvid']
     gd={"admin":{"name":"Администратор","color":[255,0,0],"order":1},"vip":{"name":"VIP","color":[0,255,0],"order":2}}
     rd={"1":gd,"2":{},"recvid":ri}
     f3('SVSyncGroups',rd)
     print(f"Sent group data back to GMod with recvid: {ri}")
   elif cn=='SVCacheImage':
    try:
     try:
      pd=await request.json()
     except Exception:
      pd=await request.post()
      if not isinstance(pd,list)or len(pd)<2:
       return web.Response(text="Missing URL or HASH in payload",status=400)
      url=pd[0]
      hn=pd[1]
     if not url or not hn:
      return web.Response(text="Missing URL or HASH",status=400)
      print("Missing URL or HASH")
     import aiohttp
     async with aiohttp.ClientSession()as ss:
      async with ss.get(url)as rs:
       if rs.status!=200:
        print(f"Failed to download image from {url}: Status {rs.status}")
        return web.Response(text=f"Failed to download image (Status {rs.status})",status=500)
       id=await rs.read()
     ct=rs.headers.get('Content-Type','').lower()
     ex='.jpg'
     if'image/png'in ct:
      ex='.png'
     elif'image/gif'in ct:
      ex='.gif'
     elif'image/jpeg'in ct:
      ex='.jpg'
     fn=hn+ex
     fp=os.path.join(CACHE_DIR,fn)
     with open(fp,'wb')as f:
      f.write(id)
     print(f"Image cached: {fn} from {url} ({len(id)} bytes)")
     return web.Response(text=f"Image {hn} cached successfully",status=200)
    except Exception as e:
     print(f"Error processing SVCacheImage: {e}")
     return web.Response(text=f"Internal Server Error: {e}",status=500)
   elif cn in['SVMessage','SVMessageReply']:
    mt=""
    if isinstance(d,dict)and'embed'in d:
     try:
      ed=d['embed']
      if dc:
       em=discord.Embed(title=ed.get('title'),description=ed.get('description'),color=ed.get('color'),url=ed.get('url'))
       if'thumbnail'in ed and ed['thumbnail'].get('url'):
        em.set_thumbnail(url=ed['thumbnail']['url'])
       if'fields'in ed and isinstance(ed['fields'],list):
        for fd in ed['fields']:
         em.add_field(name=fd.get('name'),value=fd.get('value'),inline=fd.get('inline',False))
       await dc.send(embed=em)
      mt=f1(ed)
      await f9(mt)
      print(f"Sent embed/message to both platforms")
     except Exception as e:
      print(f"Error processing embed: {e}")
    elif isinstance(d,list)and len(d)>0 and isinstance(d[0],str):
     mt=d[0]
     if dc:
      await dc.send(mt)
     await f9(mt)
     print(f"Sent message to both platforms: {mt}")
  except asyncio.TimeoutError:
   continue
  except Exception as e:
   print(f"Error processing message from GMod queue: {e}")
async def main():
 global c1,s3,a1
 s3=aiohttp.ClientSession()
 if not z9:
  it=discord.Intents.default()
  it.message_content=True
  it.guilds=True
  it.members=True
  c1=MyClient(intents=it)
 else:
  c1=None
 a1=await f8()
 try:
  tk=[]
  tk.append(asyncio.create_task(f13()))
  if c1:
   print("Discord: Добавление задачи запуска клиента...")
   async def rds():
    try:
     await c1.start(t1)
    except asyncio.TimeoutError:
     print("Discord: Connection timeout (блокировка). Discord функционал остановлен.")
    except Exception as e:
     print(f"Discord: Критическая ошибка запуска: {e}")
   tk.append(asyncio.create_task(rds()))
  tk.append(asyncio.create_task(f11()))
  rn=web.AppRunner(a1)
  await rn.setup()
  st=web.TCPSite(rn,'0.0.0.0',p1)
  tk.append(asyncio.create_task(st.start()))
  print(f"HTTP server started on port {p1}")
  print(f"Screenshot upload URL: http://localhost:{p1}/upload")
  await asyncio.sleep(10)
  print("Telegram bot initialized")
  await f9("🔄 Telegram бот запущен")
  await asyncio.gather(*tk)
 except Exception as e:
  print(f"Error in main: {e}")
 finally:
  e1.set()
  if s3:
   await s3.close()
  if c1 and hasattr(c1,'gmod_recv_thread')and c1.gmod_recv_thread and c1.gmod_recv_thread.is_alive():
   c1.gmod_recv_thread.join(timeout=1)
  print("Bot shutdown complete.")
if __name__=="__main__":
 if not f2():
  print("Failed to initialize GMod connection. Exiting.")
  exit()
 try:
  asyncio.run(main())
 except KeyboardInterrupt:
  print("Interrupted by user. Shutting down...")
  e1.set()
  time.sleep(1)
  if s1:
   s1.close()
  print("Bot stopped.")

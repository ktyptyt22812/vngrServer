import json
import os
import importlib
import sys
import asyncio
import time
import uuid
class GAPI:
    def __init__(self, connector):
        self.connector = connector
        self.responses = {}
        self.modules = {}
        self.modules_path = os.path.join(os.path.dirname(__file__), 'modules')
    def send_raw_lua(self, code):
        self.connector.send("ION_Exec", {"code": code})
    async def get_lua_data(self, code, timeout=5):
        self.send_raw_lua(code)
        future = asyncio.get_event_loop().create_future()
        self.pending_requests["ION_Exec_Result"] = future
        try:
            result = await asyncio.wait_for(future, timeout=timeout)
            return result
        except asyncio.TimeoutError:
            print("[GAPI] no otvet")
            return None
        finally:
            self.pending_requests.pop("ION_Exec_Result", None)
    def get_data(self, lua_code):
        req_id = str(uuid.uuid4())[:8]
        self.connector.send("ION_Get", {"code": lua_code, "id": req_id})
        timeout = time.time() + 2
        while time.time() < timeout:
            if req_id in self.responses:
                return self.responses.pop(req_id)
            time.sleep(0.01)
        return None
    def handle_incoming(self, channel, message):
        try:
            data = json.loads(message)
            if channel == "ION_Res":
                res_id = data.get("id")
                payload = data.get("payload")
                if res_id:
                    self.responses[res_id] = payload
            if channel in self.pending_requests:
                self.pending_requests[channel].set_result(data)
        except Exception as e:
            print(f"[GAPI] Error handling incoming: {e}")
    def load_modules(self):
        if not os.path.exists(self.modules_path):
            os.makedirs(self.modules_path)
        for filename in os.listdir(self.modules_path):
            if filename.endswith('.py') and not filename.startswith('__'):
                self.load_module(filename[:-3])
    def load_module(self, name):
        try:
            module_path = f"modules.{name}"
            if module_path in sys.modules:

                module = importlib.reload(sys.modules[module_path])
            else:
                module = importlib.import_module(module_path)
            if hasattr(module, "Module"):
                self.modules[name] = module.Module(self)
                print(f"[GAPI] Module '{name}' loaded/reloaded.")
            return True
        except Exception as e:
            print(f"[GAPI] Failed to load module '{name}': {e}")
            return False
    def unload_module(self, name):
        if name in self.modules:
            del self.modules[name]
            module_key = f"modules.{name}"
            if module_key in sys.modules:
                del sys.modules[module_key]
            print(f"[GAPI] Module '{name}' unloaded.")
            return True
        return False
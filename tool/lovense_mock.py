#!/usr/bin/env python3
"""Local Lovense Remote emulator: virtual devices only, no Bluetooth."""

import argparse
import copy
import json
import math
import threading
import time
from collections import deque
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

FUNCTION_LIMITS = {
    "Vibrate": 20, "Rotate": 20, "Pump": 3, "Thrusting": 20,
    "Fingering": 20, "Suction": 20, "Depth": 3, "Oscillate": 20,
}
TOYS = {
    "mock-nora": {
        "id": "mock-nora", "name": "nora", "nickName": "Nora (virtual)",
        "status": "1", "battery": 85, "version": "mock",
        "fullFunctionNames": ["Vibrate", "Rotate"],
    },
    "mock-max": {
        "id": "mock-max", "name": "max", "nickName": "Max (virtual)",
        "status": "1", "battery": 70, "version": "mock",
        "fullFunctionNames": ["Vibrate", "Pump"],
    },
    "mock-solace": {
        "id": "mock-solace", "name": "solace", "nickName": "Solace (virtual)",
        "status": "1", "battery": 60, "version": "mock",
        "fullFunctionNames": ["Thrusting", "Stroke"],
    },
}


def _log(message):
    print(message, flush=True)


class RemoteState:
    def __init__(self, clock=time.monotonic, log=_log):
        self.clock = clock
        self.log = log
        self.lock = threading.RLock()
        self.toys = copy.deepcopy(TOYS)
        self.active = {}
        self.deadlines = {}
        self.history = deque(maxlen=50)

    def _expire(self):
        for toy in list(self.deadlines):
            if self.deadlines[toy] <= self.clock():
                self.active.pop(toy, None)
                self.deadlines.pop(toy, None)
                self.log(f"[mock] {toy}: command expired")

    def _targets(self, value):
        targets = list(self.toys) if value is None else [value] if isinstance(value, str) else value
        if (not isinstance(targets, list) or not targets
                or any(not isinstance(toy, str) or toy not in self.toys for toy in targets)):
            raise ValueError("Unknown virtual device")
        return list(dict.fromkeys(targets))

    @staticmethod
    def _actions(value):
        if not isinstance(value, str) or not value:
            raise ValueError("action must be a string")
        result = {}
        for item in value.split(","):
            name, separator, raw = item.strip().partition(":")
            if not separator or name in result:
                raise ValueError("Malformed action string")
            if name == "Stroke":
                start, dash, end = raw.partition("-")
                if not dash or not start.isdigit() or not end.isdigit():
                    raise ValueError("Stroke must be given as min-max")
                low, high = int(start), int(end)
                if not (0 <= low < high <= 100 and high - low >= 20):
                    raise ValueError("Stroke width must be at least 20")
                result[name] = [low, high]
            else:
                if name not in FUNCTION_LIMITS or not raw.isdigit():
                    raise ValueError("Unknown function or intensity")
                strength = int(raw)
                if not 0 <= strength <= FUNCTION_LIMITS[name]:
                    raise ValueError("Intensity out of range for function")
                result[name] = strength
        if "Stroke" in result and "Thrusting" not in result:
            raise ValueError("Stroke only works together with Thrusting")
        return result

    def dispatch(self, request):
        with self.lock:
            self._expire()
            try:
                if not isinstance(request, dict):
                    raise ValueError("JSON object required")
                command = request.get("command")
                if command == "GetToys":
                    self.log("[mock] GetToys: returned three virtual toys")
                    return {"code": 200, "type": "OK", "mock": True, "data": {
                        "toys": json.dumps(self.toys, ensure_ascii=False),
                        "platform": "mock", "appType": "remote",
                    }}
                if command != "Function":
                    raise ValueError("Only GetToys and Function are supported")
                if type(request.get("apiVer")) is not int or request["apiVer"] != 1:
                    raise ValueError("apiVer must be 1")
                targets = self._targets(request.get("toy"))
                action = request.get("action")
                duration = request.get("timeSec")
                if (not isinstance(duration, (int, float)) or isinstance(duration, bool)
                        or not math.isfinite(duration)):
                    raise ValueError("A finite timeSec duration is required")
                if action == "Stop":
                    if duration != 0:
                        raise ValueError("For Stop, set timeSec: 0")
                    for toy in targets:
                        self.active.pop(toy, None)
                        self.deadlines.pop(toy, None)
                else:
                    if not 2 <= duration <= 60:
                        raise ValueError("This emulator accepts commands of 2–60 seconds")
                    actions = self._actions(action)
                    for toy in targets:
                        if not set(actions).issubset(self.toys[toy]["fullFunctionNames"]):
                            raise ValueError("Virtual device does not support this function")
                    for toy in targets:
                        if any(value > 0 for name, value in actions.items() if name != "Stroke"):
                            self.active[toy] = copy.deepcopy(actions)
                            self.deadlines[toy] = self.clock() + duration
                        else:
                            self.active.pop(toy, None)
                            self.deadlines.pop(toy, None)
                event = {"action": action, "toys": targets, "timeSec": duration}
                self.history.append(event)
                self.log(f"[mock] {', '.join(targets)}: {action}, {duration:g} s")
                return {"code": 200, "type": "OK", "mock": True}
            except ValueError as error:
                self.log(f"[mock] Error: {error}")
                return {"code": 400, "type": "ERROR", "mock": True, "message": str(error)}

    def snapshot(self):
        with self.lock:
            self._expire()
            return {"mock": True, "active": {
                toy: {"functions": copy.deepcopy(actions),
                      "remainingSeconds": round(max(0, self.deadlines[toy] - self.clock()), 1)}
                for toy, actions in self.active.items()
            }, "commands": copy.deepcopy(list(self.history))}


class MockServer(ThreadingHTTPServer):
    daemon_threads = True
    allow_reuse_address = True

    def __init__(self, address, state=None):
        self.state = state if state is not None else RemoteState()
        super().__init__(address, MockHandler)


class MockHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "LovenseMock/1.0"

    def log_message(self, *_):
        pass

    def _send(self, data, status=200):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        try:
            self.send_response(status)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            pass

    def do_GET(self):
        if self.path == "/state":
            self._send(self.server.state.snapshot())
        else:
            self._send({"code": 404, "mock": True}, 404)

    def _read_body(self):
        limit = 16384
        transfer = self.headers.get("Transfer-Encoding", "").lower()
        if transfer:
            if transfer != "chunked" or "Content-Length" in self.headers:
                raise ValueError("Malformed HTTP body encoding")
            body = bytearray()
            while True:
                line = self.rfile.readline(1024)
                if not line.endswith(b"\r\n"):
                    raise ValueError("Malformed HTTP chunk header")
                size = int(line[:-2].split(b";", 1)[0], 16)
                if size < 0:
                    raise ValueError("Negative HTTP chunk size")
                if len(body) + size > limit:
                    raise OverflowError("Request too large")
                if size == 0:
                    trailer_size = 0
                    while True:
                        trailer = self.rfile.readline(1024)
                        if trailer == b"\r\n":
                            return bytes(body)
                        trailer_size += len(trailer)
                        if not trailer.endswith(b"\r\n") or trailer_size > 4096:
                            raise ValueError("Malformed end of HTTP chunks")
                chunk = self.rfile.read(size)
                if len(chunk) != size or self.rfile.read(2) != b"\r\n":
                    raise ValueError("Truncated HTTP chunk")
                body.extend(chunk)
        size = int(self.headers.get("Content-Length", "0"))
        if size > limit:
            raise OverflowError("Request too large")
        if size <= 0:
            raise ValueError("Empty HTTP body")
        body = self.rfile.read(size)
        if len(body) != size:
            raise ValueError("Truncated HTTP body")
        return body

    def do_POST(self):
        if self.path != "/command":
            self.close_connection = True
            self._send({"code": 404, "mock": True}, 404)
            return
        try:
            self.connection.settimeout(5)
            body = self._read_body()
            if not self.headers.get("X-platform"):
                raise ValueError("X-platform header required")
            data = json.loads(body.decode("utf-8"))
        except OverflowError:
            self.close_connection = True
            self._send({"code": 413, "mock": True}, 413)
            return
        except (ValueError, UnicodeError, OSError):
            self.close_connection = True
            self._send({"code": 400, "mock": True, "message": "Malformed JSON or headers"}, 400)
            return
        self._send(self.server.state.dispatch(data))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="127.0.0.1", help="Listen address; defaults to this computer only")
    parser.add_argument("--port", type=int, default=20011, help="HTTP port, default 20011")
    args = parser.parse_args()
    if not 0 <= args.port <= 65535:
        parser.error("port must be in the range 0–65535")
    try:
        server = MockServer((args.host, args.port))
    except OSError as error:
        parser.exit(2, f"Could not open port: {error}\n")
    host = "127.0.0.1" if args.host == "0.0.0.0" else args.host
    address = f"http://{host}:{server.server_port}"
    print("EMULATOR: all toys are virtual, no Bluetooth or physical control.", flush=True)
    print(f"Tools → Lovense → address: {address}", flush=True)
    print(f"State and recent commands: {address}/state", flush=True)
    print("Use HTTP, not HTTPS. Stop the server: Ctrl+C.", flush=True)
    try:
        server.serve_forever(poll_interval=0.2)
    except KeyboardInterrupt:
        print("\nEmulator stopped.", flush=True)
    finally:
        server.server_close()


if __name__ == "__main__":
    main()

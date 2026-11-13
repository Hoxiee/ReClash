import http.client
import importlib.util
import json
import pathlib
import sys
import threading
import unittest
from urllib.request import ProxyHandler, Request, build_opener

ROOT = pathlib.Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("reclash_lovense_mock", ROOT / "tool/lovense_mock.py")
mock = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = mock
spec.loader.exec_module(mock)


class MockStateTest(unittest.TestCase):
    def setUp(self):
        self.now = 100.0
        self.state = mock.RemoteState(clock=lambda: self.now, log=lambda _: None)

    def command(self, action="Vibrate:3", toy="mock-nora", duration=10):
        return self.state.dispatch({"command": "Function", "action": action,
                                    "toy": toy, "timeSec": duration, "apiVer": 1})

    def test_get_toys_returns_vendor_format_with_explicit_virtual_names(self):
        response = self.state.dispatch({"command": "GetToys"})
        self.assertEqual(response["code"], 200)
        self.assertIsInstance(response["data"]["toys"], str)
        toys = json.loads(response["data"]["toys"])
        self.assertEqual(len(toys), 3)
        self.assertTrue(all("(virtual)" in toy["nickName"] for toy in toys.values()))
        self.assertEqual(self.state.snapshot()["active"], {})

    def test_motion_is_recorded_and_expires_without_a_real_device(self):
        self.assertEqual(self.command()["code"], 200)
        self.assertEqual(self.state.snapshot()["active"]["mock-nora"]["functions"], {"Vibrate": 3})
        self.now += 11
        self.assertEqual(self.state.snapshot()["active"], {})

    def test_targeted_stop_preserves_other_toys_and_stop_all_clears_them(self):
        self.command()
        self.command(toy="mock-max")
        self.assertEqual(self.command(action="Stop", duration=0)["code"], 200)
        self.assertEqual(set(self.state.snapshot()["active"]), {"mock-max"})
        self.assertEqual(self.command(action="Stop", toy=None, duration=0)["code"], 200)
        self.assertEqual(self.state.snapshot()["active"], {})

    def test_strength_and_duration_limits_do_not_create_activity(self):
        for action, toy, duration in [("Pump:4", "mock-max", 10), ("Vibrate:21", "mock-nora", 10),
                                      ("Vibrate:1", "mock-nora", 0), ("Vibrate:1", "mock-nora", 61)]:
            self.assertEqual(self.command(action=action, toy=toy, duration=duration)["code"], 400)
        self.assertEqual(self.state.snapshot()["active"], {})

    def test_stroke_requires_thrusting_and_a_wide_enough_range(self):
        self.assertEqual(self.command(action="Stroke:0-20,Thrusting:3", toy="mock-solace")["code"], 200)
        self.assertEqual(self.command(action="Stroke:0-19,Thrusting:3", toy="mock-solace")["code"], 400)
        self.assertEqual(self.command(action="Stroke:0-100", toy="mock-solace")["code"], 400)

    def test_unknown_devices_and_wrong_api_version_are_rejected(self):
        self.assertEqual(self.command(toy="missing")["code"], 400)
        self.assertEqual(self.state.dispatch({"command": "Function", "apiVer": True})["code"], 400)

    def test_zero_intensity_stops_motion_and_history_is_bounded(self):
        self.command()
        self.command(action="Vibrate:0")
        self.assertEqual(self.state.snapshot()["active"], {})
        for _ in range(60):
            self.command(action="Stop", duration=0)
        self.assertEqual(len(self.state.snapshot()["commands"]), 50)

    def test_chunked_http_requests_from_dart_are_supported(self):
        server = mock.MockServer(("127.0.0.1", 0), self.state)
        thread = threading.Thread(target=lambda: server.serve_forever(poll_interval=0.02), daemon=True)
        thread.start()
        connection = http.client.HTTPConnection("127.0.0.1", server.server_port, timeout=2)
        try:
            connection.request("POST", "/command", body=[b'{"command":', b'"GetToys"}'],
                               headers={"Content-Type": "application/json", "X-platform": "ReClash"},
                               encode_chunked=True)
            response = connection.getresponse()
            self.assertEqual(response.status, 200)
            self.assertEqual(json.loads(response.read())["code"], 200)
        finally:
            connection.close()
            server.shutdown()
            server.server_close()
            thread.join(timeout=2)
            self.assertFalse(thread.is_alive())

    def test_http_get_toys_function_and_state_roundtrip(self):
        server = mock.MockServer(("127.0.0.1", 0), self.state)
        thread = threading.Thread(target=lambda: server.serve_forever(poll_interval=0.02), daemon=True)
        thread.start()
        opener = build_opener(ProxyHandler({}))
        address = f"http://127.0.0.1:{server.server_port}"
        try:
            for command in [{"command": "GetToys"}, {"command": "Function", "action": "Rotate:2",
                                                    "toy": "mock-nora", "timeSec": 10, "apiVer": 1}]:
                request = Request(address + "/command", data=json.dumps(command).encode(),
                                  headers={"Content-Type": "application/json", "X-platform": "ReClash"})
                with opener.open(request, timeout=2) as response:
                    self.assertEqual(json.load(response)["code"], 200)
            with opener.open(address + "/state", timeout=2) as response:
                state = json.load(response)
                self.assertTrue(state["mock"])
                self.assertEqual(state["active"]["mock-nora"]["functions"], {"Rotate": 2})
        finally:
            server.shutdown()
            server.server_close()
            thread.join(timeout=2)
            self.assertFalse(thread.is_alive())


if __name__ == "__main__":
    unittest.main()

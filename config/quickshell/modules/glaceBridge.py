import json
import os
import re
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

SINK = '@DEFAULT_AUDIO_SINK@'
BATTERY_ROOT = '/sys/class/power_supply'

def getVolume():
    try:
        # default sink volume with pipewire's wpctl
        output = subprocess.check_output(['wpctl', 'get-volume', SINK]).decode('utf-8')

        # output
        parts = output.strip().split()
        volume = int(float(parts[1]) * 100)
        isMuted = "[MUTED]" in output

        return {
            "volume": volume,
            "isMuted": isMuted
        }
    
    except Exception as e:
        return {
            "volume": 0,
            "isMuted": True,
            "error": str(e)
        }

def _readSysfsValue(path):
    try:
        with open(path, encoding='ascii') as sysfs_file:
            return sysfs_file.read().strip()
    except (OSError, UnicodeError):
        return None


def getBattery():
    try:
        with os.scandir(BATTERY_ROOT) as entries:
            batteries = sorted(
                (entry for entry in entries if entry.is_dir()),
                key=lambda entry: entry.name
            )
    except OSError:
        batteries = []

    for entry in batteries:
        if _readSysfsValue(os.path.join(entry.path, 'type')) != 'Battery':
            continue

        capacity = _readSysfsValue(os.path.join(entry.path, 'capacity'))
        if capacity is None:
            continue

        try:
            level = max(0, min(100, int(float(capacity))))
        except ValueError:
            continue

        status = _readSysfsValue(os.path.join(entry.path, 'status'))
        return {
            'available': True,
            'level': level,
            'charging': status == 'Charging',
            'powerSaving': False,
            'status': status or 'Unknown'
        }

    return {
        'available': False,
        'level': 0,
        'charging': False,
        'powerSaving': False,
        'status': 'Unavailable'
    }


def setVolume(value):
    value = max(0.0, min(1.0, value))
    subprocess.run(['wpctl', 'set-volume', SINK, f'{value:.4f}'], check=True)
    subprocess.run(['wpctl', 'set-mute', SINK, '1' if value == 0 else '0'], check=True)

def setMute(muted):
    subprocess.run(['wpctl', 'set-mute', SINK, '1' if muted else '0'], check=True)

def setKeyboardLayout(layout):
    if layout not in ('us', 'es'):
        raise ValueError('unsupported keyboard layout')

    if subprocess.run(['qdbus6', 'org.kde.keyboard', '/Layouts',
                       'org.kde.KeyboardLayouts.getLayout'],
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
        layouts = subprocess.check_output([
            'qdbus6', '--literal', 'org.kde.keyboard', '/Layouts',
            'org.kde.KeyboardLayouts.getLayoutsList'
        ], text=True)
        layout_codes = re.findall(r'\(sss\) "([^"]+)"', layouts)
        if layout not in layout_codes:
            raise RuntimeError(
                f'layout {layout!r} is not configured in KDE Plasma'
            )
        subprocess.run([
            'qdbus6', 'org.kde.keyboard', '/Layouts',
            'org.kde.KeyboardLayouts.setLayout',
            str(layout_codes.index(layout))
        ], check=True)
        return

    try:
        subprocess.run(['hyprctl', 'keyword', 'input:kb_layout', layout], check=True)
    except FileNotFoundError:
        subprocess.run(['setxkbmap', layout], check=True)

class GlaceRequestHandler(BaseHTTPRequestHandler):
    def sendJson(self, status, payload):
        body = json.dumps(payload).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlparse(self.path).path
        if path == '/state':
            self.sendJson(200, getVolume())
        elif path == '/battery':
            self.sendJson(200, getBattery())
        else:
            self.sendJson(404, {'error': 'not found'})

    def do_POST(self):
        try:
            length = int(self.headers.get('Content-Length', 0))
            payload = json.loads(self.rfile.read(length) or '{}')
            path = urlparse(self.path).path

            if path == '/set':
                setVolume(float(payload['value']))
            elif path == '/mute':
                setMute(bool(payload['muted']))
            elif path == '/keyboard':
                setKeyboardLayout(payload['layout'])
            else:
                self.sendJson(404, {'error': 'not found'})
                return

            self.sendJson(200, getVolume())
        except Exception as error:
            self.sendJson(400, {'error': str(error)})

    def log_message(self, format, *args):
        return

def serve():
    server = ThreadingHTTPServer(('127.0.0.1', 18765), GlaceRequestHandler)
    server.serve_forever()

if __name__ == "__main__":
    command = sys.argv[1] if len(sys.argv) > 1 else 'get'

    if command == 'serve':
        serve()
        sys.exit(0)

    try:
        if command == 'set' and len(sys.argv) == 3:
            setVolume(float(sys.argv[2]))
        elif command == 'mute' and len(sys.argv) == 3:
            setMute(sys.argv[2] == '1')
        elif command != 'get':
            raise ValueError('usage: glaceBridge.py [get|set <0.0-1.0>|mute <0|1>]')

        print(json.dumps(getVolume()))
    except Exception as error:
        print(json.dumps({"volume": 0, "isMuted": True, "error": str(error)}))
        sys.exit(1)
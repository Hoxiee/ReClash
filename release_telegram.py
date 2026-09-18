import html
import json
import os
import sys
from pathlib import Path

import requests

bot_token = os.environ['TELEGRAM_BOT_TOKEN']
tag = os.environ['TAG']
run_id = os.environ['RUN_ID']
repository = os.getenv('GITHUB_REPOSITORY', 'Hoxiee/ReClash')
chat_id = os.getenv('TELEGRAM_CHAT_ID', '@ReClashApp')
api_url = f'http://localhost:8081/bot{bot_token}/sendMediaGroup'
dist_dir = Path.cwd() / 'dist'
notes_path = Path.cwd() / 'telegram.md'

release_keywords = (
    'windows-amd64-setup',
    'android-arm64',
    'macos-arm64',
    'macos-amd64',
)
media = []
files = {}

for path in sorted(dist_dir.iterdir()):
    if path.is_file() and any(keyword in path.name.lower() for keyword in release_keywords):
        file_key = f'file{len(files) + 1}'
        media.append({'type': 'document', 'media': f'attach://{file_key}'})
        files[file_key] = path.open('rb')

if not media:
    print('No Telegram release artifacts were found.', file=sys.stderr)
    sys.exit(1)

text = f'<b>{html.escape(tag)}</b>\n\n'
text += f'https://github.com/{repository}/releases/tag/{tag}\n'
if '-' in tag:
    text += f'https://github.com/{repository}/actions/runs/{run_id}\n'
if notes_path.exists():
    text += f'\n{notes_path.read_text()}'

media[-1]['caption'] = text
media[-1]['parse_mode'] = 'HTML'

try:
    response = requests.post(
        api_url,
        data={'chat_id': chat_id, 'media': json.dumps(media)},
        files=files,
        timeout=300,
    )
finally:
    for handle in files.values():
        handle.close()

try:
    payload = response.json()
except ValueError:
    payload = None

print('Response JSON:', payload if payload is not None else response.text)
if not response.ok or not (payload or {}).get('ok'):
    description = (payload or {}).get('description', response.text)
    print(f'Telegram rejected the release post: {description}', file=sys.stderr)
    sys.exit(1)

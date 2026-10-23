import argparse
import html
import json
import os
import re
import sys
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen


REPOSITORY = 'Hoxiee/ReClash'
TAG_PATTERN = re.compile(r'v\d+\.\d+\.\d+(?:-pre\.[1-9]\d*)?')


def download_rows():
    return [
        [('Android · ARM64', 'android-arm64-v8a.apk'),
         ('Android · ARMv7', 'android-armeabi-v7a.apk'),
         ('Android · x64', 'android-x86_64.apk')],
        [('Windows · x64', 'windows-amd64-setup.exe'),
         ('Windows · ARM64', 'windows-arm64-setup.exe')],
        [('Portable · x64', 'windows-amd64.zip'),
         ('Portable · ARM64', 'windows-arm64.zip')],
        [('macOS · Apple Silicon', 'macos-arm64.dmg'),
         ('macOS · Intel', 'macos-amd64.dmg')],
        [('Linux · AppImage x64', 'linux-amd64.AppImage')],
        [('DEB · x64', 'linux-amd64.deb'), ('DEB · ARM64', 'linux-arm64.deb')],
        [('RPM · x64', 'linux-amd64.rpm'), ('RPM · ARM64', 'linux-arm64.rpm')],
        [('Arch · x64', 'linux-amd64.pkg.tar.xz'),
         ('Arch · ARM64', 'linux-arm64.pkg.tar.xz')],
    ]


def visible_length(markup):
    plain = html.unescape(re.sub(r'<[^>]*>', '', markup))
    return len(plain.encode('utf-16-le')) // 2


def build_post(tag, notes, dist, chat_id):
    if not TAG_PATTERN.fullmatch(tag):
        raise ValueError('Expected a release tag such as v0.1.0-pre.1')
    version = tag[1:]
    release_url = f'https://github.com/{REPOSITORY}/releases/tag/{tag}'
    download_url = f'https://github.com/{REPOSITORY}/releases/download/{tag}'
    keyboard = []
    for row in download_rows():
        buttons = []
        for label, suffix in row:
            name = f'ReClash-{version}-{suffix}'
            file = dist / name
            if not file.is_file() or file.stat().st_size == 0:
                raise ValueError(f'Missing or empty release asset: {name}')
            buttons.append({'text': label, 'url': f'{download_url}/{quote(name)}'})
        keyboard.append(buttons)
    checksums = dist / 'SHA256SUMS'
    if not checksums.is_file() or checksums.stat().st_size == 0:
        raise ValueError('Missing or empty release asset: SHA256SUMS')
    keyboard.append([
        {'text': '📋 Full changelog', 'url': release_url},
        {'text': '🔐 SHA256', 'url': f'{download_url}/SHA256SUMS'},
    ])

    prerelease = '-pre.' in version
    status = '🧪 Pre-release' if prerelease else '✨ Stable release'
    heading = f'<b>ReClash {html.escape(version)}</b>\n{status}'
    if prerelease:
        heading += '\nTesting build — may contain bugs.'
    kept = []
    bullets = 0
    pending_heading = None
    for line in notes.strip().splitlines():
        if line.startswith('<b>') and line.endswith('</b>'):
            pending_heading = line
            continue
        if not line.strip():
            continue
        if line.startswith('…') or bullets >= 6:
            kept.append('… See the full changelog below.')
            break
        candidate = [*kept]
        if pending_heading:
            candidate.extend(['', pending_heading])
        candidate.append(line)
        if visible_length('\n'.join(candidate)) > 2800:
            kept.append('… See the full changelog below.')
            break
        kept = candidate
        pending_heading = None
        if line.startswith('• '):
            bullets += 1
    body = '\n'.join(kept).strip() or 'Maintenance and stability improvements.'
    text = f'{heading}\n\n{body}\n\n<b>Download for your platform ↓</b>'
    if visible_length(text) > 4096:
        raise ValueError('Telegram post exceeds the message limit')
    return {
        'chat_id': chat_id,
        'text': text,
        'parse_mode': 'HTML',
        'link_preview_options': {'is_disabled': True},
        'reply_markup': {'inline_keyboard': keyboard},
    }


def send_post(token, post):
    request = Request(
        f'https://api.telegram.org/bot{token}/sendMessage',
        data=json.dumps(post).encode('utf-8'),
        headers={'Content-Type': 'application/json'},
        method='POST',
    )
    try:
        with urlopen(request, timeout=60) as response:
            payload = json.load(response)
    except HTTPError as error:
        raise ValueError(f'Telegram rejected the post (HTTP {error.code})') from None
    except URLError:
        raise ValueError('Could not connect to Telegram') from None
    if not payload.get('ok'):
        raise ValueError('Telegram rejected the release post')
    return payload['result']['message_id']


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--tag', default=os.getenv('TAG', ''))
    parser.add_argument('--notes', type=Path, default=Path('telegram.md'))
    parser.add_argument('--dist', type=Path, default=Path('dist'))
    args = parser.parse_args()
    try:
        post = build_post(
            args.tag,
            args.notes.read_text(encoding='utf-8'),
            args.dist,
            os.getenv('TELEGRAM_CHAT_ID', '@ReClashApp'),
        )
        if args.dry_run:
            print(json.dumps(post, ensure_ascii=False, indent=2))
            return 0
        token = os.getenv('TELEGRAM_BOT_TOKEN')
        if not token:
            raise ValueError('TELEGRAM_BOT_TOKEN is required')
        message_id = send_post(token, post)
        print(f'Telegram release post published: message {message_id}')
        return 0
    except (ValueError, OSError, KeyError) as error:
        print(f'Telegram publishing failed: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())

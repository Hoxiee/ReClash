import argparse
import html
import json
import os
import re
import sys
import uuid
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


REPOSITORY = 'Hoxiee/ReClash'
TAG_PATTERN = re.compile(r'v\d+\.\d+\.\d+(?:-pre\.[1-9]\d*)?')


CAPTION_LIMIT = 1024
ISSUES_URL = f'https://github.com/{REPOSITORY}/issues/new/choose'
DOWNLOAD_PAGE_URL = 'https://reclash.pages.dev/en/download'
ASSET_SUFFIXES = [
    'android-arm64-v8a.apk',
    'windows-amd64-setup.exe',
    'windows-amd64.zip',
    'macos-arm64.dmg',
    'macos-amd64.dmg',
    'linux-amd64.AppImage',
]


def visible_length(markup):
    plain = html.unescape(re.sub(r'<[^>]*>', '', markup))
    return len(plain.encode('utf-16-le')) // 2


def build_post(tag, notes, dist, card, chat_id):
    if not TAG_PATTERN.fullmatch(tag):
        raise ValueError('Expected a release tag such as v0.1.0-pre.1')
    version = tag[1:]
    release_url = f'https://github.com/{REPOSITORY}/releases/tag/{tag}'
    download_url = f'https://github.com/{REPOSITORY}/releases/download/{tag}'
    for suffix in ASSET_SUFFIXES:
        name = f'ReClash-{version}-{suffix}'
        file = dist / name
        if not file.is_file() or file.stat().st_size == 0:
            raise ValueError(f'Missing or empty release asset: {name}')
    checksums = dist / 'SHA256SUMS'
    if not checksums.is_file() or checksums.stat().st_size == 0:
        raise ValueError('Missing or empty release asset: SHA256SUMS')
    if not card.is_file() or card.stat().st_size == 0:
        raise ValueError(f'Missing or empty release card: {card}')

    prerelease = '-pre.' in version
    if prerelease:
        action = {'text': 'Report a bug', 'url': ISSUES_URL, 'style': 'danger'}
    else:
        action = {'text': 'Download', 'url': DOWNLOAD_PAGE_URL, 'style': 'success'}
    keyboard = [[{'text': 'All files', 'url': release_url}, action]]
    status = '🧪 Pre-release' if prerelease else '✨ Stable release'
    heading = f'<b>ReClash</b> <code>{html.escape(version)}</code>'
    if prerelease:
        heading += f'\n\n<blockquote><b>{status}</b>\nTesting build — may contain bugs.</blockquote>'
    else:
        heading += f'\n<i>{status}</i>'
    body = notes.strip() or 'Maintenance and stability improvements.'
    repository_url = f'https://github.com/{REPOSITORY}'
    links = ' · '.join([
        f'<a href="{release_url}">Release</a>',
        f'<a href="{repository_url}/blob/{tag}/CHANGELOG.md">Changelog</a>',
        f'<a href="{repository_url}">GitHub</a>',
        f'<a href="{download_url}/SHA256SUMS">SHA256</a>',
    ])
    caption = f'{heading}\n\n{body}\n\n{links}'
    if visible_length(caption) > CAPTION_LIMIT:
        raise ValueError('Telegram post exceeds the photo caption limit')
    return {
        'chat_id': chat_id,
        'photo': str(card),
        'caption': caption,
        'parse_mode': 'HTML',
        'reply_markup': {'inline_keyboard': keyboard},
    }


def encode_multipart(post):
    boundary = uuid.uuid4().hex
    parts = []
    for name, value in post.items():
        if name == 'photo':
            continue
        if not isinstance(value, str):
            value = json.dumps(value)
        parts.append(
            f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n'.encode('utf-8')
        )
    parts.append(
        f'--{boundary}\r\nContent-Disposition: form-data; name="photo"; filename="card.png"\r\n'
        'Content-Type: image/png\r\n\r\n'.encode('utf-8')
    )
    parts.append(Path(post['photo']).read_bytes())
    parts.append(f'\r\n--{boundary}--\r\n'.encode('utf-8'))
    return boundary, b''.join(parts)


def send_post(token, post):
    boundary, data = encode_multipart(post)
    request = Request(
        f'https://api.telegram.org/bot{token}/sendPhoto',
        data=data,
        headers={'Content-Type': f'multipart/form-data; boundary={boundary}'},
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
    parser.add_argument('--card', type=Path, default=Path('card.png'))
    args = parser.parse_args()
    try:
        post = build_post(
            args.tag,
            args.notes.read_text(encoding='utf-8'),
            args.dist,
            args.card,
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

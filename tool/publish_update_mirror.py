import json
import os
import re
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory


CATALOG = 'update-manifest.json'
CATALOG_LIMIT = 1024 * 1024
HISTORY_SIZE = 30
INSTALLER_SUFFIXES = ('.apk', '.AppImage', '.dmg', '-setup.exe')
MISSING_KEY = '(NoSuchKey)'
WRITE_CONFLICT = '(PreconditionFailed)'


def version(release):
    tag = release['tag']
    match = re.fullmatch(r'v(\d+)\.(\d+)\.(\d+)(?:-pre\.([1-9]\d*))?', tag)
    if match is None or release['prerelease'] != (match[4] is not None):
        raise ValueError(f'Unexpected release tag or channel: {tag}')
    major, minor, patch, pre = match.groups()
    return (int(major), int(minor), int(patch), pre is None, int(pre or 0))


def encode_catalog(releases):
    return json.dumps({'releases': releases}, ensure_ascii=False, separators=(',', ':')).encode()


def catalog_with(current, incoming):
    by_tag = {release['tag']: release for release in [*current, incoming]}
    releases = sorted(by_tag.values(), key=version, reverse=True)
    latest_stable = next((release for release in releases if not release['prerelease']), None)
    latest_pre = next((release for release in releases if release['prerelease']), None)
    latest = [release for release in releases if release in (latest_stable, latest_pre)]
    encoded = encode_catalog(latest)
    if len(encoded) > CATALOG_LIMIT:
        raise ValueError('Latest releases exceed the app catalog limit')
    for release in releases:
        if len(latest) == HISTORY_SIZE:
            break
        if release is latest_stable or release is latest_pre:
            continue
        entries = sorted([*latest, release], key=version, reverse=True)
        candidate = encode_catalog(entries)
        if len(candidate) > CATALOG_LIMIT:
            break
        latest = entries
        encoded = candidate
    return encoded


def s3(operation, key, *args, allowed_error=None):
    result = subprocess.run(
        [
            'aws', 's3api', operation, '--output', 'json',
            '--endpoint-url', os.environ['UPDATE_R2_ENDPOINT'],
            '--bucket', os.environ['UPDATE_R2_BUCKET'], '--key', key, *args,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode == 0:
        return json.loads(result.stdout or '{}')
    if allowed_error is not None and allowed_error in result.stderr:
        return None
    raise RuntimeError(f'{operation} {key}: {result.stderr.strip()}')


def publish(dist):
    release, = json.loads((dist / CATALOG).read_text(encoding='utf-8'))['releases']
    version(release)
    if published_at := os.environ.get('UPDATE_PUBLISHED_AT'):
        release['published_at'] = published_at
    for asset in release['assets']:
        name = asset['name']
        if not name.endswith(INSTALLER_SUFFIXES):
            continue
        digest = asset['sha256']
        if not re.fullmatch(r'[A-Za-z0-9._+-]+', name) or not re.fullmatch(r'[0-9a-f]{64}', digest):
            raise ValueError(f'Invalid update asset: {name}')
        key = f"releases/{release['tag']}/{digest}/{name}"
        s3(
            'put-object', key, '--body', str(dist / name),
            '--cache-control', 'public, max-age=31536000, immutable',
            '--content-type', 'application/octet-stream', '--if-none-match', '*',
            allowed_error=WRITE_CONFLICT,
        )

    with TemporaryDirectory(prefix='reclash-update-catalog-') as directory:
        path = Path(directory) / CATALOG
        for _ in range(6):
            response = s3('get-object', CATALOG, str(path), allowed_error=MISSING_KEY)
            current = [] if response is None else json.loads(path.read_bytes())['releases']
            condition = ('--if-none-match', '*') if response is None else ('--if-match', response['ETag'])
            catalog = catalog_with(current, release)
            if response is not None and path.read_bytes() == catalog:
                return
            path.write_bytes(catalog)
            result = s3(
                'put-object', CATALOG, '--body', str(path),
                '--cache-control', 'public, max-age=60', '--content-type', 'application/json',
                *condition, allowed_error=WRITE_CONFLICT,
            )
            if result is not None:
                print(f"Published update catalog for {release['tag']}")
                return
    raise RuntimeError('Update catalog changed during every publication attempt')


if __name__ == '__main__':
    try:
        publish(Path(sys.argv[1]))
    except (KeyError, OSError, RuntimeError, ValueError) as error:
        sys.exit(str(error))

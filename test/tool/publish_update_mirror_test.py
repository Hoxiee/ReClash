import json
import runpy
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


tool = runpy.run_path(str(Path(__file__).resolve().parents[2] / 'tool/publish_update_mirror.py'))
publish = tool['publish']
catalog_with = tool['catalog_with']


def release(tag, assets=()):
    return {'tag': tag, 'prerelease': '-pre.' in tag, 'assets': list(assets)}


class PublishUpdateMirrorTest(unittest.TestCase):
    def test_retains_latest_stable_and_newest_prereleases(self):
        stable = release('v1.0.0')
        history = [stable, *(release(f'v1.1.0-pre.{i}') for i in range(1, 35))]
        newest = release('v1.1.0-pre.35')

        result = json.loads(catalog_with(history, newest))['releases']

        self.assertEqual(len(result), 30)
        self.assertEqual(result[0], newest)
        self.assertEqual(result[-1], stable)
        self.assertNotIn(release('v1.1.0-pre.1'), result)

    def test_reloads_catalog_after_conflict_and_publishes_after_installer(self):
        stable = release('v1.0.0')
        newer = release('v1.1.0-pre.10')
        digest = 'a' * 64
        incoming = release('v1.1.0-pre.9', [{'name': 'app.apk', 'sha256': digest}])
        catalogs_read = iter([('"old"', [stable]), ('"new"', [newer, stable])])
        operations = []
        writes = []

        def storage(operation, key, *args, allowed_error=None):
            operations.append((operation, key))
            if operation == 'get-object':
                etag, history = next(catalogs_read)
                Path(args[0]).write_text(json.dumps({'releases': history}), encoding='utf-8')
                return {'ETag': etag}
            if key != 'update-manifest.json':
                return {}
            self.assertEqual(allowed_error, '(PreconditionFailed)')
            writes.append((args[-2:], json.loads(Path(args[1]).read_bytes())['releases']))
            return {} if len(writes) > 1 else None

        with tempfile.TemporaryDirectory() as temporary:
            dist = Path(temporary)
            (dist / 'update-manifest.json').write_text(json.dumps({'releases': [incoming]}), encoding='utf-8')
            with patch.dict(publish.__globals__, {'s3': storage}):
                publish(dist)

        self.assertEqual(operations[0], ('put-object', f'releases/v1.1.0-pre.9/{digest}/app.apk'))
        self.assertEqual(writes[0][0], ('--if-match', '"old"'))
        self.assertEqual(writes[1], (('--if-match', '"new"'), [newer, incoming, stable]))


if __name__ == '__main__':
    unittest.main()

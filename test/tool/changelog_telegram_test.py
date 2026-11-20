import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('release_telegram', ROOT / 'release_telegram.py')
telegram = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(telegram)


class TelegramReleaseTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.dist = Path(self.temp.name)
        self.tag = 'v0.1.0-pre.1'
        for suffix in telegram.ASSET_SUFFIXES:
            (self.dist / f'ReClash-{self.tag[1:]}-{suffix}').write_text('package')
        (self.dist / 'SHA256SUMS').write_text('checksums')
        self.card = self.dist / 'card.png'
        self.card.write_bytes(b'\x89PNG card')

    def use_stable(self):
        for file in self.dist.glob('ReClash-*'):
            file.rename(file.with_name(file.name.replace('-pre.1', '')))
        self.tag = 'v0.1.0'

    def post(self, notes='<b>Features</b>\n• Faster imports'):
        return telegram.build_post(self.tag, notes, self.dist, self.card, '@test')

    def test_prerelease_has_one_row_with_all_files_and_a_bug_report_button(self):
        post = self.post()
        row = post['reply_markup']['inline_keyboard']
        self.assertEqual(len(row), 1)
        files, action = row[0]
        self.assertEqual(files['text'], 'All files')
        self.assertIn('/releases/tag/', files['url'])
        self.assertEqual(action['text'], 'Report a bug')
        self.assertEqual(action['style'], 'danger')
        self.assertIn('/issues/new/choose', action['url'])
        for label in ['Release', 'Changelog', 'GitHub', 'SHA256']:
            self.assertIn(f'>{label}</a>', post['caption'])
        self.assertIn('Pre-release', post['caption'])
        self.assertEqual(post['photo'], str(self.card))

    def test_stable_has_a_download_button(self):
        self.use_stable()
        action = self.post()['reply_markup']['inline_keyboard'][0][1]
        self.assertEqual(action['text'], 'Download')
        self.assertEqual(action['style'], 'success')
        self.assertEqual(action['url'], 'https://reclash.pages.dev/en/download')

    def test_prerelease_warning_is_a_quote_and_version_is_monospace(self):
        text = self.post()['caption']
        self.assertIn('<b>ReClash</b> <code>0.1.0-pre.1</code>', text)
        self.assertIn(
            '<blockquote><b>🧪 Pre-release</b>\nTesting build — may contain bugs.</blockquote>',
            text,
        )

    def test_stable_has_no_testing_warning(self):
        self.use_stable()
        post = self.post()
        self.assertIn('Stable release', post['caption'])
        self.assertNotIn('Testing build', post['caption'])
        self.assertNotIn('<blockquote>', post['caption'])

    def test_missing_and_empty_assets_fail_before_sending(self):
        file = next(self.dist.glob('*.apk'))
        file.write_bytes(b'')
        with self.assertRaises(ValueError):
            self.post()
        file.unlink()
        with self.assertRaises(ValueError):
            self.post()

    def test_card_is_required(self):
        self.card.unlink()
        with self.assertRaises(ValueError):
            self.post()

    def test_checksums_are_required(self):
        (self.dist / 'SHA256SUMS').unlink()
        with self.assertRaises(ValueError):
            self.post()

    def test_invalid_tags_cannot_create_urls(self):
        for tag in ['', 'main', 'v0.1.0/../../', 'v0.1.0-pre.0']:
            with self.subTest(tag=tag), self.assertRaises(ValueError):
                telegram.build_post(tag, '', self.dist, self.card, '@test')

    def test_long_notes_fail_without_silently_dropping_warnings(self):
        with self.assertRaises(ValueError):
            self.post('😀' * 520)

    def test_authored_overview_preserves_markup_and_warnings(self):
        notes = '<b>A new release line</b>\nAuto-routing &amp; profiles\n⚠️ Reinstall older builds.'
        self.assertIn(notes, self.post(notes)['caption'])

    def test_import_and_post_rendering_do_not_send_requests(self):
        with patch.object(telegram, 'urlopen') as request:
            self.post()
            request.assert_not_called()

    def test_send_uploads_the_card_as_multipart_photo(self):
        with patch.object(telegram, 'urlopen') as request:
            request.return_value.__enter__.return_value.read.return_value = b'{"ok": true, "result": {"message_id": 42}}'
            self.assertEqual(telegram.send_post('test-token', self.post()), 42)
            sent = request.call_args.args[0]
            self.assertEqual(sent.full_url, 'https://api.telegram.org/bottest-token/sendPhoto')
            content_type = sent.get_header('Content-type')
            self.assertTrue(content_type.startswith('multipart/form-data; boundary='))
            self.assertIn(b'name="photo"; filename="card.png"', sent.data)
            self.assertIn(b'\x89PNG card', sent.data)
            self.assertIn(b'name="reply_markup"', sent.data)
            self.assertIn(b'name="caption"', sent.data)

    def test_api_rejection_fails(self):
        with patch.object(telegram, 'urlopen') as request:
            request.return_value.__enter__.return_value.read.return_value = b'{"ok": false}'
            with self.assertRaises(ValueError):
                telegram.send_post('test-token', self.post())


if __name__ == '__main__':
    unittest.main()

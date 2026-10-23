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
        for row in telegram.download_rows():
            for _, suffix in row:
                (self.dist / f'ReClash-{self.tag[1:]}-{suffix}').write_text('package')
        (self.dist / 'SHA256SUMS').write_text('checksums')

    def post(self, notes='<b>Features</b>\n• Faster imports'):
        return telegram.build_post(self.tag, notes, self.dist, '@test')

    def test_all_assets_have_direct_versioned_download_buttons(self):
        post = self.post()
        buttons = [button for row in post['reply_markup']['inline_keyboard'] for button in row]
        downloads = [button for button in buttons if '/download/' in button['url']]
        self.assertEqual(len(downloads), 17)
        for button in downloads:
            name = button['url'].rsplit('/', 1)[1]
            self.assertTrue((self.dist / name).is_file())
            self.assertIn(f'/download/{self.tag}/', button['url'])
        self.assertIn('Pre-release', post['text'])
        self.assertTrue(post['link_preview_options']['is_disabled'])

    def test_stable_has_no_testing_warning(self):
        for file in self.dist.glob('ReClash-*'):
            file.rename(file.with_name(file.name.replace('-pre.1', '')))
        self.tag = 'v0.1.0'
        post = self.post()
        self.assertIn('Stable release', post['text'])
        self.assertNotIn('Testing build', post['text'])

    def test_missing_and_empty_assets_fail_before_sending(self):
        file = next(self.dist.glob('*.apk'))
        file.write_bytes(b'')
        with self.assertRaises(ValueError):
            self.post()
        file.unlink()
        with self.assertRaises(ValueError):
            self.post()

    def test_checksums_are_required(self):
        (self.dist / 'SHA256SUMS').unlink()
        with self.assertRaises(ValueError):
            self.post()

    def test_invalid_tags_cannot_create_urls(self):
        for tag in ['', 'main', 'v0.1.0/../../', 'v0.1.0-pre.0']:
            with self.subTest(tag=tag), self.assertRaises(ValueError):
                telegram.build_post(tag, '', self.dist, '@test')

    def test_long_notes_keep_whole_html_lines_within_message_limit(self):
        post = self.post('\n'.join(['<b>Changes</b>', *['• ' + '😀' * 150] * 40]))
        self.assertLessEqual(telegram.visible_length(post['text']), 4096)
        self.assertIn('full changelog below', post['text'])

    def test_preview_limits_bullets_without_dangling_section_headings(self):
        notes = '<b>Features</b>\n' + '\n'.join(f'• Change {i}' for i in range(6))
        notes += '\n<b>Fixes</b>\n• Another fix'
        text = self.post(notes)['text']
        self.assertEqual(text.count('• '), 6)
        self.assertNotIn('<b>Fixes</b>', text)
        self.assertIn('full changelog below', text)

    def test_import_and_post_rendering_do_not_send_requests(self):
        with patch.object(telegram, 'urlopen') as request:
            self.post()
            request.assert_not_called()

    def test_send_uses_public_api_without_file_uploads(self):
        with patch.object(telegram, 'urlopen') as request:
            request.return_value.__enter__.return_value.read.return_value = b'{"ok": true, "result": {"message_id": 42}}'
            self.assertEqual(telegram.send_post('test-token', self.post()), 42)
            sent = request.call_args.args[0]
            self.assertEqual(sent.full_url, 'https://api.telegram.org/bottest-token/sendMessage')
            self.assertIn('reply_markup', json.loads(sent.data))

    def test_api_rejection_fails(self):
        with patch.object(telegram, 'urlopen') as request:
            request.return_value.__enter__.return_value.read.return_value = b'{"ok": false}'
            with self.assertRaises(ValueError):
                telegram.send_post('test-token', self.post())


if __name__ == '__main__':
    unittest.main()

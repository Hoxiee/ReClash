import 'package:reclash/common/update_summary.dart';
import 'package:test/test.dart';

import '../../tool/src/changelog/git.dart';
import '../../tool/src/changelog/notes.dart';
import '../../tool/src/changelog/render.dart';

const validNotes = '''
A short lead paragraph.

### New

- **Forecast**: estimates when the quota runs out, based on recent
  daily usage.

### Fixed

- Reject malformed links.
''';

ReleaseNotes notes(String tag, [String body = validNotes]) =>
    ReleaseNotes(tag: VersionTag.tryParse(tag)!, body: body.trim());

ReleaseSummary summary({
  String tag = 'v0.8.96',
  List<ReleaseHighlight> highlights = const [],
  List<ReleaseHighlight> warnings = const [],
  String headline = 'An authored release',
}) => ReleaseSummary(
  tag: tag,
  locales: {
    'en': ReleaseSummaryLocale(
      headline: headline,
      spotlight: const ReleaseHighlight(
        title: 'Spotlight',
        description: 'Spotlight text.',
      ),
      highlights: highlights,
      warnings: warnings,
    ),
  },
);

void main() {
  group('validateReleaseNotes', () {
    test('accepts a lead paragraph and ordered sections', () {
      expect(validateReleaseNotes(validNotes), isEmpty);
    });

    final invalid = <String, String>{
      'empty notes': '  \n',
      'a level two heading': '## New\n\n- One\n',
      'an unknown section': '### Other\n\n- One\n',
      'sections out of order': '### Fixed\n\n- One\n\n### New\n\n- Two\n',
      'a repeated section': '### New\n\n- One\n\n### New\n\n- Two\n',
      'a section without bullets': '### New\n\n### Fixed\n\n- One\n',
      'a bullet before any heading': '- One\n\n### New\n\n- Two\n',
      'prose inside a section': '### New\n\n- One\nplain prose\n',
      'a comment opener': '### New\n\n- One <!-- hidden\n',
      'a comment closer': '### New\n\n- One --> hidden\n',
      'a commit hash': '### New\n\n- One (abc1234)\n',
      'no section at all': 'Only a lead paragraph.\n',
    };
    for (final MapEntry(:key, :value) in invalid.entries) {
      test('rejects $key', () {
        expect(validateReleaseNotes(value), isNotEmpty);
      });
    }
  });

  group('renderRelease', () {
    test('wraps the notes between the release markers', () {
      final body = renderRelease(notes('v0.8.96', '### Fixed\n\n- One.'));

      expect(body, startsWith('$releaseBeginMarker\n### Fixed\n\n- One.\n\n'));
      expect(body, contains('$releaseEndMarker\n'));
    });

    test('joins continuation lines into their bullet', () {
      final body = renderRelease(notes('v0.8.96'));

      expect(
        body,
        contains(
          '- **Forecast**: estimates when the quota runs out, based on recent '
          'daily usage.\n',
        ),
      );
      expect(body, isNot(contains('\n  daily')));
    });

    test('appends a summary the app can parse back', () {
      final authored = summary(
        highlights: const [
          ReleaseHighlight(title: 'Faster', description: 'Sync is quicker.'),
        ],
      );
      final body = renderRelease(notes('v0.8.96'), summary: authored);

      final parsed = parseReleaseSummary(body, tag: 'v0.8.96');
      expect(parsed?.locales['en']?.headline, 'An authored release');
      expect(parsed?.locales['en']?.highlights.single.title, 'Faster');
      expect(body, isNot(contains('reclash:changelog:json')));
    });

    test('refuses a summary authored for another tag', () {
      expect(
        () => renderRelease(notes('v0.8.97'), summary: summary()),
        throwsFormatException,
      );
    });
  });

  group('renderTelegram', () {
    test('formats the headline, spotlight, highlights and warnings', () {
      final text = renderTelegram(
        summary(
          highlights: const [
            ReleaseHighlight(title: 'New navigation', description: 'Moves.'),
          ],
          warnings: const [
            ReleaseHighlight(
              title: 'Reinstall',
              description: 'Do not update old builds.',
            ),
          ],
        ),
      );

      expect(text, startsWith('<b>An authored release</b>\n'));
      expect(text, contains('<b>Spotlight</b>\nSpotlight text.'));
      expect(text, contains('• New navigation'));
      expect(
        text,
        contains(
          '<blockquote>⚠️ <b>Reinstall</b>\n'
          'Do not update old builds.</blockquote>',
        ),
      );
    });

    test('escapes ampersands and angle brackets', () {
      final text = renderTelegram(summary(headline: 'Fix <script> & more'));

      expect(text, contains('<b>Fix &lt;script&gt; &amp; more</b>'));
    });

    test('refuses text longer than the caption limit', () {
      final long = summary(
        highlights: [
          for (var index = 0; index < 40; index++)
            ReleaseHighlight(title: 'Highlight ${'x' * 100}', description: ''),
        ],
      );

      expect(() => renderTelegram(long), throwsFormatException);
    });
  });

  group('renderChangelog', () {
    test('lists the newest tag first, one section per tag', () {
      final markdown = renderChangelog([
        notes('v1.1.0'),
        notes('v1.0.0', '### Fixed\n\n- Old fix.'),
      ]);

      expect(markdown, startsWith('# Changelog\n'));
      expect(markdown, contains('<!-- Generated from release_notes/'));
      expect(
        markdown.indexOf('## v1.1.0'),
        lessThan(markdown.indexOf('## v1.0.0')),
      );
      expect(markdown, contains('## v1.0.0\n\n### Fixed\n\n- Old fix.\n'));
      expect(markdown, contains('based on recent\n  daily usage.'));
    });

    test('drops prereleases once the stable notes exist', () {
      final markdown = renderChangelog([
        notes('v1.1.0'),
        notes('v1.1.0-pre.2'),
        notes('v1.1.0-pre.1'),
      ]);

      expect(markdown, contains('## v1.1.0\n'));
      expect(markdown, isNot(contains('-pre.')));
    });

    test('keeps prereleases of an unreleased version', () {
      final markdown = renderChangelog([
        notes('v1.2.0-pre.1'),
        notes('v1.1.0'),
        notes('v1.1.0-pre.1'),
      ]);

      expect(markdown, contains('## v1.2.0-pre.1'));
      expect(markdown, isNot(contains('## v1.1.0-pre.1')));
    });
  });
}

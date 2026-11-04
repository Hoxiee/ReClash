import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';

String _body(String notes) =>
    '$releaseNotesBeginMarker\n$notes\n$releaseNotesEndMarker\n'
    '\n<!-- reclash:update:json\n{}\n-->\n| Platform | Download |\n';

void main() {
  group('parseReleaseNotes', () {
    test('reads the lead and the sections in their fixed order', () {
      final notes = parseReleaseNotes(
        _body(
          'The release is about speed.\n\n'
          '### Fixed\n\n- Web dashboards no longer close.\n\n'
          '### Breaking changes\n\n- Re-import backups.\n\n'
          '### New\n\n- **Speed test**: measure routes.\n',
        ),
      );

      expect(notes?.lead, 'The release is about speed.');
      expect(notes?.groups.map((group) => group.section), [
        ReleaseNotesSection.breaking,
        ReleaseNotesSection.added,
        ReleaseNotesSection.fixed,
      ]);
      expect(notes?.breaking, ['Re-import backups.']);
      expect(notes?.hasBreaking, isTrue);
      expect(notes?.entryCount, 3);
    });

    test('joins wrapped lines into one entry and one lead', () {
      final notes = parseReleaseNotes(
        _body(
          'First half\nsecond half.\n\n'
          '### Improved\n\n'
          '- **Setup**: walks through profile,\n'
          '  coverage and region.\n',
        ),
      );

      expect(notes?.lead, 'First half second half.');
      expect(notes?.groups.single.entries, [
        '**Setup**: walks through profile, coverage and region.',
      ]);
    });

    test('keeps a lead without sections', () {
      final notes = parseReleaseNotes(_body('Maintenance release.'));

      expect(notes?.lead, 'Maintenance release.');
      expect(notes?.groups, isEmpty);
      expect(notes?.hasBreaking, isFalse);
    });

    test('ignores empty sections', () {
      final notes = parseReleaseNotes(
        _body('### New\n\n### Known issues\n\n- Tray icon flickers on KDE.\n'),
      );

      expect(notes?.groups.single.section, ReleaseNotesSection.known);
    });

    test('returns null for a body without the markers', () {
      expect(parseReleaseNotes('### New\n\n- Override scripts\n'), isNull);
      expect(parseReleaseNotes(null), isNull);
    });

    test('returns null for loose bullets and unknown headings', () {
      expect(parseReleaseNotes(_body('- Override scripts')), isNull);
      expect(parseReleaseNotes(_body('### Features\n\n- Scripts')), isNull);
    });
  });
}

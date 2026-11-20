import 'package:reclash/common/update_summary.dart';
import 'package:test/test.dart';

import '../../tool/src/changelog/card.dart';

ReleaseSummary summary({
  String tag = 'v0.1.0-pre.11',
  String headline = 'Fix <script> & more',
  List<String> highlights = const ['Faster imports'],
}) => ReleaseSummary(
  tag: tag,
  locales: {
    'en': ReleaseSummaryLocale(
      headline: headline,
      spotlight: const ReleaseHighlight(
        title: 'Site lock',
        description: 'Pin sites to the exits you choose.',
      ),
      highlights: [
        for (final title in highlights)
          ReleaseHighlight(title: title, description: ''),
      ],
    ),
  },
);

void main() {
  group('renderReleaseCard', () {
    test('escapes the headline and shows the version without the v', () {
      final svg = renderReleaseCard(summary());

      expect(svg, startsWith('<svg '));
      expect(svg, contains('Fix &lt;script&gt; &amp; more'));
      expect(svg, contains('>0.1.0-pre.11</text>'));
      expect(svg, contains('SITE LOCK'));
      expect(svg, contains('Faster imports'));
    });

    test('labels the channel from the tag', () {
      expect(renderReleaseCard(summary()), contains('PRE-RELEASE'));

      final stable = renderReleaseCard(summary(tag: 'v0.1.0'));
      expect(stable, contains('STABLE'));
      expect(stable, isNot(contains('PRE-RELEASE')));
    });

    test('folds highlights that do not fit into a counter chip', () {
      final svg = renderReleaseCard(
        summary(
          highlights: [for (var i = 0; i < 12; i++) 'Highlight number $i'],
        ),
      );

      expect(svg, matches(RegExp(r'>\+\d+</text>')));
    });

    test('refuses a headline that needs more than three lines', () {
      final headline = List.filled(40, 'extraordinarily').join(' ');

      expect(
        () => renderReleaseCard(summary(headline: headline)),
        throwsFormatException,
      );
    });
  });
}

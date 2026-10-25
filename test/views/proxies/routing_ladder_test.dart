import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/views/proxies/routing_ladder.dart';

void main() {
  late AppLocalizations l;

  setUpAll(() async {
    l = await AppLocalizations.load(const Locale('en'));
  });

  group('RcxStepQuery', () {
    test('reads ⚡ and * in a name as literal text', () {
      final bolt = RcxStepQuery.parse('country = RU and name ~ /⚡/');
      expect(bolt.name, '⚡');
      expect(bolt.countries, ['RU']);
      expect(bolt.other, isEmpty);
      expect(rcxConditionSummary(l, 'name ~ /⚡/'), l.rcxLadderNameHas('⚡'));

      final star = RcxStepQuery.parse(r'name ~ /\*/');
      expect(star.name, '*');
      expect(star.when, r'name ~ /\*/i');
      expect(RcxStepQuery.parse(star.when).name, '*');
    });

    test('unescapes literals and keeps real patterns as written', () {
      expect(RcxStepQuery.parse(r'name ~ /a\.b\+/i').name, 'a.b+');
      expect(RcxStepQuery.parse('name ~ /a.b/i').other, ['name ~ /a.b/i']);
      expect(RcxStepQuery.parse('name ~ /Fast/').other, ['name ~ /Fast/']);
    });
  });
}

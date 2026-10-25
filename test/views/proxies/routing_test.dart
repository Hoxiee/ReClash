import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/proxies/routing.dart';
import 'package:flutter_test/flutter_test.dart';

// Captured from the Go engine after a "Change server"; regenerate it when the
// wire shapes in core/rcx change.
const _engineJson = r'''
{"explain":{"group":"G","profile":"builtin/simple","decision":{"action":"hold","target":"b","reason":{"code":"hold.best"},"tier":"Working","ranking":[{"name":"b","tier":0,"tierLabel":"Working","health":"unknown","score":1048576,"current":true},{"name":"a","tier":1,"health":"unknown","score":1048576,"excluded":{"code":"cooldown","args":{"until":"2026-10-22T12:15:00Z"}}}]},"freshnessSeconds":2700,"at":"2026-10-22T12:00:00Z"},"journal":[{"seq":1,"at":"2026-10-22T12:00:00Z","group":"G","kind":"change","from":"a","reason":{"code":"change.requested"}},{"seq":2,"at":"2026-10-22T12:00:00Z","group":"G","kind":"switch","from":"a","to":"b","reason":{"code":"switch.change-server","args":{"from":"a"}}}],"status":{"running":true,"mode":"normal","network":"default","groups":[{"name":"G","source":"provider","profile":"builtin/simple","profileTitle":"Simple","level":"simple","offered":["builtin/simple","builtin/fastest"],"binding":{"profiles":["builtin/simple","builtin/fastest"],"default":"builtin/simple"},"control":{"mode":"auto"},"now":"b","decision":{"action":"switch","target":"b","reason":{"code":"switch.change-server","args":{"from":"a"}},"tier":"Working"},"members":2,"candidates":1,"excluded":[{"name":"a","until":"2026-10-22T12:15:00Z"}],"switchesHour":1,"maxPerHour":2,"improve":false,"health":{"unknown":2},"current":{"name":"b","health":"unknown","since":"2026-10-22T12:00:00Z"}}],"energy":{"level":"balanced","day":"2026-10-22","requests":0,"bytes":0,"capBytes":20971520,"hourlyLimits":{"discover":12,"maintain":10,"recover":24}}}}
''';

void main() {
  setUpAll(() => AppLocalizations.load(const Locale('en')));

  final engine = jsonDecode(_engineJson) as Map<String, Object?>;

  test('engine status, explanation and journal decode', () {
    final status = RcxStatus.fromJson(
      engine['status']! as Map<String, Object?>,
    );
    final group = status.group('G')!;
    expect(group.now, 'b');
    expect(group.binding.defaultProfile, 'builtin/simple');
    expect(group.offered, ['builtin/simple', 'builtin/fastest']);
    expect(group.excluded.single.name, 'a');
    expect(group.current?.name, 'b');
    expect(status.energy.capBytes, greaterThan(0));

    final explanation = RcxExplanation.fromJson(
      engine['explain']! as Map<String, Object?>,
    );
    expect(explanation.decision.ranking.first.current, isTrue);
    expect(explanation.decision.ranking.last.excluded?.code, 'cooldown');

    final journal = [
      for (final entry in engine['journal']! as List)
        RcxJournalEntry.fromJson(entry as Map<String, Object?>),
    ];
    expect(
      rcxJournalText(AppLocalizations.current, journal.last),
      'a → b: Changed server; a is skipped for 15 minutes',
    );
  });

  test('the user layer encodes as the engine reads it', () {
    const layer = RcxUserLayer(
      groups: {
        'G': RcxBinding(
          profile: 'builtin/from-list',
          pool: RcxPool(include: 'name ~ /DE/i'),
          feel: 'calm',
        ),
      },
    );
    final json = jsonDecode(jsonEncode(layer)) as Map<String, Object?>;
    final group = (json['groups']! as Map)['G'] as Map;
    expect(group['profile'], 'builtin/from-list');
    expect(group['pool'], {'include': 'name ~ /DE/i'});
    expect(group.containsKey('default'), isFalse);
    expect(RcxUserLayer.safeFromJson('garbage'), const RcxUserLayer());
  });

  test('every reason code the engine emits has a sentence', () {
    final codes = <String>{};
    final pattern = RegExp(
      r'"((?:hold|switch|stranded|until|pool|profile|group|network|pin|auto|'
      r'manual|change|failure|select|store|split|route)\.[a-z-]+|cooldown|'
      r'dead|no-tier|pending|manual)"',
    );
    for (final file in [
      ...Directory('core/rcx').listSync(),
      File('core/rcx_routes.go'),
    ]) {
      // cond.go names condition fields such as network.kind, and studio.go
      // lint codes, which rcxIssueText words; neither are reasons.
      if (file is! File ||
          !file.path.endsWith('.go') ||
          file.path.endsWith('_test.go') ||
          file.path.endsWith('cond.go') ||
          file.path.endsWith('studio.go')) {
        continue;
      }
      for (final match in pattern.allMatches(file.readAsStringSync())) {
        codes.add(match.group(1)!);
      }
    }
    expect(codes, containsAll(['switch.failover', 'route.to-missing']));
    final l = AppLocalizations.current;
    for (final code in codes) {
      final text = rcxReasonText(l, RcxReason(code: code));
      expect(text, isNot(code), reason: '$code has no sentence');
      expect(text, isNotEmpty);
    }
  });

  test('advanced profiles report network, exit and checks', () {
    final group = RcxGroupStatus.fromJson({
      'name': 'G',
      'now': 'b',
      'directSplit': 'standby',
      'network': {
        'kind': 'whitelist',
        'kinds': ['portal', 'whitelist', 'open'],
      },
      'current': {'name': 'b', 'exit': 'DE'},
    });
    expect(group.network?.kind, 'whitelist');
    expect(group.current?.exit, 'DE');
    final row = RcxRanked.fromJson({
      'name': 'a',
      'exit': 'NL',
      'checks': {'open': 'fail'},
      'pending': 'Opens blocked',
      'excluded': {'code': 'pending'},
    });
    expect(row.checks['open'], 'fail');
    final l = AppLocalizations.current;
    expect(rcxCountryLabel('de'), '🇩🇪 DE');
    expect(rcxCountryLabel('Germany'), 'Germany');
    expect(rcxKindLabel(l, 'whitelist'), l.rcxKindWhitelist);
    expect(rcxKindLabel(l, 'office'), 'office');
    expect(
      rcxReasonText(
        l,
        const RcxReason(code: 'hold.paused', args: {'kind': 'portal'}),
      ),
      l.rcxReasonPaused(l.rcxKindPortal),
    );
  });

  test('the pool pattern round-trips and counts matches', () {
    final include = rcxIncludeOf('DE|NL/x')!;
    expect(include, r'name ~ /DE|NL\/x/i');
    expect(rcxPatternOf(include), 'DE|NL/x');
    expect(rcxIncludeOf(''), isNull);
    expect(rcxCountMatches('de', ['DE-1', 'de-2', 'NL']), 2);
    expect(rcxCountMatches('', ['a', 'b']), 2);
    expect(rcxCountMatches('(', ['a']), isNull);
  });

  test('flags in server names become pools, most common first', () {
    final chips = rcxFlagChips([
      '🇩🇪 Frankfurt 1',
      '🇳🇱 Amsterdam',
      '🇩🇪 Berlin',
      'Plain',
    ]);
    expect([for (final chip in chips) chip.label], ['🇩🇪', '🇳🇱']);
    expect(rcxPatternOf(chips.first.include), '🇩🇪');
    expect(rcxCountMatches(rcxPatternOf(chips.first.include), ['🇩🇪 a']), 1);
    expect(rcxFlagChips(['🇩🇪 a', '🇩🇪 b', 'c']), isEmpty);

    const binding = RcxBinding(
      chips: [RcxChip(label: 'Games', include: 'name ~ /game/i')],
    );
    final json = jsonDecode(jsonEncode(binding)) as Map<String, Object?>;
    expect(json['chips'], [
      {'label': 'Games', 'include': 'name ~ /game/i'},
    ]);
  });
}

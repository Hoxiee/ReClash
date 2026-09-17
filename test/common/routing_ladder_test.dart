import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _decide = 'core/rcx_decide.go';

const _rungOfField = {
  'verdict': RoutingRung.verdict,
  'misfit': RoutingRung.misfit,
  'evidence': RoutingRung.evidence,
  'latencyMs': RoutingRung.latency,
  'recurrence': RoutingRung.recurrence,
  'degraded': RoutingRung.degraded,
  'unproven': RoutingRung.unproven,
  'challenger': RoutingRung.incumbent,
  'order': RoutingRung.tiebreak,
};

List<RoutingRung> _goLadder(
  String source,
  String function, [
  Set<String> visited = const {},
]) {
  if (visited.contains(function)) {
    fail('Comparator delegation cycle at $function');
  }
  final match = RegExp(
    'func $function\\(a, b rcxKey\\) int \\{.*?\\n\\}',
    dotAll: true,
  ).firstMatch(source);
  expect(match, isNotNull, reason: '$function is gone from $_decide');
  final body = match!.group(0)!;
  final delegate = RegExp(r'return (rcxCompare\w*)\(a, b\);?').firstMatch(body);
  if (delegate != null) {
    final ignored = {
      for (final field in RegExp(r'a\.(\w+), b\.\1 = 0, 0').allMatches(body))
        _rungOfField[field.group(1)]!,
    };
    return _goLadder(source, delegate.group(1)!, {
      ...visited,
      function,
    }).where((rung) => !ignored.contains(rung)).toList();
  }
  final fields = RegExp(r'a\.(\w+) != b\.\1').allMatches(body);
  expect(fields, isNotEmpty, reason: '$function has no recognized comparisons');
  return [for (final field in fields) _rungOfField[field.group(1)]!];
}

const _base = RcxCandidateReport(
  node: 'base',
  verdict: 'viable',
  evidence: 'fresh',
  latencyMs: 249,
);

void main() {
  late String source;

  setUpAll(() => source = File(_decide).readAsStringSync());

  test('every ladder is the one the core compares by', () {
    const comparators = {
      'balanced': 'rcxCompare',
      'lowest-latency': 'rcxCompareLatency',
      'stable': 'rcxCompareStable',
      'saver': 'rcxCompareStable',
    };
    for (final entry in comparators.entries) {
      expect(routingLadder(entry.key), [
        RoutingRung.admission,
        ..._goLadder(source, entry.value),
      ], reason: entry.key);
    }
    expect(routingLadder(''), routingLadder('balanced'));
  });

  test('the core dispatches the same comparator this page reads', () {
    final dispatch = RegExp(
      r'func rcxCompareFor\(strategy string\).*?\n\}',
      dotAll: true,
    ).firstMatch(source);
    expect(dispatch, isNotNull, reason: 'rcxCompareFor is gone from $_decide');
    for (final name in ['rcxCompareLatency', 'rcxCompareStable']) {
      expect(dispatch!.group(0), contains(name));
    }
  });

  test('confirmed quality ranking can improve an active stable incumbent', () {
    final incumbent = _base.copyWith(current: true, evidence: 'live');
    final faster = _base.copyWith(latencyMs: 69, confirmed: true);
    for (final strategy in ['balanced', 'lowest-latency', 'stable', 'saver']) {
      final duel = routingDuel(
        faster,
        incumbent,
        terrain: 'normal',
        strategy: strategy,
      );
      expect(duel.rung, RoutingRung.latency);
      expect(duel.won, isTrue);
    }
  });

  test('ranking does not claim promotion before confirmation', () {
    final faster = _base.copyWith(latencyMs: 69);
    expect(faster.confirmed, isFalse);
    expect(
      routingDuel(faster, _base, terrain: 'normal', strategy: 'stable').rung,
      RoutingRung.latency,
    );
  });

  test('a gate outranks every comparison the core would have made', () {
    expect(
      RegExp(
        r'a\.Block == rcxBlockNone\) != \(b\.Block == rcxBlockNone',
      ).hasMatch(source),
      isTrue,
      reason: 'rcxRank no longer sorts blocked candidates last',
    );
    final blocked = _base.copyWith(verdict: 'preferred', block: 'cooling');
    final duel = routingDuel(
      blocked,
      _base,
      terrain: 'normal',
      strategy: 'balanced',
    );

    expect(duel.rung, RoutingRung.admission);
    expect(duel.won, isFalse);
  });

  test('the specialist fits a whitelist network and wastes an open one', () {
    final breaker = _base.copyWith(breaker: true);
    RoutingDuel duelOn(String terrain) =>
        routingDuel(breaker, _base, terrain: terrain, strategy: 'balanced');

    expect(duelOn('whitelist').rung, RoutingRung.misfit);
    expect(duelOn('whitelist').won, isTrue);
    expect(duelOn('normal').won, isFalse);
  });

  test('latency ignores specialist suitability', () {
    final breaker = _base.copyWith(breaker: true, latencyMs: 900);
    final duel = routingDuel(
      breaker,
      _base,
      terrain: 'whitelist',
      strategy: 'lowest-latency',
    );

    expect(duel.rung, RoutingRung.latency);
    expect(duel.won, isFalse);
  });

  test('a rung below the first difference cannot change the outcome', () {
    final worseVerdict = _base.copyWith(verdict: 'last-resort', latencyMs: 1);
    final duel = routingDuel(
      worseVerdict,
      _base,
      terrain: 'normal',
      strategy: 'balanced',
    );

    expect(duel.rung, RoutingRung.verdict);
    expect(duel.won, isFalse);
  });

  test('two identical servers are separated by nothing at all', () {
    expect(
      routingDuel(_base, _base, terrain: 'normal', strategy: 'balanced').rung,
      isNull,
    );
  });

  test('fresh probes and live traffic have equal evidence rank', () {
    final live = _base.copyWith(evidence: 'live');
    expect(live.evidence, isNot(_base.evidence));
    expect(
      routingDuel(live, _base, terrain: 'normal', strategy: 'balanced').rung,
      isNull,
    );
  });

  test('recurrence starts ranking at two episodes and precedes speed', () {
    final oneEpisode = _base.copyWith(recurrence: 1);
    expect(
      routingDuel(
        oneEpisode,
        _base,
        terrain: 'normal',
        strategy: 'balanced',
      ).rung,
      isNull,
    );
    final recurrent = _base.copyWith(recurrence: 2, latencyMs: 20);
    final duel = routingDuel(
      recurrent,
      _base,
      terrain: 'normal',
      strategy: 'lowest-latency',
    );
    expect(duel.rung, RoutingRung.recurrence);
    expect(duel.won, isFalse);
  });

  test('degradation precedes speed without changing its displayed value', () {
    final degraded = _base.copyWith(degraded: true, latencyMs: 20);
    final duel = routingDuel(
      degraded,
      _base,
      terrain: 'normal',
      strategy: 'stable',
    );
    expect(degraded.latencyMs, 20);
    expect(duel.rung, RoutingRung.degraded);
    expect(duel.won, isFalse);
  });

  test('unknown latency sorts behind measured latency', () {
    for (final latencyMs in [0, -1]) {
      final unknown = _base.copyWith(latencyMs: latencyMs, order: 0);
      final duel = routingDuel(
        unknown,
        _base,
        terrain: 'normal',
        strategy: 'balanced',
      );
      expect(duel.rung, RoutingRung.latency);
      expect(duel.won, isFalse);
    }
  });

  test('latency uses milliseconds rather than display bands', () {
    final slow = _base.copyWith(latencyMs: 140, band: 0);
    final fast = _base.copyWith(latencyMs: 100, band: 0);
    final duel = routingDuel(
      fast,
      slow,
      terrain: 'normal',
      strategy: 'balanced',
    );
    expect(duel.rung, RoutingRung.latency);
    expect(duel.won, isTrue);
  });

  test('incumbency wins equal quality before source order', () {
    final current = _base.copyWith(current: true, order: 70000);
    final earlier = _base.copyWith(order: 1);
    final duel = routingDuel(
      current,
      earlier,
      terrain: 'normal',
      strategy: 'balanced',
    );
    expect(duel.rung, RoutingRung.incumbent);
    expect(duel.won, isTrue);
  });

  test('every rung reads low-is-better so one comparison covers them all', () {
    final best = _base.copyWith(
      verdict: 'preferred',
      evidence: 'live',
      latencyMs: 69,
      current: true,
      order: 1,
    );
    final worst = _base.copyWith(
      verdict: 'reject',
      evidence: 'none',
      latencyMs: 900,
      recurrence: 2,
      degraded: true,
      unproven: true,
      breaker: true,
      block: 'absent',
      order: 2,
    );
    for (final rung in RoutingRung.values) {
      expect(
        routingRungValue(rung, best, 'normal'),
        lessThan(routingRungValue(rung, worst, 'normal')),
        reason: '${rung.name} does not order the better server first',
      );
    }
  });
}

import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _decide = 'core/rcx_decide.go';

const _rungOfField = {
  'verdict': RoutingRung.verdict,
  'misfit': RoutingRung.misfit,
  'evidence': RoutingRung.evidence,
  'latBucket': RoutingRung.band,
  'unproven': RoutingRung.unproven,
  'challenger': RoutingRung.incumbent,
  'order': RoutingRung.tiebreak,
};

List<RoutingRung> _goLadder(String source, String function) {
  final body = RegExp(
    'func $function\\(a, b rcxKey\\) int \\{.*?\\n\\}',
    dotAll: true,
  ).firstMatch(source);
  expect(body, isNotNull, reason: '$function is gone from $_decide');
  return [
    for (final match in RegExp(
      r'a\.(\w+) != b\.\1',
    ).allMatches(body!.group(0)!))
      _rungOfField[match.group(1)]!,
  ];
}

const _base = RcxCandidateReport(
  node: 'base',
  verdict: 'viable',
  evidence: 'fresh',
  band: 2,
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

  test('holding still outranks a faster band, and evidence outranks both', () {
    const ladder = 'stable';
    final incumbent = _base.copyWith(current: true, band: 3);
    final faster = _base.copyWith(band: 0);
    final betterEvidence = _base.copyWith(band: 3, evidence: 'live');

    expect(
      routingDuel(faster, incumbent, terrain: 'normal', strategy: ladder).won,
      isFalse,
    );
    expect(
      routingDuel(
        faster,
        incumbent,
        terrain: 'normal',
        strategy: 'balanced',
      ).won,
      isTrue,
    );
    expect(
      routingDuel(
        betterEvidence,
        incumbent,
        terrain: 'normal',
        strategy: ladder,
      ).won,
      isTrue,
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

  test('latency reads the band before the terrain it does not rank by', () {
    final breaker = _base.copyWith(breaker: true, band: 4);
    final duel = routingDuel(
      breaker,
      _base,
      terrain: 'whitelist',
      strategy: 'lowest-latency',
    );

    expect(duel.rung, RoutingRung.band);
    expect(duel.won, isFalse);
  });

  test('a rung below the first difference cannot change the outcome', () {
    final worseVerdict = _base.copyWith(verdict: 'last-resort', band: 0);
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

  test('every rung reads low-is-better so one comparison covers them all', () {
    final best = _base.copyWith(
      verdict: 'preferred',
      evidence: 'live',
      band: 0,
      current: true,
      order: 1,
    );
    final worst = _base.copyWith(
      verdict: 'reject',
      evidence: 'none',
      band: 9,
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

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';

const _goldenLadder = 'core/rcx/testdata/default_ladder.json';

const _base = RcxCandidateReport(
  node: 'base',
  verdict: 'viable',
  evidence: 'fresh',
  latencyMs: 249,
);

void main() {
  test('the Dart default ladder is the committed golden order', () {
    final golden = jsonDecode(File(_goldenLadder).readAsStringSync()) as List;
    final tokens = [for (final rung in golden) (rung as Map)['id'] as String];
    expect(
      tokens,
      routingDefaultRungTokens,
      reason: 'Dart default drifted from $_goldenLadder',
    );
    expect(routingDefaultLadder(), [
      RoutingRung.admission,
      for (final token in tokens) RoutingRung.values.byName(token),
    ]);
  });

  test('lowest-latency drops the misfit rung, others keep the full ladder', () {
    expect(routingLadder('lowest-latency'), [
      for (final rung in routingDefaultLadder())
        if (rung != RoutingRung.misfit) rung,
    ]);
    expect(routingLadder(''), routingLadder('balanced'));
    expect(routingLadder('balanced'), routingDefaultLadder());
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
      homeRisk: 2,
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

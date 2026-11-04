import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/report/sources.dart';
import 'package:reclash/features/doctor/report/sweep.dart';
import 'package:reclash/models/models.dart';

const _testUrl = 'https://check.example/204';

class _FakeCore extends Fake implements CoreController {
  _FakeCore({this.dials = const {}, this.delays = const {}});

  final Map<String, DialDirectResult?> dials;
  final Map<String, int?> delays;
  final Map<String, Completer<void>> gates = {};
  int running = 0;
  int peak = 0;

  Future<void> _enter(String node) async {
    running++;
    peak = running > peak ? running : peak;
    await (gates[node]?.future ?? Future<void>.delayed(Duration.zero));
    running--;
  }

  @override
  Future<DialDirectResult?> dialDirect(DialDirectParams params) async {
    await _enter(params.proxyName);
    return dials[params.proxyName] ??
        const DialDirectResult(
          stage: 'done',
          server: 'node.example',
          port: 443,
        );
  }

  @override
  Future<Delay?> getDelay(
    String url,
    String proxyName,
    Duration timeout,
  ) async {
    final value = delays.containsKey(proxyName) ? delays[proxyName] : 80;
    return Delay(name: proxyName, url: url, value: value);
  }
}

List<SweepNode> _nodes(int count) => [
  for (var i = 0; i < count; i++)
    SweepNode(name: 'n$i', group: 'Proxy', testUrl: _testUrl),
];

Future<List<SweepRow>> _sweep(
  CoreNodeSweeper sweeper, {
  bool Function()? cancelled,
}) => sweeper.sweep(onProgress: (_, _) {}, cancelled: cancelled ?? () => false);

void main() {
  group('sweepNodes', () {
    test('dedupes leaves and skips groups and built-ins', () {
      final groups = [
        const Group(
          type: GroupType.Selector,
          name: _globalGroupName,
          all: [
            Proxy(name: 'tokyo', type: 'Vless'),
            Proxy(name: 'paris', type: 'Trojan'),
          ],
        ),
        const Group(
          type: GroupType.Selector,
          name: 'Proxy',
          all: [
            Proxy(name: 'Auto', type: 'URLTest'),
            Proxy(name: 'DIRECT', type: 'Direct'),
            Proxy(name: 'REJECT', type: 'Reject'),
            Proxy(name: 'tokyo', type: 'Vless'),
          ],
        ),
        const Group(
          type: GroupType.URLTest,
          name: 'Auto',
          testUrl: 'https://auto.example/204',
          all: [
            Proxy(name: 'tokyo', type: 'Vless'),
            Proxy(name: 'COMPATIBLE', type: 'Compatible'),
          ],
        ),
      ];

      final nodes = sweepNodes(
        groups: groups,
        testUrl: _testUrl,
        delays: {
          _testUrl: {'tokyo': 120, 'paris': -1},
        },
      );

      expect(nodes.map((node) => (node.name, node.group)), [
        ('tokyo', 'Proxy'),
        ('paris', _globalGroupName),
      ]);
      expect(nodes.first.lastDelayMs, 120);
      expect(nodes.last.lastDelayMs, isNull);
    });
  });

  group('sweepStatus', () {
    DialDirectResult failed(String cause) => DialDirectResult(
      stage: 'tcp',
      server: 'node.example',
      port: 443,
      cause: cause,
    );

    test('maps the Core failure causes', () {
      expect(sweepStatus(failed('serverDns'), -2), SweepStatus.dns);
      expect(sweepStatus(failed('refused'), -2), SweepStatus.refused);
      expect(sweepStatus(failed('timeout'), -1), SweepStatus.timeout);
      expect(sweepStatus(failed('tlsHandshake'), -2), SweepStatus.tls);
      expect(sweepStatus(failed('authRejected'), -2), SweepStatus.auth);
      expect(sweepStatus(failed('reset'), -2), SweepStatus.unknown);
    });

    test('a working delay wins, a node without server is skipped', () {
      expect(sweepStatus(failed('refused'), 90), SweepStatus.ok);
      expect(sweepStatus(const DialDirectResult(), 90), SweepStatus.skipped);
    });

    test('a clean dial falls back to the delay outcome', () {
      const clean = DialDirectResult(stage: 'done', server: 'node.example');
      expect(sweepStatus(clean, -1), SweepStatus.timeout);
      expect(sweepStatus(clean, -2), SweepStatus.unknown);
      expect(sweepStatus(null, null), SweepStatus.unknown);
    });
  });

  group('CoreNodeSweeper', () {
    test('runs at most eight nodes at a time and reports progress', () async {
      final core = _FakeCore();
      final progress = <int>[];
      final rows = await CoreNodeSweeper(core: core, nodes: () => _nodes(20))
          .sweep(
            onProgress: (done, total) {
              expect(total, 20);
              progress.add(done);
            },
            cancelled: () => false,
          );

      expect(core.peak, sweepConcurrency);
      expect(rows.map((row) => row.node), [for (var i = 0; i < 20; i++) 'n$i']);
      expect(progress.first, 0);
      expect(progress.last, 20);
      expect(rows.first.status, SweepStatus.ok);
      expect(rows.first.delayMs, 80);
      expect(rows.first.tcpMs, 0);
    });

    test('cancelling keeps the finished rows and starts no more', () async {
      final core = _FakeCore();
      for (var i = 0; i < 4; i++) {
        core.gates['n$i'] = Completer<void>();
      }
      var cancelled = false;
      final sweep = _sweep(
        CoreNodeSweeper(core: core, nodes: () => _nodes(10), concurrency: 2),
        cancelled: () => cancelled,
      );
      await pumpEventQueue();
      core.gates['n0']!.complete();
      await pumpEventQueue();
      cancelled = true;
      core.gates['n1']!.complete();
      core.gates['n2']!.complete();
      final rows = await sweep;

      expect(rows.map((row) => row.node), ['n0', 'n1', 'n2']);
    });

    test('maps each row from the dial and the delay', () async {
      final core = _FakeCore(
        dials: {
          'dead': const DialDirectResult(
            stage: 'tcp',
            server: '198.51.100.7',
            port: 8443,
            type: 'Vless',
            tcpMs: 5000,
            cause: 'timeout',
          ),
          'gone': const DialDirectResult(),
        },
        delays: {'dead': -1, 'gone': -2},
      );
      final rows = await _sweep(
        CoreNodeSweeper(
          core: core,
          nodes: () => [
            const SweepNode(
              name: 'dead',
              group: 'Proxy',
              testUrl: _testUrl,
              lastDelayMs: 300,
            ),
            const SweepNode(name: 'gone', group: 'Proxy', testUrl: _testUrl),
          ],
        ),
      );

      final dead = rows.first;
      expect(dead.status, SweepStatus.timeout);
      expect(
        (dead.server, dead.port, dead.type),
        ('198.51.100.7', 8443, 'Vless'),
      );
      expect(dead.resolveMs, isNull);
      expect(dead.tcpMs, 5000);
      expect(dead.delayMs, isNull);
      expect(dead.lastDelayMs, 300);
      expect(rows.last.status, SweepStatus.skipped);
    });
  });
}

const _globalGroupName = 'GLOBAL';

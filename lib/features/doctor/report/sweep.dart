import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

import '../cause.dart';
import 'sources.dart';

const sweepConcurrency = 8;
const sweepNodeTimeout = Duration(seconds: 5);

const _globalGroup = 'GLOBAL';

const _builtInTypes = {
  'Direct',
  'Reject',
  'RejectDrop',
  'Pass',
  'PassRule',
  'Rematch',
  'Compatible',
  'Dns',
};

const _delayTimedOut = -1;

class SweepNode {
  const SweepNode({
    required this.name,
    required this.group,
    required this.testUrl,
    this.lastDelayMs,
  });

  final String name;
  final String group;
  final String testUrl;
  final int? lastDelayMs;
}

/// Every leaf node of [groups] once, under the first group that lists it,
/// with GLOBAL last because it lists every node.
List<SweepNode> sweepNodes({
  required List<Group> groups,
  required String testUrl,
  required DelayMap delays,
}) {
  final groupNames = {for (final group in groups) group.name};
  final ordered = [
    ...groups.where((group) => group.name != _globalGroup),
    ...groups.where((group) => group.name == _globalGroup),
  ];
  final nodes = <String, SweepNode>{};
  for (final group in ordered) {
    final groupTestUrl = group.testUrl.takeFirstValid([testUrl]);
    for (final proxy in group.all) {
      if (groupNames.contains(proxy.name) ||
          _builtInTypes.contains(proxy.type) ||
          nodes.containsKey(proxy.name)) {
        continue;
      }
      final last = delays[groupTestUrl]?[proxy.name];
      nodes[proxy.name] = SweepNode(
        name: proxy.name,
        group: group.name,
        testUrl: groupTestUrl,
        lastDelayMs: last != null && last > 0 ? last : null,
      );
    }
  }
  return nodes.values.toList();
}

SweepStatus sweepStatus(DialDirectResult? dial, int? delay) {
  if (dial != null && dial.server.isEmpty) return SweepStatus.skipped;
  if (delay != null && delay > 0) return SweepStatus.ok;
  final status = switch (FailureCause.fromWire(dial?.cause)) {
    FailureCause.serverDns => SweepStatus.dns,
    FailureCause.refused => SweepStatus.refused,
    FailureCause.timeout => SweepStatus.timeout,
    FailureCause.tlsHandshake => SweepStatus.tls,
    FailureCause.authRejected => SweepStatus.auth,
    null => null,
    _ => SweepStatus.unknown,
  };
  if (status != null) return status;
  return delay == _delayTimedOut ? SweepStatus.timeout : SweepStatus.unknown;
}

class CoreNodeSweeper implements NodeSweeper {
  CoreNodeSweeper({
    required this.core,
    required this.nodes,
    this.concurrency = sweepConcurrency,
    this.timeout = sweepNodeTimeout,
  });

  final CoreController core;
  final List<SweepNode> Function() nodes;
  final int concurrency;
  final Duration timeout;

  @override
  Future<List<SweepRow>> sweep({
    required void Function(int done, int total) onProgress,
    required bool Function() cancelled,
  }) async {
    final targets = nodes();
    final rows = List<SweepRow?>.filled(targets.length, null);
    var next = 0;
    var done = 0;
    onProgress(0, targets.length);

    Future<void> worker() async {
      while (next < targets.length && !cancelled()) {
        final index = next++;
        rows[index] = await _sweepNode(targets[index]);
        onProgress(++done, targets.length);
      }
    }

    await Future.wait([
      for (var i = 0; i < min(concurrency, targets.length); i++) worker(),
    ]);
    return rows.nonNulls.toList();
  }

  Future<SweepRow> _sweepNode(SweepNode node) async {
    final (dial, delay) = await (
      _quietly(
        () => core.dialDirect(
          DialDirectParams(
            proxyName: node.name,
            url: node.testUrl,
            timeout: timeout.inMilliseconds,
          ),
        ),
      ),
      _quietly(() => core.getDelay(node.testUrl, node.name, timeout)),
    ).wait;
    final delayValue = delay?.value;
    return SweepRow(
      node: node.name,
      group: node.group,
      type: dial?.type ?? '',
      server: dial?.server ?? '',
      port: dial?.port ?? 0,
      status: sweepStatus(dial, delayValue),
      resolveMs: _resolved(dial) ? dial!.resolveMs : null,
      tcpMs: _dialed(dial) ? dial!.tcpMs : null,
      delayMs: delayValue != null && delayValue > 0 ? delayValue : null,
      lastDelayMs: node.lastDelayMs,
    );
  }
}

bool _resolved(DialDirectResult? dial) =>
    dial != null &&
    dial.stage.isNotEmpty &&
    InternetAddress.tryParse(dial.server) == null;

bool _dialed(DialDirectResult? dial) =>
    const {'tcp', 'handshake', 'done'}.contains(dial?.stage);

/// A Core that fails one node must not end the sweep of the rest.
Future<T?> _quietly<T>(Future<T?> Function() call) async {
  try {
    return await call();
  } catch (_) {
    return null;
  }
}

final nodeSweeperProvider = Provider<NodeSweeper>(
  (ref) => CoreNodeSweeper(
    core: ref.read(coreHandlerProvider),
    nodes: () => sweepNodes(
      groups: ref.read(groupsProvider),
      testUrl: ref.read(patchClashConfigProvider).testUrl,
      delays: ref.read(delayDataSourceProvider),
    ),
  ),
);

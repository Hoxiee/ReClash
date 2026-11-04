import 'dart:async';

import 'package:reclash/common/network_cost.dart';
import 'package:reclash/features/speed_test/client.dart';
import 'package:reclash/features/speed_test/history.dart';
import 'package:reclash/features/speed_test/types.dart';
import 'package:reclash/models/speed_test.dart';

class FakeSpeedNetwork implements NetworkCostMonitor {
  FakeSpeedNetwork({
    this.snapshot = const NetworkCostSnapshot(
      cost: NetworkCost.unmetered,
      identity: 'test-network',
    ),
  });

  NetworkCostSnapshot snapshot;
  Error? error;
  int reads = 0;
  NetworkCostSnapshot? secondRead;
  final controller = StreamController<NetworkCostSnapshot>.broadcast(
    sync: true,
  );

  @override
  Future<NetworkCostSnapshot> read() async {
    reads++;
    if (error case final error?) throw error;
    return reads > 1 ? secondRead ?? snapshot : snapshot;
  }

  @override
  Stream<NetworkCostSnapshot> get changes => controller.stream;

  void change(NetworkCostSnapshot value) {
    snapshot = value;
    controller.add(value);
  }

  Future<void> close() => controller.close();
}

class FakeSpeedClient implements SpeedTestClient {
  FakeSpeedClient({this.complete = true});

  bool complete;
  bool accepted = true;
  bool wrongId = false;
  Error? startError;
  Error? snapshotError;
  Completer<bool>? startGate;
  Completer<SpeedTestState?>? snapshotGate;
  Completer<List<SpeedTestServer>>? serversGate;
  SpeedTestState? result;
  final requests = <Map<String, Object?>>[];
  final cancellations = <String>[];
  final serverRequests = <Map<String, Object?>>[];
  final started = Completer<void>();
  int polls = 0;

  @override
  Future<bool> start(
    SpeedTestSettings settings, {
    required String requestId,
    required String proxyName,
    required bool direct,
  }) async {
    requests.add(
      settings.toRequest(
        requestId: requestId,
        proxyName: proxyName,
        direct: direct,
      ),
    );
    if (!started.isCompleted) started.complete();
    if (startError case final error?) throw error;
    if (startGate case final gate?) return gate.future;
    return accepted;
  }

  @override
  Future<SpeedTestState?> snapshot(String requestId) async {
    polls++;
    if (snapshotError case final error?) throw error;
    if (snapshotGate case final gate?) return gate.future;
    if (result case final value?) {
      return value.copyWith(requestId: wrongId ? 'older' : requestId);
    }
    final request = requests.last;
    final latencyOnly = request['mode'] == 'latencyOnly';
    return SpeedTestState(
      requestId: wrongId ? 'older' : requestId,
      phase: complete ? SpeedTestPhase.done : SpeedTestPhase.running,
      stage: latencyOnly ? SpeedTestStage.latency : SpeedTestStage.download,
      backendId: request['backendId'] as String,
      byteLimit: request['byteLimit'] as int,
      viaVpn: request['direct'] != true,
      proxyName: request['proxyName'] as String,
      progress: complete ? 1 : 0.5,
      downloadMbps: latencyOnly ? null : 123.4,
      uploadMbps: latencyOnly ? null : 56.7,
      liveMbps: latencyOnly ? null : 110,
      latency: const LatencySummary(medianMs: 18, jitterMs: 2, count: 20),
      downloadLatency: latencyOnly
          ? null
          : const LatencySummary(medianMs: 40, jitterMs: 4, count: 10),
      uploadLatency: latencyOnly
          ? null
          : const LatencySummary(medianMs: 60, jitterMs: 5, count: 10),
      rpm: latencyOnly ? null : 1200,
      elapsed: const Duration(seconds: 24),
      transferredBytes: latencyOnly ? 0 : 4096,
      server: const SpeedTestServer(
        name: 'Test city',
        sponsor: 'Test operator',
        host: 'speed.example.test:443',
      ),
      downloadSamples: latencyOnly
          ? const []
          : const [
              SpeedTestSample(elapsedMs: 200, mbps: 100),
              SpeedTestSample(elapsedMs: 400, mbps: 123.4),
            ],
      uploadSamples: latencyOnly
          ? const []
          : const [
              SpeedTestSample(elapsedMs: 200, mbps: 40),
              SpeedTestSample(elapsedMs: 400, mbps: 56.7),
            ],
    );
  }

  @override
  Future<void> cancel(String requestId) async => cancellations.add(requestId);

  @override
  Future<List<SpeedTestServer>> servers({
    required String requestId,
    required String proxyName,
    required bool direct,
    required bool useSystemDns,
    String search = '',
  }) async {
    serverRequests.add({
      'requestId': requestId,
      'proxyName': proxyName,
      'direct': direct,
      'useSystemDns': useSystemDns,
      'search': search,
    });
    if (serversGate case final gate?) return gate.future;
    return const [
      SpeedTestServer(
        id: '1',
        name: 'Test city',
        host: 'speed.example.test:443',
        sponsor: 'Test operator',
        latencyMs: 12,
      ),
    ];
  }
}

class MemorySpeedHistory implements SpeedTestHistoryStore {
  MemorySpeedHistory([List<String> records = const []])
    : records = [...records];

  List<String> records;
  Error? saveError;
  Error? loadError;
  int writes = 0;

  @override
  Future<List<String>> load() async {
    if (loadError case final error?) throw error;
    return [...records];
  }

  @override
  Future<void> save(List<String> records) async {
    if (saveError case final error?) throw error;
    writes++;
    this.records = [...records];
  }
}

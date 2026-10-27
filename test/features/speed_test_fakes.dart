import 'dart:async';

import 'package:reclash/common/network_cost.dart';
import 'package:reclash/features/speed_test/backend.dart';

class FakeSpeedNetwork implements NetworkCostMonitor {
  FakeSpeedNetwork({
    this.snapshot = const NetworkCostSnapshot(
      cost: NetworkCost.unmetered,
      identity: 'test-network',
    ),
  });

  NetworkCostSnapshot snapshot;
  final controller = StreamController<NetworkCostSnapshot>.broadcast(
    sync: true,
  );

  @override
  Future<NetworkCostSnapshot> read() async => snapshot;

  @override
  Stream<NetworkCostSnapshot> get changes => controller.stream;

  void change(NetworkCostSnapshot value) {
    snapshot = value;
    controller.add(value);
  }

  Future<void> close() => controller.close();
}

class FakeSpeedBackend implements SpeedTestBackend {
  FakeSpeedBackend({FakeSpeedSession? session, this.id = 'cloudflare'})
    : session = session ?? FakeSpeedSession();

  final FakeSpeedSession session;
  int opens = 0;

  @override
  final String id;
  @override
  String get name => 'Test service';
  @override
  Uri get website => Uri.https('example.test');
  @override
  Uri get measurementUri => website.resolve('/download');
  @override
  int get streams => 4;

  @override
  SpeedTestSession open(SpeedTestClientFactory createClient) {
    opens++;
    return session;
  }
}

class FakeSpeedSession implements SpeedTestSession {
  FakeSpeedSession({
    this.failUpload = false,
    this.holdDownload = false,
    this.holdLatency = false,
    this.dropDownloads = 0,
  });

  final bool failUpload;

  /// Number of first downloads that fail as a dropped connection would.
  final int dropDownloads;
  final bool holdDownload;
  final bool holdLatency;
  final held = Completer<void>();
  int probes = 0;
  int downloads = 0;
  int uploads = 0;
  int bytes = 0;
  int aborts = 0;
  final lanes = <int>{};
  bool closed = false;

  @override
  Future<double> latency() async {
    probes++;
    if (holdLatency) await held.future;
    return [10.0, 12.0, 18.0, 14.0][probes % 4];
  }

  @override
  Future<void> download(
    int count,
    SpeedTestByteCallback onBytes, {
    int lane = 0,
  }) async {
    downloads++;
    if (downloads <= dropDownloads) {
      throw StateError('connection dropped');
    }
    lanes.add(lane);
    if (holdDownload) {
      await held.future;
      return;
    }
    bytes += count;
    onBytes(count);
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> upload(
    int count,
    SpeedTestByteCallback onBytes, {
    int lane = 0,
  }) async {
    uploads++;
    bytes += count;
    onBytes(count);
    if (failUpload) throw StateError('upload unavailable');
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }

  @override
  void abortTransfer() {
    aborts++;
  }

  @override
  void close() {
    closed = true;
  }
}

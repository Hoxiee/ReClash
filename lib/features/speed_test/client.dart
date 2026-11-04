import 'package:reclash/core/controller.dart';
import 'package:reclash/models/speed_test.dart';

import 'types.dart';

abstract interface class SpeedTestClient {
  Future<bool> start(
    SpeedTestSettings settings, {
    required String requestId,
    required String proxyName,
    required bool direct,
  });

  Future<SpeedTestState?> snapshot(String requestId);
  Future<void> cancel(String requestId);

  Future<List<SpeedTestServer>> servers({
    required String requestId,
    required String proxyName,
    required bool direct,
    required bool useSystemDns,
    String search = '',
  });
}

class CoreSpeedTestClient implements SpeedTestClient {
  const CoreSpeedTestClient(this.core);

  final CoreController core;

  @override
  Future<bool> start(
    SpeedTestSettings settings, {
    required String requestId,
    required String proxyName,
    required bool direct,
  }) => core.startSpeedTest(
    settings,
    requestId: requestId,
    proxyName: proxyName,
    direct: direct,
  );

  @override
  Future<SpeedTestState?> snapshot(String requestId) async {
    final data = await core.getSpeedTest(requestId);
    return data == null ? null : SpeedTestState.fromJson(data);
  }

  @override
  Future<void> cancel(String requestId) async {
    await core.cancelSpeedTest(requestId);
  }

  @override
  Future<List<SpeedTestServer>> servers({
    required String requestId,
    required String proxyName,
    required bool direct,
    required bool useSystemDns,
    String search = '',
  }) => core.speedTestServers(
    requestId: requestId,
    proxyName: proxyName,
    direct: direct,
    useSystemDns: useSystemDns,
    search: search,
  );
}

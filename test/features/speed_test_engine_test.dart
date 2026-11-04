import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/speed_test/types.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/speed_test.dart';

void main() {
  test('latency uses the median and consecutive-sample jitter', () {
    final summary = LatencySummary.of([10, 20, 30, 100])!;
    expect(summary.medianMs, 25);
    expect(summary.jitterMs, 30);
    expect(summary.count, 4);
    expect(LatencySummary.of([]), isNull);
    expect(LatencySummary.of([12])!.jitterMs, isNull);
  });

  test('extended settings survive application persistence', () {
    const settings = SpeedTestSettings(
      backendId: 'speedtest',
      mode: SpeedTestMode.latencyOnly,
      budgetMiB: 250,
      durationSeconds: 20,
      multiThread: false,
      protocol: SpeedTestProtocol.http3,
      useSystemDns: true,
      server: SpeedTestServer(id: '12', host: 'example.test:443', name: 'City'),
    );
    const app = AppSettingProps(speedTest: settings);
    final restored = AppSettingProps.fromJson(
      jsonDecode(jsonEncode(app)) as Map<String, dynamic>,
    );
    expect(restored.speedTest, settings);
  });

  test('old confirmation preferences do not enable a confirmation path', () {
    final settings = SpeedTestSettings.safeFromJson({
      'backendId': 'librespeed',
      'budgetMiB': 50,
      'alwaysConfirm': true,
    });
    expect(settings.backendId, 'librespeed');
    expect(settings.budgetMiB, 50);
    expect(settings.toJson(), isNot(contains('alwaysConfirm')));
    expect(settings.durationSeconds, 10);
  });

  test('malformed settings retain safe bounded defaults', () {
    expect(
      SpeedTestSettings.safeFromJson('invalid'),
      const SpeedTestSettings(),
    );
    final settings = SpeedTestSettings.safeFromJson({
      'backendId': 'unknown',
      'budgetMiB': -1,
      'durationSeconds': 999,
      'mode': 'unknown',
      'protocol': 'unknown',
      'server': {'host': 3},
    });
    expect(settings, const SpeedTestSettings());
  });

  test('native request has one unit for each value and no double encoding', () {
    const settings = SpeedTestSettings(
      backendId: 'speedtest',
      durationSeconds: 15,
      budgetMiB: 25,
      protocol: SpeedTestProtocol.http3,
      server: SpeedTestServer(id: '7', host: 'example.test:443'),
    );
    final request = settings.toRequest(
      requestId: 'request',
      proxyName: 'node',
      direct: false,
    );
    expect(request['durationSeconds'], 15);
    expect(request['byteLimit'], 25 * 1024 * 1024);
    expect(request['streams'], 8);
    expect(request['protocol'], 'h3');
    expect(request['server'], isA<Map>());
    expect(request['proxyName'], 'node');
    expect(request['direct'], false);
    expect(
      settings
          .copyWith(mode: SpeedTestMode.latencyOnly)
          .toRequest(requestId: 'r', proxyName: '', direct: true)['byteLimit'],
      0,
    );
    expect(
      settings
          .copyWith(backendId: 'apple')
          .toRequest(requestId: 'r', proxyName: '', direct: true)['server'],
      isNull,
    );
  });

  test('native snapshots preserve Mbps, milliseconds and loaded latency', () {
    final state = SpeedTestState.fromJson({
      'requestId': 'r',
      'backendId': 'apple',
      'phase': 'done',
      'stage': 'upload',
      'downloadMbps': 812.5,
      'uploadMbps': 105.25,
      'elapsedMs': 22150,
      'latency': {'medianMs': 12.5, 'jitterMs': 1.5, 'count': 20},
      'downloadLatency': {'medianMs': 25, 'jitterMs': 3, 'count': 12},
      'uploadLatency': {'medianMs': 50, 'jitterMs': 4, 'count': 12},
      'rpm': 1600,
      'byteLimit': 104857600,
      'transferredBytes': 4096,
      'protocol': 'h2',
      'protocolFallback': true,
      'chains': ['node', 'group'],
      'downloadSamples': [
        {'elapsedMs': 200, 'mbps': 801.25},
      ],
    });
    expect(state.downloadMbps, 812.5);
    expect(state.elapsed, const Duration(milliseconds: 22150));
    expect(state.latency!.medianMs, 12.5);
    expect(state.downloadLatency!.medianMs, 25);
    expect(state.rpm, 1600);
    expect(state.downloadSamples.single.mbps, 801.25);
    expect(state.protocolFallback, isTrue);
    expect(state.toJson()['elapsedMs'], 22150);
    expect(
      () => state.downloadSamples.add(
        const SpeedTestSample(elapsedMs: 400, mbps: 1),
      ),
      throwsUnsupportedError,
    );
  });

  test('persistent records exclude live samples and request ownership', () {
    final state = SpeedTestState(
      requestId: 'private-request',
      phase: SpeedTestPhase.done,
      checkedAt: DateTime.now(),
      downloadMbps: 100,
      liveMbps: 90,
      downloadSamples: const [SpeedTestSample(elapsedMs: 200, mbps: 90)],
    );
    final record =
        jsonDecode(jsonEncode(state.toRecord())) as Map<String, dynamic>;
    expect(record['requestId'], '');
    expect(record['downloadSamples'], isEmpty);
    expect(record['liveMbps'], isNull);
    expect(SpeedTestState.fromJson(record).downloadMbps, 100);
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:reclash/core/event.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingCoreHandler extends CoreHandlerInterface {
  final Map<CoreMethod, Object?> calls = {};

  @override
  Future<CoreLifecycleResult> start() async => const CoreLifecycleResult(
    revision: 1,
    outcome: CoreLifecycleOutcome.applied,
  );

  @override
  Future<CoreLifecycleResult> restart() => start();

  @override
  Future<CoreLifecycleResult> stop() => start();

  @override
  Future<CoreLifecycleResult> close() => start();

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    calls[method] = arguments;
    final result = switch (method) {
      CoreMethod.initClash || CoreMethod.setUiActive => true as T,
      CoreMethod.getTraffic ||
      CoreMethod.getTotalTraffic => {'up': 12, 'down': 34},
      CoreMethod.asyncTestDelay => {
        'name': 'DIRECT',
        'url': 'https://example.com',
        'value': 42,
      },
      CoreMethod.getConnections => {
        'connections': [
          {
            'id': 'connection-1',
            'metadata': {'network': 'tcp'},
            'upload': 0,
            'download': 0,
            'start': '2024-01-01',
            'chains': ['DIRECT'],
            'rule': 'DIRECT',
            'rulePayload': '',
          },
        ],
      },
      CoreMethod.getExternalProviders => [
        {
          'name': 'provider-1',
          'type': 'Proxy',
          'count': 1,
          'vehicle-type': 'HTTP',
          'update-at': '2024-01-01T00:00:00.000Z',
        },
      ],
      CoreMethod.getExternalProvider => {
        'name': 'provider-1',
        'type': 'Proxy',
        'count': 1,
        'vehicle-type': 'HTTP',
        'update-at': '2024-01-01T00:00:00.000Z',
      },
      CoreMethod.getConfig => {
        'mode': 'rule',
        'rule': ['MATCH,DIRECT'],
      },
      CoreMethod.getMemory => 2048,
      CoreMethod.doctorSnapshot ||
      CoreMethod.doctorStart ||
      CoreMethod.doctorCancel ||
      CoreMethod.doctorFlushDns => {
        'schemaVersion': 1,
        'revision': 12,
        'supported': true,
        'state': 'complete',
        'health': 'healthy',
        'confidence': 'confirmed',
        'severity': 'info',
        'scope': 'app',
        'pathKind': 'vpn',
        'captureState': 'active',
        'stages': [
          {'id': 'ingress', 'state': 'passed', 'layer': 'ingress'},
        ],
        'mode': 'standard',
        'layer': 'marker',
        'progress': {'phase': 'done', 'completed': 2, 'total': 2},
        'capabilities': {'explicitExam': true},
        'generations': {'environment': 3},
        'startGenerations': {'environment': 3},
        'evidence': [
          {
            'kind': 'marker',
            'layer': 'marker',
            'outcome': 'succeeded',
            'confidence': 'confirmed',
          },
        ],
        'actions': [],
        'healAudit': [],
        'incidents': [],
      },
      CoreMethod.doctorExport => {
        'schemaVersion': 1,
        'coreVersion': '1.0.0',
        'platform': 'linux',
        'architecture': 'amd64',
        'generatedAt': 42,
        'state': 'complete',
        'health': 'healthy',
        'confidence': 'confirmed',
        'scope': 'app',
        'pathKind': 'vpn',
        'captureState': 'active',
        'stages': [
          {'id': 'ingress', 'state': 'passed', 'layer': 'ingress'},
        ],
        'mode': 'standard',
        'layer': 'marker',
        'generations': {'environment': 3},
        'evidence': [],
        'healAudit': [],
        'incidents': [],
      },
      _ => '',
    };
    return result as T;
  }
}

class _FailingConfigCoreHandler extends _RecordingCoreHandler {
  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    if (method == CoreMethod.getConfig) {
      throw const CoreMethodException(
        code: 'core_error',
        message: 'config not found',
        details: {'path': '/missing.yaml'},
      );
    }
    return super.invokeMethod(
      method: method,
      arguments: arguments,
      timeout: timeout,
    );
  }
}

class _EmptyConfigCoreHandler extends _RecordingCoreHandler {
  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    if (method == CoreMethod.getConfig) {
      return null;
    }
    return super.invokeMethod(
      method: method,
      arguments: arguments,
      timeout: timeout,
    );
  }
}

void main() {
  test('method call keeps structured arguments', () async {
    final fixture =
        json.decode(
              await File('test/fixtures/core_protocol.json').readAsString(),
            )
            as Map<String, dynamic>;
    final call = CoreMethodCall.fromJson(
      Map<String, Object?>.from(fixture['methodCall'] as Map),
    );

    expect(call.method, CoreMethod.updateConfig);
    expect(call.arguments, isA<Map<String, dynamic>>());
    expect((call.arguments as Map)['mixed-port'], 7890);
    expect(call.toJson(), containsPair('arguments', call.arguments));
    expect(call.toJson(), isNot(contains('data')));
  });

  test('core interface sends structured request parameters', () async {
    final handler = _RecordingCoreHandler();

    await handler.init(const InitParams(homeDir: '/tmp/reclash', version: 35));
    await handler.setupConfig(
      const SetupParams(selectedMap: {'GLOBAL': 'DIRECT'}, testUrl: 'test'),
    );
    await handler.changeProxy(
      const ChangeProxyParams(groupName: 'GLOBAL', proxyName: 'DIRECT'),
    );
    await handler.sideLoadExternalProvider(providerName: 'provider', data: 'x');
    await handler.asyncTestDelay('https://example.com', 'DIRECT');
    await handler.clearEffect(42);
    await handler.setUiActive(true);

    for (final method in [
      CoreMethod.initClash,
      CoreMethod.setupConfig,
      CoreMethod.changeProxy,
      CoreMethod.sideLoadExternalProvider,
      CoreMethod.asyncTestDelay,
    ]) {
      expect(handler.calls[method], isA<Map>());
    }
    expect(handler.calls[CoreMethod.clearEffect], 42);
    expect(handler.calls[CoreMethod.setUiActive], isTrue);
  });

  test('RCX lane config and status keep their additive wire contract', () {
    const config = RcxLaneConfig(
      capabilityId: 'gemini-access',
      group: 'RCX-CAP-GEMINI_ACCESS',
      fallback: 'reject',
      selectors: [RcxLaneSelector(provider: 'premium', nameContains: '⭐')],
    );

    final configWire = jsonDecode(jsonEncode(config)) as Map<String, Object?>;
    expect(configWire, {
      'id': 'gemini-access',
      'g': 'RCX-CAP-GEMINI_ACCESS',
      'fb': 'reject',
      'sel': [
        {'p': 'premium', 'has': '⭐'},
      ],
    });
    expect(RcxStatus.fromJson(const {}).lanes, isEmpty);

    final status = RcxStatus.fromJson({
      'lanes': [
        {
          'id': 'gemini-access',
          'group': 'RCX-CAP-GEMINI_ACCESS',
          'state': 'active',
          'node': 'premium ⭐',
          'candidates': 3,
          'eligible': 2,
          'searching': true,
          'fallback': 'reject',
          'reason': 'better',
          'switchedAt': 42,
        },
      ],
    });

    expect(
      status.lanes.single,
      const RcxLaneStatus(
        id: 'gemini-access',
        group: 'RCX-CAP-GEMINI_ACCESS',
        state: 'active',
        node: 'premium ⭐',
        candidates: 3,
        eligible: 2,
        searching: true,
        fallback: 'reject',
        reason: 'better',
        switchedAt: 42,
      ),
    );
  });

  test('event contract accepts batches and legacy single events', () async {
    final fixture =
        json.decode(
              await File('test/fixtures/core_protocol.json').readAsString(),
            )
            as Map<String, dynamic>;
    final call = CoreMethodCall.fromJson(
      Map<String, Object?>.from(fixture['eventCall'] as Map),
    );

    final events = coreEventsFromData(call.arguments);
    expect(events, hasLength(2));
    expect(events.first.type, CoreEventType.loaded);
    expect(events.last.type, CoreEventType.delay);

    final legacy = coreEventsFromData({'type': 'loaded', 'data': 'provider-b'});
    expect(legacy.single.data, 'provider-b');
  });

  test('event contract skips malformed entries without dropping the batch', () {
    final events = coreEventsFromData([
      {'type': 'loaded', 'data': 'provider-a'},
      {'type': 'invalid-event', 'data': null},
      {'type': 'loaded', 'data': 'provider-b'},
    ]);

    expect(events.map((event) => event.data), ['provider-a', 'provider-b']);
  });

  test('core interface converts structured method results', () async {
    final handler = _RecordingCoreHandler();

    expect(await handler.getTraffic(false), const Traffic(up: 12, down: 34));
    expect(
      await handler.getTotalTraffic(false),
      const Traffic(up: 12, down: 34),
    );
    expect(
      await handler.asyncTestDelay('https://example.com', 'DIRECT'),
      const Delay(name: 'DIRECT', url: 'https://example.com', value: 42),
    );
    expect((await handler.getConnections()).single.id, 'connection-1');
    expect((await handler.getExternalProviders()).single.name, 'provider-1');
    expect(
      (await handler.getExternalProvider('provider-1'))?.name,
      'provider-1',
    );
    expect(await handler.getConfig('/config.yaml'), {
      'mode': 'rule',
      'rule': ['MATCH,DIRECT'],
    });
    expect(await handler.getMemory(), 2048);
  });

  test(
    'doctor interface keeps action arguments and converts results',
    () async {
      final handler = _RecordingCoreHandler();

      final snapshot = await handler.doctorSnapshot();
      await handler.startDoctor(
        const DoctorStartParams(mode: DoctorExamMode.deep),
      );
      await handler.cancelDoctor(const DoctorCancelParams(examId: 'exam-12'));
      await handler.flushDoctorDns(
        const DoctorHealParams(examId: 'exam-12', revision: 12),
      );
      final report = await handler.exportDoctorReport();

      expect(snapshot.revision, 12);
      expect(snapshot.health, DoctorHealth.healthy);
      expect(snapshot.pathKind, DoctorPathKind.vpn);
      expect(snapshot.captureState, DoctorCaptureState.active);
      expect(snapshot.stages.single.state, DoctorStageState.passed);
      expect(
        snapshot.progress,
        const DoctorProgress(phase: 'done', completed: 2, total: 2),
      );
      expect(snapshot.evidence.single.kind, DoctorEvidenceKind.marker);
      expect(handler.calls[CoreMethod.doctorStart], {'mode': 'deep'});
      expect(handler.calls[CoreMethod.doctorCancel], {'examId': 'exam-12'});
      expect(handler.calls[CoreMethod.doctorFlushDns], {
        'examId': 'exam-12',
        'revision': 12,
        'actionId': 'flushDns',
      });
      expect(report.coreVersion, '1.0.0');
      expect(report.pathKind, DoctorPathKind.vpn);
      expect(report.captureState, DoctorCaptureState.active);
      expect(report.stages.single.id, 'ingress');
      expect(report.generations.environment, 3);
    },
  );

  test('doctor models tolerate unknown enum values', () {
    final snapshot = DoctorSnapshot.fromJson({
      'state': 'future-state',
      'health': 'future-health',
      'confidence': 'future-confidence',
      'severity': 'future-severity',
      'scope': 'future-scope',
      'mode': 'future-mode',
      'layer': 'future-layer',
      'pathKind': 'future-path',
      'captureState': 'future-capture',
      'stages': [
        {'id': 'future', 'state': 'future-stage', 'layer': 'future-layer'},
      ],
      'evidence': [
        {
          'kind': 'future-kind',
          'layer': 'future-layer',
          'outcome': 'future-outcome',
          'confidence': 'future-confidence',
        },
      ],
    });

    expect(snapshot.state, DoctorExamState.unknown);
    expect(snapshot.health, DoctorHealth.unknown);
    expect(snapshot.confidence, DoctorConfidence.unknown);
    expect(snapshot.severity, DoctorSeverity.unknown);
    expect(snapshot.scope, DoctorScope.unknown);
    expect(snapshot.mode, DoctorExamMode.unknown);
    expect(snapshot.layer, DoctorLayer.unknown);
    expect(snapshot.pathKind, DoctorPathKind.unknown);
    expect(snapshot.captureState, DoctorCaptureState.unknown);
    expect(snapshot.stages.single.state, DoctorStageState.unknown);
    expect(snapshot.stages.single.layer, DoctorLayer.unknown);
    expect(snapshot.evidence.single.kind, DoctorEvidenceKind.unknown);
    expect(snapshot.evidence.single.outcome, DoctorEvidenceOutcome.unknown);
  });

  test('getConfig preserves structured core errors', () async {
    final handler = _FailingConfigCoreHandler();

    await expectLater(
      handler.getConfig('/missing.yaml'),
      throwsA(
        isA<CoreMethodException>()
            .having((error) => error.code, 'code', 'core_error')
            .having((error) => error.details, 'details', {
              'path': '/missing.yaml',
            }),
      ),
    );
  });

  test('getConfig rejects empty transport results', () async {
    final handler = _EmptyConfigCoreHandler();

    await expectLater(
      handler.getConfig('/config.yaml'),
      throwsA(
        isA<CoreMethodException>().having(
          (error) => error.code,
          'code',
          'empty_result',
        ),
      ),
    );
  });

  test('method response separates result and structured errors', () async {
    final fixture =
        json.decode(
              await File('test/fixtures/core_protocol.json').readAsString(),
            )
            as Map<String, dynamic>;
    final success = CoreMethodResponse.fromJson(
      Map<String, Object?>.from(fixture['successResponse'] as Map),
    );
    final structured = CoreMethodResponse.fromJson(
      Map<String, Object?>.from(fixture['structuredResponse'] as Map),
    );
    final failure = CoreMethodResponse.fromJson(
      Map<String, Object?>.from(fixture['errorResponse'] as Map),
    );

    expect(success.unwrap<String>(), '');
    expect(success.toJson(), containsPair('result', ''));
    expect(structured.result, isA<Map>());
    expect(structured.result, isNot(isA<String>()));
    expect(structured.unwrap<Map<String, dynamic>>()?['up'], 12);
    expect(
      () => failure.unwrap<Object?>(),
      throwsA(
        isA<CoreMethodException>()
            .having((error) => error.code, 'code', 'core_error')
            .having((error) => error.message, 'message', 'config not found'),
      ),
    );
    expect(failure.toJson(), contains('error'));
    expect(failure.toJson(), isNot(contains('code')));
  });
}

import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _evidence = 'core/doctor_evidence.go';
const _flow = 'core/mihomo/tunnel/evidence.go';
const _heal = 'core/doctor_heal.go';
const _runtime = 'core/doctor_runtime.go';
const _reducer = 'core/doctor_reducer.go';
const _platform = 'core/doctor_platform_status.go';
const _actor = 'core/doctor_actor.go';

/// Codes the core writes as plain literals on a failed fact, by the file that
/// mints them. Every one is re-checked against its source so a rename in the
/// core fails here instead of silently losing the answer.
const _literalCauses = {
  _runtime: {
    'coreResolverFailed',
    'coreResolverStale',
    'systemResolverFailed',
    'applicationProbeFailed',
    'noPhysicalNetwork',
    'captivePortal',
    'networkUnvalidated',
  },
  _reducer: {'vpnNotActive', 'tunNotActive'},
  _platform: {'byeDpiListenerFailed'},
  _actor: {'staleEvidence'},
  _evidence: {'destinationDnsFailed'},
};

const _pathStages = {'app', 'ingress', 'route', 'internet', 'response'};

String _read(String path) => File(path).readAsStringSync();

Set<String> _errorClasses(String source) {
  final body = RegExp(
    r'func flowErrorClass\(err error\) string \{.*?\n\}',
    dotAll: true,
  ).firstMatch(source);
  expect(body, isNotNull, reason: 'flowErrorClass is gone from $_flow');
  return {
    for (final match in RegExp(
      r'return "([a-z]+)"',
    ).allMatches(body!.group(0)!))
      match.group(1)!,
  };
}

Set<String> _dialPrefixes(String source) => {
  for (final match in RegExp('doctorErrorCode\\("(\\w+)"').allMatches(source))
    match.group(1)!,
};

Set<String> _probeCauses(String source) {
  final body = RegExp(
    r'func doctorProbeErrorCode\(err error, fallback string\) string \{.*?\n\}',
    dotAll: true,
  ).firstMatch(source);
  expect(
    body,
    isNotNull,
    reason: 'doctorProbeErrorCode is gone from $_runtime',
  );
  return {
    for (final match in RegExp('return "(\\w+)"').allMatches(body!.group(0)!))
      match.group(1)!,
  };
}

Set<String> _flushCauses(String source) {
  final body = RegExp(
    r'doctorDNSFlushCauses = map\[string\]struct\{\}\{.*?\n\}',
    dotAll: true,
  ).firstMatch(source);
  expect(body, isNotNull, reason: 'doctorDNSFlushCauses is gone from $_heal');
  return {
    for (final match in RegExp('"(\\w+)":').allMatches(body!.group(0)!))
      match.group(1)!,
  };
}

DoctorSnapshot _failed(String cause, DoctorLayer layer) => DoctorSnapshot(
  supported: true,
  state: DoctorExamState.complete,
  health: DoctorHealth.broken,
  causeCode: cause,
  layer: layer,
);

const _text = DoctorAnswerText(
  unsupportedHeadline: 'unsupportedHeadline',
  unsupportedMeaning: 'unsupportedMeaning',
  examiningHeadline: 'examiningHeadline',
  examiningMeaning: 'examiningMeaning',
  staleHeadline: 'staleHeadline',
  staleMeaning: 'staleMeaning',
  idleHeadline: 'idleHeadline',
  idleMeaning: 'idleMeaning',
  healthyHeadline: 'healthyHeadline',
  healthyMeaning: 'healthyMeaning',
  reachableHeadline: 'reachableHeadline',
  reachableMeaning: 'reachableMeaning',
  inconclusiveHeadline: 'inconclusiveHeadline',
  inconclusiveMeaning: 'inconclusiveMeaning',
  supersededHeadline: 'supersededHeadline',
  supersededMeaning: 'supersededMeaning',
  cancelledHeadline: 'cancelledHeadline',
  cancelledMeaning: 'cancelledMeaning',
  vpnInactiveHeadline: 'vpnInactiveHeadline',
  vpnInactiveMeaning: 'vpnInactiveMeaning',
  noNetworkHeadline: 'noNetworkHeadline',
  noNetworkMeaning: 'noNetworkMeaning',
  portalHeadline: 'portalHeadline',
  portalMeaning: 'portalMeaning',
  unvalidatedHeadline: 'unvalidatedHeadline',
  unvalidatedMeaning: 'unvalidatedMeaning',
  byeDpiFailedHeadline: 'byeDpiFailedHeadline',
  byeDpiFailedMeaning: 'byeDpiFailedMeaning',
  noNodeHeadline: 'noNodeHeadline',
  noNodeMeaning: 'noNodeMeaning',
  dnsStaleHeadline: 'dnsStaleHeadline',
  dnsStaleMeaning: 'dnsStaleMeaning',
  dnsFailedHeadline: 'dnsFailedHeadline',
  dnsFailedMeaning: 'dnsFailedMeaning',
  nodeDownHeadline: 'nodeDownHeadline',
  nodeDownMeaning: 'nodeDownMeaning',
  nodeRefusedHeadline: 'nodeRefusedHeadline',
  nodeRefusedMeaning: 'nodeRefusedMeaning',
  slowHeadline: 'slowHeadline',
  slowMeaning: 'slowMeaning',
  routeHeadline: 'routeHeadline',
  routeMeaning: 'routeMeaning',
  ingressHeadline: 'ingressHeadline',
  ingressMeaning: 'ingressMeaning',
  captureHeadline: 'captureHeadline',
  captureMeaning: 'captureMeaning',
  genericHeadline: 'genericHeadline',
  genericMeaning: 'genericMeaning',
  stormHeadline: 'stormHeadline',
  stormMeaning: 'stormMeaning',
  stepStartVpn: 'stepStartVpn',
  stepCheckWifi: 'stepCheckWifi',
  stepSignInPortal: 'stepSignInPortal',
  stepSwitchNetwork: 'stepSwitchNetwork',
  stepRestartByeDpi: 'stepRestartByeDpi',
  stepPickNode: 'stepPickNode',
  stepUpdateSubscription: 'stepUpdateSubscription',
  stepFlushDns: 'stepFlushDns',
  stepChangeDns: 'stepChangeDns',
  stepCheckRules: 'stepCheckRules',
  stepRestartTunnel: 'stepRestartTunnel',
  stepRecheckLater: 'stepRecheckLater',
  stepDeepCheck: 'stepDeepCheck',
  stepUseAppThenRecheck: 'stepUseAppThenRecheck',
);

void main() {
  late Set<String> vocabulary;
  late String healSource;

  setUpAll(() {
    final evidence = _read(_evidence);
    final classes = _errorClasses(_read(_flow));
    healSource = _read(_heal);
    vocabulary = {
      for (final prefix in _dialPrefixes(evidence))
        for (final errorClass in classes)
          prefix + errorClass[0].toUpperCase() + errorClass.substring(1),
      ..._probeCauses(_read(_runtime)),
      for (final codes in _literalCauses.values) ...codes,
    };
    // The core rewrites a DNS-class route failure instead of minting routeDns.
    expect(evidence, contains('fact.Code = "destinationDnsFailed"'));
    vocabulary.remove('routeDns');
  });

  test('every literal cause still exists in the core', () {
    for (final entry in _literalCauses.entries) {
      final source = _read(entry.key);
      for (final cause in entry.value) {
        expect(source, contains('"$cause"'), reason: '$cause in ${entry.key}');
      }
    }
  });

  test('every cause the core can mint gets an answer of its own', () {
    for (final cause in vocabulary) {
      final answer = doctorAnswerOf(_failed(cause, DoctorLayer.unknown), _text);
      expect(
        answer.headline,
        isNot(_text.genericHeadline),
        reason: '$cause falls through to the generic answer',
      );
      expect(answer.remedies, isNotEmpty, reason: '$cause offers no remedy');
    }
  });

  test('no cause in the table is dead against the core', () {
    final table = _read('lib/common/connection_answer.dart');
    final listed = {
      for (final match in RegExp(
        "cause == '(\\w+)'|^\\s*'(\\w+)',?\$",
        multiLine: true,
      ).allMatches(table))
        match.group(1) ?? match.group(2)!,
    };
    final flushCauses = _flushCauses(healSource);
    for (final cause in listed) {
      expect(
        vocabulary.union(flushCauses),
        contains(cause),
        reason: '$cause is answered but the core never mints it',
      );
    }
  });

  test('the flush button is offered for exactly what the core heals', () {
    for (final cause in _flushCauses(healSource)) {
      final answer = doctorAnswerOf(_failed(cause, DoctorLayer.dns), _text);
      expect(answer.headline, _text.dnsStaleHeadline, reason: cause);
      expect(answer.remedies, contains(DoctorRemedy.flushDns), reason: cause);
    }
  });

  test('every blamed layer lands on a stage of the path map', () {
    for (final layer in DoctorLayer.values) {
      final answer = doctorAnswerOf(_failed('', layer), _text);
      expect(_pathStages, contains(answer.blame), reason: layer.name);
      expect(answer.remedies, isNotEmpty, reason: layer.name);
    }
  });

  test('answers follow the priority the screen leads with', () {
    const broken = DoctorSnapshot(
      supported: true,
      state: DoctorExamState.complete,
      health: DoctorHealth.broken,
      causeCode: 'vpnNotActive',
      layer: DoctorLayer.capture,
    );
    expect(
      doctorAnswerOf(broken.copyWith(supported: false), _text).headline,
      _text.unsupportedHeadline,
    );
    expect(
      doctorAnswerOf(
        broken.copyWith(state: DoctorExamState.examining),
        _text,
      ).headline,
      _text.examiningHeadline,
    );
    expect(
      doctorAnswerOf(broken.copyWith(freshUntil: 1), _text).headline,
      _text.staleHeadline,
    );
    expect(doctorAnswerOf(broken, _text).headline, _text.vpnInactiveHeadline);
  });

  test('expired evidence and a cancelled probe never read as a fault', () {
    for (final cause in ['staleEvidence', 'probeCancelled']) {
      final answer = doctorAnswerOf(_failed(cause, DoctorLayer.dns), _text);
      expect(answer.isProblem, isFalse, reason: cause);
      expect(answer.remedies, contains(DoctorRemedy.recheck), reason: cause);
    }
  });

  test('tone follows the health the core reports', () {
    final snapshot = _failed('coreResolverFailed', DoctorLayer.dns);
    expect(doctorAnswerOf(snapshot, _text).tone, DoctorAnswerTone.bad);
    expect(
      doctorAnswerOf(
        snapshot.copyWith(health: DoctorHealth.degraded),
        _text,
      ).tone,
      DoctorAnswerTone.warning,
    );
  });

  test('severity leads the tone when the core reports one', () {
    // A degraded verdict the core still calls critical must read as critical,
    // and health drives the tone only while severity is unknown.
    final degraded = _failed(
      'coreResolverFailed',
      DoctorLayer.dns,
    ).copyWith(health: DoctorHealth.degraded);
    expect(
      doctorAnswerOf(
        degraded.copyWith(severity: DoctorSeverity.critical),
        _text,
      ).tone,
      DoctorAnswerTone.bad,
    );
    expect(
      doctorAnswerOf(
        _failed(
          'coreResolverFailed',
          DoctorLayer.dns,
        ).copyWith(severity: DoctorSeverity.warning),
        _text,
      ).tone,
      DoctorAnswerTone.warning,
    );
  });

  test('confidence is carried through to the answer', () {
    final probable = _failed(
      'coreResolverFailed',
      DoctorLayer.dns,
    ).copyWith(confidence: DoctorConfidence.probable);
    expect(
      doctorAnswerOf(probable, _text).confidence,
      DoctorConfidence.probable,
    );
  });

  test('a wholly failed path reads as one storm, not a first fault', () {
    const storm = DoctorSnapshot(
      supported: true,
      state: DoctorExamState.complete,
      health: DoctorHealth.broken,
      causeCode: 'coreResolverFailed',
      layer: DoctorLayer.dns,
      stages: [
        DoctorStage(id: 'app', state: DoctorStageState.failed),
        DoctorStage(id: 'ingress', state: DoctorStageState.consequence),
        DoctorStage(id: 'route', state: DoctorStageState.consequence),
        DoctorStage(id: 'internet', state: DoctorStageState.consequence),
        DoctorStage(id: 'response', state: DoctorStageState.consequence),
      ],
    );
    final answer = doctorAnswerOf(storm, _text);
    expect(answer.storm, isTrue);
    expect(answer.headline, _text.stormHeadline);
    expect(answer.tone, DoctorAnswerTone.bad);
  });

  test('a healthy run without ingress proof only claims reachability', () {
    const healthy = DoctorSnapshot(
      supported: true,
      state: DoctorExamState.complete,
      health: DoctorHealth.healthy,
      captureState: DoctorCaptureState.notApplicable,
    );
    expect(doctorAnswerOf(healthy, _text).headline, _text.reachableHeadline);
    expect(
      doctorAnswerOf(
        healthy.copyWith(
          stages: const [
            DoctorStage(id: 'ingress', state: DoctorStageState.passed),
          ],
        ),
        _text,
      ).headline,
      _text.healthyHeadline,
    );
  });

  test('every remedy is reachable from some answer', () {
    final offered = <DoctorRemedy>{};
    for (final cause in {...vocabulary, 'unknownToTheApp'}) {
      for (final layer in DoctorLayer.values) {
        offered.addAll(doctorAnswerOf(_failed(cause, layer), _text).remedies);
      }
    }
    for (final state in DoctorExamState.values) {
      offered.addAll(
        doctorAnswerOf(
          DoctorSnapshot(supported: true, state: state),
          _text,
        ).remedies,
      );
    }
    expect(offered, DoctorRemedy.values.toSet());
  });
}

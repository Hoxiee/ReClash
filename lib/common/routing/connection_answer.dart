import 'package:reclash/common/milestones/finding_events.dart';
import 'package:reclash/models/models.dart';

/// A remedy the Doctor screen can actually carry out or navigate to. Advice the
/// app cannot act on stays plain text in [DoctorAnswer.steps] instead, so every
/// button on the screen leads somewhere.
enum DoctorRemedy {
  startVpn,
  recheck,
  deepCheck,
  flushDns,
  pickNode,
  openDns,
  openProfiles,
  openAdvanced,
  exportReport,
}

enum DoctorAnswerTone { neutral, working, good, warning, bad }

class DoctorAnswer {
  const DoctorAnswer({
    required this.tone,
    required this.headline,
    required this.meaning,
    this.steps = const [],
    this.remedies = const [],
    this.blame,
    this.confidence = DoctorConfidence.unknown,
    this.scope = DoctorScope.unknown,
    this.storm = false,
  });

  final DoctorAnswerTone tone;
  final String headline;

  /// One sentence in the user's own terms. Never a layer name, never a code.
  final String meaning;

  /// What to try, most likely first. Plain imperative sentences.
  final List<String> steps;

  /// Buttons offered under [steps], most useful first.
  final List<DoctorRemedy> remedies;

  /// Path stage id the fault sits on, for captioning the path map.
  final String? blame;

  final DoctorConfidence confidence;
  final DoctorScope scope;

  /// Every path stage failed at once; the screen gates its start button on this.
  final bool storm;

  bool get isProblem =>
      tone == DoctorAnswerTone.bad || tone == DoctorAnswerTone.warning;
}

/// Cause codes that mean "the node answered nothing", whatever the transport
/// error underneath was. The core mints these as prefix + error class from
/// `flowErrorClass` in `core/mihomo/tunnel/evidence.go`.
const _nodeUnreachableCauses = {
  'outerDialTimeout',
  'outerDialRefused',
  'outerDialReset',
  'outerDialUnreachable',
  'outerDialCancelled',
  'outerDialOther',
};

const _dnsStaleCauses = {
  'coreResolverStale',
  'dnsCacheStale',
  'destinationDnsStale',
};

const _dnsFailedCauses = {
  'coreResolverFailed',
  'destinationDnsFailed',
  'systemResolverFailed',
  'preHandleDns',
  'outerDialDns',
};

const _routeCauses = {
  'routeOther',
  'routeTimeout',
  'routeCancelled',
  'routeRefused',
  'routeReset',
  'routeUnreachable',
};

const _ingressCauses = {
  'preHandleOther',
  'preHandleTimeout',
  'preHandleCancelled',
  'preHandleRefused',
  'preHandleReset',
  'preHandleUnreachable',
};

const _probeRejectedCauses = {'probeStatusMismatch', 'applicationProbeFailed'};

String _stageForLayer(DoctorLayer layer) => switch (layer) {
  DoctorLayer.capture => 'app',
  DoctorLayer.ingress => 'ingress',
  DoctorLayer.dns || DoctorLayer.route => 'route',
  DoctorLayer.dial => 'internet',
  DoctorLayer.transport || DoctorLayer.marker => 'response',
  DoctorLayer.unknown => 'response',
};

/// Turns a snapshot into the one answer the screen leads with. Pure so the
/// whole cause-code table is testable without a widget tree.
DoctorAnswer doctorAnswerOf(DoctorSnapshot snapshot, DoctorAnswerText text) {
  if (!snapshot.supported) {
    return DoctorAnswer(
      tone: DoctorAnswerTone.neutral,
      headline: text.unsupportedHeadline,
      meaning: text.unsupportedMeaning,
    );
  }
  if (snapshot.state == DoctorExamState.examining) {
    return DoctorAnswer(
      tone: DoctorAnswerTone.working,
      headline: text.examiningHeadline,
      meaning: text.examiningMeaning,
    );
  }
  if (!snapshot.isFresh) {
    return DoctorAnswer(
      tone: DoctorAnswerTone.neutral,
      headline: text.staleHeadline,
      meaning: text.staleMeaning,
      remedies: const [DoctorRemedy.recheck],
    );
  }

  final cause = snapshot.causeCode;
  // Expiring evidence zeroes `freshUntil`, so the staleness check above reads
  // the snapshot as fresh and only the cause code still carries the age.
  if (cause == 'staleEvidence') {
    return DoctorAnswer(
      tone: DoctorAnswerTone.neutral,
      headline: text.staleHeadline,
      meaning: text.staleMeaning,
      remedies: const [DoctorRemedy.recheck],
    );
  }
  // The core files a cancelled probe as a failure, but it is the exam stopping
  // rather than the connection breaking, so it must not read as a fault.
  if (cause == 'probeCancelled') {
    return DoctorAnswer(
      tone: DoctorAnswerTone.neutral,
      headline: text.cancelledHeadline,
      meaning: text.cancelledMeaning,
      remedies: const [DoctorRemedy.recheck],
    );
  }
  if (allDoctorLayersFailed(snapshot)) {
    return DoctorAnswer(
      tone: DoctorAnswerTone.bad,
      headline: text.stormHeadline,
      meaning: text.stormMeaning,
      steps: [text.stepSwitchNetwork],
      confidence: snapshot.confidence,
      scope: snapshot.scope,
      storm: true,
    );
  }
  if (snapshot.health == DoctorHealth.broken ||
      snapshot.health == DoctorHealth.degraded) {
    return _problemAnswer(snapshot, text, cause);
  }

  return switch (snapshot.state) {
    DoctorExamState.complete when snapshot.health == DoctorHealth.healthy =>
      _healthyAnswer(snapshot, text),
    DoctorExamState.inconclusive => DoctorAnswer(
      tone: DoctorAnswerTone.neutral,
      headline: text.inconclusiveHeadline,
      meaning: text.inconclusiveMeaning,
      steps: [text.stepDeepCheck, text.stepUseAppThenRecheck],
      remedies: const [DoctorRemedy.deepCheck, DoctorRemedy.recheck],
    ),
    DoctorExamState.superseded => DoctorAnswer(
      tone: DoctorAnswerTone.neutral,
      headline: text.supersededHeadline,
      meaning: text.supersededMeaning,
      remedies: const [DoctorRemedy.recheck],
    ),
    DoctorExamState.cancelled => DoctorAnswer(
      tone: DoctorAnswerTone.neutral,
      headline: text.cancelledHeadline,
      meaning: text.cancelledMeaning,
      remedies: const [DoctorRemedy.recheck],
    ),
    _ => DoctorAnswer(
      tone: DoctorAnswerTone.neutral,
      headline: text.idleHeadline,
      meaning: text.idleMeaning,
      remedies: const [DoctorRemedy.recheck],
    ),
  };
}

DoctorAnswer _healthyAnswer(DoctorSnapshot snapshot, DoctorAnswerText text) {
  final provedIngress = snapshot.stages.any(
    (stage) => stage.id == 'ingress' && stage.state == DoctorStageState.passed,
  );
  if (!provedIngress &&
      snapshot.captureState == DoctorCaptureState.notApplicable) {
    return DoctorAnswer(
      tone: DoctorAnswerTone.good,
      headline: text.reachableHeadline,
      meaning: text.reachableMeaning,
      confidence: snapshot.confidence,
      scope: snapshot.scope,
    );
  }
  return DoctorAnswer(
    tone: DoctorAnswerTone.good,
    headline: text.healthyHeadline,
    meaning: text.healthyMeaning,
    confidence: snapshot.confidence,
    scope: snapshot.scope,
  );
}

/// Severity leads; health is the fallback while it is `unknown` (identical today).
DoctorAnswerTone _problemTone(DoctorSnapshot snapshot) =>
    switch (snapshot.severity) {
      DoctorSeverity.critical => DoctorAnswerTone.bad,
      DoctorSeverity.warning => DoctorAnswerTone.warning,
      DoctorSeverity.info => DoctorAnswerTone.warning,
      DoctorSeverity.unknown =>
        snapshot.health == DoctorHealth.broken
            ? DoctorAnswerTone.bad
            : DoctorAnswerTone.warning,
    };

DoctorAnswer _problemAnswer(
  DoctorSnapshot snapshot,
  DoctorAnswerText text,
  String cause,
) {
  final tone = _problemTone(snapshot);
  final blame = _stageForLayer(snapshot.layer);

  DoctorAnswer answer(
    String headline,
    String meaning, {
    List<String> steps = const [],
    List<DoctorRemedy> remedies = const [],
  }) => DoctorAnswer(
    tone: tone,
    headline: headline,
    meaning: meaning,
    steps: steps,
    remedies: remedies,
    blame: blame,
    confidence: snapshot.confidence,
    scope: snapshot.scope,
  );

  if (cause == 'tunNotActive') {
    return answer(
      text.captureHeadline,
      text.captureMeaning,
      steps: [text.stepRestartTunnel],
      remedies: const [DoctorRemedy.openAdvanced, DoctorRemedy.recheck],
    );
  }
  if (cause == 'vpnNotActive') {
    return answer(
      text.vpnInactiveHeadline,
      text.vpnInactiveMeaning,
      steps: [text.stepStartVpn],
      remedies: const [DoctorRemedy.startVpn],
    );
  }
  if (cause == 'noPhysicalNetwork') {
    return answer(
      text.noNetworkHeadline,
      text.noNetworkMeaning,
      steps: [text.stepCheckWifi],
      remedies: const [DoctorRemedy.recheck],
    );
  }
  if (cause == 'captivePortal') {
    return answer(
      text.portalHeadline,
      text.portalMeaning,
      steps: [text.stepSignInPortal],
      remedies: const [DoctorRemedy.recheck],
    );
  }
  if (cause == 'networkUnvalidated') {
    return answer(
      text.unvalidatedHeadline,
      text.unvalidatedMeaning,
      steps: [text.stepSwitchNetwork],
      remedies: const [DoctorRemedy.recheck],
    );
  }
  if (cause == 'byeDpiListenerFailed') {
    return answer(
      text.byeDpiFailedHeadline,
      text.byeDpiFailedMeaning,
      steps: [text.stepRestartByeDpi],
      remedies: const [DoctorRemedy.openAdvanced, DoctorRemedy.recheck],
    );
  }
  if (cause == 'noActiveProxy') {
    return answer(
      text.noNodeHeadline,
      text.noNodeMeaning,
      steps: [text.stepPickNode],
      remedies: const [DoctorRemedy.pickNode],
    );
  }
  if (_dnsStaleCauses.contains(cause)) {
    return answer(
      text.dnsStaleHeadline,
      text.dnsStaleMeaning,
      steps: [text.stepFlushDns],
      remedies: const [DoctorRemedy.flushDns, DoctorRemedy.recheck],
    );
  }
  if (_dnsFailedCauses.contains(cause)) {
    return answer(
      text.dnsFailedHeadline,
      text.dnsFailedMeaning,
      steps: [text.stepFlushDns, text.stepChangeDns],
      remedies: const [
        DoctorRemedy.flushDns,
        DoctorRemedy.openDns,
        DoctorRemedy.recheck,
      ],
    );
  }
  if (_nodeUnreachableCauses.contains(cause)) {
    return answer(
      text.nodeDownHeadline,
      text.nodeDownMeaning,
      steps: [text.stepPickNode, text.stepUpdateSubscription],
      remedies: const [DoctorRemedy.pickNode, DoctorRemedy.openProfiles],
    );
  }
  if (_probeRejectedCauses.contains(cause)) {
    return answer(
      text.nodeRefusedHeadline,
      text.nodeRefusedMeaning,
      steps: [text.stepPickNode, text.stepUpdateSubscription],
      remedies: const [DoctorRemedy.pickNode, DoctorRemedy.openProfiles],
    );
  }
  if (cause == 'probeTimeout') {
    return answer(
      text.slowHeadline,
      text.slowMeaning,
      steps: [text.stepPickNode, text.stepRecheckLater],
      remedies: const [DoctorRemedy.pickNode, DoctorRemedy.recheck],
    );
  }
  if (_routeCauses.contains(cause)) {
    return answer(
      text.routeHeadline,
      text.routeMeaning,
      steps: [text.stepCheckRules],
      remedies: const [DoctorRemedy.openProfiles, DoctorRemedy.recheck],
    );
  }
  if (_ingressCauses.contains(cause)) {
    return answer(
      text.ingressHeadline,
      text.ingressMeaning,
      steps: [text.stepRestartTunnel],
      remedies: const [DoctorRemedy.recheck],
    );
  }

  return switch (snapshot.layer) {
    DoctorLayer.capture => answer(
      text.captureHeadline,
      text.captureMeaning,
      steps: [text.stepStartVpn],
      remedies: const [DoctorRemedy.startVpn, DoctorRemedy.recheck],
    ),
    DoctorLayer.dns => answer(
      text.dnsFailedHeadline,
      text.dnsFailedMeaning,
      steps: [text.stepFlushDns, text.stepChangeDns],
      remedies: const [DoctorRemedy.flushDns, DoctorRemedy.openDns],
    ),
    DoctorLayer.route => answer(
      text.routeHeadline,
      text.routeMeaning,
      steps: [text.stepCheckRules],
      remedies: const [DoctorRemedy.openProfiles, DoctorRemedy.recheck],
    ),
    DoctorLayer.dial || DoctorLayer.transport => answer(
      text.nodeDownHeadline,
      text.nodeDownMeaning,
      steps: [text.stepPickNode, text.stepUpdateSubscription],
      remedies: const [DoctorRemedy.pickNode, DoctorRemedy.openProfiles],
    ),
    DoctorLayer.ingress => answer(
      text.ingressHeadline,
      text.ingressMeaning,
      steps: [text.stepRestartTunnel],
      remedies: const [DoctorRemedy.recheck],
    ),
    DoctorLayer.marker || DoctorLayer.unknown => answer(
      text.genericHeadline,
      text.genericMeaning,
      steps: [text.stepPickNode, text.stepDeepCheck],
      remedies: const [
        DoctorRemedy.pickNode,
        DoctorRemedy.deepCheck,
        DoctorRemedy.exportReport,
      ],
    ),
  };
}

/// Every string [doctorAnswerOf] can pick, passed in so the table stays free of
/// `BuildContext` and can be exercised from a plain unit test.
class DoctorAnswerText {
  const DoctorAnswerText({
    required this.unsupportedHeadline,
    required this.unsupportedMeaning,
    required this.examiningHeadline,
    required this.examiningMeaning,
    required this.staleHeadline,
    required this.staleMeaning,
    required this.idleHeadline,
    required this.idleMeaning,
    required this.healthyHeadline,
    required this.healthyMeaning,
    required this.reachableHeadline,
    required this.reachableMeaning,
    required this.inconclusiveHeadline,
    required this.inconclusiveMeaning,
    required this.supersededHeadline,
    required this.supersededMeaning,
    required this.cancelledHeadline,
    required this.cancelledMeaning,
    required this.vpnInactiveHeadline,
    required this.vpnInactiveMeaning,
    required this.noNetworkHeadline,
    required this.noNetworkMeaning,
    required this.portalHeadline,
    required this.portalMeaning,
    required this.unvalidatedHeadline,
    required this.unvalidatedMeaning,
    required this.byeDpiFailedHeadline,
    required this.byeDpiFailedMeaning,
    required this.noNodeHeadline,
    required this.noNodeMeaning,
    required this.dnsStaleHeadline,
    required this.dnsStaleMeaning,
    required this.dnsFailedHeadline,
    required this.dnsFailedMeaning,
    required this.nodeDownHeadline,
    required this.nodeDownMeaning,
    required this.nodeRefusedHeadline,
    required this.nodeRefusedMeaning,
    required this.slowHeadline,
    required this.slowMeaning,
    required this.routeHeadline,
    required this.routeMeaning,
    required this.ingressHeadline,
    required this.ingressMeaning,
    required this.captureHeadline,
    required this.captureMeaning,
    required this.genericHeadline,
    required this.genericMeaning,
    required this.stormHeadline,
    required this.stormMeaning,
    required this.stepStartVpn,
    required this.stepCheckWifi,
    required this.stepSignInPortal,
    required this.stepSwitchNetwork,
    required this.stepRestartByeDpi,
    required this.stepPickNode,
    required this.stepUpdateSubscription,
    required this.stepFlushDns,
    required this.stepChangeDns,
    required this.stepCheckRules,
    required this.stepRestartTunnel,
    required this.stepRecheckLater,
    required this.stepDeepCheck,
    required this.stepUseAppThenRecheck,
  });

  final String unsupportedHeadline;
  final String unsupportedMeaning;
  final String examiningHeadline;
  final String examiningMeaning;
  final String staleHeadline;
  final String staleMeaning;
  final String idleHeadline;
  final String idleMeaning;
  final String healthyHeadline;
  final String healthyMeaning;
  final String reachableHeadline;
  final String reachableMeaning;
  final String inconclusiveHeadline;
  final String inconclusiveMeaning;
  final String supersededHeadline;
  final String supersededMeaning;
  final String cancelledHeadline;
  final String cancelledMeaning;
  final String vpnInactiveHeadline;
  final String vpnInactiveMeaning;
  final String noNetworkHeadline;
  final String noNetworkMeaning;
  final String portalHeadline;
  final String portalMeaning;
  final String unvalidatedHeadline;
  final String unvalidatedMeaning;
  final String byeDpiFailedHeadline;
  final String byeDpiFailedMeaning;
  final String noNodeHeadline;
  final String noNodeMeaning;
  final String dnsStaleHeadline;
  final String dnsStaleMeaning;
  final String dnsFailedHeadline;
  final String dnsFailedMeaning;
  final String nodeDownHeadline;
  final String nodeDownMeaning;
  final String nodeRefusedHeadline;
  final String nodeRefusedMeaning;
  final String slowHeadline;
  final String slowMeaning;
  final String routeHeadline;
  final String routeMeaning;
  final String ingressHeadline;
  final String ingressMeaning;
  final String captureHeadline;
  final String captureMeaning;
  final String genericHeadline;
  final String genericMeaning;
  final String stormHeadline;
  final String stormMeaning;
  final String stepStartVpn;
  final String stepCheckWifi;
  final String stepSignInPortal;
  final String stepSwitchNetwork;
  final String stepRestartByeDpi;
  final String stepPickNode;
  final String stepUpdateSubscription;
  final String stepFlushDns;
  final String stepChangeDns;
  final String stepCheckRules;
  final String stepRestartTunnel;
  final String stepRecheckLater;
  final String stepDeepCheck;
  final String stepUseAppThenRecheck;
}

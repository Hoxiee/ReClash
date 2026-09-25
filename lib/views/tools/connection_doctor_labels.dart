part of 'connection_doctor.dart';

DoctorAnswer connectionDoctorAnswer(
  AppLocalizations localizations,
  DoctorSnapshot snapshot,
) => doctorAnswerOf(snapshot, doctorAnswerText(localizations));

String connectionDoctorTitle(
  AppLocalizations appLocalizations,
  DoctorSnapshot snapshot,
) => connectionDoctorAnswer(appLocalizations, snapshot).headline;

String connectionDoctorDescription(
  AppLocalizations appLocalizations,
  DoctorSnapshot snapshot, {
  int? easterEggRoll,
}) {
  if (!snapshot.supported) return appLocalizations.doctorUnsupportedDesc;
  if (!snapshot.isFresh) return appLocalizations.doctorObservingDesc;
  if (_expectedCaptureInactive(snapshot)) {
    return appLocalizations.doctorVpnInactiveDesc;
  }
  if (_markerOnlyReachable(snapshot)) {
    return appLocalizations.doctorEndpointReachableDesc;
  }
  if (_showsDoctorEasterEgg(snapshot, easterEggRoll)) {
    return appLocalizations.doctorHealthyEasterEgg;
  }
  return switch (snapshot.state) {
    DoctorExamState.examining => appLocalizations.doctorExaminingDesc,
    DoctorExamState.inconclusive => appLocalizations.doctorInconclusiveDesc,
    DoctorExamState.superseded => appLocalizations.doctorSupersededDesc,
    DoctorExamState.cancelled => appLocalizations.doctorCancelledDesc,
    _ => switch (snapshot.health) {
      DoctorHealth.healthy => appLocalizations.doctorHealthyDesc,
      DoctorHealth.degraded => appLocalizations.doctorDegradedDesc,
      DoctorHealth.broken => appLocalizations.doctorBrokenDesc,
      _ => appLocalizations.doctorObservingDesc,
    },
  };
}

bool _showsDoctorEasterEgg(DoctorSnapshot snapshot, int? roll) {
  const requiredStages = {'app', 'ingress', 'route', 'internet', 'response'};
  final passedStages = snapshot.stages
      .where((stage) => stage.state == DoctorStageState.passed)
      .map((stage) => stage.id)
      .toSet();
  return snapshot.isFresh &&
      snapshot.state == DoctorExamState.complete &&
      snapshot.health == DoctorHealth.healthy &&
      snapshot.confidence == DoctorConfidence.confirmed &&
      snapshot.captureState == DoctorCaptureState.active &&
      passedStages.containsAll(requiredStages) &&
      (roll ?? _stableEasterEggRoll(snapshot.examId, 32)) == 0;
}

int _stableEasterEggRoll(String seed, int buckets) {
  if (seed.isEmpty) return -1;
  var hash = 0x811c9dc5;
  for (final unit in seed.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
  }
  return hash % buckets;
}

bool _expectedCaptureInactive(DoctorSnapshot snapshot) =>
    snapshot.causeCode == 'vpnNotActive' &&
    snapshot.layer == DoctorLayer.capture &&
    snapshot.health == DoctorHealth.broken;

bool _markerOnlyReachable(DoctorSnapshot snapshot) {
  final responsePassed = snapshot.stages.any(
    (stage) => stage.id == 'response' && stage.state == DoctorStageState.passed,
  );
  final protectedPathProven = snapshot.stages.any(
    (stage) => stage.id == 'ingress' && stage.state == DoctorStageState.passed,
  );
  final captureNotApplicable =
      snapshot.captureState == DoctorCaptureState.notApplicable;
  return responsePassed && !protectedPathProven && captureNotApplicable;
}

String connectionDoctorLayerLabel(
  AppLocalizations appLocalizations,
  DoctorLayer layer,
) => switch (layer) {
  DoctorLayer.capture => appLocalizations.doctorLayerCapture,
  DoctorLayer.ingress => appLocalizations.doctorLayerIngress,
  DoctorLayer.dns => appLocalizations.doctorLayerDns,
  DoctorLayer.route => appLocalizations.doctorLayerRoute,
  DoctorLayer.dial => appLocalizations.doctorLayerDial,
  DoctorLayer.transport => appLocalizations.doctorLayerTransport,
  DoctorLayer.marker => appLocalizations.doctorLayerMarker,
  DoctorLayer.unknown => appLocalizations.unknown,
};

bool connectionDoctorTakesHero(DoctorSnapshot snapshot) {
  if (!snapshot.supported || !snapshot.isFresh) return false;
  return snapshot.state == DoctorExamState.examining ||
      _expectedCaptureInactive(snapshot) ||
      snapshot.health == DoctorHealth.degraded ||
      snapshot.health == DoctorHealth.broken;
}

String connectionDoctorHeroText(
  AppLocalizations appLocalizations,
  DoctorSnapshot snapshot,
) {
  if (snapshot.state == DoctorExamState.examining) {
    return appLocalizations.doctorHeroExamining(
      snapshot.progress.completed,
      snapshot.progress.total,
    );
  }
  if (_expectedCaptureInactive(snapshot)) {
    return appLocalizations.doctorVpnInactiveTitle;
  }
  return appLocalizations.doctorHeroIssue(
    connectionDoctorLayerLabel(appLocalizations, snapshot.layer),
  );
}

(String, Glyph) _remedyLabel(
  AppLocalizations appLocalizations,
  DoctorRemedy remedy,
) => switch (remedy) {
  DoctorRemedy.startVpn => (
    appLocalizations.doctorRemedyStartVpn,
    AppGlyphs.vpn,
  ),
  DoctorRemedy.recheck => (
    appLocalizations.doctorStandardExam,
    AppGlyphs.refresh,
  ),
  DoctorRemedy.deepCheck => (appLocalizations.doctorDeepExam, AppGlyphs.search),
  DoctorRemedy.flushDns => (appLocalizations.doctorFlushDns, AppGlyphs.sync),
  DoctorRemedy.pickNode => (appLocalizations.changeServer, AppGlyphs.swap),
  DoctorRemedy.openProfiles => (appLocalizations.profiles, AppGlyphs.folder),
  DoctorRemedy.openDns => (appLocalizations.doctorRemedyOpenDns, AppGlyphs.dns),
  DoctorRemedy.openAdvanced => (
    appLocalizations.advancedConfig,
    AppGlyphs.sliders,
  ),
  DoctorRemedy.exportReport => (
    appLocalizations.doctorExportReport,
    AppGlyphs.share,
  ),
};

Color _answerColor(BuildContext context, DoctorAnswerTone tone) {
  final colors = context.colorScheme;
  return switch (tone) {
    DoctorAnswerTone.good => Colors.green.harmonizeWith(colors.primary),
    DoctorAnswerTone.working => colors.primary,
    DoctorAnswerTone.warning => Colors.orange.harmonizeWith(colors.primary),
    DoctorAnswerTone.bad => colors.error,
    DoctorAnswerTone.neutral => colors.onSurfaceVariant,
  };
}

Glyph _answerIcon(DoctorAnswerTone tone) => switch (tone) {
  DoctorAnswerTone.good => AppGlyphs.checkCircle,
  DoctorAnswerTone.working => AppGlyphs.radar,
  DoctorAnswerTone.warning => AppGlyphs.warning,
  DoctorAnswerTone.bad => AppGlyphs.error,
  DoctorAnswerTone.neutral => AppGlyphs.healthMonitor,
};

String _captureStateLabel(
  AppLocalizations appLocalizations,
  DoctorCaptureState state,
) => switch (state) {
  DoctorCaptureState.active => appLocalizations.doctorCaptureActive,
  DoctorCaptureState.inactive => appLocalizations.doctorCaptureInactive,
  DoctorCaptureState.notApplicable =>
    appLocalizations.doctorCaptureNotApplicable,
  DoctorCaptureState.unknown => appLocalizations.unknown,
};

String _scopeLabel(AppLocalizations appLocalizations, DoctorScope scope) =>
    switch (scope) {
      DoctorScope.app => appLocalizations.doctorScopeApp,
      DoctorScope.inbound => appLocalizations.doctorScopeInbound,
      DoctorScope.unknown => appLocalizations.unknown,
    };

String _confidenceLabel(
  AppLocalizations appLocalizations,
  DoctorConfidence confidence,
) => switch (confidence) {
  DoctorConfidence.confirmed => appLocalizations.doctorConfidenceConfirmed,
  DoctorConfidence.probable => appLocalizations.doctorConfidenceProbable,
  DoctorConfidence.insufficient =>
    appLocalizations.doctorConfidenceInsufficient,
  DoctorConfidence.unknown => appLocalizations.unknown,
};

String _outcomeLabel(
  AppLocalizations appLocalizations,
  DoctorEvidenceOutcome outcome,
) => switch (outcome) {
  DoctorEvidenceOutcome.seen => appLocalizations.doctorOutcomeSeen,
  DoctorEvidenceOutcome.succeeded => appLocalizations.doctorOutcomeSucceeded,
  DoctorEvidenceOutcome.failed => appLocalizations.doctorOutcomeFailed,
  DoctorEvidenceOutcome.dropped => appLocalizations.doctorOutcomeDropped,
  DoctorEvidenceOutcome.notApplicable =>
    appLocalizations.doctorOutcomeNotApplicable,
  DoctorEvidenceOutcome.unknown => appLocalizations.unknown,
};

String _evidenceDescription(
  AppLocalizations appLocalizations,
  DoctorEvidence fact,
) {
  final outcome = _outcomeLabel(appLocalizations, fact.outcome);
  final confidence = _confidenceLabel(appLocalizations, fact.confidence);
  final values = <String>[
    '$outcome · $confidence',
    if (fact.code.isNotEmpty) fact.code,
    if (fact.durationBucketMs > 0) '${fact.durationBucketMs} ms',
  ];
  return values.join(' · ');
}

Glyph _evidenceIcon(DoctorEvidenceOutcome outcome) => switch (outcome) {
  DoctorEvidenceOutcome.succeeded => AppGlyphs.checkCircle,
  DoctorEvidenceOutcome.failed => AppGlyphs.error,
  DoctorEvidenceOutcome.dropped => AppGlyphs.removeCircle,
  DoctorEvidenceOutcome.notApplicable => AppGlyphs.block,
  _ => AppGlyphs.radio,
};

String _modeLabel(AppLocalizations appLocalizations, DoctorExamMode mode) =>
    switch (mode) {
      DoctorExamMode.standard => appLocalizations.doctorModeStandard,
      DoctorExamMode.deep => appLocalizations.doctorModeDeep,
      DoctorExamMode.unknown => appLocalizations.unknown,
    };

String _incidentTitle(
  AppLocalizations appLocalizations,
  DoctorIncident incident,
) {
  return switch (incident.state) {
    DoctorExamState.inconclusive => appLocalizations.doctorInconclusiveTitle,
    DoctorExamState.superseded => appLocalizations.doctorSupersededTitle,
    DoctorExamState.cancelled => appLocalizations.doctorCancelledTitle,
    _ => switch (incident.health) {
      DoctorHealth.healthy => appLocalizations.doctorHealthyTitle,
      DoctorHealth.degraded => appLocalizations.doctorDegradedTitle,
      DoctorHealth.broken => appLocalizations.doctorBrokenTitle,
      _ => appLocalizations.doctorObservingTitle,
    },
  };
}

Glyph _incidentIcon(DoctorIncident incident) => switch (incident.health) {
  DoctorHealth.healthy => AppGlyphs.checkCircle,
  DoctorHealth.degraded => AppGlyphs.warning,
  DoctorHealth.broken => AppGlyphs.error,
  _ => AppGlyphs.help,
};

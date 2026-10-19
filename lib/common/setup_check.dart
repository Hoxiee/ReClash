import 'package:flutter/foundation.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/route_state.dart';

enum SetupStep { language, agreement, profile, coverage, checking, result }

enum SetupCoverage { tun, system, local }

enum SetupPhase { core, profile, connection, route }

enum SetupPhaseStatus {
  waiting,
  running,
  confirmed,
  unconfirmed,
  failed,
  skipped,
}

enum SetupVerdict {
  connected,
  partial,
  unconfirmed,
  failed,
  permission,
  local,
  stopped,
  saved,
  safeMode,
  stale,
}

SetupStep resumableSetupStep(int step, {required bool accepted}) {
  if (step <= SetupStep.language.index) return SetupStep.language;
  if (!accepted) return SetupStep.agreement;
  if (step <= SetupStep.profile.index) return SetupStep.profile;
  return SetupStep.coverage;
}

AppSettingProps initializeSetupSettings(
  AppSettingProps settings, {
  required bool installed,
  required bool hasProfiles,
}) {
  if (settings.setupCompleted != null) return settings;
  final legacy =
      installed && (settings.acceptedDisclaimerVersion > 0 || hasProfiles);
  return settings.copyWith(setupCompleted: legacy, setupStep: 0);
}

@immutable
class SetupDraft {
  const SetupDraft({
    this.profileId,
    required this.coverage,
    this.regionCode,
    this.regionChosen = false,
  });

  final int? profileId;
  final SetupCoverage coverage;
  final String? regionCode;
  final bool regionChosen;

  SetupDraft withProfile(int? id) => SetupDraft(
    profileId: id,
    coverage: coverage,
    regionCode: regionCode,
    regionChosen: regionChosen,
  );

  SetupDraft withCoverage(SetupCoverage value) => SetupDraft(
    profileId: profileId,
    coverage: value,
    regionCode: regionCode,
    regionChosen: regionChosen,
  );

  SetupDraft withRegion(String? code) => SetupDraft(
    profileId: profileId,
    coverage: coverage,
    regionCode: code,
    regionChosen: true,
  );
}

@immutable
class SetupPhaseResult {
  const SetupPhaseResult(
    this.phase, {
    this.status = SetupPhaseStatus.waiting,
    this.detail,
  });

  final SetupPhase phase;
  final SetupPhaseStatus status;
  final String? detail;
}

@immutable
class SetupReport {
  const SetupReport({
    required this.verdict,
    this.phases = const [],
    this.delay,
    this.chains = const [],
    this.error,
    this.stamp,
    this.checkedAt,
    this.connectionActive = false,
  });

  final SetupVerdict verdict;
  final List<SetupPhaseResult> phases;
  final int? delay;
  final List<String> chains;
  final String? error;
  final RouteStamp? stamp;
  final DateTime? checkedAt;
  final bool connectionActive;

  bool get confirmed => switch (verdict) {
    SetupVerdict.connected ||
    SetupVerdict.partial ||
    SetupVerdict.local => true,
    _ => false,
  };

  SetupReport asStale() => SetupReport(
    verdict: SetupVerdict.stale,
    phases: phases,
    error: error,
    connectionActive: connectionActive,
  );
}

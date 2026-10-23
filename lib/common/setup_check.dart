import 'package:flutter/foundation.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/route_state.dart';

enum SetupStep {
  language,
  agreement,
  profile,
  coverage,
  region,
  checking,
  result,
}

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
  if (step == SetupStep.coverage.index) return SetupStep.coverage;
  return SetupStep.region;
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
    this.directRoutes = true,
    this.directApps,
  });

  final int? profileId;
  final SetupCoverage coverage;
  final String? regionCode;
  final bool regionChosen;
  final bool directRoutes;

  /// Packages of [regionCode] found on the device, or null before a scan.
  final List<String>? directApps;

  SetupDraft _copy({
    int? Function()? profileId,
    SetupCoverage? coverage,
    String? Function()? regionCode,
    bool? regionChosen,
    bool? directRoutes,
    List<String>? Function()? directApps,
  }) => SetupDraft(
    profileId: profileId != null ? profileId() : this.profileId,
    coverage: coverage ?? this.coverage,
    regionCode: regionCode != null ? regionCode() : this.regionCode,
    regionChosen: regionChosen ?? this.regionChosen,
    directRoutes: directRoutes ?? this.directRoutes,
    directApps: directApps != null ? directApps() : this.directApps,
  );

  SetupDraft withProfile(int? id) => _copy(profileId: () => id);

  SetupDraft withCoverage(SetupCoverage value) => _copy(coverage: value);

  SetupDraft withRegion(String? code) => _copy(
    regionCode: () => code,
    regionChosen: true,
    directApps: code == regionCode ? null : () => null,
  );

  SetupDraft withDirectRoutes(bool value) => _copy(directRoutes: value);

  SetupDraft withDirectApps(List<String>? packages) =>
      _copy(directApps: () => packages);
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

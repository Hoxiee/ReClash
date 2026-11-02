import 'package:flutter/foundation.dart';
import 'package:reclash/models/models.dart';

enum SetupStep { language, agreement, profile, coverage, region, summary }

enum SetupCoverage { tun, system, local }

SetupStep resumableSetupStep(int step, {required bool accepted}) {
  if (step <= SetupStep.language.index) return SetupStep.language;
  if (!accepted) return SetupStep.agreement;
  if (step <= SetupStep.profile.index) return SetupStep.profile;
  if (step == SetupStep.coverage.index) return SetupStep.coverage;
  if (step == SetupStep.region.index) return SetupStep.region;
  return SetupStep.summary;
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

  /// Packages of [regionCode] the user chose to let bypass the VPN, or null
  /// until they look for them.
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

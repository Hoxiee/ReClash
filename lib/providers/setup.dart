import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

import 'providers.dart';

final setupSessionProvider = NotifierProvider<SetupSession, SetupSessionState>(
  SetupSession.new,
);

@immutable
class SetupSessionState {
  const SetupSessionState({
    required this.active,
    required this.step,
    required this.draft,
    this.busy = false,
    this.scanningApps = false,
    this.error,
    this.saveError = false,
    this.pendingLink,
  });

  final bool active;
  final SetupStep step;
  final SetupDraft draft;
  final bool busy;
  final bool scanningApps;
  final String? error;
  final bool saveError;
  final String? pendingLink;

  SetupSessionState copyWith({
    bool? active,
    SetupStep? step,
    SetupDraft? draft,
    bool? busy,
    bool? scanningApps,
    String? error,
    bool? saveError,
    String? pendingLink,
    bool clearError = false,
    bool clearLink = false,
  }) => SetupSessionState(
    active: active ?? this.active,
    step: step ?? this.step,
    draft: draft ?? this.draft,
    busy: busy ?? this.busy,
    scanningApps: scanningApps ?? this.scanningApps,
    error: clearError ? null : error ?? this.error,
    saveError: saveError ?? this.saveError,
    pendingLink: clearLink ? null : pendingLink ?? this.pendingLink,
  );
}

AccessControlProps _bypassing(AccessControlProps props, List<String> apps) {
  if (props.enable && props.mode == AccessControlMode.acceptSelected) {
    final bypassed = apps.toSet();
    return props.copyWith(
      acceptList: [
        for (final app in props.acceptList)
          if (!bypassed.contains(app)) app,
      ],
    );
  }
  return props.copyWith(
    enable: true,
    mode: AccessControlMode.rejectSelected,
    rejectList: ({...props.rejectList, ...apps}.toList()..sort()),
  );
}

SetupDraft _draftOf(
  AppSettingProps settings, {
  required int? profileId,
  required SetupCoverage coverage,
}) => SetupDraft(
  profileId: settings.setupProfileId ?? profileId,
  coverage:
      SetupCoverage.values
          .where((value) => value.name == settings.setupCoverage)
          .firstOrNull ??
      coverage,
  regionCode: settings.setupRegionChosen
      ? sanitizeRegionCode(settings.setupRegionCode)
      : settings.regionCode,
  regionChosen: settings.setupRegionChosen || settings.regionCode != null,
  directRoutes: settings.setupDirectRoutes,
);

class SetupSession extends Notifier<SetupSessionState> {
  Future<void>? _scan;
  Future<bool> _saveTail = Future.value(true);
  bool _followsRegion = false;

  @override
  SetupSessionState build() {
    final settings = ref.read(appSettingProvider);
    _followsRegion = false;
    return SetupSessionState(
      active: settings.setupCompleted != true,
      step: resumableSetupStep(
        settings.setupStep,
        accepted: settings.acceptedDisclaimerVersion >= disclaimerVersion,
      ),
      draft: _draftOf(
        settings,
        profileId: ref.read(currentProfileIdProvider),
        coverage: currentCoverage,
      ),
    );
  }

  /// Detecting the region waits on device signals, so only a wizard that is
  /// shown asks for it.
  void followDetectedRegion() {
    if (!_followsRegion) {
      _followsRegion = true;
      ref.listen(detectedRegionProvider, (_, next) {
        if (next.hasValue && state.active) {
          state = state.copyWith(draft: _withDetectedRegion(state.draft));
        }
      });
    }
    if (state.active) {
      state = state.copyWith(draft: _withDetectedRegion(state.draft));
    }
  }

  /// Preselects the detected region until the user picks one, a neutral
  /// choice included.
  SetupDraft _withDetectedRegion(SetupDraft draft) {
    if (draft.regionChosen) return draft;
    final code = sanitizeRegionCode(
      ref.read(detectedRegionProvider).value?.countryCode,
    );
    return code == null ? draft : draft.withRegion(code);
  }

  SetupCoverage get currentCoverage => isAndroid
      ? ref.read(vpnSettingProvider).enable
            ? SetupCoverage.tun
            : SetupCoverage.local
      : ref.read(patchClashConfigProvider).tun.enable
      ? SetupCoverage.tun
      : ref.read(networkSettingProvider).systemProxy
      ? SetupCoverage.system
      : SetupCoverage.local;

  @protected
  bool get isAndroid => system.isAndroid;

  bool get _accepted =>
      ref.read(appSettingProvider).acceptedDisclaimerVersion >=
      disclaimerVersion;

  @protected
  Future<bool> saveConfig(Config config) => preferences.saveConfig(config);

  Future<bool> _save() {
    final save = _saveTail.then((_) async {
      if (!ref.mounted) return false;
      try {
        return await saveConfig(ref.read(configProvider));
      } catch (_) {
        return false;
      }
    });
    _saveTail = save;
    return save;
  }

  Future<bool> persist() async {
    final draft = state.draft;
    ref
        .read(appSettingProvider.notifier)
        .update(
          (settings) => settings.copyWith(
            setupStep: state.step.index,
            setupProfileId: draft.profileId,
            setupCoverage: draft.coverage.name,
            setupRegionCode: draft.regionCode,
            setupRegionChosen: draft.regionChosen,
            setupDirectRoutes: draft.directRoutes,
          ),
        );
    final saved = await _save();
    if (ref.mounted) state = state.copyWith(saveError: !saved);
    return saved;
  }

  Future<bool> next(SetupStep step) async {
    if (state.busy) return false;
    if (step.index > SetupStep.agreement.index && !_accepted) return false;
    final previous = state.step;
    state = state.copyWith(step: step, clearError: true);
    if (await persist()) return true;
    if (ref.mounted) state = state.copyWith(step: previous);
    return false;
  }

  Future<bool> selectLanguage(String? locale) async {
    ref
        .read(appSettingProvider.notifier)
        .update((settings) => settings.copyWith(locale: locale));
    return persist();
  }

  Future<bool> acceptAgreement() async {
    ref
        .read(appSettingProvider.notifier)
        .update(
          (settings) =>
              settings.copyWith(acceptedDisclaimerVersion: disclaimerVersion),
        );
    return next(SetupStep.profile);
  }

  void _edit(SetupDraft draft) {
    state = state.copyWith(draft: draft, clearError: true);
    unawaited(persist());
  }

  void selectProfile(int? id) => _edit(state.draft.withProfile(id));

  void selectCoverage(SetupCoverage value) =>
      _edit(state.draft.withCoverage(value));

  void selectRegion(String? code) =>
      _edit(state.draft.withRegion(sanitizeRegionCode(code)));

  void selectDirectRoutes(bool value) =>
      _edit(state.draft.withDirectRoutes(value));

  /// Whether the draft lets the region's local apps bypass the VPN.
  bool get offersDirectApps {
    final draft = state.draft;
    return isAndroid &&
        draft.coverage == SetupCoverage.tun &&
        draft.regionChosen &&
        draft.directRoutes &&
        directRulesForCode(draft.regionCode).isNotEmpty;
  }

  /// The region's installed packages, or null when the user refused the
  /// installed-apps permission.
  @protected
  Future<List<String>?> domesticPackages(String regionCode) async {
    final system = ref.read(systemActionProvider.notifier);
    if (!await system.isInstalledAppsPermissionGranted() &&
        !await system.requestInstalledAppsPermission()) {
      return null;
    }
    final packages = await system.getDomesticPackageNames(regionCode);
    try {
      await system.getPackages();
    } catch (_) {}
    return packages;
  }

  Future<void> findDirectApps() {
    if (!offersDirectApps) return Future.value();
    return _scan ??= _findDirectApps().whenComplete(() => _scan = null);
  }

  Future<void> _findDirectApps() async {
    final regionCode = state.draft.regionCode!;
    state = state.copyWith(scanningApps: true, clearError: true);
    try {
      final packages = await domesticPackages(regionCode);
      if (ref.mounted &&
          packages != null &&
          state.draft.regionCode == regionCode) {
        state = state.copyWith(
          draft: state.draft.withDirectApps(List.unmodifiable(packages)),
        );
      }
    } catch (error) {
      if (ref.mounted) showError(error);
    } finally {
      if (ref.mounted) state = state.copyWith(scanningApps: false);
    }
  }

  void clearDirectApps() =>
      state = state.copyWith(draft: state.draft.withDirectApps(null));

  void setDirectApp(String package, {required bool bypass}) {
    final apps = state.draft.directApps;
    if (apps == null || apps.contains(package) == bypass) return;
    state = state.copyWith(
      draft: state.draft.withDirectApps(
        List.unmodifiable(
          bypass ? [...apps, package] : apps.where((app) => app != package),
        ),
      ),
    );
  }

  /// Puts the region's direct rules above the global rules, skipping those
  /// already present so a repeated setup does not stack copies.
  @protected
  Future<void> addDirectRules(List<String> rawRules) async {
    final existing = await database.rulesDao.queryGlobalRules().get();
    final present = {for (final rule in existing) rule.rawValue};
    final missing = [
      for (final raw in rawRules)
        if (Rule.parse(raw) case final rule
            when !present.contains(rule.rawValue))
          rule,
    ];
    if (missing.isEmpty) return;
    final orders = indexing.generateNKeysBetween(
      null,
      existing.firstOrNull?.order,
      missing.length,
    );
    await database.transaction(() async {
      for (final (index, rule) in missing.indexed) {
        await database.rulesDao.putRule(rule.copyWith(order: orders[index]));
      }
    });
  }

  void offerLink(String link) => state = state.copyWith(pendingLink: link);
  void consumeLink() => state = state.copyWith(clearLink: true);

  /// Whether external links must wait: the wizard is open or the agreement
  /// has not been accepted.
  bool get holdsLinks => state.active || !_accepted;

  /// Hands over the held link once nothing holds it back any more.
  String? takeHeldLink() {
    final link = state.pendingLink;
    if (link == null || holdsLinks) return null;
    consumeLink();
    return link;
  }

  void showError(Object error) =>
      state = state.copyWith(error: compactError(error));

  Future<bool> prepareCore() async {
    if (!_accepted) return false;
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      final started = await ref
          .read(coreActionProvider.notifier)
          .startCore(silence: true, allowPrompt: true);
      if (!started) {
        throw MessageException(currentAppLocalizations.setupUnknownError);
      }
    }
    return true;
  }

  Future<bool> _commitDraft() async {
    final draft = state.draft;
    if (draft.profileId != null &&
        ref.read(profilesProvider).getProfile(draft.profileId!) == null) {
      throw MessageException(currentAppLocalizations.nullProfileDesc);
    }
    final directRules = draft.regionChosen && draft.directRoutes
        ? directRulesForCode(draft.regionCode)
        : const <String>[];
    if (directRules.isNotEmpty) await addDirectRules(directRules);
    if (!ref.mounted) return false;
    final directApps = offersDirectApps
        ? draft.directApps ?? const <String>[]
        : const <String>[];
    ref.read(currentProfileIdProvider.notifier).value = draft.profileId;
    if (draft.regionChosen &&
        draft.regionCode != ref.read(appSettingProvider).regionCode) {
      ref.read(systemActionProvider.notifier).applyRegion(draft.regionCode);
    }
    if (isAndroid) {
      ref
          .read(vpnSettingProvider.notifier)
          .update(
            (settings) => settings.copyWith(
              enable: draft.coverage == SetupCoverage.tun,
              accessControlProps: directApps.isEmpty
                  ? settings.accessControlProps
                  : _bypassing(settings.accessControlProps, directApps),
            ),
          );
    } else {
      ref
          .read(patchClashConfigProvider.notifier)
          .update(
            (config) => config.copyWith.tun(
              enable: draft.coverage == SetupCoverage.tun,
            ),
          );
      ref
          .read(networkSettingProvider.notifier)
          .update(
            (settings) => settings.copyWith(
              systemProxy: draft.coverage == SetupCoverage.system,
            ),
          );
    }
    return persist();
  }

  /// Turns the connection on the way the dashboard's power button does, so
  /// its prompts and failures surface in the app the wizard hands over to.
  @protected
  Future<void> startConnection() =>
      ref.read(commonActionProvider.notifier).setRunning(true);

  @protected
  Future<bool> applyProfile() => ref
      .read(setupActionProvider.notifier)
      .applyProfile(force: true, silence: true, suppressErrors: true);

  /// Marks setup complete; a failed save rolls the flag back so the wizard
  /// reappears on the next launch.
  Future<bool> _complete({bool? autoRun}) async {
    final previous = ref.read(appSettingProvider);
    ref
        .read(appSettingProvider.notifier)
        .update(
          (settings) => settings.copyWith(
            setupCompleted: true,
            setupStep: state.step.index,
            autoRun: autoRun ?? settings.autoRun,
          ),
        );
    final saved = await _save();
    if (!ref.mounted) return false;
    if (!saved) {
      ref
          .read(appSettingProvider.notifier)
          .update(
            (settings) => settings.copyWith(
              setupCompleted: previous.setupCompleted,
              autoRun: previous.autoRun,
            ),
          );
      state = state.copyWith(saveError: true);
      return false;
    }
    state = state.copyWith(active: false, saveError: false);
    return true;
  }

  Future<bool> _busy(Future<bool> Function() action) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, clearError: true);
    try {
      return await action();
    } catch (error) {
      if (ref.mounted) showError(error);
      return false;
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  /// Applies the draft and leaves the wizard, starting the connection when
  /// [connect] asks for it and a profile is there to run.
  Future<bool> finish({required bool connect, required bool autoRun}) {
    if (state.step != SetupStep.summary) return Future.value(false);
    return _busy(() async {
      await _scan;
      if (!ref.mounted || !await _commitDraft() || !ref.mounted) return false;
      final draft = state.draft;
      final runnable = draft.profileId != null && !ref.read(safeModeProvider);
      if (!await _complete(autoRun: runnable && autoRun)) return false;
      if (!runnable) return true;
      if (ref.read(isStartProvider)) {
        unawaited(applyProfile());
      } else if (connect) {
        // Choosing TUN coverage here is the consent the app's TUN setup prompt
        // would otherwise ask for, so the wizard may install its Helper.
        if (!isAndroid && draft.coverage == SetupCoverage.tun) {
          ref.read(coreHandlerProvider).allowPrivilegeInstall();
        }
        unawaited(startConnection());
      }
      return true;
    });
  }

  /// Leaves the wizard keeping the current settings, apart from a profile
  /// the user picked or imported along the way.
  Future<bool> skip() {
    if (!_accepted) return Future.value(false);
    return _busy(() async {
      final profileId = state.draft.profileId;
      if (profileId != null &&
          ref.read(profilesProvider).getProfile(profileId) != null) {
        ref.read(currentProfileIdProvider.notifier).value = profileId;
      }
      return _complete();
    });
  }

  Future<bool> reopen() async {
    if (state.active || state.busy) return false;
    final settings = ref.read(appSettingProvider);
    ref
        .read(appSettingProvider.notifier)
        .update((value) => value.copyWith(setupCompleted: false));
    state = SetupSessionState(
      active: true,
      step: settings.acceptedDisclaimerVersion >= disclaimerVersion
          ? SetupStep.profile
          : SetupStep.language,
      draft: _withDetectedRegion(
        _draftOf(
          settings,
          profileId: ref.read(currentProfileIdProvider),
          coverage: currentCoverage,
        ),
      ),
    );
    return persist();
  }
}

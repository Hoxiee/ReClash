import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/provider_settings.dart';

import 'action.dart';
import 'config.dart';
import 'state.dart';
import 'wallpaper.dart';

/// Null until the current profile has loaded, so a launch does not read the
/// subscription's settings as withdrawn before the profiles arrive.
final providerHintsProvider = Provider<ProviderHints?>((ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  final profile = ref.watch(currentProfileProvider);
  if (profileId != null && profile == null) return null;
  final metadata = profile?.subscriptionSnapshot?.metadata;
  return metadata == null ? ProviderHints.empty : ProviderHints(metadata);
});

final providerRestrictionsProvider = Provider<Set<ProviderRestriction>>(
  (ref) => ref.watch(
    providerHintsProvider.select(
      (hints) => hints?.restrictions ?? const <ProviderRestriction>{},
    ),
  ),
);

/// The tunnel modes the user may pick; a provider can take Global away.
final availableModesProvider = Provider<List<Mode>>(
  (ref) =>
      ref
          .watch(providerRestrictionsProvider)
          .contains(ProviderRestriction.noGlobal)
      ? [
          for (final mode in Mode.values)
            if (mode != Mode.global) mode,
        ]
      : Mode.values,
);

class DismissedNotices extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    unawaited(
      preferences.getDismissedNotices().then((stored) {
        if (ref.mounted) state = {...stored, ...state};
      }),
    );
    return const {};
  }

  void dismiss(String id) {
    state = {...state, id};
    final kept = state.toList();
    unawaited(
      preferences.saveDismissedNotices(
        kept.skip(kept.length > 20 ? kept.length - 20 : 0).toList(),
      ),
    );
  }
}

final dismissedNoticesProvider =
    NotifierProvider<DismissedNotices, Set<String>>(DismissedNotices.new);

typedef ProviderNoticeCard = ({ProviderAnnouncement announcement, String id});

final providerAnnouncementProvider = Provider<ProviderAnnouncement?>((ref) {
  return ref.watch(
    providerHintsProvider.select((hints) => hints?.announcement),
  );
});

/// The subscription's notice, until the user dismisses that very text.
final providerNoticeProvider = Provider<ProviderNoticeCard?>((ref) {
  final announcement = ref.watch(
    providerHintsProvider.select((hints) => hints?.notice),
  );
  if (announcement == null) return null;
  final id = md5
      .convert(utf8.encode('${announcement.text}\n${announcement.link}'))
      .toString();
  if (ref.watch(dismissedNoticesProvider).contains(id)) return null;
  return (announcement: announcement, id: id);
});

/// The proxy the subscription's named group currently routes through.
final providerServerNodeProvider = Provider<String?>((ref) {
  final group = ref.watch(
    providerHintsProvider.select((hints) => hints?.serverGroup),
  );
  if (group == null) return null;
  final selected = ref.watch(selectedMapProvider);
  final key = selected.keys
      .where((name) => name.toLowerCase() == group.toLowerCase())
      .firstOrNull;
  final node = key == null ? null : selected[key];
  return node == null || node.isEmpty ? null : node;
});

/// A provider can ask an Android device to open no local ports at all.
final providerSecureNetworkProvider = Provider<bool>(
  (ref) =>
      system.isAndroid &&
      ref
          .watch(providerRestrictionsProvider)
          .contains(ProviderRestriction.androidSecure),
);

/// On Android only: elsewhere no app list exists to resolve against.
final providerAppsProvider = FutureProvider<ProviderApps>((ref) async {
  final hints = ref.watch(providerHintsProvider) ?? ProviderHints.empty;
  final excluded = {...hints.excludedApps};
  final domestic = hints.domesticApps;
  if (domestic.enabled) {
    final region = sanitizeRegionCode(
      domestic.region ??
          ref.watch(appSettingProvider.select((state) => state.regionCode)),
    );
    if (region != null && hasProfileForCode(region)) {
      excluded.addAll(
        await ref
            .read(systemActionProvider.notifier)
            .getDomesticPackageNames(region),
      );
    }
  }
  return ProviderApps(excluded: excluded, included: {...hints.includedApps});
});

final _providerBackgroundProvider = FutureProvider<String?>((ref) async {
  final url = ref.watch(
    providerHintsProvider.select((hints) => hints?.background?.url.toString()),
  );
  if (url == null) return null;
  final fileName = '${md5.convert(utf8.encode(url))}.png';
  final store = ref.read(wallpaperStoreProvider);
  if (await store.hasImage(fileName)) return fileName;
  final response = await request.getFileResponseForUrl(url);
  final bytes = response.data;
  return bytes == null ? null : store.importBytes(bytes, fileName);
});

final providerSettingsInputProvider = Provider<ProviderSettingsInput?>((ref) {
  final hints = ref.watch(providerHintsProvider);
  if (hints == null) return null;
  final background = ref.watch(_providerBackgroundProvider);
  if (background.hasError) {
    commonPrint.log(
      'Provider background unavailable: ${background.error}',
      logLevel: LogLevel.warning,
    );
  }
  return ProviderSettingsInput(
    hints,
    backgroundFile: background.asData?.value,
    backgroundPending: background.isLoading,
  );
});

void _write(Ref ref, Config Function(Config config) change) {
  final config = ref.read(configProvider);
  final next = change(config);
  if (next != config) writeConfig(ref, next);
}

/// Keeps the settings a subscription sets in step with the current profile.
final providerSettingsSyncProvider = Provider<void>((ref) {
  ref.listen(availableModesProvider, (_, modes) {
    if (modes.contains(ref.read(patchClashConfigProvider).mode)) return;
    scheduleMicrotask(() {
      if (ref.mounted) {
        ref.read(setupActionProvider.notifier).changeMode(Mode.rule);
      }
    });
  }, fireImmediately: true);
  ref.listen(providerSettingsInputProvider, (_, input) {
    if (input == null) return;
    scheduleMicrotask(() {
      if (ref.mounted) {
        _write(ref, (config) => applyProviderSettings(config, input));
      }
    });
  }, fireImmediately: true);
});

final providerSettingsActionProvider = Provider<ProviderSettingsAction>(
  ProviderSettingsAction.new,
);

class ProviderSettingsAction {
  const ProviderSettingsAction(this._ref);

  final Ref _ref;

  void returnToProvider([Iterable<String>? ids]) {
    final input = _ref.read(providerSettingsInputProvider);
    if (input == null) return;
    _write(_ref, (config) => returnProviderSettings(config, input, ids: ids));
  }
}

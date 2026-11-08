import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/state.dart';
import 'package:reclash/subscriptions/metadata/provider_cards.dart';
import 'package:reclash/subscriptions/metadata/provider_conditions.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';
import 'package:reclash/subscriptions/metadata/provider_config_store.dart';
import 'package:reclash/subscriptions/metadata/provider_policy.dart';
import 'package:reclash/subscriptions/metadata/provider_power_labels.dart';
import 'package:reclash/subscriptions/provider_settings.dart';

import 'action.dart';
import 'config.dart';
import 'state.dart';
import 'wallpaper.dart';

typedef LoadedProviderConfig = ({int profileId, ProviderConfig? config});

/// Rebuilt by the snapshot time, because an update replaces the file before
/// it publishes the new snapshot. A rebuild keeps the previous value, so an
/// update or a locale change never leaves the profile without its file.
final _providerConfigProvider =
    FutureProvider.autoDispose<LoadedProviderConfig?>((ref) async {
      final current = ref.watch(
        currentProfileProvider.select((profile) {
          return profile == null
              ? null
              : (id: profile.id, at: profile.subscriptionSnapshot?.receivedAt);
        }),
      );
      if (current == null) return null;
      final locale =
          ref.watch(appSettingProvider.select((state) => state.locale)) ??
          PlatformDispatcher.instance.locale.toLanguageTag();
      final stored = await readStoredProviderConfig(current.id);
      final parsed = stored == null
          ? null
          : await parseProviderConfigOffThread(
              stored.source,
              locale.replaceAll('_', '-'),
            );
      return (profileId: current.id, config: parsed?.config);
    });

/// Null until the current profile has loaded, so a launch does not read the
/// subscription's settings as withdrawn before the profiles arrive.
final providerHintsProvider = Provider<ProviderHints?>((ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  final profile = ref.watch(currentProfileProvider);
  if (profileId != null && profile == null) return null;
  final snapshot = profile?.subscriptionSnapshot;
  if (profile == null || snapshot == null) return ProviderHints.empty;
  final metadata = snapshot.metadata;
  if (metadata.text('presentation.config') == null) {
    return ProviderHints(metadata);
  }
  final loaded = ref.watch(_providerConfigProvider);
  final held = loaded.value;
  return held?.profileId == profile.id
      ? ProviderHints(metadata, config: held?.config)
      : ProviderHints(metadata, configPending: !loaded.hasError);
});

class ProviderPowerButtonSelection extends Notifier<ProviderPowerButton> {
  ProviderPowerButtonSelection({math.Random? random})
    : _random = random ?? math.Random();

  final math.Random _random;
  int? _profileId;
  List<ProviderPowerShape> _shapes = const [];
  ProviderPowerShape _shape = ProviderPowerShape.cookie;

  @override
  ProviderPowerButton build() {
    final profileId = ref.watch(currentProfileIdProvider);
    final hint =
        ref.watch(providerHintsProvider)?.powerButton ??
        defaultProviderPowerButtonHint;
    if (_profileId != profileId || !listEquals(_shapes, hint.shapes)) {
      _profileId = profileId;
      _shapes = hint.shapes;
      _shape = _shapes.length == 1
          ? _shapes.single
          : _shapes[_random.nextInt(_shapes.length)];
    }
    return (shape: _shape, type: hint.type);
  }
}

final providerPowerButtonProvider =
    NotifierProvider<ProviderPowerButtonSelection, ProviderPowerButton>(
      ProviderPowerButtonSelection.new,
    );

/// One entry per state from the provider's label arrays, held for the app
/// session until the labels change.
class ProviderPowerLabelSelection
    extends Notifier<Map<String, ProviderPowerLabel>> {
  ProviderPowerLabelSelection({math.Random? random})
    : _random = random ?? math.Random();

  final math.Random _random;
  ProviderPowerLabels _labels = const {};
  Map<String, ProviderPowerLabel> _picked = const {};

  @override
  Map<String, ProviderPowerLabel> build() {
    final labels = ref.watch(providerHintsProvider)?.powerLabels ?? const {};
    if (!_sameLabels(labels, _labels)) {
      _labels = labels;
      _picked = {
        for (final MapEntry(:key, :value) in labels.entries)
          key: value.length == 1
              ? value.single
              : value[_random.nextInt(value.length)],
      };
    }
    return _picked;
  }
}

bool _sameLabels(ProviderPowerLabels a, ProviderPowerLabels b) =>
    a.length == b.length &&
    a.entries.every((entry) => listEquals(entry.value, b[entry.key]));

final providerPowerLabelProvider =
    NotifierProvider<
      ProviderPowerLabelSelection,
      Map<String, ProviderPowerLabel>
    >(ProviderPowerLabelSelection.new);

final providerRestrictionsProvider = Provider<Set<ProviderRestriction>>(
  (ref) => ref.watch(
    providerHintsProvider.select(
      (hints) => hints?.restrictions ?? const <ProviderRestriction>{},
    ),
  ),
);

final providerPolicyProvider = Provider<ProviderPolicy?>(
  (ref) => ref.watch(
    currentProfileProvider.select(
      (profile) => profile?.subscriptionSnapshot?.providerPolicy,
    ),
  ),
);

/// Only the Android VPN can exclude apps; elsewhere the tunnel starts without
/// them rather than not at all.
final providerRequiredAppsProvider = Provider<Set<String>>(
  (ref) =>
      system.isAndroid && ref.watch(vpnSettingProvider.select((s) => s.enable))
      ? ref.watch(providerPolicyProvider)?.requiredExcludedApps ?? const {}
      : const {},
);

/// The tunnel modes the user may pick; a provider can take Global away.
final availableModesProvider = Provider<List<Mode>>(
  (ref) =>
      ref
              .watch(providerRestrictionsProvider)
              .contains(ProviderRestriction.noGlobal) ||
          ref.watch(providerPolicyProvider)?.isGlobalRestricted == true
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

typedef ProviderCardsEnvironment = ({
  DateTime Function() now,
  String platform,
  String appVersion,
});

/// What conditions are judged against; tests replace the clock and version.
final providerCardsEnvironmentProvider = Provider<ProviderCardsEnvironment>(
  (ref) => (
    now: DateTime.now,
    platform: system.isAndroid
        ? 'android'
        : system.isWindows
        ? 'windows'
        : system.isMacOS
        ? 'macos'
        : 'linux',
    appVersion: globalState.packageInfo.version,
  ),
);

String _actionKey(ProviderAction? action) => action == null
    ? ''
    : '${action.kind.name}:${action.url ?? action.text ?? action.app?.name}';

String _cardContent(ProviderCard card) => switch (card) {
  ProviderNote() =>
    '${card.level.name}\n${card.text}\n${_actionKey(card.action)}',
  ProviderBanner() =>
    '${card.layout.name}\n${card.title}\n${card.text}\n${card.image}\n'
        '${card.imageDark}\n${card.countdown}\n${card.button?.label}\n'
        '${_actionKey(card.button?.action)}\n${_actionKey(card.action)}',
  ProviderActions() => [
    for (final item in card.items)
      '${item.icon}|${item.label}|${_actionKey(item.action)}',
  ].join('\n'),
};

/// Identifies a card's exact content, so a changed card shows again.
String providerCardDismissId(ProviderCard card) =>
    md5.convert(utf8.encode('${card.id}\n${_cardContent(card)}')).toString();

/// The current profile's cards whose conditions hold now, in file order.
/// One timer re-evaluates at the nearest condition or countdown boundary.
final providerCardsProvider = Provider<List<ProviderCard>>((ref) {
  final cards =
      ref.watch(providerHintsProvider.select((hints) => hints?.cards)) ??
      const <ProviderCard>[];
  if (cards.isEmpty) return const [];
  final env = ref.watch(providerCardsEnvironmentProvider);
  final info = ref.watch(
    currentProfileProvider.select((profile) => profile?.subscriptionInfo),
  );
  final metadata = ref.watch(
    currentProfileProvider.select(
      (profile) => profile?.subscriptionSnapshot?.metadata,
    ),
  );
  final stale = ref.watch(
    currentProfileProvider.select(
      (profile) => profile?.subscriptionSnapshot?.usageStale ?? false,
    ),
  );
  final dismissed = ref.watch(dismissedNoticesProvider);
  final now = env.now();
  final snapshot = ProviderConditionSnapshot(
    now: now,
    platform: env.platform,
    appVersion: env.appVersion,
    expire: metadata?.perpetual == true ? 0 : info?.expire ?? 0,
    total: metadata?.unlimited == true ? 0 : info?.total ?? 0,
    used: info == null ? 0 : info.upload + info.download,
    usageStale: stale,
  );
  final seconds = now.millisecondsSinceEpoch ~/ 1000;
  final timer = nearestFutureBoundary(now, [
    for (final card in cards) ...card.boundaries,
  ]);
  if (timer != null) {
    final handle = Timer(
      timer.difference(now) + const Duration(milliseconds: 50),
      ref.invalidateSelf,
    );
    ref.onDispose(handle.cancel);
  }
  return [
    for (final card in cards)
      if (card.when.holds(snapshot) &&
          !(card is ProviderBanner &&
              card.countdown != null &&
              card.countdown! <= seconds) &&
          !(card.dismissible &&
              dismissed.contains(providerCardDismissId(card))))
        card,
  ];
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
      (ref.watch(providerRequiredAppsProvider).isNotEmpty ||
          ref
              .watch(providerRestrictionsProvider)
              .contains(ProviderRestriction.androidSecure)),
);

PatchClashConfig withoutLocalProxyPorts(PatchClashConfig config) => config
    .copyWith(mixedPort: 0, port: 0, socksPort: 0, redirPort: 0, tproxyPort: 0);

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
  return ProviderApps(
    excluded: excluded,
    included: {...hints.includedApps},
    requiredExcluded: ref.watch(providerRequiredAppsProvider),
  );
});

final _providerBackgroundProvider = FutureProvider<String?>((ref) async {
  final url = ref.watch(
    providerHintsProvider.select((hints) => hints?.background?.url.toString()),
  );
  if (url == null) return null;
  final id = md5.convert(utf8.encode(url));
  final store = ref.read(wallpaperStoreProvider);
  for (final extension in ['png', 'svg']) {
    final fileName = '$id.$extension';
    if (await store.hasImage(fileName)) return fileName;
  }
  final response = await request.getFileResponseForUrl(url);
  final bytes = response.data;
  return bytes == null ? null : store.importBytes(bytes, '$id.png');
});

final providerSettingsInputProvider = Provider<ProviderSettingsInput?>((ref) {
  final hints = ref.watch(providerHintsProvider);
  if (hints == null || hints.configPending) return null;
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

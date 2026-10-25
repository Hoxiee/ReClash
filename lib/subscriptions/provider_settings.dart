import 'package:collection/collection.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/ui/color.dart';

import 'metadata/hints.dart';

class ProviderSettingsInput {
  const ProviderSettingsInput(
    this.hints, {
    this.backgroundFile,
    this.backgroundPending = false,
  });

  final ProviderHints hints;

  /// The stored copy of the provider's background image.
  final String? backgroundFile;

  /// The background is still downloading; its setting is left untouched
  /// rather than read as dropped.
  final bool backgroundPending;
}

/// One app setting a subscription may set, kept as a JSON value.
class ProviderSetting {
  const ProviderSetting(
    this.id, {
    required this.provided,
    required this.read,
    required this.write,
    this.pending,
  });

  final String id;
  final Object? Function(ProviderSettingsInput input) provided;
  final Object? Function(Config config) read;
  final Config Function(Config config, Object? value) write;
  final bool Function(ProviderSettingsInput input)? pending;
}

ProviderSetting _enum<T extends Enum>(
  String id,
  List<T> values,
  T? Function(ProviderView view) pick,
  T Function(Config config) get,
  Config Function(Config config, T value) set,
) => ProviderSetting(
  id,
  provided: (input) => pick(input.hints.view)?.name,
  read: (config) => get(config).name,
  write: (config, value) =>
      switch (values.where((item) => item.name == value).firstOrNull) {
        final item? => set(config, item),
        null => config,
      },
);

ProviderSetting _flag(
  String id,
  bool? Function(ProviderSettingsInput input) provided,
  bool Function(Config config) get,
  Config Function(Config config, bool value) set,
) => ProviderSetting(
  id,
  provided: provided,
  read: get,
  write: (config, value) => value is bool ? set(config, value) : config,
);

Config _proxies(
  Config config,
  ProxiesStyleProps Function(ProxiesStyleProps) f,
) => config.copyWith(proxiesStyleProps: f(config.proxiesStyleProps));

Config _app(Config config, AppSettingProps Function(AppSettingProps) f) =>
    config.copyWith(appSettingProps: f(config.appSettingProps));

Config _theme(Config config, ThemeProps Function(ThemeProps) f) =>
    config.copyWith(themeProps: f(config.themeProps));

ProviderSetting _setting(
  ProviderSettingFlag flag,
  bool Function(AppSettingProps props) get,
  AppSettingProps Function(AppSettingProps props, bool value) set,
) => _flag(
  'settings.${flag.name}',
  (input) => input.hints.settings?[flag],
  (config) => get(config.appSettingProps),
  (config, value) => _app(config, (props) => set(props, value)),
);

final providerSettingsCatalog = <ProviderSetting>[
  _enum(
    'proxies.type',
    ProxiesType.values,
    (view) => view.proxiesType,
    (config) => config.proxiesStyleProps.type,
    (config, value) => _proxies(config, (p) => p.copyWith(type: value)),
  ),
  _enum(
    'proxies.sort',
    ProxiesSortType.values,
    (view) => view.proxiesSort,
    (config) => config.proxiesStyleProps.sortType,
    (config, value) => _proxies(config, (p) => p.copyWith(sortType: value)),
  ),
  _enum(
    'proxies.layout',
    ProxiesLayout.values,
    (view) => view.proxiesLayout,
    (config) => config.proxiesStyleProps.layout,
    (config, value) => _proxies(config, (p) => p.copyWith(layout: value)),
  ),
  _enum(
    'proxies.icon',
    ProxiesIconStyle.values,
    (view) => view.proxiesIcon,
    (config) => config.proxiesStyleProps.iconStyle,
    (config, value) => _proxies(config, (p) => p.copyWith(iconStyle: value)),
  ),
  _enum(
    'proxies.card',
    ProxyCardType.values,
    (view) => view.proxiesCard,
    (config) => config.proxiesStyleProps.cardType,
    (config, value) => _proxies(config, (p) => p.copyWith(cardType: value)),
  ),
  _flag(
    'app.navbar',
    (input) => input.hints.view.floatingNavigationBar,
    (config) => config.appSettingProps.floatingNavigationBar,
    (config, value) =>
        _app(config, (p) => p.copyWith(floatingNavigationBar: value)),
  ),
  _enum(
    'app.tabs',
    TabAnimation.values,
    (view) => view.tabAnimation,
    (config) => config.appSettingProps.tabAnimation,
    (config, value) => _app(config, (p) => p.copyWith(tabAnimation: value)),
  ),
  _enum(
    'app.glass',
    LiquidGlassMode.values,
    (view) => view.liquidGlass,
    (config) => config.themeProps.liquidGlass,
    (config, value) => _theme(config, (p) => p.copyWith(liquidGlass: value)),
  ),
  ProviderSetting(
    'app.color',
    provided: (input) => input.hints.view.primaryColor,
    read: (config) => config.themeProps.primaryColor,
    write: (config, value) => value is int?
        ? _theme(
            config,
            (p) => p.copyWith(
              primaryColor: value,
              primaryColors: value == null || p.primaryColors.contains(value)
                  ? p.primaryColors
                  : [...p.primaryColors, value],
            ),
          )
        : config,
  ),
  _enum(
    'app.style',
    ColorStyle.values,
    (view) => view.colorStyle,
    (config) => config.themeProps.colorStyle,
    (config, value) => _theme(config, (p) => p.copyWith(colorStyle: value)),
  ),
  _flag(
    'app.black',
    (input) => input.hints.view.pureBlack,
    (config) => config.themeProps.pureBlack,
    (config, value) => _theme(config, (p) => p.copyWith(pureBlack: value)),
  ),
  ProviderSetting(
    'widgets',
    provided: (input) => switch (input.hints.widgets) {
      final widgets? => [
        if (!widgets.contains(DashboardWidget.currentOutbound))
          DashboardWidget.currentOutbound.name,
        for (final widget in widgets) widget.name,
      ],
      null => null,
    },
    read: (config) => [
      for (final widget in config.appSettingProps.dashboardWidgets) widget.name,
    ],
    write: (config, value) => value is List
        ? _app(
            config,
            (p) =>
                p.copyWith(dashboardWidgets: dashboardWidgetsFromJson(value)),
          )
        : config,
  ),
  ProviderSetting(
    'simpleWidgets',
    provided: (input) => switch (input.hints.simpleWidgets) {
      final widgets? => [for (final widget in widgets) widget.name],
      null => null,
    },
    read: (config) => [
      for (final widget in config.appSettingProps.simpleDashboardWidgets)
        widget.name,
    ],
    write: (config, value) => value is List
        ? _app(
            config,
            (p) => p.copyWith(
              simpleDashboardWidgets: simpleDashboardWidgetsFromJson(value),
            ),
          )
        : config,
  ),
  ProviderSetting(
    'background',
    pending: (input) => input.backgroundPending,
    provided: (input) =>
        switch ((input.backgroundFile, input.hints.background)) {
          (final file?, final background?) => {
            'enabled': true,
            'fileName': file,
            'opacity': background.opacity,
          },
          _ => null,
        },
    read: (config) {
      final wallpaper = config.themeProps.wallpaper;
      return {
        'enabled': wallpaper.enabled,
        'fileName': wallpaper.fileName,
        'opacity': wallpaper.opacity,
      };
    },
    write: (config, value) => value is Map
        ? _theme(
            config,
            (p) => p.copyWith(
              wallpaper: p.wallpaper.copyWith(
                enabled: value['enabled'] == true,
                fileName: isWallpaperFileName(value['fileName'])
                    ? value['fileName'] as String
                    : null,
                opacity:
                    (value['opacity'] as num?)?.toDouble() ??
                    p.wallpaper.opacity,
              ),
            ),
          )
        : config,
  ),
  _setting(
    ProviderSettingFlag.minimize,
    (p) => p.minimizeOnExit,
    (p, value) => p.copyWith(minimizeOnExit: value),
  ),
  _setting(
    ProviderSettingFlag.autorun,
    (p) => p.autoLaunch,
    (p, value) => p.copyWith(autoLaunch: value),
  ),
  _setting(
    ProviderSettingFlag.shadowstart,
    (p) => p.silentLaunch,
    (p, value) => p.copyWith(silentLaunch: value),
  ),
  _setting(
    ProviderSettingFlag.autostart,
    (p) => p.autoRun,
    (p, value) => p.copyWith(autoRun: value),
  ),
  _setting(
    ProviderSettingFlag.autoupdate,
    (p) => p.autoCheckUpdate,
    (p, value) => p.copyWith(autoCheckUpdate: value),
  ),
  _setting(
    ProviderSettingFlag.openlogs,
    (p) => p.openLogs,
    (p, value) => p.copyWith(openLogs: value),
  ),
  _setting(
    ProviderSettingFlag.closeconnections,
    (p) => p.closeConnections,
    (p, value) => p.copyWith(closeConnections: value),
  ),
];

final _byId = {
  for (final setting in providerSettingsCatalog) setting.id: setting,
};

const _equality = DeepCollectionEquality();

/// A setting the provider set and the user has not changed since. A setting
/// the user changes stops following the provider until handed back.
Config applyProviderSettings(Config config, ProviderSettingsInput input) {
  final state = config.providerSettings;
  final applied = {...state.applied};
  final baseline = {...state.userBaseline};
  final owned = {...state.userOwned};
  var next = config;
  for (final setting in providerSettingsCatalog) {
    if (setting.pending?.call(input) ?? false) continue;
    final id = setting.id;
    final provided = setting.provided(input);
    final current = setting.read(next);
    final tracked = applied.containsKey(id);
    final following = tracked && _equality.equals(current, applied[id]);
    if (provided == null) {
      if (following && baseline.containsKey(id)) {
        next = setting.write(next, baseline[id]);
      }
      applied.remove(id);
      baseline.remove(id);
      continue;
    }
    if (tracked && !following) {
      owned.add(id);
      applied.remove(id);
      baseline.remove(id);
      continue;
    }
    if (owned.contains(id)) continue;
    if (!tracked) baseline[id] = current;
    if (!_equality.equals(current, provided)) {
      next = setting.write(next, provided);
    }
    applied[id] = setting.read(next);
  }
  return next.copyWith(
    providerSettings: ProviderSettingsState(
      applied: applied,
      userBaseline: baseline,
      userOwned: owned,
    ),
  );
}

/// Hands settings back to the provider; with no [ids], every one of them.
Config returnProviderSettings(
  Config config,
  ProviderSettingsInput input, {
  Iterable<String>? ids,
}) {
  final state = config.providerSettings;
  final returned = ids?.toSet();
  return applyProviderSettings(
    config.copyWith(
      providerSettings: state.copyWith(
        userOwned: returned == null
            ? const {}
            : state.userOwned.difference(returned),
      ),
    ),
    input,
  );
}

bool isProviderManaged(Config config, String id) {
  final setting = _byId[id];
  final applied = config.providerSettings.applied;
  return setting != null &&
      applied.containsKey(id) &&
      _equality.equals(setting.read(config), applied[id]);
}

/// The user took the setting from a provider that still sets it.
bool isProviderReleased(Config config, ProviderSettingsInput input, String id) {
  final setting = _byId[id];
  if (setting == null || setting.provided(input) == null) return false;
  final applied = config.providerSettings.applied;
  return config.providerSettings.userOwned.contains(id) ||
      (applied.containsKey(id) &&
          !_equality.equals(setting.read(config), applied[id]));
}

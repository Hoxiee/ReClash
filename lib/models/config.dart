import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'models.dart';

part 'generated/config.freezed.dart';
part 'generated/config.g.dart';

const defaultBypassDomain = [
  '*zhihu.com',
  '*zhimg.com',
  '*jd.com',
  '100ime-iat-api.xfyun.cn',
  '*360buyimg.com',
  'localhost',
  '*.local',
  '127.*',
  '10.*',
  '172.16.*',
  '172.17.*',
  '172.18.*',
  '172.19.*',
  '172.2*',
  '172.30.*',
  '172.31.*',
  '192.168.*',
];

const defaultAppSettingProps = AppSettingProps();
const defaultVpnProps = VpnProps();
const defaultAuthenticationProps = AuthenticationProps();
const defaultNetworkProps = NetworkProps();
const defaultSmartRoutingProps = SmartRoutingProps();
const defaultProxiesStyleProps = ProxiesStyleProps();
const defaultWindowProps = WindowProps();
const defaultAccessControlProps = AccessControlProps();
const defaultThemeProps = ThemeProps(primaryColor: defaultPrimaryColor);

const List<DashboardWidget> defaultDashboardWidgets = [
  DashboardWidget.networkSpeed,
  DashboardWidget.systemProxyButton,
  DashboardWidget.tunButton,
  DashboardWidget.outboundMode,
  DashboardWidget.networkDetection,
  DashboardWidget.trafficUsage,
  DashboardWidget.intranetIp,
];

List<DashboardWidget> dashboardWidgetsSafeFormJson(
  List<dynamic>? dashboardWidgets,
) {
  return decodeOrRestoreDefault(
    'dashboard widgets',
    () =>
        dashboardWidgets
            ?.map((e) => $enumDecode(_$DashboardWidgetEnumMap, e))
            .toList() ??
        defaultDashboardWidgets,
    () => defaultDashboardWidgets,
  );
}

@freezed
abstract class AppSettingProps with _$AppSettingProps {
  const factory AppSettingProps({
    String? locale,
    @Default(defaultDashboardWidgets)
    @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
    List<DashboardWidget> dashboardWidgets,
    @Default(false) bool onlyStatisticsProxy,
    @Default(true) bool showNotificationStopAction,
    @Default(false) bool autoLaunch,
    @Default(false) bool silentLaunch,
    @Default(false) bool autoRun,
    @Default(false) bool openLogs,
    @Default(true) bool closeConnections,
    @Default(true) bool newDashboard,
    @Default(defaultTestUrl) String testUrl,
    @Default(true) bool isAnimateToPage,
    @Default(true) bool autoCheckUpdate,
    @Default(false) bool showLabel,
    @Default(false) bool disclaimerAccepted,
    @Default(false) bool setupCompleted,
    @Default(false) bool crashlyticsTip,
    @Default(false) bool crashlytics,
    @Default(true) bool minimizeOnExit,
    @Default(false) bool hidden,
    @Default(false) bool developerMode,
    @Default(RestoreStrategy.compatible) RestoreStrategy restoreStrategy,
    @Default(true) bool showTrayTitle,
    @Default(true) bool checkCertificate,
    @Default('') String customUserAgent,
    @Default(true) bool sendDeviceIdentity,
    @Default('default') String iconVariant,
    @Default(false) bool reduceMotion,
  }) = _AppSettingProps;

  factory AppSettingProps.fromJson(Map<String, Object?> json) =>
      _$AppSettingPropsFromJson(json);

  factory AppSettingProps.safeFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultAppSettingProps;
    }
    return decodeOrRestoreDefault(
      'app settings',
      () => AppSettingProps.fromJson(json),
      () => defaultAppSettingProps,
    );
  }
}

@freezed
abstract class AccessControlProps with _$AccessControlProps {
  const factory AccessControlProps({
    @Default(false) bool enable,
    @Default(AccessControlMode.rejectSelected) AccessControlMode mode,
    @Default([]) List<String> acceptList,
    @Default([]) List<String> rejectList,
    @Default(AccessSortType.none) AccessSortType sort,
    @Default(true) bool isFilterSystemApp,
    @Default(true) bool isFilterNonInternetApp,
  }) = _AccessControlProps;

  factory AccessControlProps.fromJson(Map<String, Object?> json) =>
      _$AccessControlPropsFromJson(json);
}

extension AccessControlPropsExt on AccessControlProps {
  List<String> get currentList => switch (mode) {
    AccessControlMode.acceptSelected => acceptList,
    AccessControlMode.rejectSelected => rejectList,
  };

  AccessControlProps copyWithNewList(List<String> value) => switch (mode) {
    AccessControlMode.acceptSelected => copyWith(acceptList: value),
    AccessControlMode.rejectSelected => copyWith(rejectList: value),
  };
}

@freezed
abstract class WindowProps with _$WindowProps {
  const factory WindowProps({
    @Default(0) double width,
    @Default(0) double height,
    double? top,
    double? left,
  }) = _WindowProps;

  factory WindowProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const WindowProps() : _$WindowPropsFromJson(json);
}

extension WindowPropsExt on WindowProps {
  Size get _size => Size(width, height);

  Size get size => _size.isEmpty ? const Size(680, 580) : _size;
}

@freezed
abstract class VpnProps with _$VpnProps {
  const factory VpnProps({
    @Default(true) bool enable,
    @Default(true) bool systemProxy,
    @Default(false) bool ipv6,
    @Default(true) bool allowBypass,
    @Default(false) bool dnsHijacking,
    @Default(false) bool smartPauseEnabled,
    @Default([]) List<String> smartPauseNetworks,
    @Default(false) bool smartPauseCloseConnections,
    @Default(defaultAccessControlProps) AccessControlProps accessControlProps,
  }) = _VpnProps;

  factory VpnProps.fromJson(Map<String, Object?>? json) =>
      json == null ? defaultVpnProps : _$VpnPropsFromJson(json);
}

/// Mirrors what the Go engine persists for itself. Dart owns the user's choice
/// and pushes it down; the core keeps a copy so it still runs with the UI dead.
@freezed
abstract class SmartRoutingProps with _$SmartRoutingProps {
  // explicitToJson keeps the toJson map re-parsable in-process: migration
  // re-reads it before any json.encode pass.
  @JsonSerializable(explicitToJson: true)
  const factory SmartRoutingProps({
    @Default(false) bool enabled,
    @Default(SmartRoutingPreset.off) SmartRoutingPreset preset,
    @Default(SmartRoutingStrategy.balanced) SmartRoutingStrategy strategy,
    @Default([]) List<String> censorCountries,
    @Default([]) List<String> canaryForeign,
    @Default([]) List<String> canaryDomestic,
    @Default([]) List<RcxMarker> openMarkers,
    @Default([]) List<RcxMarker> domesticMarkers,
    @Default([]) List<String> breakerPatterns,
    @Default(true) bool allowDomesticLastResort,
    @Default(false) bool requireUdp,
    @Default(true) bool respectPick,
    @Default(90) int dwellSeconds,
    @Default(12) int waveWidth,
  }) = _SmartRoutingProps;

  factory SmartRoutingProps.fromJson(Map<String, Object?>? json) => json == null
      ? defaultSmartRoutingProps
      : _$SmartRoutingPropsFromJson(json);
}

@freezed
abstract class AuthenticationProps with _$AuthenticationProps {
  const factory AuthenticationProps({
    @Default(false) bool enable,
    @Default('') String username,
    @Default('') String password,
  }) = _AuthenticationProps;

  factory AuthenticationProps.fromJson(Map<String, Object?>? json) =>
      json == null
      ? defaultAuthenticationProps
      : _$AuthenticationPropsFromJson(json);
}

extension AuthenticationPropsExt on AuthenticationProps {
  List<String> get credentials =>
      enable && username.isNotEmpty ? ['$username:$password'] : [];
}

@freezed
abstract class NetworkProps with _$NetworkProps {
  const factory NetworkProps({
    @Default(true) bool systemProxy,
    @Default(defaultBypassDomain) List<String> bypassDomain,
    @Default(RouteMode.config) RouteMode routeMode,
    @Default(true) bool autoSetSystemDns,
    @Default(false) bool appendSystemDns,
    @Default(false) bool overrideSubscriptionNetwork,
    @Default(defaultAuthenticationProps) AuthenticationProps authentication,
  }) = _NetworkProps;

  factory NetworkProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const NetworkProps() : _$NetworkPropsFromJson(json);
}

@freezed
abstract class ProxiesStyleProps with _$ProxiesStyleProps {
  const factory ProxiesStyleProps({
    @Default(ProxiesType.tab) ProxiesType type,
    @Default(ProxiesSortType.none) ProxiesSortType sortType,
    @Default(ProxiesLayout.standard) ProxiesLayout layout,
    @Default(ProxiesIconStyle.standard) ProxiesIconStyle iconStyle,
    @Default(ProxyCardType.expand) ProxyCardType cardType,
    @Default(true) bool followPanel,
    @Default(<ProxiesStyleField>{}) Set<ProxiesStyleField> userOwned,
  }) = _ProxiesStyleProps;

  factory ProxiesStyleProps.fromJson(Map<String, Object?>? json) => json == null
      ? defaultProxiesStyleProps
      : _$ProxiesStylePropsFromJson(json);
}

@freezed
abstract class TextScale with _$TextScale {
  const factory TextScale({
    @Default(false) bool enable,
    @Default(1.0) double scale,
  }) = _TextScale;

  factory TextScale.fromJson(Map<String, Object?> json) =>
      _$TextScaleFromJson(json);
}

@freezed
abstract class ThemeProps with _$ThemeProps {
  const factory ThemeProps({
    int? primaryColor,
    @Default(defaultPrimaryColors) List<int> primaryColors,
    @Default(ThemeMode.dark) ThemeMode themeMode,
    @Default(false) bool scheduledTheme,
    String? darkAt,
    String? lightAt,
    @Default(DynamicSchemeVariant.content) DynamicSchemeVariant schemeVariant,
    @Default(false) bool pureBlack,
    @Default(0) double contrastLevel,
    @Default(TextScale()) TextScale textScale,
  }) = _ThemeProps;

  factory ThemeProps.fromJson(Map<String, Object?> json) =>
      _$ThemePropsFromJson(json);

  factory ThemeProps.safeFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultThemeProps;
    }
    return decodeOrRestoreDefault(
      'theme settings',
      () => ThemeProps.fromJson(json),
      () => defaultThemeProps,
    );
  }
}

extension ThemePropsScheduleExt on ThemeProps {
  ThemeMode get effectiveThemeMode => themeModeAt(DateTime.now());

  ThemeMode themeModeAt(DateTime now) {
    final window = _scheduleWindow;
    if (window == null) {
      return themeMode;
    }
    final (dark, light) = window;
    final minutes = now.hour * 60 + now.minute;
    final isDark = dark < light
        ? minutes >= dark && minutes < light
        : minutes >= dark || minutes < light;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Duration? nextScheduleFlip(DateTime now) {
    final window = _scheduleWindow;
    if (window == null) {
      return null;
    }
    final (dark, light) = window;
    final seconds = now.hour * 3600 + now.minute * 60 + now.second;
    Duration until(int boundary) {
      final delta = (boundary * 60 - seconds) % 86400;
      return Duration(seconds: delta == 0 ? 86400 : delta);
    }

    final toDark = until(dark);
    final toLight = until(light);
    return toDark <= toLight ? toDark : toLight;
  }

  (int, int)? get _scheduleWindow {
    if (!scheduledTheme || darkAt == null || lightAt == null) {
      return null;
    }
    final dark = _parseDayMinutes(darkAt!);
    final light = _parseDayMinutes(lightAt!);
    if (dark == null || light == null) {
      return null;
    }
    return (dark, light);
  }
}

int? _parseDayMinutes(String value) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value);
  if (match == null) {
    return null;
  }
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  if (hour > 23 || minute > 59) {
    return null;
  }
  return hour * 60 + minute;
}

@freezed
abstract class Config with _$Config {
  const factory Config({
    int? currentProfileId,
    @Default(false) bool overrideDns,
    @Default([]) List<HotKeyAction> hotKeyActions,
    @JsonKey(fromJson: AppSettingProps.safeFromJson)
    @Default(defaultAppSettingProps)
    AppSettingProps appSettingProps,
    DAVProps? davProps,
    @Default(defaultNetworkProps) NetworkProps networkProps,
    @Default(defaultVpnProps) VpnProps vpnProps,
    @Default(defaultSmartRoutingProps) SmartRoutingProps smartRoutingProps,
    @JsonKey(fromJson: DesyncProps.safeFromJson)
    @Default(defaultDesyncProps)
    DesyncProps desyncProps,
    @JsonKey(fromJson: ThemeProps.safeFromJson) required ThemeProps themeProps,
    @Default(defaultProxiesStyleProps) ProxiesStyleProps proxiesStyleProps,
    @Default(defaultWindowProps) WindowProps windowProps,
    @Default(defaultClashConfig) PatchClashConfig patchClashConfig,
  }) = _Config;

  factory Config.fromJson(Map<String, Object?> json) => _$ConfigFromJson(json);

  factory Config.realFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const Config(themeProps: defaultThemeProps);
    }
    return _$ConfigFromJson(migrateExcludeSSIDs(json));
  }

  static Map<String, Object?> migrateExcludeSSIDs(Map<String, Object?> json) {
    final legacy = json['excludeSSIDs'];
    if (legacy is! List || legacy.isEmpty) {
      return json;
    }
    final migrated = Map<String, Object?>.of(json)..remove('excludeSSIDs');
    final props = Map<String, Object?>.of(
      (migrated['vpnProps'] as Map?)?.cast<String, Object?>() ?? {},
    );
    final networks = props['smartPauseNetworks'];
    if (networks is! List || networks.isEmpty) {
      props['smartPauseEnabled'] = true;
      props['smartPauseNetworks'] = legacy.whereType<String>().toList();
      migrated['vpnProps'] = props;
    }
    return migrated;
  }
}

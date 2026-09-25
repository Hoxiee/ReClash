// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:reclash/common/util/context.dart';
import 'package:reclash/common/desktop/system.dart';
import 'package:reclash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Whitelisted decorative overlay a subscription panel may request on the
/// dashboard. The panel only ever names one of these; it can never ship code.
enum ProviderHeroEffect { none, aurora }

enum SupportPlatform {
  Windows,
  MacOS,
  Linux,
  Android;

  static SupportPlatform get currentPlatform {
    if (system.isWindows) {
      return SupportPlatform.Windows;
    } else if (system.isMacOS) {
      return SupportPlatform.MacOS;
    } else if (Platform.isLinux) {
      return SupportPlatform.Linux;
    } else if (system.isAndroid) {
      return SupportPlatform.Android;
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}

const desktopPlatforms = [
  SupportPlatform.Linux,
  SupportPlatform.MacOS,
  SupportPlatform.Windows,
];

enum GroupName { GLOBAL }

enum GroupType {
  @JsonValue('select')
  Selector('select'),
  @JsonValue('url-test')
  URLTest('url-test'),
  @JsonValue('fallback')
  Fallback('fallback'),
  @JsonValue('load-balance')
  LoadBalance('load-balance'),
  @JsonValue('relay')
  Relay('relay'),
  @JsonValue('smart')
  Smart('smart'),
  @JsonValue('unknown')
  unknown('unknown');

  final String value;

  const GroupType(this.value);

  static GroupType parse(String type) {
    return switch (type.toLowerCase()) {
      'url-test' || 'urltest' => URLTest,
      'select' || 'selector' => Selector,
      'fallback' => Fallback,
      'load-balance' || 'loadbalance' => LoadBalance,
      'relay' => Relay,
      'smart' => Smart,
      String() => unknown,
    };
  }
}

extension GroupTypeExtension on GroupType {
  static List<String> get valueList =>
      GroupType.values.map((e) => e.toString().split('.').last).toList();

  bool get isComputedSelected {
    return [GroupType.URLTest, GroupType.Fallback].contains(this);
  }

  static GroupType? getGroupType(String value) {
    final index = GroupTypeExtension.valueList.indexOf(value);
    if (index == -1) return null;
    return GroupType.values[index];
  }
}

enum UsedProxy { GLOBAL, DIRECT, REJECT }

extension UsedProxyExtension on UsedProxy {
  static List<String> get valueList =>
      UsedProxy.values.map((e) => e.toString().split('.').last).toList();

  String get value => UsedProxyExtension.valueList[index];
}

enum Mode { rule, global, direct }

/// What the mode selector offers. [auto] is not a core mode: it is [Mode.rule]
/// with smart routing on, so an inconsistent pair cannot be expressed.
enum UiOutboundMode { auto, rule, global, direct }

enum NotificationComponentType {
  connectionDoctor,
  networkState,
  currentServer,
  smartRouting,
  speed,
  sessionTraffic,
}

enum DoctorNotificationPriority { problems, always }

enum NotificationVisibility { detailed, minimal }

extension UiOutboundModeExt on UiOutboundMode {
  Mode get coreMode => switch (this) {
    UiOutboundMode.auto || UiOutboundMode.rule => Mode.rule,
    UiOutboundMode.global => Mode.global,
    UiOutboundMode.direct => Mode.direct,
  };

  bool get smartRouting => this == UiOutboundMode.auto;
}

extension ModeUiExt on Mode {
  UiOutboundMode uiMode({required bool smartRouting}) =>
      smartRouting && this == Mode.rule
      ? UiOutboundMode.auto
      : UiOutboundMode.values.byName(name);
}

enum AppRegion {
  @JsonValue('ru')
  russia,
  @JsonValue('ir')
  iran,
  @JsonValue('cn')
  china,
  @JsonValue('other')
  other;

  static AppRegion fromPreset(SmartRoutingPreset preset) => switch (preset) {
    SmartRoutingPreset.russia => russia,
    SmartRoutingPreset.iran => iran,
    SmartRoutingPreset.china => china,
    SmartRoutingPreset.off => other,
  };

  SmartRoutingPreset get preset => switch (this) {
    russia => SmartRoutingPreset.russia,
    iran => SmartRoutingPreset.iran,
    china => SmartRoutingPreset.china,
    other => SmartRoutingPreset.off,
  };

  String get wire => switch (this) {
    russia => 'ru',
    iran => 'ir',
    china => 'cn',
    other => 'other',
  };

  String label(BuildContext context) {
    final l10n = context.appLocalizations;
    return switch (this) {
      russia => l10n.smartRoutingPresetRussia,
      iran => l10n.smartRoutingPresetIran,
      china => l10n.smartRoutingPresetChina,
      other => l10n.appRegionOther,
    };
  }
}

enum SmartRoutingPreset {
  @JsonValue('off')
  off,
  @JsonValue('ru')
  russia,
  @JsonValue('ir')
  iran,
  @JsonValue('cn')
  china,
}

enum SmartRoutingStrategy {
  @JsonValue('stable')
  stable,
  @JsonValue('balanced')
  balanced,
  @JsonValue('lowest-latency')
  lowestLatency,
  @JsonValue('saver')
  saver,
}

enum ViewMode { mobile, laptop, desktop }

enum LogLevel { debug, info, warning, error, silent }

enum LogSource { app, core }

extension LogLevelExt on LogLevel {
  Color? color(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      LogLevel.silent => colorScheme.outline,
      LogLevel.debug => colorScheme.onSurfaceVariant,
      LogLevel.info => null,
      LogLevel.warning => colorScheme.tertiary,
      LogLevel.error => colorScheme.error,
    };
  }

  Color accentColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      LogLevel.error => colorScheme.error,
      LogLevel.warning => colorScheme.tertiary,
      LogLevel.info => colorScheme.primary,
      LogLevel.debug => colorScheme.outlineVariant,
      LogLevel.silent => colorScheme.outlineVariant,
    };
  }

  Color badgeColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      LogLevel.error => colorScheme.errorContainer,
      LogLevel.warning => colorScheme.tertiaryContainer,
      _ => colorScheme.surfaceContainerHighest,
    };
  }

  Color onBadgeColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      LogLevel.error => colorScheme.onErrorContainer,
      LogLevel.warning => colorScheme.onTertiaryContainer,
      LogLevel.info => colorScheme.onSurface,
      LogLevel.debug => colorScheme.onSurfaceVariant,
      LogLevel.silent => colorScheme.outline,
    };
  }
}

enum MessageLevel { info, success, warning, error }

extension MessageLevelExt on MessageLevel {
  Glyph? get icon {
    return switch (this) {
      MessageLevel.info => null,
      MessageLevel.success => AppGlyphs.checkCircle,
      MessageLevel.warning => AppGlyphs.warning,
      MessageLevel.error => AppGlyphs.error,
    };
  }

  Color containerColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      MessageLevel.error => colorScheme.errorContainer,
      _ => colorScheme.surfaceContainerHigh,
    };
  }

  Color contentColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      MessageLevel.error => colorScheme.onErrorContainer,
      _ => colorScheme.onSurfaceVariant,
    };
  }

  Color iconColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      MessageLevel.info => colorScheme.onSurfaceVariant,
      MessageLevel.success => colorScheme.primary,
      MessageLevel.warning => colorScheme.tertiary,
      MessageLevel.error => colorScheme.onErrorContainer,
    };
  }

  Duration get duration {
    return switch (this) {
      MessageLevel.info || MessageLevel.success => const Duration(seconds: 3),
      MessageLevel.warning => const Duration(seconds: 5),
      MessageLevel.error => const Duration(seconds: 6),
    };
  }
}

enum TrafficUnit { B, KB, MB, GB, TB }

enum NavigationItemMode { mobile, desktop, more }

enum Network { tcp, udp }

enum ProxiesSortType { none, delay, name }

enum TunStack { gvisor, system, mixed, mips }

enum AccessControlMode { acceptSelected, rejectSelected }

enum AccessSortType { none, name, time }

enum ProfileType { file, url }

/// Compatibility preset for subscription servers that vary by User-Agent.
/// A profile can request a specific response format or use [auto] selection.
enum SubscriptionClient {
  auto,
  clashMeta,
  clash,
  happ,
  incy,
  singbox,
  v2rayng,
  custom,
}

enum ResultType {
  @JsonValue(0)
  success,
  @JsonValue(-1)
  error,
}

enum CoreEventType {
  log,
  delay,
  request,
  dns,
  loaded,
  crash,
  geoUpdate,
  rcxStatus,
  doctorStatus,
  routeChanged,
}

enum InvokeMessageType { protect, process }

enum FindProcessMode { always, off }

enum InterfaceNameMode { clear, follow, custom }

enum RestoreOption { all, onlyProfiles }

enum CommonCardType { plain, filled }

enum ProxiesType { tab, list }

enum ProxiesLayout { loose, standard, tight }

enum ProxyCardType { expand, shrink, min }

enum DnsMode {
  normal,
  @JsonValue('fake-ip')
  fakeIp,
  @JsonValue('redir-host')
  redirHost,
  hosts,
}

enum KeyboardModifier {
  alt([PhysicalKeyboardKey.altLeft, PhysicalKeyboardKey.altRight]),
  capsLock([PhysicalKeyboardKey.capsLock]),
  control([PhysicalKeyboardKey.controlLeft, PhysicalKeyboardKey.controlRight]),
  fn([PhysicalKeyboardKey.fn]),
  meta([PhysicalKeyboardKey.metaLeft, PhysicalKeyboardKey.metaRight]),
  shift([PhysicalKeyboardKey.shiftLeft, PhysicalKeyboardKey.shiftRight]);

  final List<PhysicalKeyboardKey> physicalKeys;

  const KeyboardModifier(this.physicalKeys);
}

enum HotAction {
  start,
  view,
  mode,
  proxy,
  tun,
  ruleMode,
  globalMode,
  directMode,
  delayTest,
  updateProfiles,
  copyEnv,
  exit,
}

enum ProxiesIconStyle { none, standard, icon }

enum ProxiesStyleField { type, sortType, layout, iconStyle, cardType }

enum FontFamily {
  twEmoji('Twemoji'),
  jetBrainsMono('JetBrainsMono'),
  icon('Icons');

  final String value;

  const FontFamily(this.value);
}

enum RouteMode { bypassPrivate, config }

enum AuthorizeCode { none, success, error }

enum TunAuthorizationState { none, authorized, unauthorized }

enum FunctionTag {
  updateConfig,
  setupConfig,
  updateGroups,
  addCheckIpNum,
  applyProfile,
  savePreferences,
  changeProxy,
  checkIp,
  handleWill,
  updateDelay,
  vpnTip,
  autoLaunch,
  renderPause,
  updatePageIndex,
  pageChange,
  proxiesTabChange,
  logs,
  requests,
  autoScrollToEnd,
  loadedProvider,
  saveSharedFile,
  removeProxy,
  smartPause,
  coreErrorNotifier,
  dnsQueries,
}

/// ByeDPI-only runs without a profile, so server tiles have nothing to say.
enum DashboardMode { vpn, byedpi }

const _vpnOnly = [DashboardMode.vpn];
const _byedpiOnly = [DashboardMode.byedpi];

enum DashboardWidget {
  networkSpeed,
  outboundModeV2(modes: _vpnOnly),
  outboundMode(modes: _vpnOnly),
  trafficUsage,
  networkDetection,
  tunButton(platforms: desktopPlatforms),
  vpnButton(platforms: [SupportPlatform.Android]),
  systemProxyButton(platforms: desktopPlatforms),
  intranetIp,
  memoryInfo,
  goroutineInfo,
  metaInfo(modes: _vpnOnly),
  announce(modes: _vpnOnly),
  serviceInfo(modes: _vpnOnly),
  changeServerButton(modes: _vpnOnly),
  smartRouting(modes: _vpnOnly),
  desyncStrategy(modes: _byedpiOnly),
  desyncTest(modes: _byedpiOnly),
  desyncEngine(modes: _byedpiOnly),
  serviceStatus(modes: _vpnOnly);

  final List<SupportPlatform> platforms;
  final List<DashboardMode> modes;

  const DashboardWidget({
    this.platforms = SupportPlatform.values,
    this.modes = DashboardMode.values,
  });

  bool visibleIn(DashboardMode mode) =>
      platforms.contains(SupportPlatform.currentPlatform) &&
      modes.contains(mode);
}

enum GeodataLoader { standard, memconservative }

enum GeoResource {
  @JsonValue('mmdb')
  MMDB,
  @JsonValue('asn')
  ASN,
  @JsonValue('geoip')
  GEOIP,
  @JsonValue('geosite')
  GEOSITE;

  static GeoResource fromJson(String value) {
    return switch (value) {
      'mmdb' => GeoResource.MMDB,
      'asn' => GeoResource.ASN,
      'geo-ip' || 'geoip' => GeoResource.GEOIP,
      'geo-site' || 'geosite' => GeoResource.GEOSITE,
      _ => throw ArgumentError.value(value, 'value', 'Invalid geo resource'),
    };
  }
}

extension GeoResourceExt on GeoResource {
  String get configKey {
    return switch (this) {
      GeoResource.MMDB => 'mmdb',
      GeoResource.ASN => 'asn',
      GeoResource.GEOIP => 'geoip',
      GeoResource.GEOSITE => 'geosite',
    };
  }

  String get updatingKey => 'geo_resource_$name';
}

enum PageLabel {
  dashboard,
  proxies,
  profiles,
  tools,
  logs,
  requests,
  resources,
  connections,
  dns,
}

/// The engine only distinguishes app-originated lookups from the rest; the
/// finer FlClash split needs `component/resolver` wiring we did not vendor.
enum DnsQueryInitiator { app, other }

enum RuleAction {
  DOMAIN('DOMAIN'),
  DOMAIN_SUFFIX('DOMAIN-SUFFIX'),
  DOMAIN_KEYWORD('DOMAIN-KEYWORD'),
  DOMAIN_REGEX('DOMAIN-REGEX'),
  DOMAIN_WILDCARD('DOMAIN-WILDCARD'),
  GEOSITE('GEOSITE'),
  IP_CIDR('IP-CIDR'),
  IP_CIDR6('IP-CIDR6'),
  IP_SUFFIX('IP-SUFFIX'),
  IP_ASN('IP-ASN'),
  GEOIP('GEOIP'),
  SRC_GEOIP('SRC-GEOIP'),
  SRC_IP_ASN('SRC-IP-ASN'),
  SRC_IP_CIDR('SRC-IP-CIDR'),
  SRC_IP_SUFFIX('SRC-IP-SUFFIX'),
  DST_PORT('DST-PORT'),
  SRC_PORT('SRC-PORT'),
  IN_PORT('IN-PORT'),
  IN_TYPE('IN-TYPE'),
  IN_USER('IN-USER'),
  IN_NAME('IN-NAME'),
  REMATCH_NAME('REMATCH-NAME'),
  PROCESS_PATH('PROCESS-PATH'),
  PROCESS_PATH_REGEX('PROCESS-PATH-REGEX'),
  PROCESS_PATH_WILDCARD('PROCESS-PATH-WILDCARD'),
  PROCESS_NAME('PROCESS-NAME'),
  PROCESS_NAME_REGEX('PROCESS-NAME-REGEX'),
  PROCESS_NAME_WILDCARD('PROCESS-NAME-WILDCARD'),
  UID('UID'),
  NETWORK('NETWORK'),
  DSCP('DSCP'),
  RULE_SET('RULE-SET'),
  AND('AND'),
  OR('OR'),
  NOT('NOT'),
  SUB_RULE('SUB-RULE'),
  MATCH('MATCH');

  final String value;

  const RuleAction(this.value);

  static List<RuleAction> get addedRuleActions {
    return RuleAction.values
        .where(
          (item) => ![
            RuleAction.MATCH,
            RuleAction.RULE_SET,
            RuleAction.SUB_RULE,
          ].contains(item),
        )
        .toList();
  }
}

extension RuleActionExt on RuleAction {
  bool get hasParams => [
    RuleAction.GEOIP,
    RuleAction.IP_ASN,
    RuleAction.IP_CIDR,
    RuleAction.IP_CIDR6,
    RuleAction.IP_SUFFIX,
    RuleAction.RULE_SET,
  ].contains(this);

  bool get hasCommaPayload => [
    RuleAction.AND,
    RuleAction.OR,
    RuleAction.NOT,
    RuleAction.SUB_RULE,
    RuleAction.DOMAIN_REGEX,
    RuleAction.PROCESS_NAME_REGEX,
    RuleAction.PROCESS_PATH_REGEX,
  ].contains(this);

  String getDesc(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return switch (this) {
      RuleAction.DOMAIN => appLocalizations.ruleActionDomainDesc,
      RuleAction.DOMAIN_SUFFIX => appLocalizations.ruleActionDomainSuffixDesc,
      RuleAction.DOMAIN_KEYWORD => appLocalizations.ruleActionDomainKeywordDesc,
      RuleAction.DOMAIN_REGEX => appLocalizations.ruleActionDomainRegexDesc,
      RuleAction.DOMAIN_WILDCARD =>
        appLocalizations.ruleActionDomainWildcardDesc,
      RuleAction.GEOSITE => appLocalizations.ruleActionGeositeDesc,
      RuleAction.IP_CIDR => appLocalizations.ruleActionIpCidrDesc,
      RuleAction.IP_CIDR6 => appLocalizations.ruleActionIpCidr6Desc,
      RuleAction.IP_SUFFIX => appLocalizations.ruleActionIpSuffixDesc,
      RuleAction.IP_ASN => appLocalizations.ruleActionIpAsnDesc,
      RuleAction.GEOIP => appLocalizations.ruleActionGeoipDesc,
      RuleAction.SRC_GEOIP => appLocalizations.ruleActionSrcGeoipDesc,
      RuleAction.SRC_IP_ASN => appLocalizations.ruleActionSrcIpAsnDesc,
      RuleAction.SRC_IP_CIDR => appLocalizations.ruleActionSrcIpCidrDesc,
      RuleAction.SRC_IP_SUFFIX => appLocalizations.ruleActionSrcIpSuffixDesc,
      RuleAction.DST_PORT => appLocalizations.ruleActionDstPortDesc,
      RuleAction.SRC_PORT => appLocalizations.ruleActionSrcPortDesc,
      RuleAction.IN_PORT => appLocalizations.ruleActionInPortDesc,
      RuleAction.IN_TYPE => appLocalizations.ruleActionInTypeDesc,
      RuleAction.IN_USER => appLocalizations.ruleActionInUserDesc,
      RuleAction.IN_NAME => appLocalizations.ruleActionInNameDesc,
      RuleAction.REMATCH_NAME => appLocalizations.ruleActionRematchNameDesc,
      RuleAction.PROCESS_PATH => appLocalizations.ruleActionProcessPathDesc,
      RuleAction.PROCESS_PATH_REGEX =>
        appLocalizations.ruleActionProcessPathRegexDesc,
      RuleAction.PROCESS_PATH_WILDCARD =>
        appLocalizations.ruleActionProcessPathWildcardDesc,
      RuleAction.PROCESS_NAME => appLocalizations.ruleActionProcessNameDesc,
      RuleAction.PROCESS_NAME_REGEX =>
        appLocalizations.ruleActionProcessNameRegexDesc,
      RuleAction.PROCESS_NAME_WILDCARD =>
        appLocalizations.ruleActionProcessNameWildcardDesc,
      RuleAction.UID => appLocalizations.ruleActionUidDesc,
      RuleAction.NETWORK => appLocalizations.ruleActionNetworkDesc,
      RuleAction.DSCP => appLocalizations.ruleActionDscpDesc,
      RuleAction.RULE_SET => appLocalizations.ruleActionRuleSetDesc,
      RuleAction.AND => appLocalizations.ruleActionAndDesc,
      RuleAction.OR => appLocalizations.ruleActionOrDesc,
      RuleAction.NOT => appLocalizations.ruleActionNotDesc,
      RuleAction.SUB_RULE => appLocalizations.ruleActionSubRuleDesc,
      RuleAction.MATCH => appLocalizations.ruleActionMatchDesc,
    };
  }
}

enum OverwriteType { standard, script, custom }

enum RuleTarget {
  DIRECT,
  REJECT,
  DESYNC;

  static const _always = [RuleTarget.DIRECT, RuleTarget.REJECT];

  static final List<String> baseTargetNames = List.unmodifiable(
    _always.map((item) => item.name),
  );

  static final Set<String> baseTargets = Set.unmodifiable(baseTargetNames);

  static List<String> targetNames({required bool desync}) =>
      desync ? [...baseTargetNames, DESYNC.name] : baseTargetNames;
}

enum RestoreStrategy { compatible, override }

enum Language { yaml, javaScript, json }

enum ScrollPositionCacheKey { tools, profiles, proxiesList, proxiesTabList }

enum QueryTag { proxies, access }

enum LoadingTag {
  profiles,
  backup_restore,
  access,
  proxies,
  batteryOptimization,
}

enum CoreStatus { connecting, connected, disconnected }

enum UpdatingScope { core, local }

enum RuleScene { added, disabled, custom }

enum ItemPosition {
  start,
  middle,
  end,
  startAndEnd;

  static ItemPosition get(int index, int length) {
    ItemPosition position = ItemPosition.middle;
    if (length == 1) {
      position = ItemPosition.startAndEnd;
    } else if (index == length - 1) {
      position = ItemPosition.end;
    } else if (index == 0) {
      position = ItemPosition.start;
    }
    return position;
  }

  static ItemPosition calculateVisualPosition<T>(
    int currentIndex,
    List<T> items,
    Set<T> deletedItems,
  ) {
    if (deletedItems.isEmpty) {
      return ItemPosition.get(currentIndex, items.length);
    }
    final currentItem = items[currentIndex];
    if (deletedItems.contains(currentItem)) {
      return ItemPosition.middle;
    }
    final int visualLength = items.length - deletedItems.length;
    if (visualLength <= 0) return ItemPosition.middle;
    int deletedCountBeforeMe = 0;
    for (int i = 0; i < currentIndex; i++) {
      if (deletedItems.contains(items[i])) {
        deletedCountBeforeMe++;
      }
    }
    final int visualIndex = currentIndex - deletedCountBeforeMe;
    return ItemPosition.get(visualIndex, visualLength);
  }
}

enum IpType { residential, mobile, business, hosting }

enum IpQualityLevel { good, normal, risky }

enum IpQualitySource {
  identMe('ident.me'),
  ipApiCom('ip-api.com'),
  ipQuery('ipquery.io'),
  ipLocate('iplocate.io'),
  proxyCheck('proxycheck.io'),
  ipApiIs('ipapi.is');

  const IpQualitySource(this.label);

  final String label;
}

enum IpQualitySourceStatus { noType, timeout, rateLimited, failed, ipMismatch }

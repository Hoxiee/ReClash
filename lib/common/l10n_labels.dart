import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

import 'app_localizations.dart';
import 'connection_answer.dart';
import 'routing_overview.dart';
import 'task.dart';

/// The engine's group name is wire detail, not a label to decode.
String groupDisplayName(String groupName) {
  return groupName == rcxNodeGroupName
      ? currentAppLocalizations.smartRouting
      : groupName;
}

extension PageLabelL10n on PageLabel {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      PageLabel.dashboard => appLocalizations.dashboard,
      PageLabel.proxies => appLocalizations.proxies,
      PageLabel.profiles => appLocalizations.profiles,
      PageLabel.tools => appLocalizations.tools,
      PageLabel.logs => appLocalizations.logs,
      PageLabel.requests => appLocalizations.requests,
      PageLabel.resources => appLocalizations.resources,
      PageLabel.connections => appLocalizations.connections,
    };
  }

  String? get description {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      PageLabel.logs => appLocalizations.logsDesc,
      PageLabel.requests => appLocalizations.requestsDesc,
      PageLabel.resources => appLocalizations.resourcesDesc,
      PageLabel.connections => appLocalizations.connectionsDesc,
      PageLabel.dashboard ||
      PageLabel.proxies ||
      PageLabel.profiles ||
      PageLabel.tools => null,
    };
  }
}

extension ModeL10n on Mode {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      Mode.rule => appLocalizations.rule,
      Mode.global => appLocalizations.global,
      Mode.direct => appLocalizations.direct,
    };
  }
}

extension UiOutboundModeL10n on UiOutboundMode {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      UiOutboundMode.auto => appLocalizations.auto,
      UiOutboundMode.rule => appLocalizations.rule,
      UiOutboundMode.global => appLocalizations.global,
      UiOutboundMode.direct => appLocalizations.direct,
    };
  }
}

extension SmartRoutingPresetL10n on SmartRoutingPreset {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      SmartRoutingPreset.off => appLocalizations.smartRoutingPresetOff,
      SmartRoutingPreset.russia => appLocalizations.smartRoutingPresetRussia,
      SmartRoutingPreset.iran => appLocalizations.smartRoutingPresetIran,
      SmartRoutingPreset.china => appLocalizations.smartRoutingPresetChina,
    };
  }
}

extension SmartRoutingStrategyL10n on SmartRoutingStrategy {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      SmartRoutingStrategy.stable =>
        appLocalizations.smartRoutingStrategyStable,
      SmartRoutingStrategy.balanced =>
        appLocalizations.smartRoutingStrategyBalanced,
      SmartRoutingStrategy.lowestLatency =>
        appLocalizations.smartRoutingStrategyLowestLatency,
      SmartRoutingStrategy.saver => appLocalizations.smartRoutingStrategySaver,
    };
  }

  String get description {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      SmartRoutingStrategy.stable =>
        appLocalizations.smartRoutingStrategyStableDesc,
      SmartRoutingStrategy.balanced =>
        appLocalizations.smartRoutingStrategyBalancedDesc,
      SmartRoutingStrategy.lowestLatency =>
        appLocalizations.smartRoutingStrategyLowestLatencyDesc,
      SmartRoutingStrategy.saver =>
        appLocalizations.smartRoutingStrategySaverDesc,
    };
  }
}

extension NetworkFormatL10n on NetworkFormat {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      NetworkFormat.open => appLocalizations.smartRoutingFormatOpen,
      NetworkFormat.restricted => appLocalizations.smartRoutingFormatRestricted,
      NetworkFormat.portal => appLocalizations.smartRoutingFormatPortal,
      NetworkFormat.offline => appLocalizations.smartRoutingFormatOffline,
      NetworkFormat.unknown => appLocalizations.smartRoutingFormatUnknown,
    };
  }

  String get description {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      NetworkFormat.open => appLocalizations.smartRoutingFormatOpenDesc,
      NetworkFormat.restricted =>
        appLocalizations.smartRoutingFormatRestrictedDesc,
      NetworkFormat.portal => appLocalizations.smartRoutingFormatPortalDesc,
      NetworkFormat.offline => appLocalizations.smartRoutingFormatOfflineDesc,
      NetworkFormat.unknown => appLocalizations.smartRoutingFormatUnknownDesc,
    };
  }
}

extension ProxiesTypeL10n on ProxiesType {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      ProxiesType.tab => appLocalizations.tab,
      ProxiesType.list => appLocalizations.list,
    };
  }
}

extension ProxyCardTypeL10n on ProxyCardType {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      ProxyCardType.expand => appLocalizations.expand,
      ProxyCardType.shrink => appLocalizations.shrink,
      ProxyCardType.min => appLocalizations.min,
    };
  }
}

extension HotActionL10n on HotAction {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      HotAction.start => appLocalizations.actionStart,
      HotAction.view => appLocalizations.actionView,
      HotAction.mode => appLocalizations.actionMode,
      HotAction.proxy => appLocalizations.actionProxy,
      HotAction.tun => appLocalizations.actionTun,
    };
  }
}

extension RouteModeL10n on RouteMode {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      RouteMode.bypassPrivate => appLocalizations.routeModeBypassPrivate,
      RouteMode.config => appLocalizations.routeModeConfig,
    };
  }
}

extension RestoreStrategyL10n on RestoreStrategy {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      RestoreStrategy.compatible => appLocalizations.restoreStrategyCompatible,
      RestoreStrategy.override => appLocalizations.restoreStrategyOverride,
    };
  }
}

extension DynamicSchemeVariantL10n on DynamicSchemeVariant {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      DynamicSchemeVariant.tonalSpot => appLocalizations.tonalSpotScheme,
      DynamicSchemeVariant.fidelity => appLocalizations.fidelityScheme,
      DynamicSchemeVariant.monochrome => appLocalizations.monochromeScheme,
      DynamicSchemeVariant.neutral => appLocalizations.neutralScheme,
      DynamicSchemeVariant.vibrant => appLocalizations.vibrantScheme,
      DynamicSchemeVariant.expressive => appLocalizations.expressiveScheme,
      DynamicSchemeVariant.content => appLocalizations.contentScheme,
      DynamicSchemeVariant.rainbow => appLocalizations.rainbowScheme,
      DynamicSchemeVariant.fruitSalad => appLocalizations.fruitSaladScheme,
    };
  }
}

extension LocaleL10n on Locale {
  /// Fixed names: the picker must stay readable in the current locale.
  String get nativeLabel {
    return switch (toString()) {
      'en' => 'English',
      'ja' => '日本語',
      'ru' => 'Русский',
      'uz' => 'Oʻzbekcha',
      'kk' => 'Қазақша',
      'tk' => 'Türkmençe',
      'ko' => '한국어',
      'zh_CN' => '简体中文',
      final code => code,
    };
  }

  String get englishLabel {
    return switch (toString()) {
      'en' => 'English',
      'ja' => 'Japanese',
      'ru' => 'Russian',
      'uz' => 'Uzbek',
      'kk' => 'Kazakh',
      'tk' => 'Turkmen',
      'ko' => 'Korean',
      'zh_CN' => 'Chinese (Simplified)',
      final code => code,
    };
  }

  String get flagEmoji {
    return switch (toString()) {
      'en' => '🇬🇧',
      'ja' => '🇯🇵',
      'ru' => '🇷🇺',
      'uz' => '🇺🇿',
      'kk' => '🇰🇿',
      'tk' => '🇹🇲',
      'ko' => '🇰🇷',
      'zh_CN' => '🇨🇳',
      _ => '🌐',
    };
  }
}

DoctorAnswerText doctorAnswerText(AppLocalizations appLocalizations) =>
    DoctorAnswerText(
      unsupportedHeadline: appLocalizations.doctorUnsupportedTitle,
      unsupportedMeaning: appLocalizations.doctorUnsupportedDesc,
      examiningHeadline: appLocalizations.doctorExaminingTitle,
      examiningMeaning: appLocalizations.doctorExaminingDesc,
      staleHeadline: appLocalizations.doctorStaleTitle,
      staleMeaning: appLocalizations.doctorStaleHint,
      idleHeadline: appLocalizations.doctorObservingTitle,
      idleMeaning: appLocalizations.doctorObservingDesc,
      healthyHeadline: appLocalizations.doctorHealthyTitle,
      healthyMeaning: appLocalizations.doctorHealthyDesc,
      reachableHeadline: appLocalizations.doctorEndpointReachableTitle,
      reachableMeaning: appLocalizations.doctorEndpointReachableDesc,
      inconclusiveHeadline: appLocalizations.doctorInconclusiveTitle,
      inconclusiveMeaning: appLocalizations.doctorInconclusiveDesc,
      supersededHeadline: appLocalizations.doctorSupersededTitle,
      supersededMeaning: appLocalizations.doctorSupersededDesc,
      cancelledHeadline: appLocalizations.doctorCancelledTitle,
      cancelledMeaning: appLocalizations.doctorCancelledDesc,
      vpnInactiveHeadline: appLocalizations.doctorVpnInactiveTitle,
      vpnInactiveMeaning: appLocalizations.doctorVpnInactiveDesc,
      noNetworkHeadline: appLocalizations.doctorNoNetworkTitle,
      noNetworkMeaning: appLocalizations.doctorNoNetworkDesc,
      portalHeadline: appLocalizations.doctorPortalTitle,
      portalMeaning: appLocalizations.doctorPortalDesc,
      unvalidatedHeadline: appLocalizations.doctorUnvalidatedTitle,
      unvalidatedMeaning: appLocalizations.doctorUnvalidatedDesc,
      byeDpiFailedHeadline: appLocalizations.doctorByeDpiFailedTitle,
      byeDpiFailedMeaning: appLocalizations.doctorByeDpiFailedDesc,
      noNodeHeadline: appLocalizations.doctorNoNodeTitle,
      noNodeMeaning: appLocalizations.doctorNoNodeDesc,
      dnsStaleHeadline: appLocalizations.doctorDnsStaleTitle,
      dnsStaleMeaning: appLocalizations.doctorDnsStaleDesc,
      dnsFailedHeadline: appLocalizations.doctorDnsFailedTitle,
      dnsFailedMeaning: appLocalizations.doctorDnsFailedDesc,
      nodeDownHeadline: appLocalizations.doctorNodeDownTitle,
      nodeDownMeaning: appLocalizations.doctorNodeDownDesc,
      nodeRefusedHeadline: appLocalizations.doctorNodeRefusedTitle,
      nodeRefusedMeaning: appLocalizations.doctorNodeRefusedDesc,
      slowHeadline: appLocalizations.doctorSlowTitle,
      slowMeaning: appLocalizations.doctorSlowDesc,
      routeHeadline: appLocalizations.doctorRouteTitle,
      routeMeaning: appLocalizations.doctorRouteDesc,
      ingressHeadline: appLocalizations.doctorIngressTitle,
      ingressMeaning: appLocalizations.doctorIngressDesc,
      captureHeadline: appLocalizations.doctorVpnInactiveTitle,
      captureMeaning: appLocalizations.doctorVpnInactiveDesc,
      genericHeadline: appLocalizations.doctorBrokenTitle,
      genericMeaning: appLocalizations.doctorGenericDesc,
      stormHeadline: appLocalizations.findingStormTitle,
      stormMeaning: appLocalizations.findingStormVerdict,
      stepStartVpn: appLocalizations.doctorStepStartVpn,
      stepCheckWifi: appLocalizations.doctorStepCheckWifi,
      stepSignInPortal: appLocalizations.doctorStepSignInPortal,
      stepSwitchNetwork: appLocalizations.doctorStepSwitchNetwork,
      stepRestartByeDpi: appLocalizations.doctorStepRestartByeDpi,
      stepPickNode: appLocalizations.doctorStepPickNode,
      stepUpdateSubscription: appLocalizations.doctorStepUpdateSubscription,
      stepFlushDns: appLocalizations.doctorStepFlushDns,
      stepChangeDns: appLocalizations.doctorStepChangeDns,
      stepCheckRules: appLocalizations.doctorStepCheckRules,
      stepRestartTunnel: appLocalizations.doctorStepRestartTunnel,
      stepRecheckLater: appLocalizations.doctorStepRecheckLater,
      stepDeepCheck: appLocalizations.doctorStepDeepCheck,
      stepUseAppThenRecheck: appLocalizations.doctorStepUseAppThenRecheck,
    );

import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/ui/color.dart';
import 'package:material_ui/material_ui.dart';

import 'app_localizations.dart';

extension PageLabelL10n on PageLabel {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      PageLabel.dashboard => appLocalizations.dashboard,
      PageLabel.proxies => appLocalizations.proxies,
      PageLabel.profiles => appLocalizations.profiles,
      PageLabel.tools => appLocalizations.tools,
      PageLabel.logs => appLocalizations.logs,
      PageLabel.requests => appLocalizations.recentRequests,
      PageLabel.resources => appLocalizations.resources,
      PageLabel.connections => appLocalizations.liveConnections,
      PageLabel.dns => appLocalizations.dnsQueries,
    };
  }
}

extension DnsQueryInitiatorL10n on DnsQueryInitiator {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      DnsQueryInitiator.app => appLocalizations.app,
      DnsQueryInitiator.rule => appLocalizations.rule,
      DnsQueryInitiator.direct => appLocalizations.direct,
      DnsQueryInitiator.proxy => appLocalizations.proxies,
      DnsQueryInitiator.other => appLocalizations.other,
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
      ProxyCardType.loose => appLocalizations.loose,
      ProxyCardType.standard => appLocalizations.standard,
      ProxyCardType.compact => appLocalizations.compact,
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
      HotAction.ruleMode => appLocalizations.actionRuleMode,
      HotAction.globalMode => appLocalizations.actionGlobalMode,
      HotAction.directMode => appLocalizations.actionDirectMode,
      HotAction.delayTest => appLocalizations.actionDelayTest,
      HotAction.updateProfiles => appLocalizations.actionUpdateProfiles,
      HotAction.copyEnv => appLocalizations.copyEnvVar,
      HotAction.exit => appLocalizations.exit,
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

extension ColorStyleL10n on ColorStyle {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      ColorStyle.vivid => appLocalizations.vividStyle,
      ColorStyle.tinted => appLocalizations.tintedStyle,
      ColorStyle.soft => appLocalizations.softStyle,
      ColorStyle.monochrome => appLocalizations.monochromeScheme,
    };
  }
}

extension LocaleL10n on Locale {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (toString()) {
      'en' => appLocalizations.en,
      'es' => appLocalizations.es,
      'fr' => appLocalizations.fr,
      'ja' => appLocalizations.ja,
      'ko' => appLocalizations.ko,
      'ru' => appLocalizations.ru,
      'zh_CN' => appLocalizations.zhCN,
      'uz' => appLocalizations.uz,
      'kk' => appLocalizations.kk,
      'tk' => appLocalizations.tk,
      final code => code,
    };
  }

  /// Fixed names: a language picker must stay readable in any locale.
  String get nativeLabel {
    return switch (toString()) {
      'en' => 'English',
      'es' => 'Español',
      'fr' => 'Français',
      'ja' => '日本語',
      'ko' => '한국어',
      'ru' => 'Русский',
      'uz' => 'Oʻzbekcha',
      'kk' => 'Қазақша',
      'tk' => 'Türkmençe',
      'zh_CN' => '简体中文',
      final code => code,
    };
  }

  String get englishLabel {
    return switch (toString()) {
      'en' => 'English',
      'es' => 'Spanish',
      'fr' => 'French',
      'ja' => 'Japanese',
      'ko' => 'Korean',
      'ru' => 'Russian',
      'uz' => 'Uzbek',
      'kk' => 'Kazakh',
      'tk' => 'Turkmen',
      'zh_CN' => 'Chinese (Simplified)',
      final code => code,
    };
  }

  String get flagEmoji {
    return switch (toString()) {
      'en' => '🇬🇧',
      'es' => '🇪🇸',
      'fr' => '🇫🇷',
      'ja' => '🇯🇵',
      'ko' => '🇰🇷',
      'ru' => '🇷🇺',
      'uz' => '🇺🇿',
      'kk' => '🇰🇿',
      'tk' => '🇹🇲',
      'zh_CN' => '🇨🇳',
      _ => '🌐',
    };
  }
}

extension WebDashboardFlavorL10n on WebDashboardFlavor {
  String get label => switch (this) {
    WebDashboardFlavor.zashboard => 'zashboard',
    WebDashboardFlavor.metacubexd => 'MetaCubeXD',
  };
}

extension WebDashboardFailureL10n on WebDashboardFailure {
  String get label {
    final l = currentAppLocalizations;
    return switch (this) {
      WebDashboardFailure.download => l.webDashboardDownloadFailed,
      WebDashboardFailure.checksum => l.webDashboardChecksumFailed,
      WebDashboardFailure.archive => l.webDashboardArchiveFailed,
      WebDashboardFailure.tooLarge => l.webDashboardTooLarge,
      WebDashboardFailure.storage => l.webDashboardStorageFailed,
      WebDashboardFailure.busy => l.webDashboardBusy,
      WebDashboardFailure.safeMode => l.webDashboardSafeMode,
      WebDashboardFailure.restricted => l.webDashboardRestricted,
      WebDashboardFailure.noProfile => l.webDashboardNoProfile,
      WebDashboardFailure.coreUnavailable => l.webDashboardCoreUnavailable,
      WebDashboardFailure.apply => l.webDashboardApplyFailed,
      WebDashboardFailure.unreachable => l.webDashboardUnreachable,
      WebDashboardFailure.authentication => l.webDashboardAuthenticationFailed,
      WebDashboardFailure.launch => l.webDashboardLaunchFailed,
      WebDashboardFailure.cancelled => l.webDashboardCancelled,
    };
  }
}

extension WallpaperFitL10n on WallpaperFit {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      WallpaperFit.cover => appLocalizations.wallpaperFitCover,
      WallpaperFit.contain => appLocalizations.wallpaperFitContain,
      WallpaperFit.fill => appLocalizations.wallpaperFitFill,
    };
  }
}

import 'package:reclash/common/constant.dart';
import 'package:reclash/common/exception.dart';
import 'package:reclash/common/network_error.dart';
import 'package:reclash/common/url_scheme.dart';
import 'package:reclash/core/desktop/launch_policy.dart';
import 'package:reclash/core/desktop/privilege.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/desktop/windows_launcher.dart';
import 'package:reclash/core/desktop/macos_helper.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/l10n.dart';
import 'package:material_ui/material_ui.dart';

final currentAppLocalizations = AppLocalizations.current;

// material_ui generates localization data for a fixed language list that lacks
// tk; without these clones MaterialLocalizations.of stays null for them and
// crashes every surface with a text field.
final fallbackMaterialLocalizationsDelegates = [
  for (final delegate in GlobalMaterialLocalizations.delegates)
    FallbackLocalizationsDelegate(delegate),
];

class FallbackLocalizationsDelegate extends LocalizationsDelegate<dynamic> {
  const FallbackLocalizationsDelegate(this.delegate);

  final LocalizationsDelegate<dynamic> delegate;

  @override
  Type get type => delegate.type;

  @override
  bool isSupported(Locale locale) => !delegate.isSupported(locale);

  @override
  Future<dynamic> load(Locale locale) => delegate.load(const Locale('en'));

  @override
  bool shouldReload(FallbackLocalizationsDelegate old) => false;
}

class AppUiLocalizations implements UiLocalizations {
  const AppUiLocalizations(this._localizations);

  static const LocalizationsDelegate<UiLocalizations> delegate =
      _AppUiLocalizationsDelegate();

  final AppLocalizations _localizations;

  @override
  String get back => _localizations.back;

  @override
  String get cancel => _localizations.cancel;

  @override
  String get clearSearch => _localizations.clearSearch;

  @override
  String get close => _localizations.close;

  @override
  String get hidePassword => _localizations.hidePassword;

  @override
  String get more => _localizations.more;

  @override
  String get noSearchResults => _localizations.noSearchResults;

  @override
  String get reset => _localizations.reset;

  @override
  String get search => _localizations.search;

  @override
  String get showLess => _localizations.showLess;

  @override
  String get showMore => _localizations.showMore;

  @override
  String get showPassword => _localizations.showPassword;

  @override
  String get sort => _localizations.sort;

  @override
  String get submit => _localizations.submit;
}

class _AppUiLocalizationsDelegate
    extends LocalizationsDelegate<UiLocalizations> {
  const _AppUiLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale);

  @override
  Future<UiLocalizations> load(Locale locale) =>
      AppLocalizations.load(locale).then(AppUiLocalizations.new);

  @override
  bool shouldReload(_AppUiLocalizationsDelegate old) => false;
}

String? coreLaunchBlockedMessage(
  Object error,
  AppLocalizations appLocalizations,
) {
  if (!isPolicyBlockedLaunch(error)) {
    return null;
  }
  return switch (smartAppControlStateReader()) {
    SmartAppControlState.on || SmartAppControlState.evaluation =>
      appLocalizations.coreBlockedBySmartAppControlTip,
    _ => appLocalizations.coreBlockedByPolicyTip(launchOsError(error)!),
  };
}

String userFacingErrorMessage(Object error, AppLocalizations appLocalizations) {
  return (error is UrlSchemeException
          ? urlSchemeErrorMessage(error.issue, appLocalizations)
          : null) ??
      networkErrorMessage(error, appLocalizations) ??
      coreLaunchBlockedMessage(error, appLocalizations) ??
      desktopPrivilegeErrorMessage(error, appLocalizations) ??
      switch (error) {
        AgeSecretKeyRequiredException() =>
          appLocalizations.ageSecretKeyRequiredTip,
        CoreMethodException(code: 'rule_set_empty') =>
          appLocalizations.ruleSetEmptyTip,
        CoreMethodException(code: 'rule_set_mixed') =>
          appLocalizations.ruleSetMixedTip,
        CoreMethodException(code: 'rule_set_invalid') =>
          appLocalizations.ruleSetInvalidTip,
        CoreMethodException(:final message) => message,
        _ => error.toString(),
      };
}

String delayFailureText(int delay, AppLocalizations appLocalizations) {
  return delay == delayTimedOutValue
      ? appLocalizations.timeout
      : appLocalizations.delayFailed;
}

Locale? getLocaleForString(String? localString) {
  if (localString == null) return null;
  final localSplit = localString.split('_');
  if (localSplit.length == 1) {
    return Locale(localSplit[0]);
  }
  if (localSplit.length == 2) {
    return Locale(localSplit[0], localSplit[1]);
  }
  if (localSplit.length == 3) {
    return Locale.fromSubtags(
      languageCode: localSplit[0],
      scriptCode: localSplit[1],
      countryCode: localSplit[2],
    );
  }
  return null;
}

String? desktopPrivilegeErrorMessage(Object error, AppLocalizations l10n) {
  final code = switch (error) {
    DesktopCoreFailure(:final cause) when cause != null =>
      _desktopPrivilegeCode(cause) ?? error.code,
    DesktopCoreFailure(:final code) => code,
    _ => _desktopPrivilegeCode(error),
  }?.toLowerCase();
  if (code == null) return null;
  if (code.contains('cancelled')) return l10n.desktopAuthorizationCancelled;
  if (code.contains('requires_approval') || code.contains('requiresapproval')) {
    return l10n.desktopHelperApprovalRequired;
  }
  if (code.contains('sign') ||
      code.contains('team') ||
      code.contains('requirement')) {
    return l10n.desktopSigningRequired;
  }
  if (code.contains('hash') ||
      code.contains('bundle_invalid') ||
      code.contains('bundleinvalid') ||
      code.contains('manifest')) {
    return l10n.desktopBundleInvalid;
  }
  if (code.contains('agentunavailable') || code.contains('pkexecunavailable')) {
    return l10n.desktopAuthorizationAgentUnavailable;
  }
  if (code.contains('denied')) return l10n.desktopAuthorizationDenied;
  if (code.contains('authorization_timeout')) {
    return l10n.desktopAuthorizationTimeout;
  }
  if (code.contains('pending') ||
      code.contains('stop_failed') ||
      code.contains('stopfailed')) {
    return l10n.desktopLaunchPending;
  }
  if (code.contains('authorization_required')) {
    return l10n.desktopAuthorizationRequired;
  }
  if (code.contains('tun_not_ready')) return l10n.desktopTunNotReady;
  if (code.contains('linux_') ||
      code.contains('notready') ||
      code.contains('notregistered') ||
      code.contains('notfound') ||
      code.contains('helper_unavailable')) {
    return l10n.desktopHelperUnavailable;
  }
  if (code.startsWith('windows_') ||
      code.startsWith('macos_') ||
      code.contains('bootstrap') ||
      code.contains('helperresponseinvalid')) {
    return l10n.desktopBootstrapFailed;
  }
  return null;
}

String? _desktopPrivilegeCode(Object error) => switch (error) {
  DesktopPrivilegeException(:final code) => code,
  WindowsLaunchException(:final detail) => detail,
  MacOSHelperException(:final code) => code,
  DesktopCoreFailure(:final cause) when cause != null => _desktopPrivilegeCode(
    cause,
  ),
  _ => null,
};

String urlSchemeErrorMessage(UrlSchemeIssue issue, AppLocalizations l) =>
    switch (issue) {
      UrlSchemeIssue.invalidLink => l.urlSchemeInvalidLink,
      UrlSchemeIssue.unknownCommand => l.urlSchemeUnknownCommand,
      UrlSchemeIssue.missingPayload => l.urlSchemeMissingPayload,
      UrlSchemeIssue.invalidUrl => l.urlSchemeInvalidUrl,
      UrlSchemeIssue.invalidName => l.urlSchemeInvalidName,
      UrlSchemeIssue.invalidBase64 => l.urlSchemeInvalidBase64,
      UrlSchemeIssue.tooLarge => l.urlSchemeTooLarge,
      UrlSchemeIssue.tooDeep => l.urlSchemeTooDeep,
      UrlSchemeIssue.unsupportedEncryption => l.urlSchemeUnsupportedEncryption,
      UrlSchemeIssue.authenticationFailed => l.urlSchemeAuthenticationFailed,
    };

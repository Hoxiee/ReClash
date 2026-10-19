import 'url_scheme.dart';
import 'package:reclash/common/constant.dart';
import 'package:reclash/common/exception.dart';
import 'package:reclash/common/network_error.dart';
import 'package:reclash/core/desktop/launch_policy.dart';
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

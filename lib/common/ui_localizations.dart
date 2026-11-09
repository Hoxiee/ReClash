import 'package:material_ui/material_ui.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/l10n.dart';

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

import 'package:material_ui/material_ui.dart';
import 'package:prism_ui/l10n.dart' as prism;
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

/// [prism_ui]'s own localization contract, fed from the app's strings so the
/// package's components speak the same language as the app.
class AppPrismUiLocalizations implements prism.UiLocalizations {
  const AppPrismUiLocalizations(this._localizations, this.dialog);

  static const LocalizationsDelegate<prism.UiLocalizations> delegate =
      _AppPrismUiLocalizationsDelegate();

  final AppLocalizations _localizations;

  @override
  final String dialog;

  @override
  String get back => _localizations.back;

  @override
  String get cancel => _localizations.cancel;

  @override
  String get clearSearch => _localizations.clearSearch;

  @override
  String get close => _localizations.close;

  @override
  String get copy => _localizations.copy;

  @override
  String get cut => _localizations.cut;

  @override
  String get hidePassword => _localizations.hidePassword;

  @override
  String get more => _localizations.more;

  @override
  String get noSearchResults => _localizations.noSearchResults;

  @override
  String get paste => _localizations.paste;

  @override
  String get reset => _localizations.reset;

  @override
  String get search => _localizations.search;

  @override
  String get select => _localizations.select;

  @override
  String get selectAll => _localizations.selectAll;

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

class _AppPrismUiLocalizationsDelegate
    extends LocalizationsDelegate<prism.UiLocalizations> {
  const _AppPrismUiLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale);

  @override
  Future<prism.UiLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale).then(
      (localizations) => _material(locale).then(
        (material) =>
            AppPrismUiLocalizations(localizations, material.dialogLabel),
      ),
    );
  }

  // The package names the dialog surface for semantics only, a word Material
  // already translates for every locale the app ships.
  Future<MaterialLocalizations> _material(Locale locale) {
    const delegate = GlobalMaterialLocalizations.delegate;
    return delegate.load(
      delegate.isSupported(locale) ? locale : const Locale('en'),
    );
  }

  @override
  bool shouldReload(_AppPrismUiLocalizationsDelegate old) => false;
}

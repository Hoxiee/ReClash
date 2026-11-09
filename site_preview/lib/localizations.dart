import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
// ignore: implementation_imports
import 'package:intl/src/intl_helpers.dart';
import 'package:reclash/l10n/intl/messages_ru.dart' as messages_ru;
import 'package:reclash/common/ui_localizations.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/l10n.dart';

const previewLocales = [Locale('en'), Locale('ru')];

/// [AppLocalizations] for the site's two languages. The generated delegate
/// would load the app's message tables for every locale it ships, which is
/// most of the preview's script; English needs none, since every message
/// falls back to its English source text.
class PreviewLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const PreviewLocalizationsDelegate();

  static var _registered = false;

  static void _register() {
    if (_registered) return;
    _registered = true;
    initializeInternalMessageLookup(CompositeMessageLookup.new);
    messageLookup.addLocale('ru', (_) => messages_ru.messages);
  }

  @override
  bool isSupported(Locale locale) =>
      previewLocales.any((it) => it.languageCode == locale.languageCode);

  static AppLocalizations _load(Locale locale) {
    _register();
    Intl.defaultLocale = locale.languageCode;
    return AppLocalizations();
  }

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(_load(locale));

  @override
  bool shouldReload(PreviewLocalizationsDelegate old) => false;
}

class PreviewUiLocalizationsDelegate
    extends LocalizationsDelegate<UiLocalizations> {
  const PreviewUiLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const PreviewLocalizationsDelegate().isSupported(locale);

  @override
  Future<UiLocalizations> load(Locale locale) => SynchronousFuture(
    AppUiLocalizations(PreviewLocalizationsDelegate._load(locale)),
  );

  @override
  bool shouldReload(PreviewUiLocalizationsDelegate old) => false;
}

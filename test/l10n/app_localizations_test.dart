import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('load resolves accessors for every supported locale', () async {
    for (final locale in AppLocalizations.delegate.supportedLocales) {
      final appLocalizations = await AppLocalizations.load(locale);

      expect(AppLocalizations.current, same(appLocalizations));
      expect(appLocalizations.dashboard, isNotEmpty);
      expect(appLocalizations.proxies, isNotEmpty);
      expect(appLocalizations.settings, isNotEmpty);
      expect(appLocalizations.secondsCount(30), contains('30'));
      expect(appLocalizations.geoUpdated('geoip'), contains('geoip'));
    }
  });

  test('delegate recognizes only supported locales', () {
    expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('de')), isFalse);
    expect(
      AppLocalizations.delegate.shouldReload(AppLocalizations.delegate),
      isFalse,
    );
  });

  test('fallback delegates cover locales missing package Material data', () {
    final materialClone = fallbackMaterialLocalizationsDelegates.firstWhere(
      (delegate) => delegate.type == MaterialLocalizations,
    );
    for (final locale in [
      const Locale('kk'),
      const Locale('tk'),
      const Locale('uz'),
    ]) {
      expect(
        materialClone.isSupported(locale),
        !GlobalMaterialLocalizations.delegate.isSupported(locale),
      );
    }
    expect(
      GlobalMaterialLocalizations.delegate.isSupported(const Locale('tk')),
      isFalse,
    );
    expect(materialClone.isSupported(const Locale('tk')), isTrue);
    expect(materialClone.isSupported(const Locale('en')), isFalse);
  });

  testWidgets('material localizations resolve for a locale without data', (
    tester,
  ) async {
    MaterialLocalizations? localizations;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tk'),
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          AppUiLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
          ...fallbackMaterialLocalizationsDelegates,
        ],
        home: Builder(
          builder: (context) {
            localizations = MaterialLocalizations.of(context);
            return const Scaffold(body: TextField());
          },
        ),
      ),
    );
    await tester.pump();

    expect(localizations, isNotNull);
  });
}

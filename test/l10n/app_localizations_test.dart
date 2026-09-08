import 'package:reclash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  test('load resolves accessors for every supported locale', () async {
    for (final locale in AppLocalizations.delegate.supportedLocales) {
      final appLocalizations = await AppLocalizations.load(locale);

      expect(AppLocalizations.current, same(appLocalizations));
      expect(appLocalizations.dashboard, isNotEmpty);
      expect(appLocalizations.proxies, isNotEmpty);
      expect(appLocalizations.settings, isNotEmpty);
      expect(appLocalizations.hoursCount(2), contains('2'));
      expect(appLocalizations.secondsCount(30), contains('30'));
      expect(appLocalizations.geoUpdated('geoip'), contains('geoip'));
    }
  });

  testWidgets('unsupported Flutter locale keeps Material resources', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        locale: const Locale('tk'),
        child: Builder(
          builder: (context) => Text(
            '${MaterialLocalizations.of(context).okButtonLabel} · '
            '${AppLocalizations.of(context).dashboard}',
          ),
        ),
      ),
    );

    expect(find.text('OK · Panel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('delegate recognizes only supported locales', () {
    expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('fr')), isFalse);
    expect(
      AppLocalizations.delegate.shouldReload(AppLocalizations.delegate),
      isFalse,
    );
  });
}

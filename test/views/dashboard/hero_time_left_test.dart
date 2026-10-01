import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_words.dart';

void main() {
  Future<void> pumpEnglish(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: [Locale('en')],
        home: SizedBox.shrink(),
      ),
    );
    await tester.pump();
  }

  testWidgets('heroTimeLeftWords splits days hours and minutes', (
    tester,
  ) async {
    await pumpEnglish(tester);

    expect(heroTimeLeftWords(const Duration(days: 3)), '3 days');
    expect(heroTimeLeftWords(const Duration(hours: 5, minutes: 10)), '5 hours');
    expect(heroTimeLeftWords(const Duration(hours: 2)), '2 hours');
    expect(heroTimeLeftWords(const Duration(minutes: 45)), '45 minutes');
    expect(heroTimeLeftWords(const Duration(seconds: 30)), '1 minute');
    expect(heroTimeLeftWords(Duration.zero), '0 days');
    expect(heroTimeLeftWords(const Duration(seconds: -5)), '0 days');
  });
}

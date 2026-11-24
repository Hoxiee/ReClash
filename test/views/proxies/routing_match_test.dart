import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/views/proxies/routing_match.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';

void main() {
  late AppLocalizations l;

  setUpAll(() async {
    await mockPreferences();
    l = await AppLocalizations.load(const Locale('en'));
  });

  Future<void> pump(
    WidgetTester tester, {
    List<String> match = const [],
  }) async {
    await tester.pumpWidget(
      TestApp(
        child: SingleChildScrollView(
          child: RouteTrafficSection(match: match, onChanged: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('custom rules and the Add entry row are always offered', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text(l.rcxMatchCustom), findsOneWidget);
    expect(find.text(l.rcxMatchAdd), findsOneWidget);
  });

  testWidgets('existing custom entries show beside the Add row', (
    tester,
  ) async {
    await pump(tester, match: const ['DOMAIN-SUFFIX,a.test']);
    expect(find.text('a.test'), findsOneWidget);
    expect(find.text(l.rcxMatchAdd), findsOneWidget);
  });
}

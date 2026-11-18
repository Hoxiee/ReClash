import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
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
    required bool advanced,
    List<String> match = const [],
  }) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [
          appSettingProvider.overrideWithBuild(
            (_, _) => AppSettingProps(routingAdvanced: advanced),
          ),
        ],
        child: SingleChildScrollView(
          child: RouteTrafficSection(match: match, onChanged: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('simple mode hides custom rules and the Add entry row', (
    tester,
  ) async {
    await pump(tester, advanced: false);
    expect(find.text(l.rcxMatchCustom), findsNothing);
    expect(find.text(l.rcxMatchAdd), findsNothing);
  });

  testWidgets('advanced mode shows custom rules and the Add entry row', (
    tester,
  ) async {
    await pump(tester, advanced: true);
    expect(find.text(l.rcxMatchCustom), findsOneWidget);
    expect(find.text(l.rcxMatchAdd), findsOneWidget);
  });

  testWidgets('existing custom entries show without Add in simple mode', (
    tester,
  ) async {
    await pump(tester, advanced: false, match: const ['DOMAIN-SUFFIX,a.test']);
    expect(find.text('a.test'), findsOneWidget);
    expect(find.text(l.rcxMatchAdd), findsNothing);
  });
}

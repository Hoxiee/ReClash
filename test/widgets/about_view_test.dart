import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/settings/about.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  setUpAll(() {
    globalState.packageInfo = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: '1.2.3',
      buildNumber: '42',
    );
  });

  Future<AppLocalizations> pumpAbout(WidgetTester tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [profilesProvider.overrideWith(TestProfiles.new)],
        child: const AboutView(),
      ),
    );
    await tester.pump();
    return AppLocalizations.load(const Locale('en'));
  }

  testWidgets('credits the author and thanks the upstream projects', (
    tester,
  ) async {
    final l10n = await pumpAbout(tester);
    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text(l10n.madeBy),
      200,
      scrollable: scrollable,
    );
    expect(find.text(l10n.madeBy), findsOneWidget);
    expect(find.text('Hoxiee'), findsOneWidget);
    expect(find.text(l10n.roleAuthor), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(l10n.gratitude),
      200,
      scrollable: scrollable,
    );
    expect(find.text(l10n.gratitude), findsOneWidget);
    for (final name in ['chen08209', 'pluralplay', 'MetaCubeX']) {
      await tester.scrollUntilVisible(
        find.text(name),
        200,
        scrollable: scrollable,
      );
      expect(find.text(name), findsOneWidget);
    }
    expect(tester.takeException(), null);
  });

  testWidgets('shows version chips and the link section', (tester) async {
    final l10n = await pumpAbout(tester);
    final scrollable = find.byType(Scrollable).first;

    expect(find.text('v1.2.3'), findsOneWidget);
    expect(find.text(l10n.desc), findsOneWidget);

    for (final label in [l10n.sourceCode, l10n.license, 'Telegram']) {
      await tester.scrollUntilVisible(
        find.text(label),
        200,
        scrollable: scrollable,
      );
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), null);
  });

  testWidgets('opens the bundled packages license page', (tester) async {
    final l10n = await pumpAbout(tester);

    await tester.scrollUntilVisible(
      find.text(l10n.licenses),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(l10n.licenses));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.licenses));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
    expect(tester.takeException(), null);
  });
}

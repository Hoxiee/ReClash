import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/about.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_app.dart';

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
      const TestApp(wrapInProviderScope: true, child: AboutView()),
    );
    await tester.pump();
    return AppLocalizations.load(const Locale('en'));
  }

  testWidgets('credits the author and thanks the upstream projects', (
    tester,
  ) async {
    final l10n = await pumpAbout(tester);

    expect(find.text(l10n.madeBy), findsOneWidget);
    expect(find.text('Hoxiee'), findsOneWidget);
    expect(find.text(l10n.roleAuthor), findsOneWidget);

    expect(find.text(l10n.gratitude), findsOneWidget);
    for (final name in ['chen08209', 'pluralplay', 'MetaCubeX']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(tester.takeException(), null);
  });

  testWidgets('shows version chips and the link section', (tester) async {
    final l10n = await pumpAbout(tester);

    expect(find.text('v1.2.3'), findsOneWidget);
    expect(find.text(l10n.desc), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pump();

    expect(find.text(l10n.sourceCode), findsOneWidget);
    expect(find.text(l10n.license), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(tester.takeException(), null);
  });
}

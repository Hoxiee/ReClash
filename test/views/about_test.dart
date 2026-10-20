import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/about.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_app.dart';

Future<void> _pumpAbout(
  WidgetTester tester, {
  Size size = const Size(1200, 1800),
  Locale locale = const Locale('en'),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        locale: locale,
        homeBuilder: (child) => Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child,
          ),
        ),
        child: const AboutView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    globalState.packageInfo = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: '0.0.0',
      buildNumber: '1',
    );
  });

  testWidgets('identifies the maintainer and puts acknowledgments last', (
    tester,
  ) async {
    await _pumpAbout(tester);
    final l10n = AppLocalizations.current;

    expect(find.text('Maintainer'), findsOneWidget);
    expect(find.text('Hoxiee'), findsOneWidget);
    expect(find.text('v0.0.0'), findsOneWidget);
    expect(
      tester
          .widgetList<ListHeader>(find.byType(ListHeader))
          .map((header) => header.title),
      [l10n.maintainer, l10n.more, l10n.gratitude],
    );
    expect(find.text('Made by'), findsNothing);
    expect(find.text('Author and maintainer'), findsNothing);
    expect(find.text(l10n.otherContributors), findsNothing);
    expect(find.text('June2'), findsNothing);
    expect(find.text('Arue'), findsNothing);
    expect(find.text(l10n.license), findsOneWidget);
    expect(find.text(l10n.licenses), findsOneWidget);
    final credits = {
      'FlClash': 'chen08209',
      'FlClashX': 'pluralplay',
      'FlClash-Patched': 'chenx-dust',
      'mihomo': 'MetaCubeX',
      'ByeDPI': 'hufrea',
    };
    for (final credit in credits.entries) {
      expect(find.text(credit.key).hitTestable(), findsOneWidget);
      expect(find.text(credit.value).hitTestable(), findsOneWidget);
    }
    expect(
      tester
          .widgetList<CircleAvatar>(find.byType(CircleAvatar))
          .map((avatar) => (avatar.foregroundImage! as AssetImage).assetName),
      containsAll([
        'assets/images/avatar/chen08209.jpg',
        'assets/images/avatar/pluralplay.jpg',
        'assets/images/avatar/chenx-dust.jpg',
        'assets/images/avatar/metacubex.jpg',
        'assets/images/avatar/hufrea.jpg',
      ]),
    );
    expect(find.byTooltip('chen08209: ${l10n.creditFlClash}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Russian acknowledgments stay reachable with large text', (
    tester,
  ) async {
    await _pumpAbout(
      tester,
      size: const Size(320, 640),
      locale: const Locale('ru'),
      textScale: 1.8,
    );

    await tester.scrollUntilVisible(
      find.text('Мейнтейнер'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Автор'), findsNothing);
    expect(find.text('Автор и мейнтейнер'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('ByeDPI'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Благодарности'), findsOneWidget);
    expect(find.text('hufrea').hitTestable(), findsOneWidget);
    expect(find.text('Другие участники'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'maintainer and project links preserve destination confirmation',
    (tester) async {
      await _pumpAbout(tester);
      final l10n = AppLocalizations.current;
      final destinations = {
        'Hoxiee': 'https://github.com/Hoxiee',
        'FlClash': 'https://github.com/chen08209/FlClash',
        'FlClashX': 'https://github.com/pluralplay/FlClashX',
        'FlClash-Patched': 'https://github.com/chenx-dust/FlClash-Patched',
        'mihomo': 'https://github.com/MetaCubeX/mihomo',
        'ByeDPI': 'https://github.com/hufrea/byedpi',
      };

      for (final entry in destinations.entries) {
        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();
        expect(find.text(l10n.externalLink), findsOneWidget);
        expect(find.text(entry.value, findRichText: true), findsOneWidget);
        await tester.tap(find.text(l10n.cancel));
        await tester.pumpAndSettle();
        expect(find.text(l10n.externalLink), findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );
}

import 'dart:async';

import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/regional/region_detection.dart';
import 'package:reclash/common/regional/regional_network.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/region.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late Future<RegionDetectionResult?> Function() detect;

  setUp(() {
    detect = () async =>
        const RegionDetectionResult('CN', RegionDetectionSource.timeZone);
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        detectedRegionProvider.overrideWith((ref) => detect()),
      ],
    );
    globalState.container = container;
    container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
    container.listen(
      patchClashConfigProvider,
      (_, _) {},
      fireImmediately: true,
    );
    container.listen(networkSettingProvider, (_, _) {}, fireImmediately: true);
    container.listen(
      currentProfileIdProvider,
      (_, _) {},
      fireImmediately: true,
    );
  });

  tearDown(() => container.dispose());

  Future<void> pumpRegionView(
    WidgetTester tester, {
    Size size = const Size(1200, 1800),
    Locale locale = const Locale('en'),
    bool inSheet = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).value = size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          locale: locale,
          child: inSheet
              ? Builder(
                  builder: (context) => FilledButton(
                    onPressed: () => showFormSheet<void>(
                      context: context,
                      builder: (_) => const RegionView(),
                    ),
                    child: const Text('Open region'),
                  ),
                )
              : const RegionView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (inSheet) {
      await tester.tap(find.text('Open region'));
      await tester.pumpAndSettle();
    }
  }

  Future<void> choose(WidgetTester tester, String name) async {
    await tester.ensureVisible(find.text(name).last);
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  Finder applyButton() => find.ancestor(
    of: find.byTooltip('Apply region'),
    matching: find.byType(IconButton),
  );

  testWidgets('a device suggestion is only marked until a country is applied', (
    tester,
  ) async {
    await pumpRegionView(tester);
    expect(find.text('Recommended for this device'), findsOneWidget);
    expect(find.text('What changes'), findsNothing);
    expect(tester.widget<IconButton>(applyButton()).onPressed, isNull);
    await choose(tester, 'China');
    expect(find.text('What changes'), findsOneWidget);
    expect(container.read(appSettingProvider).regionCode, isNull);
    await tester.tap(find.byTooltip('Apply region'));
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).regionCode, 'CN');
    expect(
      container.read(networkSettingProvider).bypassDomain,
      contains('*zhihu.com'),
    );
  });

  testWidgets('applying a country writes its defaults into settings', (
    tester,
  ) async {
    await pumpRegionView(tester);
    await choose(tester, 'Russia');
    expect(find.text('DNS servers'), findsOneWidget);
    expect(find.text('TUN MTU'), findsOneWidget);
    expect(
      find.text('Values you changed yourself stay as they are.'),
      findsOneWidget,
    );
    expect(find.textContaining('77.88.8.8'), findsNothing);
    await tester.tap(find.byTooltip('Apply region'));
    await tester.pumpAndSettle();

    final patch = container.read(patchClashConfigProvider);
    expect(patch.dns.nameserver, ['tls://77.88.8.8', 'tls://77.88.8.1']);
    expect(patch.dnsOverrideKeys, regionDnsKeys('RU'));
    expect(patch.tun.mtu, regionalDefaultTunMtu);
    expect(
      container.read(networkSettingProvider).bypassDomain,
      defaultBypassDomain,
    );
  });

  testWidgets(
    'region sheet keeps close left and apply right without footer copies',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      container.read(viewSizeProvider.notifier).value = const Size(1200, 900);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showFormSheet<void>(
                  context: context,
                  builder: (_) => const RegionView(),
                ),
                child: const Text('Open region'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open region'));
      await tester.pumpAndSettle();

      final close = find.byTooltip('Close');
      final apply = applyButton();
      expect(close, findsOneWidget);
      expect(apply, findsOneWidget);
      expect(tester.getCenter(close).dx, lessThan(tester.getCenter(apply).dx));
      expect(find.widgetWithText(FilledButton, 'Apply region'), findsNothing);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsNothing);
    },
  );

  testWidgets('unchanged saved region disables apply', (tester) async {
    container.read(systemActionProvider.notifier).applyRegion('RU');
    await pumpRegionView(tester);
    expect(tester.widget<IconButton>(applyButton()).onPressed, isNull);
    expect(find.text('What changes'), findsNothing);
  });

  testWidgets('cancelling a country preview leaves stored settings unchanged', (
    tester,
  ) async {
    container.read(systemActionProvider.notifier).applyRegion('RU');
    final stored = container.read(configProvider);
    await pumpRegionView(tester, inSheet: true);
    await choose(tester, 'Iran');
    expect(find.text('What changes'), findsOneWidget);
    expect(container.read(configProvider), stored);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    expect(container.read(configProvider), stored);
  });

  testWidgets('failed detection does not block a manual choice', (
    tester,
  ) async {
    detect = () => Future.error(StateError('unavailable'));
    await pumpRegionView(tester);
    expect(find.text('Recommended for this device'), findsNothing);
    await choose(tester, 'Egypt');
    expect(tester.widget<IconButton>(applyButton()).onPressed, isNotNull);
  });

  testWidgets('detection arriving later never replaces the manual draft', (
    tester,
  ) async {
    final gate = Completer<RegionDetectionResult?>();
    detect = () => gate.future;
    await pumpRegionView(tester);
    await choose(tester, 'Iran');
    gate.complete(
      const RegionDetectionResult('RU', RegionDetectionSource.localeCountry),
    );
    await tester.pumpAndSettle();
    final iran = tester.widget<DecorationListItem>(
      find.ancestor(
        of: find.text('Iran'),
        matching: find.byType(DecorationListItem),
      ),
    );
    expect(iran.isSelected, isTrue);
    expect(container.read(appSettingProvider).regionCode, isNull);
  });

  testWidgets(
    'a Russian mobile choice applies without changing interface locale',
    (tester) async {
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(locale: 'ru'));
      await pumpRegionView(
        tester,
        size: const Size(390, 700),
        locale: const Locale('ru'),
      );
      expect(find.text('Рекомендуется для этого устройства'), findsOneWidget);
      await choose(tester, 'Китай');
      await tester.tap(find.byTooltip('Применить регион'));
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).regionCode, 'CN');
      expect(container.read(appSettingProvider).locale, 'ru');
      expect(tester.takeException(), isNull);
    },
  );
}

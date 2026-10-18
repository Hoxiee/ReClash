import 'dart:async';

import 'package:reclash/common/regional/region_detection.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/region.dart';
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
    bool isAndroid = false,
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
          child: RegionView(isAndroid: isAndroid),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String name) async {
    await tester.ensureVisible(find.text('Choose a country'));
    await tester.tap(find.text('Choose a country'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  Finder applyButton() => find.widgetWithText(FilledButton, 'Apply region');

  testWidgets(
    'a device suggestion remains a preview until explicitly applied',
    (tester) async {
      await pumpRegionView(tester);
      expect(find.text('Suggested: China · time zone'), findsOneWidget);
      expect(find.text('Country profile: Off'), findsOneWidget);
      expect(tester.widget<FilledButton>(applyButton()).onPressed, isNull);
      await tester.tap(find.text('Use detected region'));
      await tester.pumpAndSettle();
      expect(find.text('Country profile: China'), findsOneWidget);
      expect(container.read(appSettingProvider).regionCode, isNull);
      await tester.tap(applyButton());
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).regionCode, 'CN');
    },
  );

  testWidgets('unchanged saved region disables apply', (tester) async {
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(regionCode: 'RU'));
    await pumpRegionView(tester);
    expect(tester.widget<FilledButton>(applyButton()).onPressed, isNull);
    expect(container.read(appSettingProvider).regionCode, 'RU');
  });

  testWidgets(
    'cancelling a country preview leaves stored and effective state unchanged',
    (tester) async {
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(regionCode: 'RU'));
      final stored = container.read(configProvider);
      final effective = container.read(regionalNetworkConfigProvider);
      await pumpRegionView(tester);
      await choose(tester, 'Iran');
      expect(find.text('Country profile: Iran'), findsOneWidget);
      expect(container.read(configProvider), stored);
      expect(container.read(regionalNetworkConfigProvider), effective);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      expect(container.read(configProvider), stored);
      expect(container.read(regionalNetworkConfigProvider), effective);
    },
  );

  testWidgets('turning adaptation off restores raw network settings', (
    tester,
  ) async {
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(regionCode: 'RU'));
    final raw = container.read(patchClashConfigProvider);
    await pumpRegionView(tester);
    await choose(tester, 'Off');
    expect(container.read(appSettingProvider).regionCode, 'RU');
    expect(find.textContaining('Profile defaults'), findsWidgets);
    await tester.tap(applyButton());
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).regionCode, isNull);
    expect(container.read(regionalNetworkConfigProvider).patchConfig, raw);
  });

  testWidgets('empty and failed detection do not block a manual choice', (
    tester,
  ) async {
    detect = () async => null;
    await pumpRegionView(tester);
    expect(
      find.text(
        'No matching suggestion. Only the time zone and system locale are used.',
      ),
      findsOneWidget,
    );
    await choose(tester, 'Egypt');
    expect(find.text('Country profile: Egypt'), findsOneWidget);
    detect = () => Future.error(StateError('unavailable'));
    await tester.tap(find.byTooltip('Update'));
    await tester.pumpAndSettle();
    expect(find.text('Country profile: Egypt'), findsOneWidget);
    expect(tester.widget<FilledButton>(applyButton()).onPressed, isNotNull);
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
    expect(find.text('Country profile: Iran'), findsOneWidget);
    expect(container.read(appSettingProvider).regionCode, isNull);
  });

  testWidgets(
    'a Russian mobile preview scrolls to apply without changing interface locale',
    (tester) async {
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(locale: 'ru'));
      await pumpRegionView(
        tester,
        size: const Size(390, 700),
        locale: const Locale('ru'),
        isAndroid: true,
      );
      await tester.tap(find.text('Выбрать определённый регион'));
      await tester.pumpAndSettle();
      final button = find.widgetWithText(FilledButton, 'Применить регион');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).regionCode, 'CN');
      expect(container.read(appSettingProvider).locale, 'ru');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('preview respects the current custom-profile DNS and MTU', (
    tester,
  ) async {
    container
        .read(profilesProvider.notifier)
        .put(
          const Profile(
            id: 9,
            type: ProfileType.custom,
            autoUpdateDuration: Duration.zero,
            overrides: ProfileOverrides(
              dns: Dns(nameserver: ['https://private.example/dns-query']),
              dnsOverrideKeys: {DnsOverrideKey.nameserver},
              tun: ProfileTun(mtu: 1360),
              tunOverrideKeys: {TunOverrideKey.mtu},
            ),
          ),
        );
    container.read(currentProfileIdProvider.notifier).value = 9;
    await pumpRegionView(tester);
    await choose(tester, 'Russia');
    expect(
      find.textContaining(
        RegExp(r'^nameserver: tls://77\.88\.8\.8', multiLine: true),
      ),
      findsNothing,
    );
    expect(
      find.textContaining('default-nameserver: 77.88.8.8'),
      findsOneWidget,
    );
    expect(find.text('TUN MTU: 1500'), findsNothing);
  });
}

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/smart_routing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _profileId = 77;

final _russia = const SmartRoutingProps(
  enabled: true,
).applyPreset(SmartRoutingPreset.russia);

Future<void> _reveal(
  WidgetTester tester,
  Finder finder, {
  double delta = 250,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required SmartRoutingProps props,
  Profile? profile,
  Size size = const Size(1000, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: profile == null
        ? const []
        : [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => _profileId),
          ],
  );
  addTearDown(container.dispose);
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1000, 800));
  container.read(smartRoutingSettingProvider.notifier).value = props;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(
        includeNavigatorKey: true,
        child: SmartRoutingView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('a disabled engine shows nothing to tune', (tester) async {
    await _pump(tester, props: const SmartRoutingProps());

    expect(find.text('Smart routing'), findsWidgets);
    expect(find.text('Region'), findsNothing);
    expect(find.text('Behaviour'), findsNothing);
  });

  testWidgets('the intro card is omitted', (tester) async {
    await _pump(tester, props: const SmartRoutingProps());

    expect(find.textContaining('Start from a region preset'), findsNothing);

    await tester.tap(find.byType(Switch), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.textContaining('Start from a region preset'), findsNothing);
  });

  testWidgets('the mid layer is settings, never weights', (tester) async {
    await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
      ),
    );

    expect(find.text('Region'), findsOne);
    expect(find.text('Require UDP support'), findsOne);
    expect(find.text('Settle time'), findsOne);
    await _reveal(tester, find.text('Servers per check'), delta: 200);

    expect(find.text('Servers per check'), findsOne);
  });

  for (final title in ['Open-internet checks', 'Local checks']) {
    testWidgets('$title uses the standard list editor', (tester) async {
      await _pump(
        tester,
        props: const SmartRoutingProps(
          enabled: true,
          preset: SmartRoutingPreset.russia,
          openMarkers: [
            RcxMarker(url: 'https://example.com/open', statuses: [204]),
          ],
          domesticMarkers: [
            RcxMarker(url: 'https://example.com/local', statuses: [200]),
          ],
        ),
      );

      await _reveal(tester, find.text(title), delta: 300);
      await tester.tap(find.text(title), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(ReorderableListView), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Add'), findsOneWidget);
    });
  }

  testWidgets('an adjusted preset says so and can be reset', (tester) async {
    final container = await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
        requireUdp: true,
      ),
    );

    expect(find.text('Russia · adjusted'), findsOne);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    final props = container.read(smartRoutingSettingProvider);
    expect(props.matchesPreset, isTrue);
    expect(props.enabled, isTrue);
    expect(find.text('Russia'), findsAtLeast(1));
  });

  testWidgets('the strategy is named in plain words with what it does', (
    tester,
  ) async {
    await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
      ),
    );

    await _reveal(tester, find.text('Strategy'));
    await tester.tap(find.text('Strategy'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(
      find.text('Keeps a working server and changes it less often'),
      findsOne,
    );
    expect(find.text('Takes the quickest of the servers that work'), findsOne);
    expect(
      find.text('Checks servers less often, saving data and battery'),
      findsOne,
    );
  });

  testWidgets('picking a strategy repaces the engine and leaves the region', (
    tester,
  ) async {
    final container = await _pump(tester, props: _russia);

    await _reveal(tester, find.text('Strategy'));
    await tester.tap(find.text('Strategy'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saver').last);
    await tester.pumpAndSettle();

    final props = container.read(smartRoutingSettingProvider);
    expect(props.strategy, SmartRoutingStrategy.saver);
    expect(props.dwellSeconds, SmartRoutingStrategy.saver.pacing.dwellSeconds);
    expect(props.matchesStrategy, isTrue);
    expect(props.matchesPreset, isTrue);
    expect(find.text('Russia · adjusted'), findsNothing);
  });

  testWidgets('a hand-moved pace marks the strategy and resets back', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      props: _russia
          .applyStrategy(SmartRoutingStrategy.stable)
          .copyWith(dwellSeconds: 30),
    );

    await _reveal(tester, find.text('Strategy'));

    expect(find.text('Reliable · adjusted'), findsOne);
    final reset = find.text('Reset');
    await tester.ensureVisible(reset);
    await tester.pumpAndSettle();
    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    final props = container.read(smartRoutingSettingProvider);
    expect(props.matchesStrategy, isTrue);
    expect(props.dwellSeconds, SmartRoutingStrategy.stable.pacing.dwellSeconds);
  });

  testWidgets('service routes summarize profile capability sources', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'profile').copyWith(
      id: _profileId,
      capabilityManifest: ProviderCapabilityManifest(
        version: 1,
        claims: const [
          CapabilityClaim(
            capabilityId: 'gemini-access',
            selectors: [
              CapabilitySelector(provider: 'premium', nameContains: 'star'),
            ],
          ),
        ],
        receivedAt: DateTime.utc(2026, 9, 10),
        sourceHost: 'provider.test',
      ),
      manualCapabilitySelectors: const [
        ManualCapabilitySelector(
          capabilityId: 'gemini-access',
          nameContains: 'spark',
        ),
      ],
    );
    await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
      ),
      profile: profile,
    );

    await _reveal(tester, find.text('Gemini access'));

    expect(find.text('2 specialist selectors'), findsOneWidget);
    expect(find.text('No specialist selectors'), findsOneWidget);
  });

  testWidgets('service route toggle persists in the active profile', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'profile').copyWith(id: _profileId);
    final container = await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
      ),
      profile: profile,
    );

    await _reveal(tester, find.text('Gemini access'));
    await tester.tap(find.text('Gemini access'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Use service route'));
    await tester.pumpAndSettle();

    final updated = container.read(currentProfileProvider)!;
    expect(
      updated.serviceRoutePolicies
          .singleWhere((policy) => policy.capabilityId == 'gemini-access')
          .enabled,
      isTrue,
    );
  });

  testWidgets('service route UI is inert without an active profile', (
    tester,
  ) async {
    await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
      ),
    );

    await _reveal(tester, find.text('Gemini access'));
    await tester.tap(find.text('Gemini access'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the open service route page reflects an edit in place', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'profile').copyWith(id: _profileId);
    await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
      ),
      profile: profile,
    );

    await _reveal(tester, find.text('Gemini access'));
    await tester.tap(find.text('Gemini access'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Status'), findsNothing);

    await tester.tap(find.widgetWithText(ListTile, 'Use service route'));
    await tester.pumpAndSettle();

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Waiting for the engine'), findsOneWidget);
  });

  testWidgets('the fallback row shows the choice and swaps it in place', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'profile').copyWith(id: _profileId);
    await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
      ),
      profile: profile,
    );

    await _reveal(tester, find.text('Gemini access'));
    await tester.tap(find.text('Gemini access'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Use the main Smart Routing node'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'When no specialist works'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block the service').last);
    await tester.pumpAndSettle();

    expect(find.text('Block the service'), findsOneWidget);
    expect(find.text('Use the main Smart Routing node'), findsNothing);
  });

  testWidgets('the fallback choice does not squeeze its row on a phone', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'profile').copyWith(id: _profileId);
    await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
      ),
      profile: profile,
      size: const Size(360, 800),
    );

    await _reveal(tester, find.text('Gemini access'));
    await tester.tap(find.text('Gemini access'), warnIfMissed: false);
    await tester.pumpAndSettle();

    final title = tester.renderObject<RenderBox>(
      find.text('When no specialist works'),
    );
    expect(title.size.width, greaterThan(150));
    expect(find.text('Use the main Smart Routing node'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dismissing the fallback dialog changes nothing', (tester) async {
    final profile = Profile.normal(label: 'profile').copyWith(id: _profileId);
    final container = await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
      ),
      profile: profile,
    );

    await _reveal(tester, find.text('Gemini access'));
    await tester.tap(find.text('Gemini access'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'When no specialist works'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Use the main Smart Routing node'), findsOneWidget);
    expect(
      container.read(currentProfileProvider)!.serviceRoutePolicies,
      isEmpty,
    );
  });

  testWidgets(
    'region selection shares HWID consent and preserves manual edits',
    (tester) async {
      final container = await _pump(
        tester,
        props: const SmartRoutingProps(enabled: true)
            .applyPreset(SmartRoutingPreset.iran)
            .applyStrategy(SmartRoutingStrategy.saver),
      );
      await tester.tap(find.text('Region'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Russia').last);
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).region, AppRegion.russia);
      expect(container.read(appSettingProvider).sendDeviceIdentity, isTrue);
      expect(container.read(smartRoutingSettingProvider).enabled, isTrue);
      expect(
        container.read(smartRoutingSettingProvider).strategy,
        SmartRoutingStrategy.saver,
      );

      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(sendDeviceIdentity: false));
      final edited = container
          .read(smartRoutingSettingProvider)
          .copyWith(
            openMarkers: const [
              RcxMarker(url: 'https://example.com/', statuses: [204]),
            ],
          );
      container.read(smartRoutingSettingProvider.notifier).value = edited;
      await tester.pumpAndSettle();
      await tester.tap(find.text('Region'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Russia').last);
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
      expect(container.read(smartRoutingSettingProvider), edited);
    },
  );

  testWidgets('turning it on from Other uses neutral markers, not the locale', (
    tester,
  ) async {
    final container = await _pump(tester, props: const SmartRoutingProps());
    final previousLocale = Intl.defaultLocale;
    addTearDown(() => Intl.defaultLocale = previousLocale);
    Intl.defaultLocale = 'ru';

    await tester.tap(find.byType(Switch), warnIfMissed: false);
    await tester.pumpAndSettle();

    final props = container.read(smartRoutingSettingProvider);
    expect(props.enabled, isTrue);
    expect(props.rcxParams.enabled, isTrue);
    expect(props.preset, SmartRoutingPreset.off);
    expect(props.openMarkers, isNotEmpty);
    expect(props.canaryForeign, isNotEmpty);
    expect(props.censorCountries, isEmpty);
    expect(container.read(appSettingProvider).region, isNull);
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
  });
}

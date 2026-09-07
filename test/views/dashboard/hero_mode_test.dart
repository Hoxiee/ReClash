import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/desync.dart';
import 'package:reclash/views/dashboard/widgets/hero_connect.dart';
import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _TestDesyncSetting extends DesyncSetting {
  _TestDesyncSetting(this._initial);

  final DesyncProps _initial;

  @override
  DesyncProps build() => _initial;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpHero(
    WidgetTester tester, {
    DesyncProps desync = const DesyncProps(),
    List<Profile> profiles = const [],
    int? currentProfileId,
  }) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles(profiles)),
        currentProfileIdProvider.overrideWithBuild((_, _) => currentProfileId),
        desyncSettingProvider.overrideWith(() => _TestDesyncSetting(desync)),
        groupsProvider.overrideWithValue(const []),
        tunEnabledProvider.overrideWith((ref) => true),
        initProvider.overrideWithBuild((_, _) => true),
        isStartProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(900, 1600));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          child: Scaffold(body: HeroConnect()),
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets('only-dpi mode shows the orb without any profile', (
    tester,
  ) async {
    await pumpHero(
      tester,
      desync: const DesyncProps(enabled: true, onlyDpi: true),
    );

    expect(find.byType(HeroOrb), findsOneWidget);
    expect(
      tester.widget<HeroOrb>(find.byType(HeroOrb)).variant,
      HeroOrbVariant.byedpi,
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('byedpi-core-mark')), findsOneWidget);
    expect(find.text('DPI bypass is active'), findsOneWidget);
    expect(find.text('You are protected'), findsNothing);
    expect(find.text('Add profile'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('without a profile and without the bypass the hero stays empty', (
    tester,
  ) async {
    await pumpHero(tester);

    expect(find.byType(HeroOrb), findsNothing);
    expect(find.text('Set up a connection'), findsOneWidget);
    expect(find.text('Add profile'), findsOneWidget);
    expect(find.text('No VPN provider?'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('saved profiles without an active one offer profile selection', (
    tester,
  ) async {
    const profile = Profile(id: 7, autoUpdateDuration: Duration.zero);
    final container = await pumpHero(tester, profiles: const [profile]);

    expect(find.byType(HeroOrb), findsNothing);
    expect(find.text('Choose a VPN profile'), findsOneWidget);
    expect(find.text('Choose profile'), findsOneWidget);
    expect(find.text('Add profile'), findsOneWidget);

    await tester.tap(find.text('Choose profile'));
    expect(container.read(currentPageLabelProvider), PageLabel.profiles);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a long press on the orb switches the mode', (tester) async {
    final container = await pumpHero(
      tester,
      desync: const DesyncProps(enabled: true, onlyDpi: true),
    );

    await tester.longPress(find.byType(HeroOrb));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Connection mode'), findsOneWidget);

    await tester.tap(find.text('VPN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(desyncSettingProvider).enabled, isFalse);
    expect(container.read(desyncSettingProvider).onlyDpi, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('only-dpi mode shows dashboard cards instead of settings', (
    tester,
  ) async {
    await pumpHero(
      tester,
      desync: const DesyncProps(enabled: true, onlyDpi: true),
    );

    expect(find.byType(DesyncControls), findsNothing);
    expect(find.text('Default ladder'), findsOneWidget);
    expect(find.text('Strategy test'), findsOneWidget);
    expect(find.text('Engine'), findsOneWidget);
    expect(find.text('Port 7898', skipOffstage: false), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('strategy card opens the strategy page', (tester) async {
    await pumpHero(
      tester,
      desync: const DesyncProps(enabled: true, onlyDpi: true),
    );

    await tester.tap(find.text('Default ladder'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(DesyncStrategyView), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DesyncStrategyView),
        matching: find.text('Save current'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('test card opens the strategy test page', (tester) async {
    await pumpHero(
      tester,
      desync: const DesyncProps(enabled: true, onlyDpi: true),
    );

    await tester.tap(find.text('Strategy test'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(DesyncTestView), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DesyncTestView),
        matching: find.text('Run every preset'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('engine card opens engine and routing settings', (tester) async {
    await pumpHero(
      tester,
      desync: const DesyncProps(enabled: true, onlyDpi: true),
    );

    await tester.tap(find.text('Engine'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(DesyncEngineView), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DesyncEngineView),
        matching: find.text('Strategy cache'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(DesyncEngineView),
        matching: find.text('Routing'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the empty hero can switch into only-dpi mode', (tester) async {
    final container = await pumpHero(tester);

    expect(find.byType(HeroOrb), findsNothing);
    await tester.tap(find.text('No VPN provider?'));
    await tester.pump();

    expect(container.read(desyncSettingProvider).onlyDpi, isTrue);
    expect(find.byType(HeroOrb), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}

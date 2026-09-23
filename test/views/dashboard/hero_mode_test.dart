import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/desync.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_connect.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_status.dart';
import 'package:reclash/widgets/widgets.dart';
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

class _ModeSetupAction extends SetupAction {
  static UiOutboundMode? selected;

  @override
  void changeUiMode(UiOutboundMode mode) {
    selected = mode;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpHero(
    WidgetTester tester, {
    DesyncProps desync = const DesyncProps(featureEnabled: true),
    List<Profile> profiles = const [],
    int? currentProfileId,
    bool byeDpiSupported = true,
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
        byeDpiSupportedProvider.overrideWithValue(byeDpiSupported),
        setupActionProvider.overrideWith(_ModeSetupAction.new),
        groupsProvider.overrideWithValue(const []),
        tunEnabledProvider.overrideWith((ref) => true),
        initProvider.overrideWithBuild((_, _) => true),
        isStartProvider.overrideWithValue(true),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(appSettingProvider.notifier).value = const AppSettingProps(region: AppRegion.russia);
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(900, 1600));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: Scaffold(body: HeroConnect())),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets('the orb keeps its authored size in both modes', (tester) async {
    const profile = Profile(
      id: 7,
      label: 'Local profile',
      autoUpdateDuration: Duration.zero,
    );
    final container = await pumpHero(
      tester,
      profiles: const [profile],
      currentProfileId: profile.id,
    );
    final vpnSize = tester.widget<HeroOrb>(find.byType(HeroOrb)).size;

    container
        .read(desyncSettingProvider.notifier)
        .update((state) => state.copyWith(enabled: true, onlyDpi: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final byedpiSize = tester.widget<HeroOrb>(find.byType(HeroOrb)).size;

    expect(vpnSize, heroOrbBaseSize);
    expect(byedpiSize, heroOrbBaseSize);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('only-dpi mode shows the orb without any profile', (
    tester,
  ) async {
    await pumpHero(
      tester,
      desync: const DesyncProps(featureEnabled: true, enabled: true, onlyDpi: true),
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

  testWidgets('the mode chip enters only-dpi from the outbound menu', (
    tester,
  ) async {
    const profile = Profile(
      id: 7,
      label: 'Local profile',
      autoUpdateDuration: Duration.zero,
    );
    final container = await pumpHero(
      tester,
      profiles: const [profile],
      currentProfileId: profile.id,
    );

    await tester.tap(find.byTooltip('Rule'));
    await tester.pump();

    final popup = tester
        .widgetList<CommonPopupMenu>(find.byType(CommonPopupMenu))
        .last;
    expect(popup.items.last.label, 'ByeDPI');
    popup.items.last.onPressed!();
    await tester.pump();

    expect(container.read(desyncSettingProvider).enabled, isTrue);
    expect(container.read(desyncSettingProvider).onlyDpi, isTrue);
    expect(find.byTooltip('ByeDPI'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('unsupported platforms hide and ignore ByeDPI mode', (
    tester,
  ) async {
    const profile = Profile(
      id: 7,
      label: 'Local profile',
      autoUpdateDuration: Duration.zero,
    );
    await pumpHero(
      tester,
      desync: const DesyncProps(featureEnabled: true, enabled: true, onlyDpi: true),
      profiles: const [profile],
      currentProfileId: profile.id,
      byeDpiSupported: false,
    );

    expect(find.byTooltip('Rule'), findsOneWidget);
    expect(find.text('DPI bypass without VPN'), findsNothing);

    await tester.tap(find.byTooltip('Rule'));
    await tester.pump();

    final popup = tester
        .widgetList<CommonPopupMenu>(find.byType(CommonPopupMenu))
        .last;
    expect(popup.items.map((item) => item.label), isNot(contains('ByeDPI')));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the mode chip leaves only-dpi for an outbound mode', (
    tester,
  ) async {
    _ModeSetupAction.selected = null;
    final container = await pumpHero(
      tester,
      desync: const DesyncProps(featureEnabled: true, enabled: true, onlyDpi: true),
    );

    await tester.tap(find.byTooltip('ByeDPI'));
    await tester.pump();

    expect(find.text('ByeDPI'), findsOneWidget);
    expect(find.text('Rule'), findsOneWidget);
    expect(find.text('Direct'), findsOneWidget);
    expect(find.text('Global'), findsOneWidget);

    final popup = tester
        .widgetList<CommonPopupMenu>(find.byType(CommonPopupMenu))
        .last;
    popup.items.singleWhere((item) => item.label == 'Direct').onPressed!();
    await tester.pump();

    expect(container.read(desyncSettingProvider).enabled, isFalse);
    expect(container.read(desyncSettingProvider).onlyDpi, isFalse);
    expect(_ModeSetupAction.selected, UiOutboundMode.direct);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('only-dpi mode shows dashboard cards instead of settings', (
    tester,
  ) async {
    await pumpHero(
      tester,
      desync: const DesyncProps(featureEnabled: true, enabled: true, onlyDpi: true),
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
      desync: const DesyncProps(featureEnabled: true, enabled: true, onlyDpi: true),
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
      desync: const DesyncProps(featureEnabled: true, enabled: true, onlyDpi: true),
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
      desync: const DesyncProps(featureEnabled: true, enabled: true, onlyDpi: true),
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

import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/hero_connect.dart';
import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
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
  }) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles()),
        desyncSettingProvider.overrideWith(() => _TestDesyncSetting(desync)),
        groupsProvider.overrideWithValue(const []),
        tunEnabledProvider.overrideWith((ref) => true),
        initProvider.overrideWithBuild((_, _) => true),
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
    expect(find.text('Add profile'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('without a profile and without the bypass the hero stays empty', (
    tester,
  ) async {
    await pumpHero(tester);

    expect(find.byType(HeroOrb), findsNothing);

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
}

import 'package:reclash/icons/icons.dart';
import '../../helpers/glyph_finders.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_connect.dart';
import 'package:reclash/views/config/smart_pause_network_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  Future<ProviderContainer> pumpHero(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profile = Profile.normal().copyWith(
      selectedMap: const {'Selector': 'Node A'},
    );
    const group = Group(
      name: 'Selector',
      type: GroupType.Selector,
      hidden: false,
      now: 'Node A',
      all: [Proxy(name: 'Node A', type: 'Shadowsocks')],
    );
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        groupsProvider.overrideWithValue([group]),
        tunEnabledProvider.overrideWith((ref) => true),
        initProvider.overrideWithBuild((_, _) => true),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(900, 1600));
    container.read(runTimeProvider.notifier).value = 90000;

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

  testWidgets('a long press on the pause chip opens the network picker', (
    tester,
  ) async {
    const channel = MethodChannel('wifi_ssid');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'listSsid');
          return <Object?>['Home Wi-Fi'];
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final container = await pumpHero(tester);

    expect(find.byType(SmartPauseNetworkPicker), findsNothing);
    await tester.longPress(find.byGlyph(AppGlyphs.pause));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SmartPauseNetworkPicker), findsOneWidget);
    expect(find.text('Home Wi-Fi'), findsOneWidget);

    await tester.tap(find.text('Home Wi-Fi'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));

    expect(container.read(vpnSettingProvider).smartPauseNetworks, [
      'Home Wi-Fi',
    ]);
    expect(find.byType(SmartPauseNetworkPicker), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a short tap still toggles pause', (tester) async {
    final container = await pumpHero(tester);

    await tester.tap(find.byGlyph(AppGlyphs.pause));
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(pausedProvider), isTrue);
    expect(find.byType(SmartPauseNetworkPicker), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

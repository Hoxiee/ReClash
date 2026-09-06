import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/hero_connect.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpHero(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profile = Profile.normal().copyWith(
      url: 'https://example.com/sub',
      subscriptionInfo: const SubscriptionInfo(
        upload: 25,
        download: 45,
        total: 100,
      ),
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

  testWidgets('a tap on the traffic card opens the subscription overview', (
    tester,
  ) async {
    await pumpHero(tester);

    await tester.tap(find.text('Subscription'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Traffic usage'), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}

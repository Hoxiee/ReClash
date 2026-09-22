import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_connect.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpHero(
    WidgetTester tester, {
    int expire = 0,
  }) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profile = Profile.normal().copyWith(
      url: 'https://example.com/sub',
      subscriptionInfo: SubscriptionInfo(
        upload: 25,
        download: 45,
        total: 100,
        expire: expire,
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
        isStartProvider.overrideWithValue(true),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
        networkReachableProvider.overrideWithBuild((_, _) => true),
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

  testWidgets('an expired plan is explicit in the traffic card and orb', (
    tester,
  ) async {
    final expire =
        DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch ~/
        1000;

    await pumpHero(tester, expire: expire);

    expect(find.text('Subscription expired'), findsNWidgets(2));
    expect(find.text('Remaining 0 days'), findsNothing);
    expect(find.byIcon(Icons.event_busy_rounded), findsNWidgets(2));
  });

  testWidgets('a tap on the traffic card opens the subscription overview', (
    tester,
  ) async {
    await pumpHero(tester);

    await tester.tap(find.byKey(const ValueKey('hero-subscription-strip')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('System'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    // The memory row's in-flight getMemory arms a 10s connect timeout; let it
    // drain before teardown checks for pending timers.
    await tester.pump(const Duration(seconds: 11));
  });
}

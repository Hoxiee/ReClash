import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/widgets/announcement_card.dart';
import 'package:reclash/views/dashboard/dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        providerHintsProvider.overrideWithValue(ProviderHints.empty),
      ],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<ScrollPosition> pumpDashboard(
    WidgetTester tester,
    Size size,
    SupportPlatform platform,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).value = size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: DashboardView(platform: platform)),
      ),
    );
    await tester.pump();
    return tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  }

  testWidgets('the phone cards keep their scroll end while scrolling', (
    tester,
  ) async {
    final position = await pumpDashboard(
      tester,
      const Size(412, 700),
      SupportPlatform.Android,
    );
    final end = position.maxScrollExtent;
    expect(end, greaterThan(0));

    final gesture = await tester.startGesture(const Offset(200, 500));
    while (position.pixels < end) {
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump(const Duration(milliseconds: 16));
      expect(position.maxScrollExtent, end);
    }
    await gesture.up();
    await tester.pump(const Duration(seconds: 2));
    expect(position.pixels, end);

    await teardown(tester);
  });

  for (final size in [const Size(412, 700), const Size(1600, 1100)]) {
    testWidgets('long description scrolls without clipping at $size', (
      tester,
    ) async {
      container.updateOverrides([
        profilesProvider.overrideWith(TestProfiles.new),
        providerHintsProvider.overrideWithValue(
          ProviderHints(
            readSubscriptionMetadata({
              'announce': [
                List.filled(30, 'Your subscription description.').join('\n'),
              ],
              'reclash-notice': ['Maintenance tonight'],
            }).metadata,
          ),
        ),
      ]);
      final position = await pumpDashboard(tester, size, SupportPlatform.MacOS);
      expect(find.byType(AnnouncementCard), findsOneWidget);
      expect(find.byType(NoticeCard), findsOneWidget);
      final end = position.maxScrollExtent;
      expect(end, greaterThan(0));
      position.jumpTo(end);
      await tester.pump();
      expect(position.maxScrollExtent, closeTo(end, 1));
      expect(tester.takeException(), isNull);
      await teardown(tester);
    });
  }

  testWidgets('the desktop grid bounces when it fits the window', (
    tester,
  ) async {
    final position = await pumpDashboard(
      tester,
      const Size(1220, 900),
      SupportPlatform.MacOS,
    );
    expect(position.maxScrollExtent, 0);

    final gesture = await tester.startGesture(const Offset(600, 450));
    await gesture.moveBy(const Offset(0, 20));
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump(const Duration(milliseconds: 16));
    expect(position.pixels, lessThan(0));

    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(position.pixels, closeTo(0, 1));

    await teardown(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}

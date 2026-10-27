import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/speed_test/engine.dart';
import 'package:reclash/features/speed_test/settings_sheet.dart';
import 'package:reclash/features/speed_test/sheet.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/speed_test.dart';
import 'package:reclash/widgets/widgets.dart';

import '../features/speed_test_fakes.dart';
import '../helpers/preferences.dart';
import '../helpers/test_app.dart';

class _QuietRoutes extends RouteTracker {
  @override
  RouteState build() => const RouteState();
  @override
  void attach() {}
  @override
  void detach() {}
}

void main() {
  setUpAll(mockPreferences);

  Future<ProviderContainer> mount(
    WidgetTester tester,
    FakeSpeedBackend backend,
    FakeSpeedNetwork network, {
    Widget child = const SpeedTestSheet(),
    Size size = const Size(412, 915),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        isStartProvider.overrideWithValue(false),
        suspendProvider.overrideWithValue(false),
        providerSecureNetworkProvider.overrideWithValue(false),
        selectedMapProvider.overrideWithValue(const {}),
        effectiveModeProvider.overrideWithValue(Mode.rule),
        routeTrackerProvider.overrideWith(_QuietRoutes.new),
        speedTestBackendsProvider.overrideWithValue([backend]),
        speedTestNetworkProvider.overrideWithValue(network),
        speedTestPlanProvider.overrideWithValue(
          const SpeedTestPlan(
            latencyCount: 3,
            probeInterval: Duration(milliseconds: 1),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(network.close);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(locale: const Locale('en'), child: child),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> start(WidgetTester tester) async {
    final button = find.widgetWithText(FilledButton, 'Start test');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Finder dialogAction(String label) => find.descendant(
    of: find.byType(CommonDialog),
    matching: find.text(label),
  );

  testWidgets('opening the sheet makes no test requests', (tester) async {
    final backend = FakeSpeedBackend();
    await mount(tester, backend, FakeSpeedNetwork());
    expect(find.text('Ready to measure'), findsOneWidget);
    expect(backend.opens, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'metered traffic waits for confirmation and cancel sends nothing',
    (tester) async {
      final backend = FakeSpeedBackend();
      final network = FakeSpeedNetwork(
        snapshot: const NetworkCostSnapshot(
          cost: NetworkCost.metered,
          identity: 'mobile',
        ),
      );
      await mount(tester, backend, network);
      await start(tester);
      expect(find.text('Use data on this metered network?'), findsOneWidget);
      expect(backend.opens, 0);
      await tester.tap(dialogAction('Cancel'));
      await tester.pumpAndSettle();
      expect(backend.opens, 0);
      expect(find.byType(CommonDialog), findsNothing);
    },
  );

  testWidgets('unknown networks also require confirmation', (tester) async {
    final backend = FakeSpeedBackend();
    await mount(
      tester,
      backend,
      FakeSpeedNetwork(
        snapshot: const NetworkCostSnapshot(
          cost: NetworkCost.unknown,
          identity: 'wifi',
        ),
      ),
    );
    await start(tester);
    expect(find.text('The network’s data limit is unknown'), findsOneWidget);
    expect(backend.opens, 0);
    await tester.tap(dialogAction('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('the economical dialog action never downloads or uploads', (
    tester,
  ) async {
    final backend = FakeSpeedBackend();
    final container = await mount(
      tester,
      backend,
      FakeSpeedNetwork(
        snapshot: const NetworkCostSnapshot(
          cost: NetworkCost.metered,
          identity: 'mobile',
        ),
      ),
    );
    await start(tester);
    await tester.tap(dialogAction('Latency and jitter only'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(backend.opens, 1);
    expect(backend.session.downloads, 0);
    expect(backend.session.uploads, 0);
    expect(container.read(speedTestProvider).phase, SpeedTestPhase.done);
    expect(find.byType(CommonCircleLoading), findsNothing);
    expect(find.textContaining('Total data budget:'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Test again'))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('an offline network never opens a backend', (tester) async {
    final backend = FakeSpeedBackend();
    await mount(
      tester,
      backend,
      FakeSpeedNetwork(
        snapshot: const NetworkCostSnapshot(
          cost: NetworkCost.offline,
          identity: 'offline',
        ),
      ),
    );
    await start(tester);
    expect(find.text('No network connection'), findsOneWidget);
    expect(backend.opens, 0);
  });

  testWidgets('settings open from the sheet without starting a test', (
    tester,
  ) async {
    final backend = FakeSpeedBackend();
    await mount(tester, backend, FakeSpeedNetwork());
    await tester.tap(find.byTooltip('Test settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SpeedTestSettingsSheet), findsOneWidget);
    expect(find.text('Test platform'), findsWidgets);
    expect(backend.opens, 0);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(412, 915), const Size(1280, 800)]) {
    testWidgets('settings stay in the same sheet at $size', (tester) async {
      final backend = FakeSpeedBackend();
      await mount(
        tester,
        backend,
        FakeSpeedNetwork(),
        size: size,
        child: Builder(
          builder: (context) => CommonScaffold(
            title: 'Speed test',
            body: Center(
              child: TextButton(
                onPressed: () => showSpeedTestSheet(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(
        find.byType(SheetPagesNavigator),
      );
      expect(find.byType(NestedPagedSheet), findsOneWidget);
      await tester.tap(find.byTooltip('Test settings'));
      await tester.pumpAndSettle();
      final settingsContext = tester.element(
        find.byType(SpeedTestSettingsSheet),
      );
      expect(Navigator.of(settingsContext), same(navigator));
      expect(find.byType(NestedPagedSheet), findsOneWidget);
      expect(find.byType(SheetPagesNavigator), findsOneWidget);
      Navigator.of(settingsContext).pop();
      await tester.pumpAndSettle();
      expect(find.byType(SpeedTestSheet), findsOneWidget);
      expect(
        tester.state<NavigatorState>(find.byType(SheetPagesNavigator)),
        same(navigator),
      );
      expect(backend.opens, 0);
    });
  }

  testWidgets('disposing the sheet stops an active transfer', (tester) async {
    final backend = FakeSpeedBackend(
      session: FakeSpeedSession(holdDownload: true),
    );
    final container = await mount(tester, backend, FakeSpeedNetwork());
    await start(tester);
    expect(container.read(speedTestProvider).running, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(backend.session.closed, isTrue);
    expect(container.read(speedTestProvider).phase, SpeedTestPhase.cancelled);
    backend.session.held.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

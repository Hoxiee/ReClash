import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/speed_test/chart.dart';
import 'package:reclash/features/speed_test/history.dart';
import 'package:reclash/features/speed_test/history_sheet.dart';
import 'package:reclash/features/speed_test/server_picker.dart';
import 'package:reclash/features/speed_test/settings_sheet.dart';
import 'package:reclash/features/speed_test/sheet.dart';
import 'package:reclash/models/speed_test.dart';
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
  setUp(mockPreferences);

  Future<ProviderContainer> mount(
    WidgetTester tester,
    FakeSpeedClient client, {
    FakeSpeedNetwork? network,
    MemorySpeedHistory? history,
    Widget child = const SpeedTestSheet(),
    Size size = const Size(412, 915),
    SpeedTestSettings settings = const SpeedTestSettings(),
  }) async {
    final monitor = network ?? FakeSpeedNetwork();
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
        speedTestClientProvider.overrideWithValue(client),
        speedTestNetworkProvider.overrideWithValue(monitor),
        speedTestHistoryStoreProvider.overrideWithValue(
          history ?? MemorySpeedHistory(),
        ),
      ],
    );
    container
        .read(appSettingProvider.notifier)
        .update((value) => value.copyWith(speedTest: settings));
    addTearDown(container.dispose);
    addTearDown(monitor.close);
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
    final button = find.text('Start test');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('opening the sheet sends no requests and shows all platforms', (
    tester,
  ) async {
    final client = FakeSpeedClient();
    await mount(tester, client);
    expect(find.text('Ready to measure'), findsOneWidget);
    for (final name in ['Apple', 'Cloudflare', 'Speedtest.net', 'LibreSpeed']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(client.requests, isEmpty);
    expect(client.serverRequests, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final cost in [NetworkCost.metered, NetworkCost.unknown]) {
    testWidgets(
      '${cost.name} networks start on one tap without a confirmation dialog',
      (tester) async {
        final client = FakeSpeedClient();
        final container = await mount(
          tester,
          client,
          network: FakeSpeedNetwork(
            snapshot: NetworkCostSnapshot(cost: cost, identity: 'network'),
          ),
        );
        await start(tester);
        expect(client.requests, hasLength(1));
        expect(find.byType(CommonDialog), findsNothing);
        expect(container.read(speedTestProvider).phase, SpeedTestPhase.done);
        expect(find.text('Test again'), findsOneWidget);
      },
    );
  }

  testWidgets('an offline network shows an error and sends no request', (
    tester,
  ) async {
    final client = FakeSpeedClient();
    await mount(
      tester,
      client,
      network: FakeSpeedNetwork(
        snapshot: const NetworkCostSnapshot(
          cost: NetworkCost.offline,
          identity: 'offline',
        ),
      ),
    );
    await start(tester);
    expect(find.text('No network connection'), findsOneWidget);
    expect(client.requests, isEmpty);
  });

  testWidgets('a failed start releases the action for a retry', (tester) async {
    final client = FakeSpeedClient()..startError = StateError('failed');
    final container = await mount(tester, client);
    await start(tester);
    expect(container.read(speedTestProvider).phase, SpeedTestPhase.failed);
    final retry = find.text('Test again');
    expect(retry, findsOneWidget);
    client.startError = null;
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(container.read(speedTestProvider).phase, SpeedTestPhase.done);
    expect(tester.takeException(), isNull);
  });

  testWidgets('latency-only keeps throughput unavailable and hides charts', (
    tester,
  ) async {
    final client = FakeSpeedClient();
    await mount(
      tester,
      client,
      settings: const SpeedTestSettings(mode: SpeedTestMode.latencyOnly),
    );
    await start(tester);
    expect(client.requests.single['mode'], 'latencyOnly');
    expect(find.byType(SpeedTestCharts), findsNothing);
    expect(find.text('Jitter'), findsOneWidget);
  });

  testWidgets(
    'settings include measurement controls without traffic confirmation',
    (tester) async {
      final client = FakeSpeedClient();
      await mount(tester, client);
      await tester.tap(find.byTooltip('Test settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SpeedTestSettingsSheet), findsOneWidget);
      expect(find.text('Time per direction'), findsOneWidget);
      expect(find.text('Protocol'), findsOneWidget);
      expect(find.text('Confirm on every network'), findsNothing);
      expect(client.requests, isEmpty);
    },
  );

  for (final size in [const Size(412, 915), const Size(1280, 800)]) {
    testWidgets('settings stay on the same sheet navigator at $size', (
      tester,
    ) async {
      await mount(
        tester,
        FakeSpeedClient(),
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
      await tester.tap(find.byTooltip('Test settings'));
      await tester.pumpAndSettle();
      final settingsContext = tester.element(
        find.byType(SpeedTestSettingsSheet),
      );
      expect(Navigator.of(settingsContext), same(navigator));
      expect(find.byType(NestedPagedSheet), findsOneWidget);
      Navigator.of(settingsContext).pop();
      await tester.pumpAndSettle();
      expect(find.byType(SpeedTestSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('server picker does not search until the user asks', (
    tester,
  ) async {
    final client = FakeSpeedClient();
    await mount(tester, client, child: const SpeedTestServerPicker());
    expect(client.serverRequests, isEmpty);
    await tester.tap(find.widgetWithText(FilledButton, 'Find servers'));
    await tester.pumpAndSettle();
    expect(client.serverRequests, hasLength(1));
    expect(find.text('Test operator · Test city'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed runs show graphs, loaded latency and history', (
    tester,
  ) async {
    final client = FakeSpeedClient();
    await mount(tester, client);
    await start(tester);
    await tester.pumpAndSettle();
    expect(find.text('Latency under load'), findsOneWidget);
    expect(find.text('1200 RPM'), findsOneWidget);
    expect(find.byType(SpeedTestCharts), findsOneWidget);
    await tester.tap(find.byTooltip('Test history'));
    await tester.pumpAndSettle();
    expect(find.byType(SpeedTestHistorySheet), findsOneWidget);
    expect(find.textContaining('123'), findsWidgets);
    expect(client.requests, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'history clear requires a destructive confirmation and persists',
    (tester) async {
      final history = MemorySpeedHistory();
      final container = await mount(
        tester,
        FakeSpeedClient(),
        history: history,
      );
      await start(tester);
      await tester.tap(find.byTooltip('Test history'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear test history'));
      await tester.pumpAndSettle();
      expect(history.records, hasLength(1));
      await tester.tap(
        find.descendant(
          of: find.byType(CommonDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(history.records, isEmpty);
      expect(container.read(speedTestHistoryProvider).requireValue, isEmpty);
      expect(find.text('No completed tests yet'), findsOneWidget);
    },
  );

  for (final size in [const Size(320, 640), const Size(1280, 800)]) {
    testWidgets('finished result and scrollable charts fit $size', (
      tester,
    ) async {
      await mount(tester, FakeSpeedClient(), size: size);
      await start(tester);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(SpeedTestCharts));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('closing the sheet cancels the running request and timers', (
    tester,
  ) async {
    final client = FakeSpeedClient(complete: false);
    final container = await mount(tester, client);
    await start(tester);
    expect(container.read(speedTestProvider).running, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(container.read(speedTestProvider).phase, SpeedTestPhase.cancelled);
    expect(client.cancellations, contains(client.requests.single['requestId']));
    expect(tester.takeException(), isNull);
  });
}

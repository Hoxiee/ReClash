import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/views.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  const logCount = 200;

  late ProviderContainer container;

  List<Log> seedLogs() => List.generate(
    logCount,
    (i) => Log(payload: 'log $i', dateTime: '2024-01-01 12:00:$i'),
  );

  Future<void> pumpLogsView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: LogsView()),
      ),
    );
    final notifier = container.read(logsProvider.notifier);
    for (final log in seedLogs()) {
      notifier.add(log);
    }
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
  }

  const hintKey = ValueKey('scrollbarHintPill');

  Finder hintFinder() => find.byKey(hintKey);

  testWidgets('dragging the list floats the time hint next to the scrollbar', (
    tester,
  ) async {
    await pumpLogsView(tester);
    expect(hintFinder(), findsNothing);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Scrollable).first),
    );
    await gesture.moveBy(const Offset(0, 300));
    await tester.pump();

    expect(hintFinder(), findsOneWidget);
    final label = tester.widget<Text>(
      find.descendant(of: find.byKey(hintKey), matching: find.byType(Text)),
    );
    expect(seedLogs().map((log) => log.dateTime), contains(label.data));

    final scrollableRect = tester.getRect(find.byType(Scrollable).first);
    // The list scrolls under the floating bar, so the scrollbar track insets
    // below it. Material's minimum thumb length is 48, so at the newest end
    // the thumb center rests 24px below that inset track top.
    expect(
      tester.getCenter(find.byKey(hintKey)).dy,
      closeTo(scrollableRect.top + pageToolbarHeight + 24, 6),
    );

    for (var i = 0; i < 25; i++) {
      await gesture.moveBy(const Offset(0, -2000));
      await tester.pump();
    }
    // With the scroll-to-end FAB gone, no FAB zone reserves the bottom, so the
    // pill follows the thumb: at the oldest end its center rests 24px above the
    // track bottom, mirroring the newest-end resting position.
    expect(
      tester.getCenter(find.byKey(hintKey)).dy,
      closeTo(scrollableRect.bottom - 24, 6),
    );

    await gesture.up();
    // The pill outlives the gesture briefly so transient scroll ends do not
    // blink it. No pumpAndSettle here: the fling's ballistic keeps frames
    // scheduled for seconds of fake time, which would elapse straight past
    // the hide window.
    await tester.pump(const Duration(milliseconds: 100));
    expect(hintFinder(), findsOneWidget);
    for (var i = 0; i < 20 && hintFinder().evaluate().isNotEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(hintFinder(), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('auto scroll-to-end on new logs keeps the hint hidden', (
    tester,
  ) async {
    await pumpLogsView(tester);
    expect(hintFinder(), findsNothing);

    container
        .read(logsProvider.notifier)
        .add(const Log(payload: 'log new', dateTime: '2024-01-01 12:00:new'));
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();

    expect(hintFinder(), findsNothing);
  });

  testWidgets('filter button opens the source/level menu', (tester) async {
    await pumpLogsView(tester);

    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_alt_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Source'), findsOneWidget);
    expect(find.text('Level'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  group('LogListController', () {
    final logs = seedLogs();

    test('keeps trimmed logs while auto scroll is off', () {
      final controller = LogListController();
      addTearDown(controller.dispose);
      controller.setLogs(logs.sublist(0, 100));
      controller.setAutoScrollToEnd(false);

      controller.setLogs(logs.sublist(10, 110));

      expect(controller.value.logs, logs.sublist(0, 110));
    });

    test('resume replaces the retained logs and follows the end', () {
      final controller = LogListController();
      addTearDown(controller.dispose);
      controller.setLogs(logs.sublist(0, 100));
      controller.setAutoScrollToEnd(false);
      controller.setLogs(logs.sublist(10, 110));

      final latest = logs.sublist(20, 120);
      controller.resumeAutoScrollToEnd(latest);

      expect(controller.value.autoScrollToEnd, isTrue);
      expect(controller.value.logs, latest);
      controller.setLogs(logs.sublist(30, 130));
      expect(controller.value.logs, logs.sublist(30, 130));
    });

    test('toggling a source narrows the list to that source', () {
      final controller = LogListController();
      addTearDown(controller.dispose);
      controller.setLogs(const [
        Log(payload: 'app line', dateTime: 't', source: LogSource.app),
        Log(payload: 'core line', dateTime: 't', source: LogSource.core),
      ]);

      controller.toggleSource(LogSource.core);

      expect(controller.value.hasFilters, isTrue);
      expect(controller.value.list.map((log) => log.payload), ['core line']);

      controller.toggleSource(LogSource.core);
      expect(controller.value.hasFilters, isFalse);
      expect(controller.value.list.length, 2);
    });

    test('toggling a level narrows the list to that level', () {
      final controller = LogListController();
      addTearDown(controller.dispose);
      controller.setLogs(const [
        Log(payload: 'info line', dateTime: 't', logLevel: LogLevel.info),
        Log(payload: 'error line', dateTime: 't', logLevel: LogLevel.error),
      ]);

      controller.toggleLevel(LogLevel.error);

      expect(controller.value.list.map((log) => log.payload), ['error line']);
    });

    test('clearFilters drops both source and level filters', () {
      final controller = LogListController();
      addTearDown(controller.dispose);
      controller.toggleSource(LogSource.core);
      controller.toggleLevel(LogLevel.error);
      expect(controller.value.hasFilters, isTrue);

      controller.clearFilters();

      expect(controller.value.hasFilters, isFalse);
      expect(controller.value.sources, isEmpty);
      expect(controller.value.levels, isEmpty);
    });

    test('setUseRegex switches search to regex matching', () {
      final controller = LogListController();
      addTearDown(controller.dispose);
      controller.setLogs(const [
        Log(payload: 'abc123', dateTime: 't'),
        Log(payload: 'plain text', dateTime: 't'),
      ]);

      controller.setUseRegex(true);
      controller.search(r'\d+');

      expect(controller.value.useRegex, isTrue);
      expect(controller.value.list.map((log) => log.payload), ['abc123']);
    });
  });
}

import 'package:reclash/core/controller.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/widgets/core_status_button.dart';
import 'package:reclash/views/tools/core.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

class _CoreInfoHandler extends CoreHandlerInterface {
  @override
  Future<CoreLifecycleResult> start() async => const CoreLifecycleResult(
    revision: 1,
    outcome: CoreLifecycleOutcome.applied,
  );

  @override
  Future<CoreLifecycleResult> restart() => start();

  @override
  Future<CoreLifecycleResult> stop() => start();

  @override
  Future<CoreLifecycleResult> close() => start();

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async => switch (method) {
    CoreMethod.getCoreInfo =>
      {
            'version': '1.19.31-2-gf77b7475',
            'goVersion': 'go1.27.0',
            'platform': 'linux',
            'architecture': 'amd64',
            'buildTime': '2026-10-02T08:05:06.123Z',
            'tags': ['with_gvisor'],
            'workingDirectory': '/home/reclash/.config',
            'executablePath': '/usr/bin/ReClashCore',
          }
          as T,
    _ => null,
  };
}

class _IncompleteCoreInfoHandler extends _CoreInfoHandler {
  var _reads = 0;

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    if (method == CoreMethod.getCoreInfo && _reads++ == 0) {
      return {
            'version': '1.19.31-2-gf77b7475',
            'goVersion': 'go1.27.0',
            'platform': 'linux',
            'architecture': 'amd64',
            'buildTime': '2026-10-02T08:05:06.123Z',
            'tags': ['with_gvisor'],
            'workingDirectory': '',
            'executablePath': '/usr/bin/ReClashCore',
          }
          as T;
    }
    return super.invokeMethod<T>(
      method: method,
      arguments: arguments,
      timeout: timeout,
    );
  }
}

void main() {
  testWidgets('Core summary row shows mihomo version and opens details', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(
          CoreController.scoped(_CoreInfoHandler()),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    var opened = false;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          homeBuilder: (child) => Scaffold(body: child),
          child: CoreSection(
            onOpen: () {
              opened = true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('mihomo 1.19.31'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    await tester.tap(find.text('mihomo 1.19.31'));

    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offers retry while Core metadata is incomplete', (tester) async {
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(
          CoreController.scoped(_IncompleteCoreInfoHandler()),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          homeBuilder: (child) => Scaffold(body: child),
          child: const CoreDetailView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not read core information'), findsOneWidget);
    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Could not read core information'), findsNothing);
    expect(find.text('/home/reclash/.config'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows live Core status and build details', (tester) async {
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(
          CoreController.scoped(_CoreInfoHandler()),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          homeBuilder: (child) => Scaffold(body: child),
          child: const CoreDetailView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('mihomo'), findsOneWidget);
    expect(find.text('1.19.31-2-gf77b7475'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('go1.27.0'), findsOneWidget);
    expect(find.text('/home/reclash/.config'), findsOneWidget);
    expect(find.text('/usr/bin/ReClashCore'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'holds connecting for the minimum duration after a fast restart',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            includeNavigatorKey: false,
            homeBuilder: (child) => Scaffold(body: Center(child: child)),
            child: const CoreStatusButton(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
      expect(find.byType(CommonCircleLoading), findsNothing);

      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CommonCircleLoading), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.check), findsNothing);

      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      await tester.pump();
      expect(find.byType(CommonCircleLoading), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.check), findsNothing);

      await tester.pump(const Duration(milliseconds: 199));
      expect(find.byType(CommonCircleLoading), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
      expect(find.byType(CommonCircleLoading), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    },
  );

  testWidgets(
    'shows disconnected immediately when restart fails during the hold',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            includeNavigatorKey: false,
            homeBuilder: (child) => Scaffold(body: Center(child: child)),
            child: const CoreStatusButton(),
          ),
        ),
      );
      await tester.pump();

      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CommonCircleLoading), findsOneWidget);

      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;
      await tester.pump();
      expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);
      expect(find.byType(CommonCircleLoading), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);
      expect(find.byType(CommonCircleLoading), findsNothing);
    },
  );

  testWidgets('labels the status on desktop and keeps it an icon on mobile', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;

    Future<void> pumpAt(Size size) async {
      container.read(viewSizeProvider.notifier).value = size;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            includeNavigatorKey: false,
            homeBuilder: (child) => Scaffold(body: Center(child: child)),
            child: const CoreStatusButton(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }

    await pumpAt(const Size(1200, 800));
    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);

    await pumpAt(const Size(400, 800));
    expect(find.text('Disconnected'), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);
    expect(find.byTooltip('Core status'), findsOneWidget);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Connecting…'), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byType(CommonCircleLoading), findsOneWidget);
  });

  testWidgets('does not clip a connecting state longer than the hold', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          homeBuilder: (child) => Scaffold(body: Center(child: child)),
          child: const CoreStatusButton(),
        ),
      ),
    );
    await tester.pump();

    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(CommonCircleLoading), findsOneWidget);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(find.byType(CommonCircleLoading), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
  });

  testWidgets('holds connecting when restarting from disconnected', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          homeBuilder: (child) => Scaffold(body: Center(child: child)),
          child: const CoreStatusButton(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CommonCircleLoading), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.refresh), findsNothing);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();
    expect(find.byType(CommonCircleLoading), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 199));
    expect(find.byType(CommonCircleLoading), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(find.byType(CommonCircleLoading), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
  });
}

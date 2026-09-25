import 'package:reclash/icons/icons.dart';
import '../helpers/glyph_finders.dart';
import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/tools/tools.dart';
import 'package:reclash/views/tools/core.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _MockCore extends Mock implements CoreController {}

class _RestartAction extends CoreAction {
  int calls = 0;
  Completer<bool>? completion;

  @override
  void build() {}

  @override
  Future<bool> restartCore() async {
    calls++;
    return completion?.future ?? Future.value(true);
  }
}

void main() {
  late _MockCore core;
  late ProviderContainer container;

  setUp(() {
    core = _MockCore();
    when(
      () => core.getVersion(),
    ).thenAnswer((_) async => '1.19.30-2-g69197948');
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(core),
        coreActionProvider.overrideWith(_RestartAction.new),
        profilesProvider.overrideWith(TestProfiles.new),
        viewSizeProvider.overrideWithBuild((_, _) => const Size(800, 600)),
      ],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpSection(
    WidgetTester tester, {
    CoreStatus status = CoreStatus.connected,
    Widget child = const CoreSection(),
    Locale locale = const Locale('en'),
  }) async {
    container.read(coreStatusProvider.notifier).value = status;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          locale: locale,
          homeBuilder: (child) => Scaffold(body: child),
          child: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  IconButton restartButton(WidgetTester tester) => tester.widget<IconButton>(
    find.ancestor(
      of: find.byGlyph(AppGlyphs.reset),
      matching: find.byType(IconButton),
    ),
  );

  testWidgets('shows the release version and running status', (tester) async {
    await pumpSection(tester);

    expect(find.text('Core'), findsOneWidget);
    expect(find.text('mihomo 1.19.30'), findsOneWidget);
    expect(find.textContaining('69197948'), findsNothing);
    expect(find.text('Running'), findsOneWidget);
    expect(restartButton(tester).onPressed, isNotNull);
    verify(() => core.getVersion()).called(1);
  });

  testWidgets('strips the tag prefix and dirty suffix', (tester) async {
    when(() => core.getVersion()).thenAnswer((_) async => 'v1.19.30-dirty');
    await pumpSection(tester);

    expect(find.text('mihomo 1.19.30'), findsOneWidget);
  });

  testWidgets('does not invent a release number for untagged builds', (
    tester,
  ) async {
    when(() => core.getVersion()).thenAnswer((_) async => '69197948');
    await pumpSection(tester);

    expect(find.text('mihomo 69197948'), findsOneWidget);
  });

  testWidgets('keeps the stopped core visible without querying it', (
    tester,
  ) async {
    await pumpSection(tester, status: CoreStatus.disconnected);

    expect(find.text('mihomo'), findsOneWidget);
    expect(find.text('Stopped'), findsOneWidget);
    expect(restartButton(tester).onPressed, isNotNull);
    verifyNever(() => core.getVersion());
  });

  testWidgets('disables restart while starting and reads version when ready', (
    tester,
  ) async {
    await pumpSection(tester, status: CoreStatus.connecting);

    expect(find.text('Starting…'), findsOneWidget);
    expect(restartButton(tester).onPressed, isNull);
    verifyNever(() => core.getVersion());

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pumpAndSettle();
    expect(find.text('mihomo 1.19.30'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
  });

  testWidgets('retains the version when stopped and refreshes after restart', (
    tester,
  ) async {
    await pumpSection(tester);
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await tester.pumpAndSettle();

    expect(find.text('mihomo 1.19.30'), findsOneWidget);
    expect(find.text('Stopped'), findsOneWidget);
    verify(() => core.getVersion()).called(1);

    when(
      () => core.getVersion(),
    ).thenAnswer((_) async => '1.19.31-1-g12345678');
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pumpAndSettle();
    expect(find.text('mihomo 1.19.31'), findsOneWidget);
    verify(() => core.getVersion()).called(1);
  });

  testWidgets('a failed version query does not hide the status or controls', (
    tester,
  ) async {
    when(() => core.getVersion()).thenThrow(StateError('unavailable'));
    await pumpSection(tester);

    expect(find.text('mihomo'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(restartButton(tester).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel leaves the core untouched', (tester) async {
    await pumpSection(tester);
    await tester.tap(find.byGlyph(AppGlyphs.reset));
    await tester.pumpAndSettle();
    expect(
      find.text('Are you sure you want to force restart the core?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final action =
        container.read(coreActionProvider.notifier) as _RestartAction;
    expect(action.calls, 0);
    expect(restartButton(tester).onPressed, isNotNull);
  });

  testWidgets('confirms restart and locks the button until completion', (
    tester,
  ) async {
    await pumpSection(tester);
    final action =
        container.read(coreActionProvider.notifier) as _RestartAction;
    action.completion = Completer<bool>();

    await tester.tap(find.byGlyph(AppGlyphs.reset));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(action.calls, 1);
    expect(restartButton(tester).onPressed, isNull);

    action.completion!.complete(true);
    await tester.pumpAndSettle();
    expect(restartButton(tester).onPressed, isNotNull);
  });

  testWidgets(
    'does not restart if another transition began during confirmation',
    (tester) async {
      await pumpSection(tester);
      await tester.tap(find.byGlyph(AppGlyphs.reset));
      await tester.pumpAndSettle();
      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      final action =
          container.read(coreActionProvider.notifier) as _RestartAction;
      expect(action.calls, 0);
      expect(restartButton(tester).onPressed, isNull);
    },
  );

  testWidgets('fits a narrow Russian layout', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpSection(tester, locale: const Locale('ru'));

    expect(find.text('Ядро'), findsOneWidget);
    expect(find.text('Работает'), findsOneWidget);
    expect(find.byTooltip('Перезапустить'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tools places the core in its final category', (tester) async {
    await pumpSection(tester, child: const ToolsView());
    final list = tester.widget<ListView>(find.byKey(toolsStoreKey));
    final delegate = list.childrenDelegate as SliverChildBuilderDelegate;
    final context = tester.element(find.byType(ToolsView));

    expect(
      delegate.builder(context, delegate.childCount! - 2),
      isA<CoreSection>(),
    );
    expect(
      delegate.builder(context, delegate.childCount! - 1),
      isA<SettingBottomInset>(),
    );
  });
}

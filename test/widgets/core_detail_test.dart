import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/editor.dart';
import 'package:reclash/views/tools/core.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/test_app.dart';

class _MockCore extends Mock implements CoreController {}

void main() {
  late _MockCore core;
  late CoreInfo info;
  late ProviderContainer container;
  const yaml = 'mixed-port: 17890\nrules: ["MATCH,DIRECT"]\n';

  setUp(() {
    info = CoreInfo(
      rcxVersion: '0.1.0',
      rcxCommit: 'v0.1.0-pre.1-3-gf77b7475',
      version: '1.19.31-2-gf77b7475-dirty',
      goVersion: 'go1.27.0',
      platform: 'linux',
      architecture: 'amd64',
      buildTime: DateTime.utc(2026, 10, 2, 8, 5, 6, 123),
      tags: ['with_gvisor', 'no_tailscale'],
      workingDirectory: '/core-data',
      executablePath: '/core/ReClashCore',
    );
    core = _MockCore();
    when(() => core.getCoreInfo()).thenAnswer((_) async => info);
    when(() => core.processOwner).thenReturn(CoreProcessOwner.direct);
    when(() => core.getAppliedConfigContent()).thenAnswer((_) async => yaml);
    container = ProviderContainer(
      overrides: [coreHandlerProvider.overrideWithValue(core)],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }

  Future<void> pumpDetail(
    WidgetTester tester, {
    CoreStatus status = CoreStatus.connected,
    Locale locale = const Locale('en'),
  }) async {
    container.read(coreStatusProvider.notifier).value = status;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(locale: locale, child: const CoreDetailView()),
      ),
    );
    await settle(tester);
  }

  Future<void> openConfig(WidgetTester tester) async {
    final link = find.text('Open runtime configuration');
    await tester.scrollUntilVisible(link, 250);
    await tester.tap(link);
    await settle(tester);
  }

  testWidgets('shows the running core passport, not traffic or inline config', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpDetail(tester);

    for (final value in [
      '0.1.0 (v0.1.0-pre.1-3-gf77b7475)',
      info.version,
      info.goVersion,
      info.platform,
      info.architecture,
      info.workingDirectory,
      info.executablePath,
      'with_gvisor, no_tailscale',
      'Separate process',
      'Running',
    ]) {
      expect(find.text(value), findsOneWidget);
    }
    expect(find.textContaining('08:05:06 UTC'), findsOneWidget);
    expect(find.byType(EditorPage), findsNothing);
    expect(find.textContaining('17890'), findsNothing);
    expect(find.textContaining('Upload'), findsNothing);
    expect(find.textContaining('Download'), findsNothing);
    verify(() => core.getCoreInfo()).called(1);
    verifyNever(() => core.getAppliedConfigContent());
  });

  testWidgets('uses the actual Helper process owner', (tester) async {
    when(() => core.processOwner).thenReturn(CoreProcessOwner.helper);
    await pumpDetail(tester);

    expect(find.text('Process via Helper'), findsOneWidget);
    expect(find.text('Separate process'), findsNothing);
  });

  testWidgets('Android reports a library, not the host executable', (
    tester,
  ) async {
    info = info.copyWith(platform: 'android', architecture: 'arm64');
    await pumpDetail(tester);

    expect(find.text('In-process library'), findsOneWidget);
    expect(find.text('arm64'), findsOneWidget);
    expect(find.text('Core binary'), findsNothing);
    expect(find.text(info.executablePath), findsNothing);
    verifyNever(() => core.processOwner);
  });

  testWidgets('does not invent a build date or build flags', (tester) async {
    info = info.copyWith(buildTime: null, tags: []);
    await pumpDetail(tester);

    expect(find.text('Unknown'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
    expect(find.textContaining('UTC'), findsNothing);
  });

  for (final status in [CoreStatus.disconnected, CoreStatus.connecting]) {
    testWidgets('does not query an unavailable core: ${status.name}', (
      tester,
    ) async {
      await pumpDetail(tester, status: status);

      verifyNever(() => core.getCoreInfo());
      expect(find.text(info.version), findsNothing);
    });
  }

  testWidgets('failed metadata can be retried without hiding the status', (
    tester,
  ) async {
    when(() => core.getCoreInfo()).thenThrow(StateError('unavailable'));
    await pumpDetail(tester);

    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Could not read core information'), findsOneWidget);
    when(() => core.getCoreInfo()).thenAnswer((_) async => info);
    await tester.tap(find.byTooltip('Reload'));
    await settle(tester);

    expect(find.text('Could not read core information'), findsNothing);
    expect(find.text(info.version), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uninitialized metadata stays readable and can be refreshed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final initialized = info;
    info = info.copyWith(workingDirectory: '');
    await pumpDetail(tester);

    expect(find.text(info.version), findsOneWidget);
    expect(find.text('Unknown'), findsOneWidget);
    info = initialized;
    await tester.tap(find.byTooltip('Reload'));
    await settle(tester);

    expect(find.text(info.workingDirectory), findsOneWidget);
    expect(find.text('Could not read core information'), findsNothing);
  });

  testWidgets('null metadata leaves a retry rather than a spinner', (
    tester,
  ) async {
    when(() => core.getCoreInfo()).thenAnswer((_) async => null);
    await pumpDetail(tester);

    expect(find.text('Could not read core information'), findsOneWidget);
    expect(find.byType(CommonCircleLoading), findsNothing);
  });

  testWidgets('a pre-restart response cannot replace the new core passport', (
    tester,
  ) async {
    final oldRequest = Completer<CoreInfo?>();
    when(() => core.getCoreInfo()).thenAnswer((_) => oldRequest.future);
    await pumpDetail(tester);
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await tester.pump();
    when(() => core.getCoreInfo()).thenAnswer((_) async => info);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await settle(tester);

    oldRequest.complete(info.copyWith(version: 'outdated-build'));
    await settle(tester);

    expect(find.text(info.version), findsOneWidget);
    expect(find.text('outdated-build'), findsNothing);
  });

  testWidgets('a metadata reply after disposal is ignored', (tester) async {
    final request = Completer<CoreInfo?>();
    when(() => core.getCoreInfo()).thenAnswer((_) => request.future);
    await pumpDetail(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    request.complete(info);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the unchanged YAML in the existing read-only editor', (
    tester,
  ) async {
    await pumpDetail(tester);
    verifyNever(() => core.getAppliedConfigContent());
    await openConfig(tester);

    final editor = tester.widget<EditorPage>(find.byType(EditorPage));
    expect(editor.title, 'Runtime configuration');
    expect(editor.content, yaml);
    expect(editor.onSave, isNull);
    expect(editor.titleEditable, isFalse);
    expect(editor.readOnly, isTrue);
    verify(() => core.getAppliedConfigContent()).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reads the last generated config even when the core is stopped', (
    tester,
  ) async {
    await pumpDetail(tester, status: CoreStatus.disconnected);
    await openConfig(tester);

    expect(tester.widget<EditorPage>(find.byType(EditorPage)).content, yaml);
    verifyNever(() => core.getCoreInfo());
  });

  testWidgets('a configuration read failure can be retried', (tester) async {
    when(() => core.getAppliedConfigContent()).thenThrow(StateError('missing'));
    await pumpDetail(tester, status: CoreStatus.disconnected);
    await openConfig(tester);

    expect(
      find.text('Could not read the runtime configuration'),
      findsOneWidget,
    );
    when(() => core.getAppliedConfigContent()).thenAnswer((_) async => yaml);
    await tester.tap(find.text('Reload'));
    await settle(tester);

    expect(tester.widget<EditorPage>(find.byType(EditorPage)).content, yaml);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [
    Locale('en'),
    Locale('ru'),
    Locale('ja'),
    Locale('zh', 'CN'),
    Locale('kk'),
    Locale('ko'),
    Locale('uz'),
    Locale('tk'),
  ]) {
    testWidgets('long paths and enlarged text fit a narrow $locale layout', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      info = info.copyWith(
        workingDirectory: '/very-long-directory/' * 12,
        executablePath: '${'/very-long-directory/' * 12}ReClashCore',
      );
      await pumpDetail(tester, locale: locale);
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DetailRow && widget.copyText == info.executablePath,
        ),
        findsOneWidget,
      );
    });
  }
}

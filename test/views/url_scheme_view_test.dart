import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/features/url_scheme/form.dart';
import 'package:reclash/features/url_scheme/inspect.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/url_scheme.dart';
import 'package:reclash/widgets/url_scheme_preview.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/test_app.dart';

Future<void> _settleForm(WidgetTester tester) async {
  await tester.pump();
  var idle = false;
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 25));
    final forms = find.byType(FormPage);
    final settled =
        forms.evaluate().isNotEmpty &&
        !tester.widget<FormPage>(forms).saving &&
        !tester.binding.hasScheduledFrame;
    if (!settled) {
      idle = false;
    } else if (idle) {
      return;
    } else {
      idle = true;
      await tester.pump(const Duration(milliseconds: 200));
    }
  }
  fail('Link builder did not settle');
}

Future<void> _reveal(WidgetTester tester, Finder target) async {
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
  await tester.pump();
}

void main() {
  late List<String> copied;
  late bool copyFails;

  setUp(() {
    copied = [];
    copyFails = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            if (copyFails) throw PlatformException(code: 'unavailable');
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1200, 1000),
    double scale = 1,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final container = ProviderContainer(
      overrides: [viewSizeProvider.overrideWithBuild((_, _) => size)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          locale: const Locale('en'),
          withStatusManager: true,
          theme: ThemeData(
            brightness: brightness,
          ).withAppShapes.withAppTypography,
          child: const UrlSchemeView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
  }

  testWidgets('the catalog shows all commands and only ready-to-use links', (
    tester,
  ) async {
    await pump(tester);
    final l = currentAppLocalizations;
    expect(find.text(l.urlSchemeConnection), findsOneWidget);
    expect(find.text(l.urlSchemeProfiles), findsOneWidget);
    expect(find.text(l.urlSchemeSupportedLinks), findsOneWidget);
    for (final action in ReClashCommand.values.where(
      (action) => !action.isProfile,
    )) {
      expect(find.text('reclash://${action.host}'), findsOneWidget);
    }
    expect(find.textContaining('<'), findsNothing);
    expect(find.byTooltip(l.urlSchemeBuild), findsOneWidget);
    expect(find.byTooltip(l.urlSchemeInspect), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('copying an action copies a usable link and reports failures', (
    tester,
  ) async {
    await pump(tester);
    final l = currentAppLocalizations;
    final copy = find.descendant(
      of: find.widgetWithText(DecorationListItem, l.urlSchemeConnect),
      matching: find.byType(IconButton),
    );
    await tester.tap(copy);
    await tester.pumpAndSettle();
    expect(copied, ['reclash://connect']);
    expect(find.text(l.copySuccess), findsOneWidget);
    copyFails = true;
    await tester.tap(copy);
    await tester.pumpAndSettle();
    expect(copied, hasLength(1));
    expect(find.text(l.urlSchemeCopyFailed), findsOneWidget);
  });

  testWidgets(
    'profile commands open their builder rather than copying a template',
    (tester) async {
      await pump(tester);
      final l = currentAppLocalizations;
      await _reveal(tester, find.text(l.urlSchemeInstallConfig));
      await tester.tap(find.text(l.urlSchemeInstallConfig));
      await _settleForm(tester);
      expect(find.byType(UrlSchemeForm), findsOneWidget);
      expect(
        tester.widget<UrlSchemeForm>(find.byType(UrlSchemeForm)).command,
        ReClashCommand.installConfig,
      );
      expect(find.byType(FormRow), findsNWidgets(2));
      expect(copied, isEmpty);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(UrlSchemeForm), findsNothing);
    },
  );

  testWidgets('both header tools open and return to the page', (tester) async {
    await pump(tester);
    final l = currentAppLocalizations;
    await tester.tap(find.byTooltip(l.urlSchemeBuild));
    await _settleForm(tester);
    expect(find.byType(UrlSchemeForm), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l.urlSchemeInspect));
    await tester.pumpAndSettle();
    expect(find.byType(UrlSchemeInspector), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(UrlSchemeInspector), findsNothing);
    expect(find.byType(UrlSchemeView), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'phone width and larger text remain usable in ${brightness.name}',
      (tester) async {
        await pump(
          tester,
          size: const Size(320, 700),
          scale: 1.4,
          brightness: brightness,
        );
        final l = currentAppLocalizations;
        await _reveal(tester, find.text(l.urlSchemeInstallConfig));
        await tester.tap(find.text(l.urlSchemeInstallConfig));
        await _settleForm(tester);
        expect(find.byType(UrlSchemeForm), findsOneWidget);
        final urlRow = find.byWidgetPredicate(
          (widget) => widget is FormRow && widget.title == l.url,
        );
        final scrollable = find
            .descendant(
              of: find.byType(FormPage),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(urlRow, 150, scrollable: scrollable);
        final urlField = find.descendant(
          of: urlRow,
          matching: find.byType(TextFormField),
        );
        await _reveal(tester, urlField);
        await tester.enterText(
          urlField,
          'https://example.com/${'a' * 1500}?token=example',
        );
        await _settleForm(tester);
        await tester.scrollUntilVisible(
          find.byType(UrlSchemePreview),
          150,
          scrollable: scrollable,
        );
        await tester.pump();
        expect(
          tester.widget<UrlSchemePreview>(find.byType(UrlSchemePreview)).link,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

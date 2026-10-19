import 'dart:async';

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
import 'package:reclash/widgets/url_scheme_preview.dart';

import '../helpers/test_app.dart';

Finder _field(String title) => find.descendant(
  of: find.widgetWithText(FormRow, title),
  matching: find.byType(TextFormField),
);

Future<void> _settleWork(WidgetTester tester) async {
  await tester.pump();
  var idle = false;
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 25));
    final form = find.byType(FormPage);
    final settled =
        form.evaluate().isNotEmpty &&
        !tester.widget<FormPage>(form).saving &&
        find.byType(CommonPopupMenu).evaluate().isEmpty &&
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
  fail('The link operation did not settle');
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool sheet = false,
}) async {
  const size = Size(1100, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
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
        child: sheet
            ? Builder(
                builder: (context) => FilledButton(
                  onPressed: () => unawaited(
                    showFormSheet<void>(
                      context: context,
                      builder: (_) => child,
                    ),
                  ),
                  child: const Text('Open'),
                ),
              )
            : child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (sheet) {
    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 350));
  }
  await _settleWork(tester);
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
}

void main() {
  late List<String> copied;
  late bool clipboardFails;
  String? clipboardText;

  setUp(() {
    copied = [];
    clipboardFails = false;
    clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            if (clipboardFails) throw PlatformException(code: 'unavailable');
            copied.add((call.arguments as Map)['text'] as String);
          }
          if (call.method == 'Clipboard.getData') {
            if (clipboardFails) throw PlatformException(code: 'unavailable');
            return clipboardText == null ? null : {'text': clipboardText};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets(
    'builder previews Unicode names and encoded URLs, then copies and closes',
    (tester) async {
      await _pump(tester, const UrlSchemeForm(), sheet: true);
      final l = currentAppLocalizations;
      expect(find.text(l.urlSchemePreviewEmpty), findsOneWidget);
      expect(find.text(l.urlSchemeMissingPayload), findsNothing);
      const url = 'https://example.com/a%2Fb?token=a+b&next=%23#anchor';
      await tester.enterText(_field(l.name), 'Дом 🦊 & 工作');
      await tester.enterText(_field(l.url), url);
      await _settleWork(tester);
      final preview = tester.widget<UrlSchemePreview>(
        find.byType(UrlSchemePreview),
      );
      expect(parseUrlSchemeLink(preview.link!)!.payload, url);
      expect(parseUrlSchemeLink(preview.link!)!.name, 'Дом 🦊 & 工作');
      await tester.ensureVisible(find.byTooltip(l.copy));
      await tester.tap(find.byTooltip(l.copy));
      await tester.pumpAndSettle();
      expect(copied, [preview.link]);
      expect(find.text(l.copySuccess), findsOneWidget);
      expect(find.byType(UrlSchemeForm), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, l.urlSchemeCopyLink));
      await tester.pumpAndSettle();
      expect(copied, [preview.link, preview.link]);
      expect(find.byType(UrlSchemeForm), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'builder refuses incomplete and malformed input without copying',
    (tester) async {
      await _pump(tester, const UrlSchemeForm(), sheet: true);
      final l = currentAppLocalizations;
      await tester.tap(find.widgetWithText(TextButton, l.urlSchemeCopyLink));
      await _settleWork(tester);
      expect(find.text(l.urlSchemeMissingPayload), findsOneWidget);
      await tester.enterText(_field(l.url), 'file:///tmp/config');
      await _settleWork(tester);
      expect(find.text(l.urlSchemeInvalidUrl), findsOneWidget);
      expect(copied, isEmpty);
      expect(
        tester.widget<UrlSchemePreview>(find.byType(UrlSchemePreview)).link,
        isNull,
      );
      expect(find.byType(UrlSchemeForm), findsOneWidget);
    },
  );

  testWidgets(
    'name-only input exposes the missing payload rather than a silent preview',
    (tester) async {
      await _pump(tester, const UrlSchemeForm());
      final l = currentAppLocalizations;
      await tester.enterText(_field(l.name), 'Home');
      await _settleWork(tester);
      expect(find.text(l.urlSchemeMissingPayload), findsOneWidget);
      expect(copied, isEmpty);
    },
  );

  testWidgets('builder keeps only the latest debounced preview', (
    tester,
  ) async {
    await _pump(tester, const UrlSchemeForm());
    final l = currentAppLocalizations;
    await tester.enterText(_field(l.url), 'https://first.test');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(_field(l.url), 'https://last.test/a?token=final');
    await _settleWork(tester);
    final link = tester
        .widget<UrlSchemePreview>(find.byType(UrlSchemePreview))
        .link!;
    expect(
      parseUrlSchemeLink(link)!.payload,
      'https://last.test/a?token=final',
    );
  });

  testWidgets('builder copy failure stays in the form and a retry succeeds', (
    tester,
  ) async {
    await _pump(
      tester,
      const UrlSchemeForm(command: ReClashCommand.connect),
      sheet: true,
    );
    final l = currentAppLocalizations;
    clipboardFails = true;
    await tester.tap(find.widgetWithText(TextButton, l.urlSchemeCopyLink));
    await tester.pumpAndSettle();
    expect(find.text(l.urlSchemeCopyFailed), findsOneWidget);
    expect(find.byType(UrlSchemeForm), findsOneWidget);
    clipboardFails = false;
    await tester.tap(find.widgetWithText(TextButton, l.urlSchemeCopyLink));
    await tester.pumpAndSettle();
    expect(copied, ['reclash://connect']);
    expect(find.byType(UrlSchemeForm), findsNothing);
  });

  testWidgets(
    'switching to embedded import drops the URL and rejects invalid config',
    (tester) async {
      await _pump(tester, const UrlSchemeForm(), sheet: true);
      final l = currentAppLocalizations;
      await tester.enterText(_field(l.url), 'https://example.com/sub');
      await _settleWork(tester);
      await tester.tap(find.text(l.urlSchemeAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.urlSchemeImport).last);
      await _settleWork(tester);
      final configField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == l.urlSchemeConfigHint,
      );
      expect(_field(l.url), findsNothing);
      await tester.enterText(configField, 'this is not a configuration');
      await _settleWork(tester);
      expect(find.text(l.importConfigInvalid), findsOneWidget);
      expect(
        tester.widget<UrlSchemePreview>(find.byType(UrlSchemePreview)).link,
        isNull,
      );
      await tester.tap(find.byTooltip(l.urlSchemeUseExample));
      await _settleWork(tester);
      final link = tester
          .widget<UrlSchemePreview>(find.byType(UrlSchemePreview))
          .link!;
      expect(parseUrlSchemeLink(link)!.command, ReClashCommand.importProfile);
      expect(parseUrlSchemeLink(link)!.name, l.urlSchemeExampleProfile);
      expect(find.text(l.importConfigInvalid), findsNothing);
    },
  );

  testWidgets('inspector recognizes commands without executing or closing', (
    tester,
  ) async {
    await _pump(tester, const UrlSchemeInspector());
    final l = currentAppLocalizations;
    await tester.enterText(find.byType(TextField), 'reclash://close');
    await tester.tap(find.byTooltip(l.urlSchemeInspect));
    await _settleWork(tester);
    expect(find.text(l.urlSchemeRecognized), findsOneWidget);
    expect(find.text(l.urlSchemeNoExecution), findsOneWidget);
    expect(find.text(l.urlSchemeClose), findsOneWidget);
    expect(find.byType(UrlSchemeInspector), findsOneWidget);
    expect(copied, isEmpty);
  });

  testWidgets(
    'inspector redacts subscription tokens and clears a result on edit',
    (tester) async {
      await _pump(tester, const UrlSchemeInspector());
      final l = currentAppLocalizations;
      await tester.enterText(
        find.byType(TextField),
        'reclash://add?url=https%3A%2F%2Fexample.com%2Fprivate%3Ftoken%3Dsecret'
        '&name=Home',
      );
      await tester.tap(find.byTooltip(l.urlSchemeInspect));
      await _settleWork(tester);
      expect(find.text('https://example.com'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text(l.urlSchemeInspectionLimit), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'reclash://unknown');
      await tester.pump();
      expect(find.text(l.urlSchemeRecognized), findsNothing);
      await tester.tap(find.byTooltip(l.urlSchemeInspect));
      await _settleWork(tester);
      expect(find.text(l.urlSchemeUnknownCommand), findsOneWidget);
    },
  );

  testWidgets('inspector summarizes a share link using local conversion', (
    tester,
  ) async {
    await _pump(tester, const UrlSchemeInspector());
    final l = currentAppLocalizations;
    await tester.enterText(
      find.byType(TextField),
      'vless://12345678-1234-1234-1234-123456789abc@node.test:443'
      '?security=tls#Local',
    );
    await tester.tap(find.byTooltip(l.urlSchemeInspect));
    await _settleWork(tester);
    expect(find.text(l.urlSchemeRecognized), findsOneWidget);
    expect(find.text(l.urlSchemeConfigCounts(1, 1, 0)), findsOneWidget);
    expect(find.text('vless://'), findsOneWidget);
    expect(find.text(l.urlSchemeNoExecution), findsOneWidget);
  });

  testWidgets(
    'inspector rejects malformed share content without claiming success',
    (tester) async {
      await _pump(tester, const UrlSchemeInspector());
      final l = currentAppLocalizations;
      await tester.enterText(find.byType(TextField), 'vmess://not-base64');
      await tester.tap(find.byTooltip(l.urlSchemeInspect));
      await _settleWork(tester);
      expect(find.text(l.urlSchemeRecognized), findsNothing);
      expect(find.text(l.urlSchemeInspectionResult), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('clipboard paste handles failure and supports manual recovery', (
    tester,
  ) async {
    await _pump(tester, const UrlSchemeInspector());
    final l = currentAppLocalizations;
    clipboardFails = true;
    await tester.tap(find.byTooltip(l.paste));
    await tester.pumpAndSettle();
    expect(find.text(l.urlSchemePasteFailed), findsOneWidget);
    clipboardFails = false;
    clipboardText = 'reclash://open';
    await tester.tap(find.byTooltip(l.paste));
    await tester.pumpAndSettle();
    expect(find.text(l.urlSchemePasteFailed), findsNothing);
    await tester.tap(find.byTooltip(l.urlSchemeInspect));
    await _settleWork(tester);
    expect(find.text(l.urlSchemeOpen), findsOneWidget);
    expect(find.text(l.urlSchemeNoExecution), findsOneWidget);
  });

  testWidgets(
    'late clipboard content cannot overwrite input typed while pasting',
    (tester) async {
      await _pump(tester, const UrlSchemeInspector());
      final l = currentAppLocalizations;
      final gate = Completer<Object?>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.getData') return gate.future;
            return null;
          });
      await tester.tap(find.byTooltip(l.paste));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'reclash://disconnect');
      gate.complete({'text': 'reclash://close'});
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'reclash://disconnect',
      );
      await tester.tap(find.byTooltip(l.urlSchemeInspect));
      await _settleWork(tester);
      expect(find.text(l.urlSchemeDisconnect), findsOneWidget);
      expect(find.text(l.urlSchemeClose), findsNothing);
    },
  );
}

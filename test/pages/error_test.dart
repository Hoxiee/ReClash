import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/views/error.dart';

final _stack = StackTrace.fromString('#0 boot (package:reclash/main.dart:1)');

Widget _screen({ThemeData? theme, Locale? locale}) {
  return MaterialApp(
    theme: theme,
    locale: locale,
    home: InitErrorScreen(
      error: StateError('boot failed'),
      stack: _stack,
      locale: locale,
    ),
  );
}

void _wideView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('offers recovery and keeps the raw error reachable', (
    tester,
  ) async {
    _tallView(tester);
    await tester.pumpWidget(_screen());

    expect(find.text("ReClash couldn't start"), findsOneWidget);
    expect(find.text('Restart ReClash'), findsOneWidget);
    expect(find.text('Factory reset'), findsOneWidget);

    final error = StateError('boot failed').toString();
    expect(
      find.text(error),
      findsNothing,
      reason: 'details stay collapsed until the user opens them',
    );

    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();

    expect(
      find.text(error),
      findsOneWidget,
      reason: 'the raw error must stay readable when nothing else works',
    );
    expect(find.text(_stack.toString()), findsOneWidget);
  });

  testWidgets('renders in both brightness modes', (tester) async {
    _tallView(tester);
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        _screen(theme: ThemeData(brightness: brightness)),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(InitErrorScreen), findsOneWidget);
    }
  });

  testWidgets('copies the error and stack trace to the clipboard', (
    tester,
  ) async {
    _tallView(tester);
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(_screen());
    await tester.tap(find.text('Copy'));
    await tester.pump();

    expect(copied, hasLength(1));
    expect(copied.single, contains('boot failed'));
    expect(copied.single, contains(_stack.toString()));
    expect(find.text('Error details copied to clipboard'), findsOneWidget);
  });

  testWidgets('localizes recovery copy to the platform language', (
    tester,
  ) async {
    _tallView(tester);
    await tester.pumpWidget(_screen(locale: const Locale('zh', 'CN')));

    expect(find.text('ReClash 无法启动'), findsOneWidget);
    expect(find.text('恢复步骤'.toUpperCase()), findsOneWidget);
    expect(
      find.text("ReClash couldn't start"),
      findsNothing,
      reason: 'a Chinese user must not be left reading English',
    );
  });

  testWidgets('falls back to English for an untranslated locale', (
    tester,
  ) async {
    _tallView(tester);
    await tester.pumpWidget(_screen(locale: const Locale('fr')));

    expect(find.text("ReClash couldn't start"), findsOneWidget);
  });

  testWidgets('switches language in place from the picker', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_screen());

    expect(find.text("ReClash couldn't start"), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский').last);
    await tester.pumpAndSettle();

    expect(find.text('Не удалось запустить ReClash'), findsOneWidget);
    expect(find.text("ReClash couldn't start"), findsNothing);
    expect(find.text('Русский'), findsOneWidget);
  });

  testWidgets('splits into two columns on a wide desktop window', (
    tester,
  ) async {
    _wideView(tester);
    await tester.pumpWidget(_screen());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(InitErrorScreen), findsOneWidget);
    expect(find.text('Restart ReClash'), findsOneWidget);
    expect(find.text('Factory reset'), findsOneWidget);
  });
}

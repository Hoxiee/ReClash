import 'dart:async';

import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/reset_data_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> open(WidgetTester tester, Future<void> Function() reset) async {
    await tester.pumpWidget(
      TestApp(
        child: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showFloatingDialog<void>(
                context: context,
                dismissible: false,
                child: ResetDataDialog(onReset: reset),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
  }

  TextButton confirm(WidgetTester tester) => tester.widget<TextButton>(
    find.widgetWithText(TextButton, 'Delete everything'),
  );

  testWidgets('confirmation stays disabled for three seconds', (tester) async {
    var calls = 0;
    await open(tester, () async {
      calls++;
    });
    expect(confirm(tester).onPressed, isNull);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2999));
    expect(confirm(tester).onPressed, isNull);
    expect(calls, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(confirm(tester).onPressed, isNotNull);
    await tester.tap(find.text('Delete everything'));
    await tester.pump();
    expect(calls, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('cancel never deletes data and disposes the countdown', (
    tester,
  ) async {
    var calls = 0;
    await open(tester, () async {
      calls++;
    });
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(ResetDataDialog), findsNothing);
    expect(calls, 0);
  });

  testWidgets(
    'busy reset blocks repeat taps and cancellation, errors allow retry',
    (tester) async {
      final gate = Completer<void>();
      var calls = 0;
      await open(tester, () {
        calls++;
        return gate.future;
      });
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.text('Delete everything'));
      await tester.pump();
      expect(calls, 1);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
            .onPressed,
        isNull,
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      gate.completeError(StateError('test reset failure'));
      await tester.pump();
      expect(find.textContaining('test reset failure'), findsOneWidget);
      expect(confirm(tester).onPressed, isNotNull);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
            .onPressed,
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
}

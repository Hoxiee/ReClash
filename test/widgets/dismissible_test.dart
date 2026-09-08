import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/dismissible.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fires onDismissed exactly once after the exit', (tester) async {
    var dismissed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ExternalDismissible(
            dismiss: false,
            onDismissed: () => dismissed++,
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(dismissed, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ExternalDismissible(
            dismiss: true,
            onDismissed: () => dismissed++,
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(dismissed, 0);

    await tester.pump(dismissDuration + const Duration(milliseconds: 1));
    expect(dismissed, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dismisses at mount without an animation', (tester) async {
    var dismissed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ExternalDismissible(
            dismiss: true,
            onDismissed: () => dismissed++,
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      ),
    );
    await tester.pump(dismissDuration + const Duration(milliseconds: 1));

    expect(dismissed, 1);
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('repeated dismiss requests stay single-shot', (tester) async {
    var dismissed = 0;

    Widget buildApp() {
      return MaterialApp(
        home: Center(
          child: ExternalDismissible(
            dismiss: true,
            onDismissed: () => dismissed++,
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(dismissed, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completes instantly when animations are disabled', (
    tester,
  ) async {
    var dismissed = 0;

    Widget buildApp({required bool dismiss}) {
      return MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          );
        },
        home: Center(
          child: ExternalDismissible(
            dismiss: dismiss,
            onDismissed: () => dismissed++,
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(dismiss: false));
    expect(tester.hasRunningAnimations, isFalse);
    expect(dismissed, 0);

    await tester.pumpWidget(buildApp(dismiss: true));
    await tester.pump();

    expect(dismissed, 1);
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });
}

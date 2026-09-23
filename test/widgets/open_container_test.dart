import 'package:reclash/widgets/layout/open_container.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OpenContainer opens, closes, and returns a value', (
    tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 80,
              child: OpenContainer<String>(
                middleColor: Colors.orange,
                routeSettings: const RouteSettings(name: 'details'),
                transitionDuration: const Duration(milliseconds: 200),
                closedBuilder: (_, open) {
                  return FilledButton(
                    onPressed: open,
                    child: const Text('Closed'),
                  );
                },
                openBuilder: (_, close) {
                  return Center(
                    child: FilledButton(
                      onPressed: () => close(returnValue: 'done'),
                      child: const Text('Close'),
                    ),
                  );
                },
                onClosed: (value) {
                  result = value;
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Closed'));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('Close'), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pumpAndSettle();

    expect(result, 'done');
    expect(find.text('Closed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'fadeThrough opens by callback and supports interrupted reverse',
    (tester) async {
      String? result = 'unchanged';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: OpenContainer<String>(
                tappable: false,
                useRootNavigator: true,
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 300),
                closedBuilder: (_, open) {
                  return TextButton(
                    onPressed: open,
                    child: const Text('Open manually'),
                  );
                },
                openBuilder: (_, close) {
                  return TextButton(
                    onPressed: () => close(),
                    child: const Text('Reverse now'),
                  );
                },
                onClosed: (value) {
                  result = value;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open manually'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Reverse now'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(result, isNull);
      expect(find.text('Reverse now'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the container opens in one frame under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 80,
              child: OpenContainer<String>(
                transitionDuration: Duration.zero,
                closedBuilder: (_, open) {
                  return FilledButton(
                    onPressed: open,
                    child: const Text('Closed'),
                  );
                },
                openBuilder: (_, close) {
                  return Center(
                    child: FilledButton(
                      onPressed: () => close(returnValue: 'done'),
                      child: const Text('Close'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Closed'));
    await tester.pump();

    expect(find.text('Close'), findsOneWidget);
    final route = ModalRoute.of(tester.element(find.text('Close')));
    expect(route!.transitionDuration, Duration.zero);
    expect(route.animation!.isCompleted, isTrue);

    await tester.tap(find.text('Close'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Closed').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Closed'));
    await tester.pump();
    expect(find.text('Close'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

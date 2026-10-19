import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/ui/page_background.dart';

void main() {
  testWidgets('nested page backgrounds are deduplicated within one route', (
    tester,
  ) async {
    var backgroundCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: PageBackgroundRegistration(
          builder: (context, color, child) {
            backgroundCount++;
            return ColoredBox(color: color, child: child);
          },
          child: PageBackground(
            baseColor: Colors.white,
            child: PageBackground(
              baseColor: Colors.white,
              child: const Text('one route'),
            ),
          ),
        ),
      ),
    );
    expect(backgroundCount, 1);
    expect(find.text('one route'), findsOneWidget);
  });

  testWidgets('pushed route receives its own opaque background', (
    tester,
  ) async {
    var backgroundCount = 0;
    Widget page(String label) => PageBackground(
      baseColor: Colors.white,
      child: Scaffold(body: Text(label)),
    );

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => PageBackgroundRegistration(
          builder: (context, color, content) {
            backgroundCount++;
            return ColoredBox(color: color, child: content);
          },
          child: child!,
        ),
        home: page('first'),
      ),
    );
    await tester.pumpAndSettle();
    final beforePush = backgroundCount;
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.push(MaterialPageRoute<void>(builder: (_) => page('second')));
    await tester.pumpAndSettle();
    expect(backgroundCount, greaterThan(beforePush));
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('card opacity is scoped and defaults to opaque', (tester) async {
    late BuildContext inside;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(PageBackgroundScope.opacityOf(context), 1);
            return PageBackgroundScope(
              cardOpacity: 0.4,
              child: Builder(
                builder: (context) {
                  inside = context;
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );
    expect(PageBackgroundScope.opacityOf(inside), 0.4);
    expect(
      PageBackgroundScope.applyCardOpacity(inside, const Color(0xff123456)).a,
      closeTo(0.4, 0.01),
    );
  });
}

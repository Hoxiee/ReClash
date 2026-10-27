import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildEntries(List<String> items, {bool grouped = false}) {
    return MaterialApp(
      home: Scaffold(
        body: AnimatedEntries(
          grouped: grouped,
          children: [
            for (final item in items)
              SizedBox(
                key: ValueKey(item),
                height: 40,
                child: Builder(
                  builder: (context) => Text(
                    '$item ${ItemPositionProvider.of(context)?.position.name}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Finder row(String item) => find.byWidgetPredicate(
    (widget) => widget is SizedBox && widget.key == ValueKey(item),
  );

  double topOf(WidgetTester tester, String item) =>
      tester.getTopLeft(row(item)).dy;

  test('keepLeaving holds a removed item before the one it preceded', () {
    expect(keepLeaving(['a', 'b', 'c', 'd'], ['a', 'd', 'e'], (item) => item), [
      'a',
      'b',
      'c',
      'd',
      'e',
    ]);
    expect(keepLeaving(['a', 'b'], ['b', 'a'], (item) => item), ['b', 'a']);
    expect(keepLeaving(['a', 'b'], ['a'], (item) => item), ['a', 'b']);
  });

  testWidgets('a removed entry collapses before leaving the tree', (
    tester,
  ) async {
    await tester.pumpWidget(buildEntries(const ['a', 'b', 'c']));
    await tester.pumpWidget(buildEntries(const ['a', 'c']));
    await tester.pump();

    expect(row('b'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    expect(topOf(tester, 'c'), inExclusiveRange(40, 80));

    await tester.pumpAndSettle();
    expect(row('b'), findsNothing);
    expect(topOf(tester, 'c'), 40);
  });

  testWidgets('an added entry grows in', (tester) async {
    await tester.pumpWidget(buildEntries(const ['a', 'c']));
    await tester.pumpWidget(buildEntries(const ['a', 'b', 'c']));
    await tester.pump(const Duration(milliseconds: 150));

    expect(topOf(tester, 'c'), inExclusiveRange(40, 80));
    await tester.pumpAndSettle();
    expect(topOf(tester, 'c'), 80);
  });

  testWidgets('an entry put back while collapsing grows back', (tester) async {
    await tester.pumpWidget(buildEntries(const ['a', 'b', 'c']));
    await tester.pumpWidget(buildEntries(const ['a', 'c']));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpWidget(buildEntries(const ['a', 'b', 'c']));

    await tester.pumpAndSettle();
    expect(row('b'), findsOneWidget);
    expect(topOf(tester, 'c'), 80);
  });

  testWidgets('grouped rows close up while a leaving one keeps its place', (
    tester,
  ) async {
    await tester.pumpWidget(buildEntries(const ['a', 'b', 'c'], grouped: true));
    expect(find.text('c ${ItemPosition.end.name}'), findsOneWidget);

    await tester.pumpWidget(buildEntries(const ['a', 'b'], grouped: true));
    await tester.pump();
    expect(find.text('b ${ItemPosition.end.name}'), findsOneWidget);
    expect(find.text('c ${ItemPosition.end.name}'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(row('c'), findsNothing);
  });

  testWidgets('unkeyed entries of distinct types are told apart', (
    tester,
  ) async {
    Widget build({required bool middle}) => MaterialApp(
      home: Scaffold(
        body: AnimatedEntries(
          children: [
            const SizedBox(height: 40),
            if (middle) const FlutterLogo(size: 40),
            const Placeholder(fallbackHeight: 40),
          ],
        ),
      ),
    );

    await tester.pumpWidget(build(middle: false));
    await tester.pumpWidget(build(middle: true));
    await tester.pump();
    expect(find.byType(FlutterLogo), findsOneWidget);
    await tester.pumpWidget(build(middle: false));
    await tester.pumpAndSettle();
    expect(find.byType(FlutterLogo), findsNothing);
    expect(find.byType(Placeholder), findsOneWidget);
  });

  testWidgets('a reveal unfolds, then folds away showing its last child', (
    tester,
  ) async {
    Widget build(String? text) => MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            AnimatedReveal(
              visible: text != null,
              child: SizedBox(height: 40, child: Text(text ?? 'hidden')),
            ),
            const SizedBox(key: ValueKey('below'), height: 40),
          ],
        ),
      ),
    );

    await tester.pumpWidget(build(null));
    expect(topOf(tester, 'below'), 0);

    await tester.pumpWidget(build('shown'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(topOf(tester, 'below'), inExclusiveRange(0, 40));
    await tester.pumpAndSettle();
    expect(topOf(tester, 'below'), 40);

    await tester.pumpWidget(build(null));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('shown'), findsOneWidget);
    expect(find.text('hidden'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('shown'), findsNothing);
    expect(topOf(tester, 'below'), 0);
  });
}

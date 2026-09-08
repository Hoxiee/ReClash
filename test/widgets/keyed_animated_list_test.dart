import 'package:reclash/widgets/keyed_animated_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildList(
    List<String> items, {
    bool disableAnimations = false,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: child!,
        );
      },
      home: Scaffold(
        body: KeyedAnimatedList<String>(
          items: items,
          keyOf: (item) => item,
          separator: const Divider(height: 0),
          duration: duration,
          itemBuilder: (_, item) => SizedBox(
            key: ValueKey('row-$item'),
            height: 40,
            child: Text(item),
          ),
        ),
      ),
    );
  }

  double topOf(WidgetTester tester, String item) {
    return tester.getTopLeft(find.byKey(ValueKey('row-$item'))).dy;
  }

  testWidgets('neighbours of a removed row slide up to fill the gap', (
    tester,
  ) async {
    await tester.pumpWidget(buildList(const ['a', 'b', 'c']));
    await tester.pumpWidget(buildList(const ['a', 'c']));
    await tester.pump();

    expect(find.text('b'), findsNothing);
    expect(topOf(tester, 'c'), 80);
    await tester.pump(const Duration(milliseconds: 150));
    final midway = topOf(tester, 'c');
    expect(midway, lessThan(80));
    expect(midway, greaterThan(40));

    await tester.pumpAndSettle();
    expect(topOf(tester, 'c'), 40);
  });

  testWidgets('reordered item slides from its old slot', (tester) async {
    await tester.pumpWidget(buildList(const ['a', 'b', 'c']));
    expect(topOf(tester, 'c'), 80);

    await tester.pumpWidget(buildList(const ['c', 'a', 'b']));
    await tester.pump();

    final render = tester.renderObject(find.byKey(const ValueKey('row-c')));
    Offset paintedTop() => (render as RenderBox).localToGlobal(Offset.zero);
    expect(paintedTop().dy, closeTo(80, 0.01));

    await tester.pump(const Duration(milliseconds: 150));
    final midway = paintedTop().dy;
    expect(midway, greaterThan(0));
    expect(midway, lessThan(80));

    await tester.pumpAndSettle();
    expect(paintedTop().dy, closeTo(0, 0.01));
    expect(tester.takeException(), null);
  });

  testWidgets('inserted and removed rows settle without controllers', (
    tester,
  ) async {
    await tester.pumpWidget(buildList(const ['a']));
    await tester.pumpWidget(buildList(const ['a', 'b']));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('b'), findsOneWidget);

    await tester.pumpWidget(buildList(const ['a']));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('b'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('a'), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('item removed and re-added keeps a single row', (tester) async {
    await tester.pumpWidget(buildList(const ['a', 'b']));
    await tester.pumpWidget(buildList(const ['a']));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(buildList(const ['a', 'b']));
    await tester.pumpAndSettle();

    expect(find.text('b'), findsOneWidget);
    expect(topOf(tester, 'b'), 40);
  });

  testWidgets('burst removal settles with one rebuild per update', (
    tester,
  ) async {
    final items = List.generate(30, (i) => 'item$i');
    await tester.pumpWidget(buildList(items));
    await tester.pump();

    await tester.pumpWidget(buildList(const ['item0']));
    await tester.pumpAndSettle();

    expect(find.text('item1'), findsNothing);
    expect(find.text('item0'), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('rapid remove then re-add within one frame keeps one entry', (
    tester,
  ) async {
    await tester.pumpWidget(buildList(const ['a', 'b', 'c']));
    await tester.pump();
    await tester.pumpWidget(buildList(const ['a']));
    await tester.pumpWidget(buildList(const ['a', 'b', 'c']));
    await tester.pumpAndSettle();

    for (final item in ['a', 'b', 'c']) {
      expect(find.text(item), findsOneWidget);
    }
    expect(topOf(tester, 'b'), 40);
    expect(topOf(tester, 'c'), 80);
    expect(tester.takeException(), null);
  });

  testWidgets('reduced motion jumps rows with no running ticker', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildList(const ['a', 'b', 'c'], disableAnimations: true),
    );
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(
      buildList(const ['c', 'a', 'b'], disableAnimations: true),
    );
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    expect(find.byType(KeyedAnimatedList<String>), findsOneWidget);
    expect(find.text('c'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), null);
  });

  testWidgets('duration change updates in-flight controller duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildList(const ['a', 'b', 'c'], duration: const Duration(seconds: 2)),
    );
    await tester.pump();
    await tester.pumpWidget(
      buildList(const ['c', 'b', 'a'], duration: const Duration(seconds: 2)),
    );
    await tester.pump();

    await tester.pumpWidget(
      buildList(const ['b', 'a', 'c'], duration: const Duration(seconds: 2)),
    );
    await tester.pump();

    await tester.pumpWidget(
      buildList(const ['a', 'b', 'c'], duration: const Duration(seconds: 2)),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpAndSettle();
    expect(topOf(tester, 'c'), 80);
    expect(tester.takeException(), null);
  });

  testWidgets('move interrupts and restarts from the painted offset', (
    tester,
  ) async {
    await tester.pumpWidget(buildList(const ['a', 'b', 'c', 'd']));
    await tester.pump();
    await tester.pumpWidget(buildList(const ['d', 'a', 'b', 'c']));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(buildList(const ['b', 'd', 'a', 'c']));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpAndSettle();
    expect(topOf(tester, 'a'), 80);
    expect(topOf(tester, 'b'), 0);
    expect(topOf(tester, 'c'), 120);
    expect(tester.takeException(), null);
  });

  testWidgets('reduced motion flipped on mid-flight stops the ticker', (
    tester,
  ) async {
    await tester.pumpWidget(buildList(const ['a', 'b', 'c']));
    await tester.pump();
    await tester.pumpWidget(buildList(const ['c', 'a', 'b']));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(
      buildList(const ['c', 'a', 'b'], disableAnimations: true),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpAndSettle();
    expect(topOf(tester, 'a'), 40);
    expect(topOf(tester, 'b'), 80);
    expect(tester.takeException(), null);
  });

  testWidgets('TickerMode disabled mid-flight settles without exceptions', (
    tester,
  ) async {
    Widget host(bool enabled) => MaterialApp(
      home: Scaffold(
        body: TickerMode(
          enabled: enabled,
          child: KeyedAnimatedList<String>(
            items: const ['a', 'b', 'c'],
            keyOf: (item) => item,
            itemBuilder: (_, item) => SizedBox(height: 40, child: Text(item)),
          ),
        ),
      ),
    );
    await tester.pumpWidget(host(true));
    await tester.pump();
    await tester.pumpWidget(host(false));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(host(true));
    await tester.pumpAndSettle();

    double topOfText(String item) => tester.getTopLeft(find.text(item)).dy;
    expect(topOfText('a'), 0);
    expect(topOfText('b'), 40);
    expect(topOfText('c'), 80);
    expect(tester.takeException(), null);
  });

  testWidgets('rows survive scroll offscreen and back with stable elements', (
    tester,
  ) async {
    final items = List.generate(40, (i) => 'item$i');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedAnimatedList<String>(
            items: items,
            keyOf: (item) => item,
            itemBuilder: (_, item) => SizedBox(
              key: ValueKey('row-$item'),
              height: 40,
              child: Text(item),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(find.text('item0'), findsOneWidget);
    expect(find.text('item39'), findsNothing);
    expect(tester.takeException(), null);
  });
}

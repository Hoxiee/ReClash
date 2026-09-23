import 'package:reclash/widgets/input/reorder_menu.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  Future<List<(int, int)>> pumpList(
    WidgetTester tester, {
    int count = 3,
  }) async {
    final moves = <(int, int)>[];
    await tester.pumpWidget(
      TestApp(
        locale: const Locale('en'),
        child: Scaffold(
          body: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: count,
            itemBuilder: (_, index) => ListTile(
              key: ValueKey(index),
              title: Text('item $index'),
              trailing: ReorderMenuHandle(
                index: index,
                count: count,
                onReorder: (oldIndex, newIndex) =>
                    moves.add((oldIndex, newIndex)),
              ),
            ),
            onReorder: (_, _) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return moves;
  }

  Future<void> openMenuAt(WidgetTester tester, int index) async {
    await tester.tap(find.byType(ReorderMenuHandle).at(index));
    await tester.pumpAndSettle();
  }

  testWidgets('a middle item exposes every move', (tester) async {
    await pumpList(tester);
    await openMenuAt(tester, 1);
    expect(find.text('Move up'), findsOneWidget);
    expect(find.text('Move down'), findsOneWidget);
    expect(find.text('Move to top'), findsOneWidget);
    expect(find.text('Move to bottom'), findsOneWidget);
  });

  testWidgets('the first item cannot move up', (tester) async {
    await pumpList(tester);
    await openMenuAt(tester, 0);
    expect(find.text('Move up'), findsNothing);
    expect(find.text('Move to top'), findsNothing);
    expect(find.text('Move down'), findsOneWidget);
    expect(find.text('Move to bottom'), findsOneWidget);
  });

  testWidgets('moves report the destination index', (tester) async {
    final moves = await pumpList(tester);

    await openMenuAt(tester, 1);
    await tester.tap(find.text('Move up'));
    await tester.pumpAndSettle();
    expect(moves.last, (1, 0));

    await openMenuAt(tester, 1);
    await tester.tap(find.text('Move to bottom'));
    await tester.pumpAndSettle();
    expect(moves.last, (1, 2));
  });

  testWidgets('a lone item renders no interactive handle', (tester) async {
    await pumpList(tester, count: 1);
    expect(find.byType(ReorderMenuHandle), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });
}

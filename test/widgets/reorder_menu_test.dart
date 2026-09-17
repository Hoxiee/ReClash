import 'package:reclash/widgets/reorder_menu.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpMenu(
    WidgetTester tester, {
    VoidCallback? onMoveUp,
    VoidCallback? onMoveDown,
  }) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: Center(
            child: ReorderMenuButton(
              onMoveUp: onMoveUp,
              onMoveDown: onMoveDown,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('reorder menu moves through its items', (tester) async {
    var up = 0;
    var down = 0;
    await pumpMenu(tester, onMoveUp: () => up++, onMoveDown: () => down++);

    await tester.tap(find.byType(ReorderMenuButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MenuItemButton).first);
    await tester.pumpAndSettle();
    expect(up, 1);
    expect(down, 0);

    await tester.tap(find.byType(ReorderMenuButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MenuItemButton).last);
    await tester.pumpAndSettle();
    expect(up, 1);
    expect(down, 1);
  });

  testWidgets('unavailable directions stay out of the menu', (tester) async {
    await pumpMenu(tester, onMoveDown: () {});

    await tester.tap(find.byType(ReorderMenuButton));
    await tester.pumpAndSettle();

    expect(find.byType(MenuItemButton), findsOneWidget);
  });

  testWidgets('a fully pinned item renders no button', (tester) async {
    await pumpMenu(tester);

    expect(find.byType(IconButton), findsNothing);
  });
}

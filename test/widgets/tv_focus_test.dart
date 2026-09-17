import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/views/setup/widgets.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/test_app.dart';

void main() {
  setUp(() => system.isTVForTesting = true);
  tearDown(() => system.isTVForTesting = false);

  BorderSide outline(WidgetTester tester, Finder parent) {
    final box = tester.widget<DecoratedBox>(
      find.descendant(of: parent, matching: find.byType(DecoratedBox)).first,
    );
    return ((box.decoration as ShapeDecoration).shape as OutlinedBorder).side;
  }

  testWidgets('TV rows outline focus without an extra traversal stop', (
    tester,
  ) async {
    var activated = 0;
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: FocusTraversalGroup(
            child: PageFocusScope(
              autofocus: true,
              child: Column(
                children: [
                  ListItem(
                    title: const Text('First'),
                    onTap: () => activated++,
                  ),
                  ListItem(title: const Text('Second'), onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final first = find.ancestor(
      of: find.text('First'),
      matching: find.byType(TvFocusOutline),
    );
    final second = find.ancestor(
      of: find.text('Second'),
      matching: find.byType(TvFocusOutline),
    );
    expect(outline(tester, first).color, isNot(Colors.transparent));
    expect(outline(tester, second).color, Colors.transparent);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(activated, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(outline(tester, first).color, Colors.transparent);
    expect(outline(tester, second).color, isNot(Colors.transparent));
  });

  testWidgets('setup focuses an action instead of its heading', (tester) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: FocusTraversalGroup(
            child: PageFocusScope(
              autofocus: true,
              child: SetupStepScaffold(
                title: 'Heading',
                actions: [
                  SetupPrimaryButton(label: 'Continue', onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final focus = FocusManager.instance.primaryFocus!.context!;
    expect(focus.findAncestorWidgetOfExactType<FilledButton>(), isNotNull);
    expect(
      outline(tester, find.byType(TvFocusOutline)).color,
      isNot(Colors.transparent),
    );
  });

  testWidgets('TV traversal enters every inline import action', (tester) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: FocusTraversalGroup(
            policy: PageTraversalPolicy(),
            child: PageFocusScope(
              autofocus: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListItem(title: const Text('Before'), onTap: () {}),
                    const AddProfileView(shrinkWrap: true),
                    ListItem(title: const Text('After'), onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final rows = tester.widgetList<ListItem>(find.byType(ListItem)).toList();
    expect(rows, hasLength(6));
    for (var index = 1; index < rows.length; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(
        FocusManager.instance.primaryFocus!.context!
            .findAncestorWidgetOfExactType<ListItem>(),
        same(rows[index]),
      );
    }
  });

  for (final initial in [0.0, 0.5, 1.0]) {
    testWidgets('TV slider lets vertical focus escape at $initial', (
      tester,
    ) async {
      var value = initial;
      final before = FocusNode();
      final after = FocusNode();
      addTearDown(before.dispose);
      addTearDown(after.dispose);
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: FocusTraversalGroup(
              child: StatefulBuilder(
                builder: (context, setState) => Column(
                  children: [
                    TextButton(
                      focusNode: before,
                      autofocus: true,
                      onPressed: () {},
                      child: const Text('Before'),
                    ),
                    SettingSliderItem(
                      title: 'Value',
                      valueLabel: '$value',
                      min: 0,
                      max: 1,
                      value: value,
                      onChanged: (next) => setState(() => value = next),
                    ),
                    TextButton(
                      focusNode: after,
                      onPressed: () {},
                      child: const Text('After'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(
        FocusManager.instance.primaryFocus!.context!
            .findAncestorWidgetOfExactType<Slider>(),
        isNotNull,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(after.hasPrimaryFocus, isTrue);
      expect(value, initial);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(before.hasPrimaryFocus, isTrue);
      expect(value, initial);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(
        initial == 1
            ? LogicalKeyboardKey.arrowLeft
            : LogicalKeyboardKey.arrowRight,
      );
      await tester.pumpAndSettle();
      expect(value, isNot(initial));
    });
  }
}

import 'package:reclash/providers/app.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Widget _wrap(Widget child) => ProviderScope(
  overrides: [
    viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
  ],
  child: TestApp(
    child: Scaffold(body: ListView(children: [child])),
  ),
);

void main() {
  group('DecorationListItem.toggle', () {
    testWidgets('taps flip the value through the row', (tester) async {
      var value = false;
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (_, setState) => DecorationListItem.toggle(
              title: const Text('Toggle row'),
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
      await tester.tap(find.text('Toggle row'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });
  });

  group('DecorationListItem.options', () {
    testWidgets('taps open the options dialog and deliver the choice', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        _wrap(
          DecorationListItem.options(
            title: const Text('Options row'),
            dialogTitle: 'Options row',
            options: const ['a', 'b'],
            value: 'a',
            textBuilder: (value) => value as String,
            onChanged: (value) => picked = value as String?,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Options row'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('b'));
      await tester.pumpAndSettle();
      expect(picked, 'b');
    });
  });

  group('DecorationListItem.input', () {
    testWidgets('taps open the input dialog and return the text', (
      tester,
    ) async {
      String? written;
      await tester.pumpWidget(
        _wrap(
          DecorationListItem.input(
            title: const Text('Input row'),
            dialogTitle: 'Input row',
            value: 'old',
            onChanged: (value) => written = value,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Input row'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'new');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(written, 'new');
    });
  });

  group('SettingSection', () {
    testWidgets('renders header and settles the enter animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SettingSection(
            title: 'Section title',
            items: [DecorationListItem(title: Text('Row'))],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Section title'), findsOneWidget);
      expect(find.text('Row'), findsOneWidget);
    });

    testWidgets('sliver variant mounts inside a CustomScrollView', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SettingSection.sliver(
                  title: 'Sliver section',
                  items: [DecorationListItem(title: Text('Sliver row'))],
                ),
                SettingBottomInset.sliver(),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sliver section'), findsOneWidget);
      expect(find.text('Sliver row'), findsOneWidget);
    });
  });
}

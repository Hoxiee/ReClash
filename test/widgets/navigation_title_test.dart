import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/navigation_title.dart';
import 'package:reclash/ui/typography.dart';

void main() {
  testWidgets(
    'path segments retain their geometry and color at route endpoints',
    (tester) async {
      var progress = 0.0;
      var selected = -1;
      late StateSetter rebuild;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return SizedBox(
                  width: 700,
                  height: 56,
                  child: NavigationTitle(
                    previous: 'Advanced configuration',
                    title: 'Advanced configuration › Network',
                    progress: progress,
                    previousStyle: AppTextStyle.pageTitle.of(context),
                    style: AppTextStyle.pageTitle.of(context),
                    onSelect: (index) => selected = index,
                  ),
                );
              },
            ),
          ),
        ),
      );
      final parent = find.text('Advanced configuration');
      final original = tester.getRect(parent);
      final originalStyle = tester.widget<Text>(parent).style!;
      Rect? nearEnd;
      TextStyle? nearEndStyle;
      for (final value in [0.25, 0.5, 0.75, 0.999, 1.0]) {
        rebuild(() => progress = value);
        await tester.pump();
        expect(parent, findsOneWidget);
        final text = tester.widget<Text>(parent);
        expect(
          tester.getRect(parent).center.dy,
          closeTo(original.center.dy, 0.1),
        );
        if (value == 0.999) {
          nearEnd = tester.getRect(parent);
          nearEndStyle = text.style;
        }
        if (value == 1) {
          expect(tester.getRect(parent).left, closeTo(nearEnd!.left, 0.1));
          expect(text.style!.fontSize, closeTo(nearEndStyle!.fontSize!, 0.01));
          expect(text.style!.color!.r, closeTo(nearEndStyle.color!.r, 0.001));
          expect(text.style!.color!.g, closeTo(nearEndStyle.color!.g, 0.001));
          expect(text.style!.color!.b, closeTo(nearEndStyle.color!.b, 0.001));
          await tester.tap(parent);
          expect(selected, 0);
        }
      }
      for (final value in [0.999, 0.75, 0.5, 0.25, 0.0]) {
        rebuild(() => progress = value);
        await tester.pump();
        expect(parent, findsOneWidget);
        expect(
          tester.getRect(parent).center.dy,
          closeTo(original.center.dy, 0.1),
        );
      }
      expect(tester.getRect(parent), original);
      expect(tester.widget<Text>(parent).style, originalStyle);
      expect(find.text('Network'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

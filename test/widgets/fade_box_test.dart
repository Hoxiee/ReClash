import 'package:reclash/widgets/effect/fade_box.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child, {required bool disableAnimations}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: child,
      ),
    );
  }

  for (final (name, box) in [
    ('FadeSlideEnterBox', const FadeSlideEnterBox(child: SizedBox())),
    ('FadeScaleEnterBox', const FadeScaleEnterBox(child: SizedBox())),
    ('DissolveIn', const DissolveIn(child: SizedBox())),
  ]) {
    testWidgets('$name animates its entrance', (tester) async {
      await tester.pumpWidget(host(box, disableAnimations: false));

      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('$name never ticks when animations are disabled', (
      tester,
    ) async {
      await tester.pumpWidget(host(box, disableAnimations: true));

      expect(tester.hasRunningAnimations, isFalse);
      expect(find.byType(SizedBox), findsOneWidget);
    });
  }

  testWidgets('FadeScaleBox switches children instantly when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const FadeScaleBox(
          child: SizedBox(key: Key('first'), width: 10, height: 10),
        ),
        disableAnimations: true,
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('first')), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(
      host(
        const FadeScaleBox(
          child: SizedBox(key: Key('second'), width: 10, height: 10),
        ),
        disableAnimations: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('first')), findsNothing);
    expect(find.byKey(const Key('second')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'FadeRotationScaleBox switches children instantly when disabled',
    (tester) async {
      await tester.pumpWidget(
        host(
          const FadeRotationScaleBox(
            child: SizedBox(key: Key('first'), width: 10, height: 10),
          ),
          disableAnimations: true,
        ),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);

      await tester.pumpWidget(
        host(
          const FadeRotationScaleBox(
            child: SizedBox(key: Key('second'), width: 10, height: 10),
          ),
          disableAnimations: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('first')), findsNothing);
      expect(find.byKey(const Key('second')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('DissolveIn blurs while revealing then drops the filter', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const DissolveIn(child: SizedBox()), disableAnimations: false),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(ImageFiltered), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(ImageFiltered), findsNothing);
    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('DissolveIn shows a bare child when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const DissolveIn(child: SizedBox()), disableAnimations: true),
    );

    expect(find.byType(ImageFiltered), findsNothing);
    expect(find.byType(SizedBox), findsOneWidget);
  });
}

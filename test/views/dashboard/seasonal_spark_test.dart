import 'package:reclash/views/dashboard/widgets/seasonal_spark.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('spark waits for visibility and never restarts after an alert', (
    tester,
  ) async {
    Future<void> show(bool visible) => tester.pumpWidget(
      TestApp(
        child: SizedBox(
          width: 192,
          height: 192,
          child: SeasonalSpark(visible: visible, reduceMotion: false),
        ),
      ),
    );
    Finder animation() => find.descendant(
      of: find.byType(SeasonalSpark),
      matching: find.byType(TweenAnimationBuilder<double>),
    );
    await show(false);
    expect(animation(), findsNothing);
    await show(true);
    await tester.pump(const Duration(seconds: 4));
    final state = tester.state(animation());
    await show(false);
    await show(true);
    expect(tester.state(animation()), same(state));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('reduced motion does not animate the spark', (tester) async {
    await tester.pumpWidget(
      const TestApp(child: SeasonalSpark(reduceMotion: true)),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/page_transition.dart';

const _width = 400.0;

void main() {
  late AnimationController controller;

  Future<void> pumpPages(
    WidgetTester tester, {
    bool dragged = false,
    bool gesture = false,
  }) async {
    Widget page(String name, {required bool entering}) =>
        SlideOverPageTransition(
          animation: entering ? controller : kAlwaysCompleteAnimation,
          secondaryAnimation: entering ? kAlwaysDismissedAnimation : controller,
          dragged: entering && dragged,
          uncoveredByGesture: !entering && gesture,
          child: SizedBox.expand(key: ValueKey(name)),
        );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: _width,
            height: 300,
            child: Stack(
              children: [
                page('below', entering: false),
                page('above', entering: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double leftOf(WidgetTester tester, String name) =>
      tester.getTopLeft(find.byKey(ValueKey(name))).dx -
      tester.getTopLeft(find.byType(Stack)).dx;

  setUp(() {
    controller = AnimationController(
      vsync: const TestVSync(),
      duration: SlideOverPageTransition.duration,
      reverseDuration: SlideOverPageTransition.reverseDuration,
    );
  });

  tearDown(() => controller.dispose());

  testWidgets('a page slides in from the trailing edge over a trailing one', (
    tester,
  ) async {
    await pumpPages(tester);
    expect(leftOf(tester, 'above'), _width);
    expect(leftOf(tester, 'below'), 0);

    final forward = controller.forward();
    var above = _width;
    var below = 0.0;
    while (controller.isAnimating) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(leftOf(tester, 'above'), lessThanOrEqualTo(above));
      expect(leftOf(tester, 'below'), lessThanOrEqualTo(below));
      expect(leftOf(tester, 'below'), greaterThanOrEqualTo(-_width * 0.25));
      above = leftOf(tester, 'above');
      below = leftOf(tester, 'below');
    }
    await forward;
    expect(leftOf(tester, 'above'), 0);
    expect(leftOf(tester, 'below'), -_width * 0.25);

    controller.reverse();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(leftOf(tester, 'above'), inExclusiveRange(0, _width));
    expect(leftOf(tester, 'below'), inExclusiveRange(-_width * 0.25, 0));
    await tester.pumpAndSettle();
    expect(leftOf(tester, 'above'), _width);
    expect(leftOf(tester, 'below'), 0);
  });

  testWidgets('a push turned back midway reverses without a jump', (
    tester,
  ) async {
    await pumpPages(tester);
    controller.forward();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    final turned = leftOf(tester, 'above');
    controller.reverse();
    await tester.pump(const Duration(milliseconds: 16));
    expect((leftOf(tester, 'above') - turned).abs(), lessThan(_width * 0.1));
    await tester.pumpAndSettle();
    expect(leftOf(tester, 'above'), _width);
  });

  testWidgets('a drag moves both pages with the finger', (tester) async {
    controller.value = 1;
    await pumpPages(tester, dragged: true, gesture: true);
    for (final value in [0.8, 0.5, 0.2]) {
      controller.value = value;
      await tester.pump();
      expect(leftOf(tester, 'above'), closeTo(_width * (1 - value), 0.01));
      expect(leftOf(tester, 'below'), closeTo(-_width * 0.25 * value, 0.01));
    }
  });
}

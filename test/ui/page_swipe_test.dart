import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/ui/drag_back.dart';
import 'package:reclash/ui/page_swipe.dart';

class _BackRoute extends PageRoute<void> with DragBackRouteMixin<void> {
  @override
  bool get maintainState => true;
  @override
  Color? get barrierColor => null;
  @override
  String? get barrierLabel => null;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => dragBackDetector(const SizedBox.expand(key: ValueKey('pushed')));
}

void main() {
  testWidgets('a swipe inside a pushed route never turns the page', (
    tester,
  ) async {
    final swipes = <bool>[];
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: PageSwipe(
          enabled: true,
          onSwipe: swipes.add,
          child: Navigator(
            key: navigator,
            onGenerateRoute: (_) => PageRouteBuilder<void>(
              pageBuilder: (_, _, _) =>
                  const SizedBox.expand(key: ValueKey('root')),
            ),
          ),
        ),
      ),
    );

    await tester.fling(
      find.byKey(const ValueKey('root')),
      const Offset(-200, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(swipes, [true]);

    navigator.currentState!.push(_BackRoute());
    await tester.pumpAndSettle();
    for (final dx in [-200.0, 200.0]) {
      await tester.fling(
        find.byKey(const ValueKey('pushed')),
        Offset(dx, 0),
        1000,
      );
      await tester.pumpAndSettle();
    }
    expect(swipes, [true]);
    expect(find.byKey(const ValueKey('pushed')), findsNothing);
  });
}

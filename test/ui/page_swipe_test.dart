import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/ui/drag_back.dart';
import 'package:reclash/ui/page_swipe.dart';

class _BackRoute extends PageRoute<void> with DragBackRouteMixin<void> {
  _BackRoute({this.child = const SizedBox.expand(key: ValueKey('pushed'))});

  final Widget child;

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
  ) => dragBackDetector(child);
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

  Future<GlobalKey<NavigatorState>> pumpSwipe(
    WidgetTester tester,
    List<bool> swipes,
  ) async {
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
    return navigator;
  }

  Future<void> fling(WidgetTester tester, double dx) async {
    await tester.flingFrom(const Offset(400, 300), Offset(dx, 0), 1000);
    await tester.pumpAndSettle();
  }

  testWidgets('a swipe back asks a route that vetoes its pop to go back', (
    tester,
  ) async {
    final swipes = <bool>[];
    final navigator = await pumpSwipe(tester, swipes);
    var asked = 0;
    navigator.currentState!.push(
      _BackRoute(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) => asked++,
          child: const SizedBox.expand(key: ValueKey('pushed')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await fling(tester, -200);
    expect(asked, 0);
    await fling(tester, 200);
    expect(asked, 1);
    expect(swipes, isEmpty);
    expect(find.byKey(const ValueKey('pushed')), findsOneWidget);
  });

  testWidgets('a swipe back closes a layer the route holds before it pops', (
    tester,
  ) async {
    final swipes = <bool>[];
    final navigator = await pumpSwipe(tester, swipes);
    final route = _BackRoute();
    navigator.currentState!.push(route);
    await tester.pumpAndSettle();
    var closed = false;
    route.addLocalHistoryEntry(
      LocalHistoryEntry(onRemove: () => closed = true),
    );
    await tester.pump();

    await fling(tester, 200);
    expect(closed, isTrue);
    expect(find.byKey(const ValueKey('pushed')), findsOneWidget);

    await fling(tester, 200);
    expect(find.byKey(const ValueKey('pushed')), findsNothing);
    expect(swipes, isEmpty);
  });

  testWidgets('an inner pager past its first page hands the swipe to the '
      'route it is on', (tester) async {
    final swipes = <bool>[];
    final navigator = await pumpSwipe(tester, swipes);
    navigator.currentState!.push(
      _BackRoute(
        child: Builder(
          builder: (context) => GestureDetector(
            key: const ValueKey('pushed'),
            onHorizontalDragEnd: (details) => PageSwipeNotification(
              forward: details.primaryVelocity! < 0,
            ).dispatch(context),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await fling(tester, -200);
    expect(find.byKey(const ValueKey('pushed')), findsOneWidget);
    await fling(tester, 200);
    expect(find.byKey(const ValueKey('pushed')), findsNothing);
    expect(swipes, isEmpty);
  });
}

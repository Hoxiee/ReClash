import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/feedback/tooltip.dart';

const _first = Key('first');
const _second = Key('second');

Widget _app(
  Widget child, {
  Brightness brightness = Brightness.dark,
  bool reducedMotion = false,
  double textScale = 1,
}) => MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff6854c7),
      brightness: brightness,
    ),
  ).withAppTooltips,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      disableAnimations: reducedMotion,
      textScaler: TextScaler.linear(textScale),
    ),
    child: child!,
  ),
  home: Scaffold(body: Center(child: child)),
);

Widget _target({Key key = _first, String message = 'First hint'}) => AppTooltip(
  message: message,
  child: SizedBox(key: key, width: 48, height: 48),
);

Future<TestGesture> _mouse(WidgetTester tester, Finder target) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: const Offset(1, 1));
  await tester.pump();
  await mouse.moveTo(tester.getCenter(target));
  await tester.pump();
  return mouse;
}

Future<void> _reveal(
  WidgetTester tester, [
  Duration delay = AppTooltipTiming.wait,
]) async {
  await tester.pump(delay);
  await tester.pump(AppTooltipTiming.enterAnimation);
}

void main() {
  tearDown(() {
    FocusHighlightVisibility.visibleForTesting = false;
  });

  for (final brightness in Brightness.values) {
    testWidgets('the $brightness tooltip uses the app surface and shape', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_target(), brightness: brightness));
      await _mouse(tester, find.byKey(_first));
      await _reveal(tester);

      final text = find.text('First hint');
      final context = tester.element(text);
      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find
                        .ancestor(of: text, matching: find.byType(DecoratedBox))
                        .first,
                  )
                  .decoration
              as ShapeDecoration;
      expect(
        decoration.color,
        Theme.of(context).colorScheme.surfaceContainerHigh,
      );
      expect(decoration.shadows, isNotEmpty);
      expect(decoration.shape, isA<OutlinedBorder>());
      expect(
        tester.widget<Text>(text).style?.color,
        Theme.of(context).colorScheme.onSurface,
      );
    });
  }

  testWidgets('a first hover waits 600ms before revealing the hint', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_target()));
    await _mouse(tester, find.byKey(_first));
    await tester.pump(const Duration(milliseconds: 599));
    expect(find.text('First hint'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(AppTooltipTiming.enterAnimation);
    expect(find.text('First hint'), findsOneWidget);
  });

  testWidgets('the surface fades and moves in without overshoot', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_target()));
    await _mouse(tester, find.byKey(_first));
    await tester.pump(AppTooltipTiming.wait);
    final text = find.text('First hint');
    final opacity = find
        .ancestor(of: text, matching: find.byType(Opacity))
        .first;
    final transform = find
        .ancestor(of: text, matching: find.byType(Transform))
        .first;
    expect(tester.widget<Opacity>(opacity).opacity, 0);
    expect(tester.widget<Transform>(transform).transform.storage[13], 3);
    await tester.pump(const Duration(milliseconds: 75));
    expect(tester.widget<Opacity>(opacity).opacity, inExclusiveRange(0, 1));
    expect(
      tester.widget<Transform>(transform).transform.storage[13],
      inExclusiveRange(0, 3),
    );
    await tester.pump(const Duration(milliseconds: 75));
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    expect(tester.widget<Transform>(transform).transform.storage[13], 0);
  });

  testWidgets('a fly-by cancels the pending hint', (tester) async {
    await tester.pumpWidget(_app(_target()));
    final mouse = await _mouse(tester, find.byKey(_first));
    await tester.pump(const Duration(milliseconds: 300));
    await mouse.moveTo(const Offset(1, 1));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('First hint'), findsNothing);
  });

  testWidgets('adjacent hints wait 200ms rather than appearing immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _target(),
            _target(key: _second, message: 'Second hint'),
          ],
        ),
      ),
    );
    final mouse = await _mouse(tester, find.byKey(_first));
    await _reveal(tester);
    await mouse.moveTo(tester.getCenter(find.byKey(_second)));
    await tester.pump(const Duration(milliseconds: 199));
    expect(find.text('Second hint'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(AppTooltipTiming.enterAnimation);
    expect(find.text('First hint'), findsNothing);
    expect(find.text('Second hint'), findsOneWidget);
  });

  testWidgets('the warm delay expires after leaving the controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _target(),
            _target(key: _second, message: 'Second hint'),
          ],
        ),
      ),
    );
    final mouse = await _mouse(tester, find.byKey(_first));
    await _reveal(tester);
    await mouse.moveTo(const Offset(1, 1));
    await tester.pump(AppTooltipTiming.exit);
    await tester.pump(AppTooltipTiming.exitAnimation);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await mouse.moveTo(tester.getCenter(find.byKey(_second)));
    await tester.pump(const Duration(milliseconds: 599));
    expect(find.text('Second hint'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(AppTooltipTiming.enterAnimation);
    expect(find.text('Second hint'), findsOneWidget);
  });

  testWidgets('moving onto the hint keeps it open for reading', (tester) async {
    await tester.pumpWidget(_app(_target()));
    final mouse = await _mouse(tester, find.byKey(_first));
    await _reveal(tester);
    await mouse.moveTo(tester.getCenter(find.text('First hint')));
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('First hint'), findsOneWidget);
    await mouse.moveTo(const Offset(1, 1));
    await tester.pump(AppTooltipTiming.exit);
    await tester.pump(AppTooltipTiming.exitAnimation);
    await tester.pumpAndSettle();
    expect(find.text('First hint'), findsNothing);
  });

  testWidgets('a click cancels a pending hint without delaying the action', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      _app(
        IconButton(
          key: _first,
          tooltip: 'First hint',
          onPressed: () => presses++,
          icon: const Icon(Icons.refresh),
        ).withAppTooltip(),
      ),
    );
    final mouse = await _mouse(tester, find.byKey(_first));
    await tester.pump(const Duration(milliseconds: 300));
    await mouse.down(tester.getCenter(find.byKey(_first)));
    await mouse.up();
    await tester.pump(const Duration(seconds: 1));
    expect(presses, 1);
    expect(find.text('First hint'), findsNothing);
    expect(find.byTooltip('First hint'), findsOneWidget);
  });

  testWidgets('enabled and disabled buttons retain one accessible tooltip', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      for (final enabled in [true, false]) {
        await tester.pumpWidget(
          _app(
            IconButton(
              key: _first,
              tooltip: 'First hint',
              onPressed: enabled ? () {} : null,
              icon: const Icon(Icons.refresh),
            ).withAppTooltip(),
          ),
        );
        expect(find.byTooltip('First hint'), findsOneWidget);
        expect(
          tester.getSemantics(find.byKey(_first)).getSemanticsData().tooltip,
          'First hint',
        );
      }
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('navigation buttons keep their labels on the tap target', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var presses = 0;
    try {
      await tester.pumpWidget(
        _app(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BackButton(
                key: _first,
                onPressed: () => presses++,
              ).withAppTooltip('Go back'),
              CloseButton(
                key: _second,
                onPressed: () => presses++,
              ).withAppTooltip('Close page'),
            ],
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byKey(_first)).getSemanticsData().tooltip,
        'Go back',
      );
      expect(
        tester.getSemantics(find.byKey(_second)).getSemanticsData().tooltip,
        'Close page',
      );
      await tester.tap(find.byTooltip('Go back'));
      await tester.tap(find.byTooltip('Close page'));
      expect(presses, 2);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('Escape dismisses both pending and visible hints', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_target()));
    final mouse = await _mouse(tester, find.byKey(_first));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('First hint'), findsNothing);

    await mouse.moveTo(const Offset(1, 1));
    await mouse.moveTo(tester.getCenter(find.byKey(_first)));
    await _reveal(tester);
    expect(find.text('First hint'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(AppTooltipTiming.exitAnimation);
    await tester.pumpAndSettle();
    expect(find.text('First hint'), findsNothing);
  });

  testWidgets('scrolling cancels pending and visible hints', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        ListView(
          controller: controller,
          children: [_target(), const SizedBox(height: 1200)],
        ),
      ),
    );
    final mouse = await _mouse(tester, find.byKey(_first));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(find.byKey(_first)),
        scrollDelta: const Offset(0, 10),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('First hint'), findsNothing);

    await mouse.moveTo(const Offset(1, 300));
    await mouse.moveTo(tester.getCenter(find.byKey(_first)));
    await _reveal(tester);
    expect(find.text('First hint'), findsOneWidget);
    controller.animateTo(
      200,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
    await tester.pumpAndSettle();
    expect(find.text('First hint'), findsNothing);
  });

  testWidgets('a route change cancels the old hint', (tester) async {
    await tester.pumpWidget(_app(_target()));
    await _mouse(tester, find.byKey(_first));
    await tester.pump(const Duration(milliseconds: 300));
    Navigator.of(tester.element(find.byKey(_first))).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Next page')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('First hint'), findsNothing);
    expect(find.text('Next page'), findsOneWidget);
  });

  testWidgets('a covered route keeps its label without displaying the hint', (
    tester,
  ) async {
    final message = ValueNotifier('First hint');
    addTearDown(message.dispose);
    await tester.pumpWidget(
      _app(
        ValueListenableBuilder<String>(
          valueListenable: message,
          builder: (_, value, _) => _target(message: value),
        ),
      ),
    );
    await _mouse(tester, find.byKey(_first));
    await _reveal(tester);
    expect(find.text('First hint'), findsOneWidget);

    showDialog<void>(
      context: tester.element(find.byKey(_first)),
      builder: (_) => const AlertDialog(title: Text('Open menu')),
    );
    await tester.pumpAndSettle();
    message.value = 'Updated hint';
    await tester.pump();
    expect(find.byTooltip('Updated hint'), findsOneWidget);
    expect(find.text('First hint'), findsNothing);
    expect(find.text('Updated hint'), findsNothing);
  });

  testWidgets('keyboard focus reveals the hint and blur closes it', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    FocusHighlightVisibility.visibleForTesting = true;
    await tester.pumpWidget(
      _app(
        IconButton(
          focusNode: focus,
          tooltip: 'First hint',
          onPressed: () {},
          icon: const Icon(Icons.refresh),
        ).withAppTooltip(),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await _reveal(tester);
    expect(find.text('First hint'), findsOneWidget);
    focus.unfocus();
    await tester.pump();
    await tester.pump(AppTooltipTiming.exitAnimation);
    await tester.pumpAndSettle();
    expect(find.text('First hint'), findsNothing);
  });

  testWidgets('reduced motion preserves the hover delay', (tester) async {
    await tester.pumpWidget(_app(_target(), reducedMotion: true));
    await _mouse(tester, find.byKey(_first));
    await tester.pump(const Duration(milliseconds: 599));
    expect(find.text('First hint'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('First hint'), findsOneWidget);
    final opacity = tester.widget<Opacity>(
      find
          .ancestor(of: find.text('First hint'), matching: find.byType(Opacity))
          .first,
    );
    expect(opacity.opacity, 1);
  });

  testWidgets('long press opens a hint until four seconds after release', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_target()));
    final touch = await tester.startGesture(
      tester.getCenter(find.byKey(_first)),
    );
    await tester.pump(kLongPressTimeout);
    await tester.pump(AppTooltipTiming.enterAnimation);
    expect(find.text('First hint'), findsOneWidget);
    await touch.up();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('First hint'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(AppTooltipTiming.exitAnimation);
    await tester.pumpAndSettle();
    expect(find.text('First hint'), findsNothing);
  });

  testWidgets('a child long-press action keeps ownership of the gesture', (
    tester,
  ) async {
    var longPressed = false;
    await tester.pumpWidget(
      _app(
        AppTooltip(
          message: 'First hint',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => longPressed = true,
            child: const SizedBox(key: _first, width: 48, height: 48),
          ),
        ),
      ),
    );
    await tester.longPress(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    expect(longPressed, isTrue);
    expect(find.text('First hint'), findsNothing);
  });

  testWidgets('nested hints choose the innermost target', (tester) async {
    await tester.pumpWidget(
      _app(
        AppTooltip(
          message: 'Outer hint',
          child: Padding(padding: AppInsets.lg, child: _target()),
        ),
      ),
    );
    await _mouse(tester, find.byKey(_first));
    await _reveal(tester);
    expect(find.text('First hint'), findsOneWidget);
    expect(find.text('Outer hint'), findsNothing);
  });

  testWidgets('long text wraps inside a narrow viewport with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(240, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const message = 'A longer explanation that must wrap rather than overflow.';
    await tester.pumpWidget(
      _app(
        Align(
          alignment: Alignment.bottomRight,
          child: _target(message: message),
        ),
        textScale: 2,
      ),
    );
    await _mouse(tester, find.byKey(_first));
    await _reveal(tester);
    expect(tester.takeException(), isNull);
    final rect = tester.getRect(find.text(message));
    expect(rect.left, greaterThanOrEqualTo(16));
    expect(rect.right, lessThanOrEqualTo(224));
    expect(rect.bottom, lessThanOrEqualTo(400));
    expect(rect.height, greaterThan(40));
  });

  testWidgets('an empty message needs no overlay or extra interaction', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppTooltip(message: '', child: Text('Empty')),
      ),
    );
    expect(find.text('Empty'), findsOneWidget);
    expect(find.byType(RawTooltip), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unmount cancels a pending timer and resets the session', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_target()));
    await _mouse(tester, find.byKey(_first));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}

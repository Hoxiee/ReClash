import 'dart:math' as math;

import 'package:reclash/common/shape.dart';
import 'package:reclash/widgets/loading.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CommonCircleLoading uses the M3E default size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: CommonCircleLoading())),
    );

    final customPaint = find.descendant(
      of: find.byType(CommonCircleLoading),
      matching: find.byType(CustomPaint),
    );

    expect(tester.getSize(customPaint), const Size.square(48));
  });

  testWidgets('CommonCircleLoading shrink-wraps when constraints are loose', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100, maxHeight: 32),
            child: const CommonCircleLoading(),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(CommonCircleLoading)),
      const Size.square(32),
    );
  });

  testWidgets('CommonCircleLoading paints within the shortest constraint', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 100,
            child: SizedBox.square(dimension: 32, child: CommonCircleLoading()),
          ),
        ),
      ),
    );

    final customPaint = find.descendant(
      of: find.byType(CommonCircleLoading),
      matching: find.byType(CustomPaint),
    );

    expect(tester.getSize(customPaint), const Size.square(32));
  });

  testWidgets('CommonCircleLoading continuously rotates and morphs', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox.square(dimension: 48, child: CommonCircleLoading()),
        ),
      ),
    );

    final loading = find.byType(CommonCircleLoading);
    final transform = find.descendant(
      of: loading,
      matching: find.byType(Transform),
    );
    final customPaint = find.descendant(
      of: loading,
      matching: find.byType(CustomPaint),
    );
    final initialTransform = tester.widget<Transform>(transform).transform;
    final initialPainter = tester.widget<CustomPaint>(customPaint).painter!;

    await tester.pump(const Duration(milliseconds: 325));

    final animatedTransform = tester.widget<Transform>(transform).transform;
    final animatedPainter = tester.widget<CustomPaint>(customPaint).painter!;

    expect(animatedTransform.storage, isNot(equals(initialTransform.storage)));
    expect(animatedPainter.shouldRepaint(initialPainter), isTrue);

    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 650));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('CommonCircleLoading exposes optional loading semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CommonCircleLoading(
          semanticLabel: 'Loading profiles',
          semanticValue: 'In progress',
        ),
      ),
    );

    expect(find.bySemanticsLabel('Loading profiles'), findsOneWidget);
  });

  testWidgets('CommonCircleLoading supports the contained M3E API variant', (
    tester,
  ) async {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: colorScheme),
        home: Center(
          child: CommonCircleLoading(
            variant: LoadingIndicatorM3EVariant.contained,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: const EdgeInsets.all(4),
            polygons: [
              RoundedPolygon.star(numVerticesPerRadius: 6),
              RoundedPolygon.star(numVerticesPerRadius: 8),
            ],
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(CommonCircleLoading),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final customPaint = find.descendant(
      of: find.byType(CommonCircleLoading),
      matching: find.byType(CustomPaint),
    );

    expect(decoration.color, colorScheme.primaryContainer);
    expect(decoration.borderRadius, AppRadius.full);
    expect(tester.getSize(customPaint), const Size.square(32));
    expect(
      tester.getSize(find.byType(CommonCircleLoading)),
      const Size.square(40),
    );
  });

  testWidgets('CommonCircleLoading freezes when animations are disabled', (
    tester,
  ) async {
    Widget buildApp({required bool disableAnimations}) {
      return MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: child!,
          );
        },
        home: const Center(child: CommonCircleLoading()),
      );
    }

    await tester.pumpWidget(buildApp(disableAnimations: true));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isFalse);

    final customPaint = find.descendant(
      of: find.byType(CommonCircleLoading),
      matching: find.byType(CustomPaint),
    );
    final transform = find.descendant(
      of: find.byType(CommonCircleLoading),
      matching: find.byType(Transform),
    );
    final frozenTransform = tester.widget<Transform>(transform).transform;
    final frozenPainter = tester.widget<CustomPaint>(customPaint).painter!;

    await tester.pump(const Duration(milliseconds: 700));

    expect(
      tester.widget<Transform>(transform).transform.storage,
      equals(frozenTransform.storage),
    );
    expect(
      tester.widget<CustomPaint>(customPaint).painter,
      same(frozenPainter),
    );
  });

  testWidgets('CommonCircleLoading stops under TickerMode and resumes once', (
    tester,
  ) async {
    Widget buildApp({required bool enabled}) {
      return MaterialApp(
        home: Scaffold(
          body: TickerMode(
            enabled: enabled,
            child: const Center(child: CommonCircleLoading()),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(enabled: true));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(buildApp(enabled: false));
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(buildApp(enabled: true));
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('rotation stays continuous across the 4666ms wrap point', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: CommonCircleLoading())),
    );

    final transform = find.descendant(
      of: find.byType(CommonCircleLoading),
      matching: find.byType(Transform),
    );

    double rotationDegrees() {
      final matrix = tester.widget<Transform>(transform).transform;
      return math.atan2(matrix.storage[1], matrix.storage[0]) * 180 / math.pi;
    }

    double stepDegrees(double from, double to) {
      var delta = to - from;
      delta -= 360 * (delta / 360).roundToDouble();
      return delta;
    }

    // A repeat()-driven clock sawtooths at its 4666ms period, restarting the
    // morph phase mid-cycle. The monotonic clock must advance smoothly here.
    await tester.pump(const Duration(milliseconds: 4665));
    final beforeWrap = rotationDegrees();
    await tester.pump(const Duration(milliseconds: 1));
    final atWrap = rotationDegrees();
    await tester.pump(const Duration(milliseconds: 1));
    final afterWrap = rotationDegrees();

    expect(stepDegrees(beforeWrap, atWrap).abs(), lessThan(2));
    expect(stepDegrees(atWrap, afterWrap).abs(), lessThan(2));
    expect(stepDegrees(beforeWrap, afterWrap), greaterThan(0));
  });
}

import 'package:reclash/widgets/line_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const color = Color(0xFF2196F3);

  Widget buildChart(
    List<Point> points, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          height: 100,
          child: LineChart(
            points: points,
            color: color,
            gradient: true,
            duration: duration,
          ),
        ),
      ),
    );
  }

  double? progressOf(WidgetTester tester) {
    final found = find
        .descendant(
          of: find.byType(LineChart),
          matching: find.byType(CustomPaint),
        )
        .first;
    final painter = tester.widget<CustomPaint>(found).painter;
    if (painter is! LineChartPainter) {
      return null;
    }
    return painter.progress;
  }

  List<Point> flat(int count) =>
      List.generate(count, (i) => Point(i.toDouble(), 0));
  List<Point> peak(int count) => [
    for (var i = 0; i < count; i++) Point(i.toDouble(), i == count - 1 ? 1 : 0),
  ];

  testWidgets('animates between point sets', (tester) async {
    await tester.pumpWidget(buildChart(flat(4)));
    await tester.pump();

    await tester.pumpWidget(buildChart(peak(4)));
    await tester.pump();
    expect(progressOf(tester), lessThan(1));
    await tester.pumpAndSettle();
    expect(progressOf(tester), 1);
    expect(tester.takeException(), null);
  });

  testWidgets('rapid data updates retarget from the rendered state', (
    tester,
  ) async {
    await tester.pumpWidget(buildChart(flat(4)));
    await tester.pump();

    await tester.pumpWidget(buildChart(peak(4)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final midway = progressOf(tester);
    expect(midway, greaterThan(0));
    expect(midway, lessThan(1));

    await tester.pumpWidget(buildChart(peak(5)));
    await tester.pump();
    expect(progressOf(tester), 0);

    await tester.pump(const Duration(milliseconds: 16));
    final restarted = progressOf(tester)!;
    expect(restarted, greaterThan(0));
    expect(restarted, lessThan(1));

    await tester.pumpAndSettle();
    expect(progressOf(tester), 1);
    expect(tester.takeException(), null);
  });

  testWidgets('zero duration paints new points immediately', (tester) async {
    await tester.pumpWidget(buildChart(flat(4), duration: Duration.zero));
    await tester.pump();

    await tester.pumpWidget(buildChart(peak(6), duration: Duration.zero));
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    expect(progressOf(tester), 1);
    expect(tester.takeException(), null);
  });

  testWidgets('duration change updates the controller in place', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildChart(flat(4), duration: const Duration(seconds: 4)),
    );
    await tester.pump();

    await tester.pumpWidget(
      buildChart(peak(4), duration: const Duration(seconds: 4)),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(progressOf(tester), greaterThan(0));

    await tester.pumpWidget(
      buildChart(peak(5), duration: const Duration(seconds: 4)),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(
      buildChart(peak(5), duration: const Duration(seconds: 10)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 4000));
    expect(progressOf(tester), greaterThan(0));
    expect(progressOf(tester), lessThan(1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
  });

  testWidgets('renders empty points without painting or animating', (
    tester,
  ) async {
    await tester.pumpWidget(buildChart(const []));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(buildChart(peak(4)));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
  });
}

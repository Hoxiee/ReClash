import 'package:reclash/widgets/donut_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

DonutChartData _data(double value) {
  return DonutChartData(value: value, color: const Color(0xFF2196F3));
}

double? _progressOf(WidgetTester tester) {
  final found = find
      .descendant(
        of: find.byType(DonutChart),
        matching: find.byType(CustomPaint),
      )
      .first;
  final painter = tester.widget<CustomPaint>(found).painter;
  if (painter is! DonutChartPainter) {
    return null;
  }
  return painter.progress;
}

void main() {
  Widget buildChart(List<DonutChartData> data, {Duration? duration}) {
    return TestApp(
      includeNavigatorKey: false,
      homeBuilder: (child) => Scaffold(
        body: Center(child: SizedBox(width: 200, height: 200, child: child)),
      ),
      child: DonutChart(
        data: data,
        duration: duration ?? const Duration(milliseconds: 300),
      ),
    );
  }

  test('interpolation preserves exact endpoints across retargets', () {
    final start = [_data(1), _data(3)];
    final end = [_data(5), _data(7)];

    final completed = DonutChartPainter.interpolate(start, end, 1);
    expect(completed.map((item) => item.value), [6, 8]);

    var snapshot = start;
    for (var i = 0; i < 8; i++) {
      snapshot = DonutChartPainter.interpolate(snapshot, end, 0);
    }
    expect(snapshot.map((item) => item.value), [2, 4]);
  });

  testWidgets('interpolates from old data to new data', (tester) async {
    await tester.pumpWidget(buildChart([_data(1), _data(3)]));
    await tester.pump();

    await tester.pumpWidget(buildChart([_data(2), _data(2)]));
    await tester.pump();
    expect(_progressOf(tester), lessThan(1));
    await tester.pumpAndSettle();
    expect(_progressOf(tester), 1);
    expect(tester.takeException(), null);
  });

  testWidgets('data update during animation retargets from rendered state', (
    tester,
  ) async {
    await tester.pumpWidget(buildChart([_data(1), _data(1)]));
    await tester.pump();

    await tester.pumpWidget(buildChart([_data(4), _data(4)]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final midway = _progressOf(tester);
    expect(midway, greaterThan(0));
    expect(midway, lessThan(1));

    await tester.pumpWidget(buildChart([_data(8), _data(8)]));
    await tester.pump();
    expect(_progressOf(tester), 0);

    await tester.pumpAndSettle();
    expect(_progressOf(tester), 1);
    expect(tester.takeException(), null);
  });

  testWidgets('zero duration paints new data immediately', (tester) async {
    await tester.pumpWidget(
      buildChart([_data(1), _data(1)], duration: Duration.zero),
    );
    await tester.pump();

    await tester.pumpWidget(
      buildChart([_data(5), _data(5)], duration: Duration.zero),
    );
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    expect(_progressOf(tester), 1);
    expect(tester.takeException(), null);
  });

  testWidgets('duration change updates without restarting the transition', (
    tester,
  ) async {
    const long = Duration(seconds: 4);
    await tester.pumpWidget(buildChart([_data(1), _data(1)], duration: long));
    await tester.pump();

    await tester.pumpWidget(buildChart([_data(6), _data(6)], duration: long));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pump(const Duration(milliseconds: 1000));
    final before = _progressOf(tester);
    expect(before, greaterThan(0));

    await tester.pumpWidget(
      buildChart([_data(6), _data(6)], duration: const Duration(seconds: 1)),
    );
    // Only the duration changed, so the running transition is not restarted.
    expect(_progressOf(tester), greaterThan(0));
    await tester.pumpAndSettle();
    expect(_progressOf(tester), 1);

    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
  });

  testWidgets('disposes without leaving tickers running', (tester) async {
    await tester.pumpWidget(buildChart([_data(1), _data(1)]));
    await tester.pump();
    await tester.pumpWidget(buildChart([_data(9), _data(9)]));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
  });
}

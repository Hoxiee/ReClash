import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

import 'result.dart';
import 'types.dart';

class SpeedTestCharts extends StatelessWidget {
  const SpeedTestCharts({super.key, required this.test});

  final SpeedTestState test;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final empty = test.downloadSamples.isEmpty && test.uploadSamples.isEmpty;
    return CommonCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.speedTestChart,
                  style: AppTextStyle.headline.of(context),
                ),
              ),
              IconButton(
                tooltip: l.speedTestSamples,
                onPressed: empty
                    ? null
                    : () => showInSheet<void>(
                        context,
                        builder: (_) => _Measurements(test: test),
                      ),
                icon: const GlyphIcon(AppGlyphs.logs, size: 20),
              ),
            ],
          ),
          if (empty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                l.speedTestChartEmpty,
                textAlign: TextAlign.center,
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            )
          else ...[
            _SpeedChart(
              key: ValueKey(('down', test.requestId)),
              label: l.speedTestDownload,
              samples: test.downloadSamples,
            ),
            _SpeedChart(
              key: ValueKey(('up', test.requestId)),
              label: l.speedTestUpload,
              samples: test.uploadSamples,
            ),
          ],
        ],
      ),
    );
  }
}

class _SpeedChart extends StatefulWidget {
  const _SpeedChart({super.key, required this.label, required this.samples});

  final String label;
  final List<SpeedTestSample> samples;

  @override
  State<_SpeedChart> createState() => _SpeedChartState();
}

class _SpeedChartState extends State<_SpeedChart> {
  double? _fraction;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final samples = widget.samples
        .where(
          (point) =>
              point.mbps.isFinite && point.mbps >= 0 && point.elapsedMs >= 0,
        )
        .toList();
    final end = math.max(1000, samples.isEmpty ? 1000 : samples.last.elapsedMs);
    final highest = samples.fold(
      1.0,
      (value, point) => math.max(value, point.mbps),
    );
    final power = math
        .pow(10, (math.log(highest) / math.ln10).floor())
        .toDouble();
    final maximum = (highest / power).ceil() * power;
    SpeedTestSample? selected;
    if (_fraction case final fraction? when samples.isNotEmpty) {
      final target = fraction * end;
      selected = samples.reduce(
        (a, b) => (a.elapsedMs - target).abs() <= (b.elapsedMs - target).abs()
            ? a
            : b,
      );
    }
    final caption = AppTextStyle.caption2
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: AppTextStyle.footnote.of(context, emphasized: true),
              ),
            ),
            Text(
              selected == null
                  ? l.simpleSpeedUnit
                  : speedTestRate(context, selected.mbps),
              style: AppTextStyle.caption1.of(context),
            ),
          ],
        ),
        if (samples.isEmpty)
          SizedBox(
            height: 112,
            child: Center(child: Text('—', style: caption)),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              void select(double dx) => setState(
                () => _fraction =
                    ((dx - 42) / math.max(1, constraints.maxWidth - 50)).clamp(
                      0,
                      1,
                    ),
              );
              return Semantics(
                label: widget.label,
                value: speedTestRate(
                  context,
                  selected?.mbps ?? samples.last.mbps,
                ),
                child: MouseRegion(
                  onHover: (event) => select(event.localPosition.dx),
                  onExit: (_) => setState(() => _fraction = null),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => select(details.localPosition.dx),
                    onHorizontalDragUpdate: (details) =>
                        select(details.localPosition.dx),
                    child: SizedBox(
                      height: 112,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _ChartPainter(
                          samples: samples,
                          maximum: maximum,
                          end: end,
                          selected: selected,
                          ink: context.colorScheme.primary,
                          grid: context.colorScheme.onSurface.withValues(
                            alpha: 0.1,
                          ),
                          surface: context.raisedSurfaceLevel.colorOf(
                            context.colorScheme,
                          ),
                          labels: caption,
                          direction: Directionality.of(context),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        Padding(
          padding: const EdgeInsets.only(left: 42, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 ${l.speedTestSecondsUnit}', style: caption),
              if (selected != null)
                Text(
                  '${(selected.elapsedMs / 1000).toStringAsFixed(1)} ${l.speedTestSecondsUnit}',
                  style: caption,
                ),
              Text(
                '${(end / 1000).toStringAsFixed(1)} ${l.speedTestSecondsUnit}',
                style: caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter({
    required this.samples,
    required this.maximum,
    required this.end,
    required this.selected,
    required this.ink,
    required this.grid,
    required this.surface,
    required this.labels,
    required this.direction,
  });

  final List<SpeedTestSample> samples;
  final double maximum;
  final int end;
  final SpeedTestSample? selected;
  final Color ink;
  final Color grid;
  final Color surface;
  final TextStyle labels;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(42, 8, size.width - 8, size.height - 8);
    if (plot.width <= 0) return;
    for (var index = 0; index < 3; index++) {
      final fraction = index / 2;
      final y = plot.bottom - plot.height * fraction;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()
          ..color = grid
          ..strokeWidth = 1,
      );
      final text = TextPainter(
        text: TextSpan(
          text: speedTestNumber(maximum * fraction),
          style: labels,
        ),
        textDirection: direction,
      )..layout(maxWidth: 38);
      text
        ..paint(canvas, Offset(plot.left - text.width - 6, y - text.height / 2))
        ..dispose();
    }
    Offset point(SpeedTestSample sample) => Offset(
      plot.left + (sample.elapsedMs / end).clamp(0, 1) * plot.width,
      plot.bottom - (sample.mbps / maximum).clamp(0, 1) * plot.height,
    );
    final path = Path();
    for (final (index, sample) in samples.indexed) {
      final position = point(sample);
      if (index == 0) {
        path.moveTo(position.dx, position.dy);
      } else {
        path.lineTo(position.dx, position.dy);
      }
    }
    final first = point(samples.first);
    final last = point(samples.last);
    final fill = Path.from(path)
      ..lineTo(last.dx, plot.bottom)
      ..lineTo(first.dx, plot.bottom)
      ..close();
    canvas.drawPath(fill, Paint()..color = ink.withValues(alpha: 0.1));
    canvas.drawPath(
      path,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    final highlighted = point(selected ?? samples.last);
    if (selected != null) {
      canvas.drawLine(
        Offset(highlighted.dx, plot.top),
        Offset(highlighted.dx, plot.bottom),
        Paint()
          ..color = grid
          ..strokeWidth = 1,
      );
    }
    canvas.drawCircle(highlighted, 6, Paint()..color = surface);
    canvas.drawCircle(highlighted, 4, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.samples != samples ||
      old.maximum != maximum ||
      old.end != end ||
      old.selected != selected ||
      old.ink != ink ||
      old.grid != grid ||
      old.surface != surface ||
      old.labels != labels ||
      old.direction != direction;
}

class _Measurements extends StatelessWidget {
  const _Measurements({required this.test});

  final SpeedTestState test;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final rows = [
      for (final point in test.downloadSamples) (l.speedTestDownload, point),
      for (final point in test.uploadSamples) (l.speedTestUpload, point),
    ];
    return CommonScaffold(
      title: l.speedTestSamples,
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          16,
          context.contentTopPadding + 12,
          16,
          context.bottomInset + 24,
        ),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final (label, point) = rows[index];
          return ListItem(
            title: Text(
              '$label · ${(point.elapsedMs / 1000).toStringAsFixed(1)} ${l.speedTestSecondsUnit}',
            ),
            trailing: Text(
              speedTestRate(context, point.mbps),
              style: AppTextStyle.footnote.of(context),
            ),
          );
        },
      ),
    );
  }
}

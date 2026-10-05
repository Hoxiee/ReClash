import 'package:material_ui/material_ui.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:reclash/widgets/widgets.dart';

/// The shared skeleton for dashboard tiles that pin a single measured value
/// line to the bottom of the card under the standard Info header. Centralizes
/// the slot-height formula and card paddings that the intranet IP, run time,
/// memory and feed tiles each hand-rolled.
class DashboardValueCard extends StatelessWidget {
  const DashboardValueCard({
    super.key,
    required this.label,
    required this.glyph,
    required this.child,
    this.onPressed,
    this.rows = 1,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.addRepaintBoundary = false,
  });

  final String label;
  final Glyph glyph;
  final Widget child;
  final VoidCallback? onPressed;
  final int rows;
  final CrossAxisAlignment crossAxisAlignment;
  final bool addRepaintBoundary;

  @override
  Widget build(BuildContext context) {
    final padding = DashboardWidgetMetrics.paddingOf(context);
    final Widget card = CommonCard(
      radius: DashboardWidgetMetrics.radiusOf(context),
      infoPadding: padding.copyWith(bottom: 0),
      info: Info(label: label, glyph: glyph),
      onPressed: onPressed ?? () {},
      child: Container(
        padding: padding.copyWith(top: 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            SizedBox(
              height:
                  globalState.measure.bodyMediumHeight *
                      DashboardWidgetMetrics.textScaleOf(context) +
                  2,
              child: child,
            ),
          ],
        ),
      ),
    );
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, rows),
      child: addRepaintBoundary ? RepaintBoundary(child: card) : card,
    );
  }
}

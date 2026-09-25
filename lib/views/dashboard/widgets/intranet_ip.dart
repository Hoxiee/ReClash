import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntranetIP extends StatelessWidget {
  const IntranetIP({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        infoPadding: DashboardWidgetMetrics.paddingOf(
          context,
        ).copyWith(bottom: 0),
        info: Info(
          label: appLocalizations.intranetIP,
          glyph: AppGlyphs.devices,
        ),
        onPressed: () {},
        child: Container(
          padding: DashboardWidgetMetrics.paddingOf(context).copyWith(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height:
                    globalState.measure.bodyMediumHeight *
                        DashboardWidgetMetrics.textScaleOf(context) +
                    2,
                child: Consumer(
                  builder: (_, ref, _) {
                    final localIp = ref.watch(localIpProvider);
                    return FadeThroughBox(
                      child: localIp != null
                          ? TooltipText(
                              text: Text(
                                localIp.isNotEmpty
                                    ? localIp
                                    : appLocalizations.noNetwork,
                                style: context.textTheme.bodyMedium?.toLight
                                    .adjustSize(1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : Container(
                              padding: AppInsets.xxs,
                              child: const AspectRatio(
                                aspectRatio: 1,
                                child: CommonCircleLoading(),
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

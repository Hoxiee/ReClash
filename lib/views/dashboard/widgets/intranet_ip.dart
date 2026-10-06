import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_value_card.dart';
import 'package:reclash/widgets/widgets.dart';

class IntranetIP extends StatelessWidget {
  const IntranetIP({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return DashboardValueCard(
      label: appLocalizations.intranetIP,
      glyph: AppGlyphs.devices,
      child: Consumer(
        builder: (_, ref, _) {
          final localIp = ref.watch(localIpProvider);
          return FadeThroughBox(
            child: localIp != null
                ? TooltipText(
                    text: Text(
                      localIp.isNotEmpty ? localIp : appLocalizations.noNetwork,
                      style: context.textTheme.bodyMedium?.toLight.adjustSize(
                        1,
                      ),
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
    );
  }
}

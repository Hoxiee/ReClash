import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_value_card.dart';

class RunTimeCard extends StatelessWidget {
  const RunTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardValueCard(
      label: context.appLocalizations.start,
      glyph: AppGlyphs.history,
      child: Consumer(
        builder: (_, ref, _) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              getTimeText(ref.watch(runTimeProvider)),
              style: context.textTheme.bodyMedium?.toLight.adjustSize(1).copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}

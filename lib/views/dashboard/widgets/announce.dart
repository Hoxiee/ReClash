import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Announce extends StatelessWidget {
  const Announce({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: getWidgetHeight(2),
      child: RepaintBoundary(
        child: CommonCard(
          radius: AppCorner.lg,
          info: Info(
            label: appLocalizations.announce,
            iconData: Icons.campaign,
          ),
          onPressed: () {},
          child: Consumer(
            builder: (_, ref, _) {
              final announce = ref.watch(
                currentProfileProvider.select(
                  (state) => state?.panelMeta?.announce,
                ),
              );
              return Padding(
                padding: baseInfoEdgeInsets.copyWith(top: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        announce ?? appLocalizations.noAnnouncements,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.toLighter,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

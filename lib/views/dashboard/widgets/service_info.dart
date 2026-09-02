import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceInfo extends StatelessWidget {
  const ServiceInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: getWidgetHeight(1),
      child: RepaintBoundary(
        child: Consumer(
          builder: (_, ref, _) {
            final panelMeta = ref.watch(
              currentProfileProvider.select((state) => state?.panelMeta),
            );
            final supportUrl = panelMeta?.supportUrl;
            return CommonCard(
              radius: AppCorner.lg,
              onPressed: () {
                if (supportUrl != null) {
                  dialogs.openUrl(supportUrl);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: globalState.measure.titleMediumHeight + 16,
                    padding: baseInfoEdgeInsets.copyWith(bottom: 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.dns_outlined,
                          size: 16.ap,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: TooltipText(
                            text: Text(
                              appLocalizations.serviceInfo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleSmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: baseInfoEdgeInsets.copyWith(top: 0),
                    height: globalState.measure.bodyMediumHeight + 8,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20.ap,
                          height: 20.ap,
                          child: panelMeta?.serviceLogo == null
                              ? Icon(
                                  Icons.cloud_outlined,
                                  size: 20.ap,
                                  color: context.colorScheme.onSurfaceVariant,
                                )
                              : ImageCacheWidget(
                                  src: panelMeta!.serviceLogo!,
                                  defaultWidget: Icon(
                                    Icons.cloud_outlined,
                                    size: 20.ap,
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: TooltipText(
                            text: Text(
                              panelMeta?.serviceName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyMedium?.toLight
                                  .adjustSize(1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

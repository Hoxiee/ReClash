import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceInfo extends ConsumerWidget {
  const ServiceInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelMeta = ref.watch(
      currentProfileProvider.select((state) => state?.panelMeta),
    );
    final profileLabel = ref.watch(
      currentProfileProvider.select((state) => state?.label.trim() ?? ''),
    );
    final appLocalizations = context.appLocalizations;
    final supportUrl = panelMeta?.supportUrl;
    final account = panelMeta?.accountUsername?.trim();
    final title = [panelMeta?.serviceName?.trim() ?? '', profileLabel]
        .firstWhere(
          (value) => value.isNotEmpty,
          orElse: () => appLocalizations.unknown,
        );
    return DashboardInfoCard(
      height: getWidgetHeight(1),
      icon: Icons.dns_outlined,
      label: appLocalizations.serviceInfo,
      action: supportUrl == null
          ? null
          : const Icon(Icons.open_in_new_rounded, size: 18),
      onPressed: supportUrl == null ? null : () => dialogs.openUrl(supportUrl),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 28.ap,
            child: panelMeta?.serviceLogo == null
                ? Icon(Icons.cloud_outlined, color: context.colorScheme.primary)
                : ImageCacheWidget(
                    src: panelMeta!.serviceLogo!,
                    defaultWidget: Icon(
                      Icons.cloud_outlined,
                      color: context.colorScheme.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TooltipText(
                  text: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (account != null && account.isNotEmpty)
                  TooltipText(
                    text: Text(
                      account,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

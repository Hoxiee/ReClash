import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeServerButton extends ConsumerWidget {
  const ChangeServerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final server = ref.watch(activeServerProvider);
    final smartRouting = server.smartRouting;
    final flag = countryCodeToEmoji(server.countryCode ?? '');
    final name = server.displayName.isEmpty
        ? appLocalizations.unknown
        : server.displayName;
    final delay = server.measuring
        ? appLocalizations.heroChecking
        : switch (server.delay) {
            final value? when value > 0 => '${value}ms',
            _ => appLocalizations.timeout,
          };
    return DashboardInfoCard(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      icon: smartRouting ? AppGlyphs.autoMode : AppGlyphs.swap,
      label: appLocalizations.changeServer,
      action: const GlyphIcon(AppGlyphs.chevronForward, size: 20),
      onPressed: () => ref
          .read(currentPageLabelProvider.notifier)
          .toPage(PageLabel.proxies, returnable: true),
      child: Row(
        children: [
          if (flag == null)
            GlyphIcon(
              AppGlyphs.language,
              size: 20,
              color: context.colorScheme.onSurfaceVariant,
            )
          else
            Text(
              flag,
              style: context.textTheme.titleLarge?.copyWith(
                fontFamily: FontFamily.twEmoji.value,
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: TooltipText(
              text: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            delay,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color:
                  getDelayColor(server.delay) ??
                  context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

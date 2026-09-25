import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/desync.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesyncStrategyCard extends ConsumerWidget {
  const DesyncStrategyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(desyncSettingProvider);
    return DashboardInfoCard(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      icon: AppGlyphs.shield,
      label: appLocalizations.desyncStrategySection,
      action: const GlyphIcon(AppGlyphs.chevronForward, size: 20),
      onPressed: () =>
          showExtend(context, builder: (_) => const DesyncStrategyView()),
      child: Row(
        children: [
          Expanded(
            child: TooltipText(
              text: Text(
                desyncStrategyName(appLocalizations, props),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            appLocalizations.desyncArgsCount(props.strategyArgs.length),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class DesyncTestCard extends ConsumerWidget {
  const DesyncTestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(desyncSettingProvider);
    final groups = [
      for (final list in desyncTestSiteLists)
        if (props.testSiteLists.contains(list.id)) list,
    ];
    return DashboardInfoCard(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      icon: AppGlyphs.bolt,
      label: appLocalizations.desyncTestSection,
      action: const GlyphIcon(AppGlyphs.chevronForward, size: 20),
      onPressed: () =>
          showExtend(context, builder: (_) => const DesyncTestView()),
      child: Row(
        children: [
          if (props.testRunning) ...[
            const SizedBox.square(dimension: 14, child: CommonCircleLoading()),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: TooltipText(
              text: Text(
                appLocalizations.desyncTestBatterySummary(
                  desyncTestPresets.length,
                  groups.length,
                  desyncTestSitesFor(props.testSiteLists).length,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DesyncEngineCard extends ConsumerWidget {
  const DesyncEngineCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(desyncSettingProvider);
    return DashboardInfoCard(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      icon: AppGlyphs.ports,
      label: appLocalizations.desyncEngine,
      action: const GlyphIcon(AppGlyphs.chevronForward, size: 20),
      onPressed: () =>
          showExtend(context, builder: (_) => const DesyncEngineView()),
      child: Row(
        children: [
          Expanded(
            child: TooltipText(
              text: Text(
                appLocalizations.desyncEngineSummary(props.categories.length),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '127.0.0.1:${props.port}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              fontFamily: FontFamily.jetBrainsMono.value,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

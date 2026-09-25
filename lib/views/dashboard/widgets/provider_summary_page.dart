import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:reclash/views/dashboard/widgets/announce.dart';
import 'package:reclash/views/dashboard/widgets/connections.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_centered_scroll_view.dart';
import 'package:reclash/views/dashboard/widgets/dns_queries.dart';
import 'package:reclash/views/dashboard/widgets/memory_info.dart';
import 'package:reclash/views/dashboard/widgets/requests.dart';
import 'package:reclash/views/dashboard/widgets/service_status.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderSummaryPage extends ConsumerWidget {
  const ProviderSummaryPage({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProfile = ref.watch(
      currentProfileProvider.select((state) => state != null),
    );
    return DashboardCenteredScrollView(
      controller: scrollController,
      alignment: Alignment.topCenter,
      child: hasProfile ? const _ProviderStatus() : const _ProviderEmptyState(),
    );
  }
}

/// The native status read-out shared 1:1 by the pager's supplementary page and
/// the desktop split column.
class ProviderStatusCards extends StatelessWidget {
  const ProviderStatusCards({super.key, this.gap = 12, this.expanded = false});

  final double gap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DashboardWidgetMetrics(
          unitHeight: dashboardUnitHeight(constraints.maxWidth),
          // Pin the stack to the viewport so the cards fill the loose width the
          // centred scroll view hands them instead of shrinking to intrinsic.
          child: SizedBox(
            width: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Announce(expanded: expanded),
                SizedBox(height: gap),
                const ServiceStatusCard(),
                SizedBox(height: gap),
                const _StatPair(left: MemoryInfo(), right: DnsQueriesCard()),
                SizedBox(height: gap),
                const _StatPair(left: ConnectionsCard(), right: RequestsCard()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProviderStatus extends StatelessWidget {
  const _ProviderStatus();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: ProviderStatusCards(
        expanded: true,
        key: ValueKey('provider-plan-card'),
      ),
    );
  }
}

class _StatPair extends StatelessWidget {
  const _StatPair({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _ProviderEmptyState extends ConsumerWidget {
  const _ProviderEmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: AppShape.xl,
          color: context.colorScheme.surfaceContainerHigh,
        ),
        child: Padding(
          padding: AppInsets.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlyphIcon(
                AppGlyphs.folder,
                size: 44,
                color: context.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 14),
              Semantics(
                header: true,
                child: Text(
                  context.appLocalizations.dashboardNoActiveProfileTitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.appLocalizations.dashboardNoActiveProfileDesc,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(currentPageLabelProvider.notifier).toProfiles(),
                icon: const GlyphIcon(AppGlyphs.folder),
                label: Text(context.appLocalizations.dashboardSelectProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

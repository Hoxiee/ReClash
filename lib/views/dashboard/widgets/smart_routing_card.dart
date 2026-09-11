import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/views/dashboard/widgets/hero_routing.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/routing_overview.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The hero's routing line as a grid tile. It reads the same line function, so
/// the two layouts cannot describe one engine two ways.
class SmartRoutingCard extends ConsumerWidget {
  const SmartRoutingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final enabled = ref.watch(
      smartRoutingSettingProvider.select((state) => state.enabled),
    );
    final status = heroStatusOf(
      ref.watch(heroLifecycleProvider),
      heroDoctorHealthOf(ref.watch(connectionDoctorProvider)),
    );
    final view = enabled
        ? heroServiceLineViewOf(
            appLocalizations: appLocalizations,
            line: routingServiceLineOf(
              status: status,
              mode: ref.watch(
                patchClashConfigProvider.select((state) => state.mode),
              ),
              routingStatus: ref.watch(smartRoutingStatusProvider),
            ),
            status: status,
            doctor: ref.watch(connectionDoctorProvider),
          )
        : (
            icon: Icons.pause_circle_outline,
            text: appLocalizations.off,
            accented: false,
          );
    final color = view.accented
        ? context.colorScheme.primary
        : context.colorScheme.onSurfaceVariant;
    return DashboardInfoCard(
      height: getWidgetHeight(1),
      icon: Icons.alt_route_rounded,
      label: appLocalizations.smartRouting,
      action: const Icon(Icons.chevron_right_rounded, size: 20),
      onPressed: () =>
          showExtend(context, builder: (_) => const RoutingOverviewView()),
      child: FadeThroughBox(
        child: Row(
          key: ValueKey(view.text),
          children: [
            Icon(view.icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: TooltipText(
                text: Text(
                  view.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

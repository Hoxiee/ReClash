import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/routing_overview.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RoutingRowState {
  off,
  ruleOnly,
  searching,
  on,
  restricted,
  portal,
  retrying,
  noServers,
}

/// The status payload is a view of the engine, not the truth, so a missing one
/// reads as "still starting" rather than as a failure.
RoutingRowState routingRowStateOf({
  required bool enabled,
  required Mode mode,
  RcxStatus? status,
}) {
  if (!enabled) {
    return RoutingRowState.off;
  }
  if (mode != Mode.rule) {
    return RoutingRowState.ruleOnly;
  }
  final reason = status?.reason;
  if (reason == 'no-candidate') {
    return RoutingRowState.noServers;
  }
  if (reason == 'stranded' || reason == 'incumbent-dead') {
    return RoutingRowState.retrying;
  }
  if (status == null || status.searching) {
    return RoutingRowState.searching;
  }
  return switch (status.terrain) {
    'portal' => RoutingRowState.portal,
    'whitelist' => RoutingRowState.restricted,
    _ => RoutingRowState.on,
  };
}

/// The routing line of the hero card: what the engine in the core is doing to
/// keep the tunnel alive without the user opening the app.
class HeroRoutingRow extends ConsumerWidget {
  const HeroRoutingRow({super.key, required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final enabled = ref.watch(smartRoutingSettingProvider).enabled;
    final mode = ref.watch(patchClashConfigProvider).mode;
    final status = ref.watch(smartRoutingStatusProvider);
    final state = routingRowStateOf(
      enabled: enabled,
      mode: mode,
      status: status,
    );
    final muted = context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    final (IconData icon, String text, Color color) = switch (state) {
      RoutingRowState.off => (
        Icons.pause_circle_outline,
        appLocalizations.heroRoutingStub,
        muted,
      ),
      RoutingRowState.ruleOnly => (
        Icons.info_outline_rounded,
        appLocalizations.smartRoutingRuleOnly,
        muted,
      ),
      RoutingRowState.searching => (
        Icons.autorenew_rounded,
        appLocalizations.smartRoutingSearching,
        muted,
      ),
      RoutingRowState.on => (
        Icons.bolt_rounded,
        appLocalizations.smartRoutingOn,
        accent,
      ),
      RoutingRowState.restricted => (
        Icons.shield_moon_rounded,
        appLocalizations.smartRoutingRestricted,
        accent,
      ),
      RoutingRowState.portal => (
        Icons.wifi_lock_rounded,
        appLocalizations.smartRoutingPortal,
        accent,
      ),
      RoutingRowState.retrying => (
        Icons.sync_problem_rounded,
        appLocalizations.smartRoutingRetrying,
        accent,
      ),
      RoutingRowState.noServers => (
        Icons.error_outline_rounded,
        appLocalizations.smartRoutingNoServers,
        accent,
      ),
    };

    return FocusableTap(
      onTap: () {
        showExtend(context, builder: (context) => const RoutingOverviewView());
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
        child: AnimatedSwitcher(
          duration: context.motionDuration(const Duration(milliseconds: 260)),
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.centerLeft,
            children: [...previous, ?current],
          ),
          child: Row(
            key: ValueKey(text),
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The routing line of the hero card. A fault takes it over while one lasts,
/// which is how the connection doctor will speak once it lands.
class HeroLinkRow extends StatelessWidget {
  const HeroLinkRow({super.key, required this.status, required this.accent});

  final HeroStatus status;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final muted = context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    final (IconData icon, String text, Color color) = switch (status) {
      HeroStatus.paused => (
        Icons.pause_circle_outline,
        appLocalizations.heroLinkPaused,
        accent,
      ),
      HeroStatus.degraded => (
        Icons.speed_rounded,
        appLocalizations.heroLinkSlow,
        accent,
      ),
      HeroStatus.broken => (
        Icons.error_outline_rounded,
        appLocalizations.heroLinkDown,
        accent,
      ),
      _ => (Icons.alt_route_rounded, appLocalizations.heroRoutingStub, muted),
    };

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
      child: AnimatedSwitcher(
        duration: context.motionDuration(const Duration(milliseconds: 260)),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        child: Row(
          key: ValueKey(text),
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

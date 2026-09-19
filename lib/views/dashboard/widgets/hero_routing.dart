import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/routing_overview.dart';
import 'package:reclash/views/tools/connection_doctor.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final int _heroStatusEasterEggRoll = Random().nextInt(64);

/// The single line under the hero divider. One enum for every voice that can
/// claim it, so the card never has to swap widgets to change its subject.
enum HeroServiceLine {
  doctor,
  paused,
  linkSlow,
  linkBroken,
  routingRuleOnly,
  routingWaitingTunnel,
  routingWaitingNetwork,
  routingSearching,
  routingOn,
  routingRestricted,
  routingPortal,
  routingRetrying,
  routingNoServers,
  idle,
}

/// Routing lines that name a fault themselves, so they say more than the
/// tunnel's own verdict and keep the line when both apply.
const _routingExplainsFault = {
  HeroServiceLine.routingSearching,
  HeroServiceLine.routingRetrying,
  HeroServiceLine.routingNoServers,
  HeroServiceLine.routingPortal,
};

HeroServiceLine heroServiceLineOf({
  required HeroStatus status,
  required bool doctorAlerts,
  required bool routingEnabled,
  required Mode mode,
  RcxStatus? routingStatus,
}) {
  if (status == HeroStatus.paused) {
    return HeroServiceLine.paused;
  }
  if (doctorAlerts && status.isLive) {
    return HeroServiceLine.doctor;
  }
  final link = switch (status) {
    HeroStatus.broken || HeroStatus.blocked => HeroServiceLine.linkBroken,
    HeroStatus.degraded => HeroServiceLine.linkSlow,
    _ => null,
  };
  if (!routingEnabled) {
    return link ?? HeroServiceLine.idle;
  }
  final routing = routingServiceLineOf(
    status: status,
    mode: mode,
    routingStatus: routingStatus,
  );
  if (link == null || _routingExplainsFault.contains(routing)) {
    return routing;
  }
  return link;
}

/// The status payload is a view of the engine, not the truth: it outlives the
/// run that produced it, so only a flowing tunnel makes it worth reading.
HeroServiceLine routingServiceLineOf({
  required HeroStatus status,
  required Mode mode,
  RcxStatus? routingStatus,
}) {
  if (mode != Mode.rule) {
    return HeroServiceLine.routingRuleOnly;
  }
  if (status == HeroStatus.offline) {
    return HeroServiceLine.routingWaitingNetwork;
  }
  if (!status.flows) {
    return status.isTransitioning
        ? HeroServiceLine.routingSearching
        : HeroServiceLine.routingWaitingTunnel;
  }
  final reason = routingStatus?.reason;
  if (reason == 'no-candidate') {
    return HeroServiceLine.routingNoServers;
  }
  if (reason == 'stranded' || reason == 'incumbent-dead') {
    return HeroServiceLine.routingRetrying;
  }
  if (routingStatus == null || routingStatus.searching) {
    return HeroServiceLine.routingSearching;
  }
  return switch (routingStatus.terrain) {
    'portal' => HeroServiceLine.routingPortal,
    'whitelist' => HeroServiceLine.routingRestricted,
    _ => HeroServiceLine.routingOn,
  };
}

typedef HeroServiceLineView = ({IconData icon, String text, bool accented});

/// Where a line sends a tap: the fault it names owns the screen that explains
/// it, and a paused tunnel explains nothing.
enum HeroServiceTarget { none, doctor, routing }

HeroServiceLineView heroServiceLineViewOf({
  required AppLocalizations appLocalizations,
  required HeroServiceLine line,
  required HeroStatus status,
  required DoctorSnapshot doctor,
  int? easterEggRoll,
}) => switch (line) {
  HeroServiceLine.doctor => (
    icon: doctor.state == DoctorExamState.examining
        ? Icons.radar_rounded
        : Icons.monitor_heart_outlined,
    text: connectionDoctorHeroText(appLocalizations, doctor),
    accented: true,
  ),
  HeroServiceLine.paused => (
    icon: Icons.pause_circle_outline,
    text: appLocalizations.heroLinkPaused,
    accented: true,
  ),
  HeroServiceLine.linkSlow => (
    icon: Icons.speed_rounded,
    text: appLocalizations.heroLinkSlow,
    accented: true,
  ),
  HeroServiceLine.linkBroken => (
    icon: Icons.error_outline_rounded,
    text: appLocalizations.heroLinkBroken,
    accented: true,
  ),
  HeroServiceLine.routingRuleOnly => (
    icon: Icons.info_outline_rounded,
    text: appLocalizations.smartRoutingRuleOnly,
    accented: false,
  ),
  HeroServiceLine.routingWaitingTunnel => (
    icon: Icons.hourglass_empty_rounded,
    text: appLocalizations.smartRoutingWaitingTunnel,
    accented: false,
  ),
  HeroServiceLine.routingWaitingNetwork => (
    icon: Icons.wifi_off_rounded,
    text: appLocalizations.smartRoutingWaitingNetwork,
    accented: false,
  ),
  HeroServiceLine.routingSearching => (
    icon: Icons.autorenew_rounded,
    text: appLocalizations.smartRoutingSearching,
    accented: false,
  ),
  HeroServiceLine.routingOn => (
    icon: Icons.bolt_rounded,
    text: appLocalizations.smartRoutingOn,
    accented: true,
  ),
  HeroServiceLine.routingRestricted => (
    icon: Icons.shield_moon_rounded,
    text: appLocalizations.smartRoutingRestricted,
    accented: true,
  ),
  HeroServiceLine.routingPortal => (
    icon: Icons.wifi_lock_rounded,
    text: appLocalizations.smartRoutingPortal,
    accented: true,
  ),
  HeroServiceLine.routingRetrying => (
    icon: Icons.sync_problem_rounded,
    text: appLocalizations.smartRoutingRetrying,
    accented: true,
  ),
  HeroServiceLine.routingNoServers => (
    icon: Icons.error_outline_rounded,
    text: appLocalizations.smartRoutingNoServers,
    accented: true,
  ),
  HeroServiceLine.idle => (
    icon: Icons.alt_route_rounded,
    text:
        status == HeroStatus.secured &&
            (easterEggRoll ?? _heroStatusEasterEggRoll) == 0
        ? appLocalizations.heroStatusEasterEgg
        : appLocalizations.heroRoutingStub,
    accented: false,
  ),
};

HeroServiceTarget heroServiceTargetOf(HeroServiceLine line) => switch (line) {
  HeroServiceLine.paused => HeroServiceTarget.none,
  HeroServiceLine.doctor ||
  HeroServiceLine.linkSlow ||
  HeroServiceLine.linkBroken => HeroServiceTarget.doctor,
  _ => HeroServiceTarget.routing,
};

/// The service line of the hero card: what keeps the tunnel alive without the
/// user opening the app. Every state shares one row, so its height never moves.
class HeroServiceRow extends ConsumerWidget {
  const HeroServiceRow({
    super.key,
    required this.status,
    required this.accent,
    this.easterEggRoll,
  });

  final HeroStatus status;
  final Color accent;
  final int? easterEggRoll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final doctor = ref.watch(connectionDoctorProvider);
    final line = heroServiceLineOf(
      status: status,
      doctorAlerts: connectionDoctorTakesHero(doctor),
      routingEnabled: ref.watch(
        smartRoutingSettingProvider.select((state) => state.enabled),
      ),
      mode: ref.watch(patchClashConfigProvider.select((state) => state.mode)),
      routingStatus: ref.watch(smartRoutingStatusProvider),
    );
    final muted = context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    final view = heroServiceLineViewOf(
      appLocalizations: appLocalizations,
      line: line,
      status: status,
      doctor: doctor,
      easterEggRoll: easterEggRoll,
    );
    final (icon, text) = (view.icon, view.text);
    final color = view.accented ? accent : muted;

    return FocusableTap(
      onTap: switch (heroServiceTargetOf(line)) {
        HeroServiceTarget.none => null,
        HeroServiceTarget.doctor => () {
          showExtend(context, builder: (_) => const ConnectionDoctorView());
        },
        HeroServiceTarget.routing => () {
          showExtend(context, builder: (_) => const RoutingOverviewView());
        },
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

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/desync.dart';
import 'package:reclash/views/config/smart_pause_network_picker.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_offers.dart';
import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero_routing.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/subscription_overview.dart';
import 'package:reclash/views/dashboard/widgets/hero_surface.dart';
import 'package:reclash/views/dashboard/widgets/hero_words.dart';
import 'package:reclash/views/dashboard/widgets/routing_overview.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _countryCodeToEmoji(String code) {
  if (code.length != 2) return '🌐';
  final upper = code.toUpperCase();
  final first = 0x1F1E6 - 0x41 + upper.codeUnitAt(0);
  final second = 0x1F1E6 - 0x41 + upper.codeUnitAt(1);
  return String.fromCharCodes([first, second]);
}

class HeroConnect extends ConsumerStatefulWidget {
  const HeroConnect({super.key});

  @override
  ConsumerState<HeroConnect> createState() => _HeroConnectState();
}

class _HeroConnectState extends ConsumerState<HeroConnect> {
  /// Owned by the orb after seeding: it holds the optimistic `connecting` too.
  late HeroOrbPhase _phase = ref.read(heroLifecycleProvider);

  Future<void> _showModePicker() async {
    final appLocalizations = context.appLocalizations;
    const modes = ['vpn', 'byedpi'];
    final current =
        ref.read(
          desyncSettingProvider.select(
            (state) => state.enabled && state.onlyDpi,
          ),
        )
        ? 'byedpi'
        : 'vpn';
    final mode = await dialogs.showCommonDialog<String>(
      context: context,
      child: OptionsDialog<String>(
        title: appLocalizations.desyncModeTitle,
        options: modes,
        value: current,
        textBuilder: (value) => value == 'byedpi'
            ? appLocalizations.desyncModeByedpi
            : appLocalizations.desyncModeVpn,
      ),
    );
    if (mode == null || mode == current) return;
    ref
        .read(desyncSettingProvider.notifier)
        .update(
          (state) => mode == 'byedpi'
              ? state.copyWith(enabled: true, onlyDpi: true)
              : state.copyWith(enabled: false, onlyDpi: false),
        );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final hasSavedProfiles = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final byedpiMode = ref.watch(
      desyncSettingProvider.select((state) => state.enabled && state.onlyDpi),
    );
    if (profile == null && !byedpiMode) {
      return _EmptyHero(hasSavedProfiles: hasSavedProfiles);
    }

    final isReady = ref.watch(initProvider);
    if (byedpiMode) {
      const health = HeroHealth.unknown;
      final status = heroStatusOf(_phase, health);
      final palette = byedpiHeroPaletteOf(context, status);
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _OrbSection(
              isReady: isReady,
              displayName: context.appLocalizations.desyncModeByedpi,
              status: status,
              health: health,
              palette: palette,
              variant: HeroOrbVariant.byedpi,
              onPhaseChanged: (phase) => setState(() => _phase = phase),
              onLongPress: () => _showModePicker(),
            ),
            const SizedBox(height: 16),
            const _ByeDpiDashboard(),
            SizedBox(height: 12 + BottomInsetScope.of(context)),
          ],
        ),
      );
    }

    final activeProfile = profile!;
    final panelMeta = activeProfile.panelMeta;
    final announce = panelMeta?.announce?.trim();
    final sub = activeProfile.subscriptionInfo;
    final hasSub = sub != null && (sub.total > 0 || sub.expire > 0);

    final buyPlanUrl = panelMeta?.buyPlanUrl;
    final buyTrafficUrl = panelMeta?.buyTrafficUrl;

    final activeServer = ref.watch(activeServerProvider);
    final smartRoutingEnabled = activeServer.smartRouting;
    final displayName = activeServer.displayName;
    final nameCountryCode = activeServer.countryCode;
    final otherCodes = activeServer.otherCodes;
    final otherLocations = activeServer.otherLocations;
    final delay = activeServer.delay;
    final measuring = activeServer.measuring;
    final isUpdating = ref.watch(isUpdatingProvider(activeProfile.updatingKey));
    final health = heroHealthOf(delay: delay, measuring: measuring);
    final status = heroStatusOf(_phase, health);
    final heroRing = parsePanelHeroRing(panelMeta?.heroRing);
    final palette = heroPaletteOf(context, status, heroRing: heroRing);
    final accent = status.isAlert ? palette.accent : null;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          _OrbSection(
            isReady: isReady,
            displayName: displayName,
            status: status,
            health: health,
            palette: palette,
            serviceLogo: panelMeta?.serviceLogo,
            heroRing: heroRing,
            onPhaseChanged: (phase) => setState(() => _phase = phase),
            onLongPress: () => _showModePicker(),
          ),
          const SizedBox(height: 16),
          _ServerPanel(
            displayName: displayName,
            nameCountryCode: nameCountryCode,
            delay: delay,
            status: status,
            accent: accent,
            otherCodes: otherCodes,
            otherLocations: otherLocations,
            smartRouting: smartRoutingEnabled,
          ),
          if (hasSub) ...[
            const SizedBox(height: 12),
            FocusableTap(
              borderRadius: heroCardRadius,
              onTap: () {
                showExtend(
                  context,
                  builder: (_) => const SubscriptionOverviewView(),
                );
              },
              child: _TrafficCard(
                sub: sub,
                buyPlanUrl: buyPlanUrl,
                buyTrafficUrl: buyTrafficUrl,
                hasAnnounce: announce != null && announce.isNotEmpty,
              ),
            ),
          ] else if (announce != null && announce.isNotEmpty) ...[
            const SizedBox(height: 12),
            FocusableTap(
              borderRadius: heroCardRadius,
              onTap: () {
                showExtend(
                  context,
                  builder: (_) => const SubscriptionOverviewView(),
                );
              },
              child: _NoticeOpenCard(text: announce),
            ),
          ],
          const SizedBox(height: 12),
          _HeroActionRow(
            isUpdating: isUpdating,
            onUpdate: () => unawaited(
              ref
                  .read(profilesActionProvider.notifier)
                  .updateProfile(activeProfile, showLoading: true),
            ),
            supportUrl: panelMeta?.supportUrl,
          ),
          SizedBox(height: 12 + BottomInsetScope.of(context)),
        ],
      ),
    );
  }
}

class _ByeDpiDashboard extends ConsumerWidget {
  const _ByeDpiDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(desyncSettingProvider);
    final matchingStrategy = props.savedStrategies.where(
      (strategy) => listEquals(strategy.args, props.strategyArgs),
    );
    final strategyName = listEquals(props.strategyArgs, desyncDefaultStrategy)
        ? appLocalizations.desyncDefaultName
        : matchingStrategy.isEmpty
        ? appLocalizations.custom
        : matchingStrategy.first.name;

    return Column(
      children: [
        _ByeDpiStrategyCard(
          name: strategyName,
          argsCount: appLocalizations.desyncArgsCount(
            props.strategyArgs.length,
          ),
          onTap: () {
            showExtend(context, builder: (_) => const DesyncStrategyView());
          },
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ByeDpiActionCard(
                icon: Icons.bolt_rounded,
                title: appLocalizations.desyncTestSection,
                subtitle: appLocalizations.desyncTestTitle,
                onTap: () {
                  showExtend(context, builder: (_) => const DesyncTestView());
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ByeDpiActionCard(
                icon: Icons.settings_rounded,
                title: appLocalizations.desyncEngine,
                subtitle: '${appLocalizations.port} ${props.port}',
                onTap: () {
                  showExtend(context, builder: (_) => const DesyncEngineView());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ByeDpiStrategyCard extends StatelessWidget {
  const _ByeDpiStrategyCard({
    required this.name,
    required this.argsCount,
    required this.onTap,
  });

  final String name;
  final String argsCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return FocusableTap(
      borderRadius: heroCardRadius,
      onTap: onTap,
      child: HeroSurface(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        child: Row(
          children: [
            const _ByeDpiCardIcon(icon: Icons.shield_rounded, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLocalizations.desyncStrategySection,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    argsCount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _ByeDpiActionCard extends StatelessWidget {
  const _ByeDpiActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return FocusableTap(
      borderRadius: heroCardRadius,
      onTap: onTap,
      child: HeroSurface(
        height: 116,
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ByeDpiCardIcon(icon: icon, size: 36),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ByeDpiCardIcon extends StatelessWidget {
  const _ByeDpiCardIcon({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: colorScheme.primaryContainer,
        shape: AppShape.md,
      ),
      child: Icon(
        icon,
        size: size * 0.48,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _OrbSection extends ConsumerWidget {
  const _OrbSection({
    required this.isReady,
    required this.displayName,
    required this.status,
    required this.health,
    required this.palette,
    this.serviceLogo,
    this.heroRing,
    this.variant = HeroOrbVariant.vpn,
    required this.onPhaseChanged,
    this.onLongPress,
  });

  final bool isReady;
  final String displayName;
  final HeroStatus status;
  final HeroHealth health;
  final HeroPalette palette;
  final String? serviceLogo;
  final List<Color>? heroRing;
  final HeroOrbVariant variant;
  final ValueChanged<HeroOrbPhase> onPhaseChanged;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final runMinutes = ref.watch(
      runTimeProvider.select((value) => value == null ? null : value ~/ 60000),
    );
    final isConnected = runMinutes != null && status != HeroStatus.paused;

    final title = variant == HeroOrbVariant.byedpi
        ? switch (status) {
            HeroStatus.offline => appLocalizations.noNetwork,
            HeroStatus.off => appLocalizations.byedpiOff,
            HeroStatus.checking => appLocalizations.byedpiChecking,
            HeroStatus.connecting => appLocalizations.byedpiStarting,
            HeroStatus.reconnecting => appLocalizations.byedpiReconnecting,
            HeroStatus.paused => appLocalizations.byedpiPaused,
            HeroStatus.broken => appLocalizations.byedpiEngineError,
            HeroStatus.secured ||
            HeroStatus.degraded => appLocalizations.byedpiActive,
          }
        : switch (status) {
            HeroStatus.offline => appLocalizations.noNetwork,
            HeroStatus.off => appLocalizations.heroNotProtected,
            HeroStatus.checking => appLocalizations.heroChecking,
            HeroStatus.connecting => appLocalizations.heroConnecting,
            HeroStatus.reconnecting => appLocalizations.heroReconnecting,
            HeroStatus.paused => appLocalizations.heroPaused,
            HeroStatus.broken => appLocalizations.heroLinkBroken,
            HeroStatus.secured ||
            HeroStatus.degraded => appLocalizations.heroProtected,
          };
    final subtitle = variant == HeroOrbVariant.byedpi
        ? switch (status) {
            HeroStatus.offline => appLocalizations.heroNoNetworkHint,
            HeroStatus.off => appLocalizations.byedpiTapToStart,
            HeroStatus.checking => displayName,
            HeroStatus.connecting => displayName,
            HeroStatus.reconnecting => displayName,
            HeroStatus.paused => appLocalizations.byedpiTapToResume,
            HeroStatus.secured ||
            HeroStatus.degraded => appLocalizations.byedpiActiveFor(
              heroDurationWords(runMinutes ?? 0),
            ),
            HeroStatus.broken => displayName,
          }
        : switch (status) {
            HeroStatus.offline => appLocalizations.heroNoNetworkHint,
            HeroStatus.off => appLocalizations.heroTapToConnect,
            HeroStatus.checking => appLocalizations.heroCheckingHint,
            HeroStatus.connecting => displayName,
            HeroStatus.reconnecting => appLocalizations.heroReconnectingHint,
            HeroStatus.paused => appLocalizations.heroTapToResume,
            HeroStatus.secured || HeroStatus.degraded || HeroStatus.broken =>
              appLocalizations.connectedFor(heroDurationWords(runMinutes ?? 0)),
          };
    final accent = status.isAlert ? palette.accent : null;

    final lastTraffic = isConnected
        ? ref.watch(
            trafficsProvider.select(
              (state) => state.list.isEmpty ? null : state.list.last,
            ),
          )
        : null;

    return Column(
      children: [
        const SizedBox(height: 18),
        HeroOrb(
          size: 220,
          enabled: isReady,
          health: health,
          activity: heroActivityOf(lastTraffic),
          serviceLogo: serviceLogo,
          heroRing: heroRing,
          variant: variant,
          onPhaseChanged: onPhaseChanged,
          onLongPress: onLongPress,
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 58,
          child: FadeThroughBox(
            alignment: Alignment.topCenter,
            child: Column(
              key: ValueKey((title, subtitle)),
              children: [
                AnimatedDefaultTextStyle(
                  duration: context.motionDuration(
                    const Duration(milliseconds: 320),
                  ),
                  curve: Curves.easeOutCubic,
                  textAlign: TextAlign.center,
                  style: (context.textTheme.headlineSmall ?? const TextStyle())
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        color: accent ?? colorScheme.onSurface,
                      ),
                  child: Text(title, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        RepaintBoundary(
          child: AnimatedSlide(
            duration: context.motionDuration(const Duration(milliseconds: 320)),
            curve: Curves.easeOutCubic,
            offset: isConnected ? Offset.zero : const Offset(0, -0.2),
            child: AnimatedOpacity(
              duration: context.motionDuration(
                const Duration(milliseconds: 220),
              ),
              curve: isConnected ? Curves.easeOut : Curves.easeIn,
              opacity: isConnected ? 1 : 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SpeedEntry(
                    icon: Icons.south_rounded,
                    value: lastTraffic?.down,
                    accent: accent,
                  ),
                  const SizedBox(width: 22),
                  _SpeedEntry(
                    icon: Icons.north_rounded,
                    value: lastTraffic?.up,
                    accent: accent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeedEntry extends StatelessWidget {
  const _SpeedEntry({required this.icon, required this.value, this.accent});

  final IconData icon;
  final num? value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final show = value?.traffic;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: accent ?? colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          show != null ? show.value : '—',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.jetBrainsMono.value,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          show != null ? '${show.unit}/s' : '',
          style: context.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    const size = 104.0;
    const radius = size * 0.25;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        'assets/images/icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _TrafficCard extends StatelessWidget {
  const _TrafficCard({
    required this.sub,
    this.buyPlanUrl,
    this.buyTrafficUrl,
    this.hasAnnounce = false,
  });

  final SubscriptionInfo sub;
  final String? buyPlanUrl;
  final String? buyTrafficUrl;
  final bool hasAnnounce;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final used = sub.upload + sub.download;
    final total = sub.total;
    final unlimited = total <= 0;
    final progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final barColor = progress > 0.9
        ? colorScheme.error
        : progress > 0.7
        ? const Color(0xFFC57F0A)
        : colorScheme.primary;

    int? daysLeft;
    if (sub.expire > 0) {
      daysLeft = DateTime.fromMillisecondsSinceEpoch(
        sub.expire * 1000,
      ).difference(DateTime.now()).inDays;
      if (daysLeft < 0) daysLeft = 0;
    }

    final daysUrgent = daysLeft != null && daysLeft <= heroRenewDaysThreshold;
    final daysColor = daysUrgent ? colorScheme.error : colorScheme.primary;
    final free = total > 0 ? (total - used).clamp(0, total) : 0;
    final offers = heroBuyOffers(
      hasPlanUrl: buyPlanUrl?.isNotEmpty ?? false,
      hasTrafficUrl: buyTrafficUrl?.isNotEmpty ?? false,
      daysLeft: daysLeft,
      total: total,
      used: used,
    );

    return HeroSurface(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appLocalizations.subscriptionCaption,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (daysLeft != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(heroPillRadius),
                    color: daysColor.withValues(alpha: 0.14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_rounded, size: 14, color: daysColor),
                      const SizedBox(width: 5),
                      Text(
                        '${appLocalizations.remaining} $daysLeft ${heroDaysWord(daysLeft)}',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: daysColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (hasAnnounce) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.campaign_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (unlimited)
            Text(
              used.traffic.show,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.jetBrainsMono.value,
              ),
            )
          else
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: free.traffic.show,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.jetBrainsMono.value,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: appLocalizations.trafficFreeOfTotal(
                      total.traffic.show,
                    ),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (!unlimited) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(heroInlayRadius),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  FractionallySizedBox(
                    widthFactor: progress <= 0 ? 0.0 : progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(heroInlayRadius),
                        gradient: LinearGradient(
                          colors: [barColor.withValues(alpha: 0.7), barColor],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (offers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final offer in offers) ...[
                  if (offer != offers.first) const SizedBox(width: 8),
                  Flexible(
                    child: _BuyChip(
                      offer: offer,
                      url: offer == HeroBuyOffer.renewPlan
                          ? buyPlanUrl!
                          : buyTrafficUrl!,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BuyChip extends StatelessWidget {
  const _BuyChip({required this.offer, required this.url});

  final HeroBuyOffer offer;
  final String url;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final (icon, label) = switch (offer) {
      HeroBuyOffer.renewPlan => (
        Icons.autorenew_rounded,
        appLocalizations.renewSubscription,
      ),
      HeroBuyOffer.topUpTraffic => (
        Icons.add_shopping_cart_rounded,
        appLocalizations.topUpTraffic,
      ),
    };
    return _ActionChip(
      icon: icon,
      label: label,
      compact: true,
      onTap: () => unawaited(dialogs.openUrl(url)),
    );
  }
}

class _ServerPanel extends StatelessWidget {
  const _ServerPanel({
    required this.displayName,
    required this.nameCountryCode,
    required this.status,
    this.delay,
    this.accent,
    this.otherCodes = const [],
    this.otherLocations = 0,
    this.smartRouting = false,
  });

  final String displayName;
  final String? nameCountryCode;
  final HeroStatus status;
  final int? delay;
  final Color? accent;
  final List<String> otherCodes;
  final int otherLocations;
  final bool smartRouting;

  @override
  Widget build(BuildContext context) => HeroSurface(
    accent: accent,
    child: AnimatedSize(
      duration: commonDuration,
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          _ServerZone(
            displayName: displayName,
            nameCountryCode: nameCountryCode,
            delay: delay,
            otherCodes: otherCodes,
            otherLocations: otherLocations,
            smartRouting: smartRouting,
          ),
          const HeroCardDivider(),
          _HeroInfoRow(
            status: status,
            accent: accent ?? context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    ),
  );
}

/// The line under the divider belongs to smart routing while it runs; the
/// tunnel's own faults keep the old link line so they are never hidden.
class _HeroInfoRow extends ConsumerWidget {
  const _HeroInfoRow({required this.status, required this.accent});

  final HeroStatus status;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(smartRoutingSettingProvider).enabled;
    if (enabled && status.isLive && status != HeroStatus.paused) {
      return HeroRoutingRow(accent: accent);
    }
    return HeroLinkRow(status: status, accent: accent);
  }
}

class _ServerZone extends ConsumerWidget {
  const _ServerZone({
    required this.displayName,
    required this.nameCountryCode,
    this.delay,
    this.otherCodes = const [],
    this.otherLocations = 0,
    this.smartRouting = false,
  });

  final String displayName;
  final String? nameCountryCode;
  final int? delay;
  final List<String> otherCodes;
  final int otherLocations;
  final bool smartRouting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final delay = this.delay;
    final isConnected = ref.watch(
      runTimeProvider.select((value) => value != null),
    );
    final networkState = ref.watch(networkDetectionProvider);
    final ipInfo = networkState.ipInfo;

    final code = nameCountryCode ?? ipInfo?.countryCode ?? '';
    final flag = _countryCodeToEmoji(code);
    final title = displayName.isNotEmpty ? displayName : '—';

    return FocusableTap(
      borderRadius: heroCardRadius,
      onTap: () {
        if (smartRouting) {
          showExtend(context, builder: (_) => const RoutingOverviewView());
          return;
        }
        ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.proxies);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            _FlagCircle(
              countryCode: code,
              fallbackEmoji: flag,
              otherCodes: otherCodes,
              stackCount: otherLocations,
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isConnected) ...[
                    const SizedBox(height: 3),
                    if (ipInfo != null)
                      Text(
                        ipInfo.ip,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: FontFamily.jetBrainsMono.value,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (networkState.isLoading)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CommonCircleLoading(
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            appLocalizations.determiningIp,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '—',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: FontFamily.jetBrainsMono.value,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 46,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _SignalBars(delay: delay),
                  if (delay != null && delay > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      '$delay ms',
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelSmall?.copyWith(
                        color:
                            getDelayColor(delay) ??
                            colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontFamily: FontFamily.jetBrainsMono.value,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlagCircle extends StatelessWidget {
  const _FlagCircle({
    required this.countryCode,
    required this.fallbackEmoji,
    this.otherCodes = const [],
    this.stackCount = 0,
    this.size = 52,
  });

  final String countryCode;
  final String fallbackEmoji;
  final List<String> otherCodes;
  final int stackCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    final colorScheme = context.colorScheme;
    final cc = countryCode.trim().toLowerCase();

    Widget fallback() => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainerHighest,
      ),
      alignment: Alignment.center,
      child: EmojiText(fallbackEmoji, style: TextStyle(fontSize: size * 0.5)),
    );

    // The emoji stands in until the image lands, so no frame shows a grey disc.
    Widget emojiFill(double side, String code) => Container(
      width: side,
      height: side,
      color: colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: EmojiText(
        _countryCodeToEmoji(code),
        style: TextStyle(fontSize: side * 0.5),
      ),
    );

    final active = cc.length != 2
        ? fallback()
        : ClipOval(
            child: CachedNetworkImage(
              imageUrl: 'https://flagcdn.com/w160/$cc.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero,
              placeholderFadeInDuration: Duration.zero,
              placeholder: (_, _) => emojiFill(size, cc),
              errorWidget: (_, _, _) => fallback(),
            ),
          );

    // Always two behind: an empty disc holds the height when history is short.
    const backCount = 2;
    final backs = [
      for (var i = 0; i < backCount; i++)
        i < otherCodes.length ? otherCodes[i] : null,
    ];
    Widget backFlag(int i, String? code) {
      final s = size * (1 - 0.14 * i);
      return Transform.translate(
        offset: Offset(0, -10.0 * i),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.surface, width: 1.5),
          ),
          child: ClipOval(
            child: Stack(
              children: [
                if (code == null)
                  Container(
                    width: s,
                    height: s,
                    color: colorScheme.surfaceContainerHigh,
                  )
                else
                  CachedNetworkImage(
                    imageUrl:
                        'https://flagcdn.com/w80/${code.toLowerCase()}.png',
                    width: s,
                    height: s,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration.zero,
                    placeholderFadeInDuration: Duration.zero,
                    placeholder: (_, _) => emojiFill(s, code),
                    errorWidget: (_, _, _) => emojiFill(s, code),
                  ),
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.15 * i),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final badge = stackCount <= 0
        ? null
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(heroPillRadius),
              color: colorScheme.primary,
              border: Border.all(color: colorScheme.surface, width: 1.5),
            ),
            child: Text(
              '+$stackCount',
              style: context.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.jetBrainsMono.value,
              ),
            ),
          );

    final unit = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        for (var i = backs.length; i >= 1; i--) backFlag(i, backs[i - 1]),
        active,
        if (badge != null) Positioned(right: -3, bottom: -3, child: badge),
      ],
    );

    final topPeek =
        (10.0 * backCount + size * (1 - 0.14 * backCount) / 2 - size / 2 + 2)
            .clamp(0.0, 40.0)
            .toDouble();
    const bottomPeek = 7.0;

    return SizedBox(
      width: size,
      height: size + topPeek + bottomPeek,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: topPeek,
            left: 0,
            width: size,
            height: size,
            child: unit,
          ),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.delay});

  final int? delay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final dim = colorScheme.onSurfaceVariant.withValues(alpha: 0.25);

    final int level;
    final Color color;
    if (delay == null || delay == 0) {
      level = 0;
      color = dim;
    } else if (delay! < 0) {
      level = 0;
      color = Colors.red.shade400;
    } else {
      color = getDelayColor(delay) ?? Colors.green;
      level = delay! < 150
          ? 4
          : delay! < 300
          ? 3
          : delay! < 600
          ? 2
          : 1;
    }

    const heights = [9.0, 13.0, 17.0, 21.0];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 3),
          child: Container(
            width: 4,
            height: heights[i],
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(heroInlayRadius),
              color: i < level ? color : dim,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHero extends ConsumerWidget {
  const _EmptyHero({required this.hasSavedProfiles});

  final bool hasSavedProfiles;

  void _showAddProfile(BuildContext context) {
    showExtend(
      context,
      builder: (context) => AdaptiveSheetScaffold(
        title: context.appLocalizations.addProfile,
        body: AddProfileView(context: context),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final title = hasSavedProfiles
        ? appLocalizations.dashboardNoActiveProfileTitle
        : appLocalizations.dashboardNoProfileTitle;
    final description = hasSavedProfiles
        ? appLocalizations.dashboardNoActiveProfileDesc
        : appLocalizations.dashboardNoProfileDesc;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const _Logo(),
          const SizedBox(height: 16),
          Text(
            appName,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          HeroSurface(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  autofocus: true,
                  onPressed: hasSavedProfiles
                      ? () => ref
                            .read(currentPageLabelProvider.notifier)
                            .toProfiles()
                      : () => _showAddProfile(context),
                  icon: Icon(
                    hasSavedProfiles
                        ? Icons.folder_open_rounded
                        : Icons.add_rounded,
                  ),
                  label: Text(
                    hasSavedProfiles
                        ? appLocalizations.dashboardSelectProfile
                        : appLocalizations.addProfile,
                  ),
                ),
                if (hasSavedProfiles) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showAddProfile(context),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(appLocalizations.addProfile),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          FocusableTap(
            borderRadius: heroCardRadius,
            onTap: () => ref
                .read(desyncSettingProvider.notifier)
                .update(
                  (state) => state.copyWith(enabled: true, onlyDpi: true),
                ),
            child: HeroSurface(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const _ByeDpiCardIcon(icon: Icons.shield_rounded, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appLocalizations.dashboardByedpiTitle,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          appLocalizations.dashboardByedpiDesc,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12 + BottomInsetScope.of(context)),
        ],
      ),
    );
  }
}

class _NoticeOpenCard extends StatelessWidget {
  const _NoticeOpenCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return HeroSurface(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Icon(Icons.campaign_rounded, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.appLocalizations.announce,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                EmojiText(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _HeroActionRow extends ConsumerWidget {
  const _HeroActionRow({
    required this.isUpdating,
    required this.onUpdate,
    this.supportUrl,
  });

  final bool isUpdating;
  final VoidCallback? onUpdate;
  final String? supportUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final hasSupport = supportUrl != null && supportUrl!.isNotEmpty;
    final showPauseChip =
        ref.watch(isStartProvider) &&
        (ref.watch(tunEnabledProvider) || ref.watch(pausedProvider));
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: Icons.refresh_rounded,
            label: appLocalizations.update,
            busy: isUpdating,
            onTap: onUpdate,
          ),
        ),
        if (hasSupport) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _ActionChip(
              icon: Icons.support_agent_rounded,
              label: appLocalizations.support,
              onTap: () => unawaited(dialogs.openUrl(supportUrl!)),
            ),
          ),
        ],
        if (showPauseChip) ...[const SizedBox(width: 10), const _PauseChip()],
        const SizedBox(width: 10),
        const _ModeChip(),
      ],
    );
  }
}

class _PauseChip extends ConsumerWidget {
  const _PauseChip();

  void _showSmartPauseSheet(BuildContext context, WidgetRef ref) {
    showSheet(
      context: context,
      props: const SheetProps(maxHeight: 520),
      builder: (sheetContext) {
        return SizedBox(
          height: 460,
          child: AdaptiveSheetScaffold(
            title: sheetContext.appLocalizations.pickNetwork,
            body: SmartPauseNetworkPicker(
              selected: ref
                  .read(
                    vpnSettingProvider.select(
                      (state) => state.smartPauseNetworks,
                    ),
                  )
                  .toSet(),
              onSelected: (ssid) {
                Navigator.of(sheetContext).maybePop();
                ref.read(vpnSettingProvider.notifier).update((state) {
                  if (state.smartPauseNetworks.any(
                    (item) => item.trim().toLowerCase() == ssid.toLowerCase(),
                  )) {
                    return state;
                  }
                  return state.copyWith(
                    smartPauseNetworks: [...state.smartPauseNetworks, ssid],
                  );
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final paused = ref.watch(pausedProvider);
    return Tooltip(
      message: paused ? appLocalizations.resume : appLocalizations.pause,
      child: FocusableTap(
        borderRadius: heroPillRadius,
        onTap: () => ref.read(commonActionProvider.notifier).togglePaused(),
        onLongPress: () => _showSmartPauseSheet(context, ref),
        child: HeroSurface(
          radius: heroPillRadius,
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends ConsumerWidget {
  const _ModeChip();

  IconData _modeIcon(UiOutboundMode mode) => switch (mode) {
    UiOutboundMode.auto => Icons.auto_mode,
    UiOutboundMode.rule => Icons.rule,
    UiOutboundMode.global => Icons.public,
    UiOutboundMode.direct => Icons.flash_on,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final mode = ref.watch(uiOutboundModeProvider);
    return CommonPopupBox(
      targetBuilder: (open) => Tooltip(
        message: mode.label,
        child: FocusableTap(
          borderRadius: heroPillRadius,
          onTap: () => open(offset: const Offset(0, 20)),
          child: HeroSurface(
            radius: heroPillRadius,
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(_modeIcon(mode), size: 18, color: colorScheme.primary),
          ),
        ),
      ),
      popupBuilder: (_) => CommonPopupMenu(
        items: [
          for (final item in UiOutboundMode.values)
            CommonPopupMenuItem(
              icon: _modeIcon(item),
              label: item.label,
              onPressed: () {
                ref.read(setupActionProvider.notifier).changeUiMode(item);
              },
            ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final height = compact ? 34.0 : 44.0;
    final iconSize = compact ? 16.0 : 18.0;
    return FocusableTap(
      borderRadius: heroPillRadius,
      onTap: busy ? null : onTap,
      child: HeroSurface(
        radius: heroPillRadius,
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: busy
                  ? CommonCircleLoading(color: colorScheme.primary)
                  : Icon(icon, size: iconSize, color: colorScheme.primary),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style:
                    (compact
                            ? context.textTheme.labelMedium
                            : context.textTheme.labelLarge)
                        ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

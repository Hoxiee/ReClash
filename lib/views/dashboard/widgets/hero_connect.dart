import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/desync.dart';
import 'package:reclash/views/config/smart_pause_network_picker.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_centered_scroll_view.dart';
import 'package:reclash/views/dashboard/widgets/connection_mode.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_elastic_flow.dart';
import 'package:reclash/views/dashboard/widgets/hero_layout.dart';
import 'package:reclash/views/dashboard/widgets/hero_offers.dart';
import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero_routing.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/subscription_overview.dart';
import 'package:reclash/views/dashboard/widgets/hero_surface.dart';
import 'package:reclash/views/dashboard/widgets/hero_words.dart';
import 'package:reclash/views/dashboard/widgets/provider_summary_page.dart';
import 'package:reclash/views/dashboard/widgets/routing_overview.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `splitLeft` is the left half of the two-column board: the orb keeps its
/// caption and the connection chips, while the panels move to the right column.
enum HeroLayoutMode { column, splitLeft }

class HeroConnect extends ConsumerStatefulWidget {
  const HeroConnect({
    super.key,
    this.scrollController,
    this.onShowProvider,
    this.mode = HeroLayoutMode.column,
  });

  final ScrollController? scrollController;
  final VoidCallback? onShowProvider;
  final HeroLayoutMode mode;

  @override
  ConsumerState<HeroConnect> createState() => _HeroConnectState();
}

class _HeroConnectState extends ConsumerState<HeroConnect> {
  late HeroOrbPhase _phase = ref.read(heroLifecycleProvider);
  String? _revealId;
  Timer? _revealTimer;
  bool _revealScheduled = false;
  bool _piDiscovered = false;
  String? _sessionNote;
  Timer? _sessionNoteTimer;

  @override
  void initState() {
    super.initState();
    ref.listenManual(heroLifecycleProvider, (_, phase) {
      final hasHero =
          ref.read(currentProfileProvider) != null ||
          ref.read(
            effectiveDesyncSettingProvider.select(
              (state) => state.enabled && state.onlyDpi,
            ),
          );
      final delaysVisibleConnection =
          hasHero &&
          _phase == HeroOrbPhase.connecting &&
          (phase == HeroOrbPhase.on || phase == HeroOrbPhase.reconnecting);
      if (mounted && phase != _phase && !delaysVisibleConnection) {
        setState(() => _phase = phase);
      }
    });
    ref.listenManual(runTimeProvider, (previous, value) {
      const piMillis = ((3 * 60 + 14) * 60 + 15) * 1000;
      if (value == null || value < piMillis) {
        _piDiscovered = false;
        return;
      }
      if (_piDiscovered ||
          previous == null ||
          previous >= piMillis ||
          !_calm ||
          ref.read(findingPreviewProvider).enabled) {
        return;
      }
      _piDiscovered = true;
      if (!ref.read(milestonesProvider.notifier).discover('pi')) return;
      setState(() => _sessionNote = 'pi');
      _sessionNoteTimer?.cancel();
      _sessionNoteTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _sessionNote = null);
      });
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _sessionNoteTimer?.cancel();
    super.dispose();
  }

  bool get _calm {
    final profile = ref.read(currentProfileProvider);
    final subscription = profile?.subscriptionInfo;
    return heroStatusOf(
              ref.read(heroLifecycleProvider),
              heroDoctorHealthOf(ref.read(connectionDoctorProvider)),
            ) ==
            HeroStatus.secured &&
        !(subscription != null &&
            subscriptionIsExpired(
              expire: subscription.expire,
              now: DateTime.now(),
            )) &&
        PageActivityScope.isActiveOf(context) &&
        (ModalRoute.of(context)?.isCurrent ?? true) &&
        ref.read(runRequestStateProvider).phase == RunRequestPhase.idle &&
        !ref.read(loadingProvider(LoadingTag.proxies));
  }

  void _queueReveal(HeroStatus status) {
    if (_revealScheduled ||
        _revealId != null ||
        status != HeroStatus.secured ||
        !_calm) {
      return;
    }
    _revealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealScheduled = false;
      if (!mounted || !_calm) return;
      final preview = ref.read(findingPreviewProvider);
      if (preview.pending != null) {
        ref.read(findingPreviewProvider.notifier).activate(calm: _calm);
        return;
      }
      if (preview.active != null || preview.enabled) return;
      final id = ref.read(milestonesProvider.notifier).takeReveal(calm: _calm);
      if (id == null) return;
      setState(() => _revealId = id);
      _revealTimer?.cancel();
      _revealTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _revealId = null);
      });
    });
  }

  void _handleShowSubscription() {
    final onShowProvider = widget.onShowProvider;
    if (onShowProvider != null) {
      onShowProvider();
      return;
    }
    showExtend(context, builder: (_) => const SubscriptionOverviewView());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(milestoneSettingProvider);
    final preview = ref.watch(findingPreviewProvider);
    final reveal = preview.active ?? _revealId;
    final note = preview.active == 'pi' ? 'pi' : _sessionNote;
    final profile = ref.watch(currentProfileProvider);
    final hasSavedProfiles = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final byedpiMode = ref.watch(
      effectiveDesyncSettingProvider.select(
        (state) => state.enabled && state.onlyDpi,
      ),
    );
    if (profile == null && !byedpiMode) {
      return _EmptyHero(
        hasSavedProfiles: hasSavedProfiles,
        scrollController: widget.scrollController,
      );
    }

    final split = widget.mode == HeroLayoutMode.splitLeft;
    final isReady = ref.watch(initProvider);
    final doctor = ref.watch(connectionDoctorProvider);
    final health = heroDoctorHealthOf(doctor);
    if (byedpiMode) {
      final status = heroStatusOf(_phase, health);
      _queueReveal(status);
      final palette = byedpiHeroPaletteOf(context, status);
      return _HeroBoard(
        controller: widget.scrollController,
        split: split,
        head: _OrbSlot(
          isReady: isReady,
          status: status,
          health: health,
          variant: HeroOrbVariant.byedpi,
          onPhaseChanged: (phase) => setState(() => _phase = phase),
        ),
        tail: (metrics) => [
          _OrbCaption(
            displayName: context.appLocalizations.desyncModeByedpi,
            status: status,
            palette: palette,
            metrics: metrics,
            variant: HeroOrbVariant.byedpi,
            revealId: reveal,
            sessionNote: note,
          ),
          SizedBox(height: metrics.gapCard),
          if (!split) ...[
            const _ByeDpiDashboard(),
            SizedBox(height: metrics.gapCard),
          ],
          const _HeroActionRow(showUpdate: false),
        ],
      );
    }

    final activeProfile = profile!;
    final panelMeta = activeProfile.panelMeta;
    final announce = panelMeta?.announce?.trim();
    final sub = activeProfile.subscriptionInfo;
    final hasSub = sub != null && sub.hasFacts;
    final subscriptionExpired =
        sub != null &&
        subscriptionIsExpired(expire: sub.expire, now: DateTime.now());

    final buyPlanUrl = panelMeta?.buyPlanUrl;
    final buyTrafficUrl = panelMeta?.buyTrafficUrl;

    final activeServer = ref.watch(activeServerProvider);
    final displayName = activeServer.displayName;
    final isUpdating = ref.watch(isUpdatingProvider(activeProfile.updatingKey));
    final baseStatus = heroStatusOf(_phase, health);
    final status = subscriptionExpired && baseStatus.flows
        ? HeroStatus.subscriptionExpired
        : baseStatus;
    _queueReveal(status);
    final heroRing = parsePanelHeroRing(panelMeta?.heroRing);
    final palette = heroPaletteOf(context, status, heroRing: heroRing);
    final accent = status.isAlert ? palette.accent : null;

    return _HeroBoard(
      controller: widget.scrollController,
      split: split,
      head: _OrbSlot(
        isReady: isReady,
        status: status,
        health: health,
        serviceLogo: panelMeta?.serviceLogo,
        heroRing: heroRing,
        subscriptionExpired: subscriptionExpired,
        onPhaseChanged: (phase) => setState(() => _phase = phase),
      ),
      tail: (metrics) => [
        _OrbCaption(
          displayName: displayName,
          status: status,
          palette: palette,
          metrics: metrics,
          revealId: reveal,
          sessionNote: note,
        ),
        SizedBox(height: metrics.gapCard),
        if (!split) ...[
          _ServerPanel(
            displayName: displayName,
            nameCountryCode: activeServer.countryCode,
            delay: activeServer.delay,
            status: status,
            accent: accent,
            otherCodes: activeServer.otherCodes,
            otherLocations: activeServer.otherLocations,
            smartRouting: activeServer.smartRouting,
          ),
          SizedBox(height: metrics.gapCard),
        ],
        if (hasSub) ...[
          FocusableTap(
            borderRadius: heroCardRadius,
            onTap: _handleShowSubscription,
            child: _SubscriptionStrip(
              key: const ValueKey('hero-subscription-strip'),
              sub: sub,
              buyPlanUrl: buyPlanUrl,
              buyTrafficUrl: buyTrafficUrl,
              hasAnnounce: !split && announce != null && announce.isNotEmpty,
            ),
          ),
          SizedBox(height: metrics.gapCard),
        ] else if (!split && announce != null && announce.isNotEmpty) ...[
          FocusableTap(
            borderRadius: heroCardRadius,
            onTap: _handleShowSubscription,
            child: _NoticeOpenCard(text: announce),
          ),
          SizedBox(height: metrics.gapCard),
        ],
        _HeroActionRow(
          isUpdating: isUpdating,
          onUpdate: () => unawaited(
            ref
                .read(profilesActionProvider.notifier)
                .updateProfile(activeProfile, showLoading: true),
          ),
          supportUrl: panelMeta?.supportUrl,
        ),
      ],
    );
  }
}

/// The right column of the two-column board: what the pager would otherwise
/// hide behind its second page, in one scroll.
class HeroSplitDetails extends ConsumerWidget {
  const HeroSplitDetails({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byedpiMode = ref.watch(
      effectiveDesyncSettingProvider.select(
        (state) => state.enabled && state.onlyDpi,
      ),
    );
    final profile = ref.watch(currentProfileProvider);
    final bottomInset = BottomInsetScope.of(context);
    if (byedpiMode) {
      return _DetailsScroll(
        controller: scrollController,
        bottomInset: bottomInset,
        children: (metrics) => const [_ByeDpiDashboard()],
      );
    }
    final activeServer = ref.watch(activeServerProvider);
    final health = heroDoctorHealthOf(ref.watch(connectionDoctorProvider));
    final status = heroStatusOf(ref.watch(heroLifecycleProvider), health);
    final palette = heroPaletteOf(
      context,
      status,
      heroRing: parsePanelHeroRing(profile?.panelMeta?.heroRing),
    );
    final accent = status.isAlert ? palette.accent : null;
    return _DetailsScroll(
      controller: scrollController,
      bottomInset: bottomInset,
      children: (metrics) => [
        _ServerPanel(
          displayName: activeServer.displayName,
          nameCountryCode: activeServer.countryCode,
          delay: activeServer.delay,
          status: status,
          accent: accent,
          otherCodes: activeServer.otherCodes,
          otherLocations: activeServer.otherLocations,
          smartRouting: activeServer.smartRouting,
        ),
        if (profile != null) ...[
          SizedBox(height: metrics.gapCard),
          ...providerSummaryCards(
            context,
            profile,
            gap: metrics.gapCard,
            showQuota: false,
          ),
        ],
      ],
    );
  }
}

class _DetailsScroll extends StatelessWidget {
  const _DetailsScroll({
    required this.controller,
    required this.bottomInset,
    required this.children,
  });

  final ScrollController? controller;
  final double bottomInset;
  final List<Widget> Function(HeroMetrics metrics) children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final metrics = HeroMetrics.of(
          box,
          MediaQuery.textScalerOf(context),
          split: true,
        );
        final top = metrics.gapEdge;
        final bottom = metrics.gapCard + bottomInset;
        final height = box.hasBoundedHeight ? box.maxHeight : 0.0;
        return SingleChildScrollView(
          controller: controller,
          primary: false,
          padding: EdgeInsets.only(top: top, bottom: bottom),
          child: ConstrainedBox(
            // The orb column centres its whole board, so a shorter card column
            // pinned to the top would sit visibly higher than its neighbour.
            constraints: BoxConstraints(
              minHeight: math.max(0, height - top - bottom),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children(metrics),
            ),
          ),
        );
      },
    );
  }
}

/// Scroll plus elastic flow: the orb takes the height the rest leaves over, and
/// when the rest alone outgrows the viewport the scroll takes over instead of
/// the board overflowing.
class _HeroBoard extends StatelessWidget {
  const _HeroBoard({
    required this.controller,
    required this.split,
    required this.head,
    required this.tail,
  });

  final ScrollController? controller;
  final bool split;
  final Widget head;
  final List<Widget> Function(HeroMetrics metrics) tail;

  @override
  Widget build(BuildContext context) {
    final bottomInset = BottomInsetScope.of(context);
    // The window decides, not the board's own box: the left column of the
    // two-column layout is tall and narrow inside a landscape window.
    final portrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    return LayoutBuilder(
      builder: (context, box) {
        final metrics = HeroMetrics.of(
          box,
          MediaQuery.textScalerOf(context),
          split: split,
          portrait: portrait,
        );
        final top = metrics.gapEdge;
        final bottom = metrics.gapCard + bottomInset;
        final height = box.hasBoundedHeight ? box.maxHeight : 0.0;
        return SingleChildScrollView(
          controller: controller,
          primary: false,
          padding: EdgeInsets.only(top: top, bottom: bottom),
          child: HeroElasticFlow(
            viewportHeight: math.max(0, height - top - bottom),
            headMin: metrics.orbMin,
            headMax: metrics.orbMax,
            head: head,
            tail: tail(metrics),
          ),
        );
      },
    );
  }
}

class _ByeDpiDashboard extends ConsumerWidget {
  const _ByeDpiDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(desyncSettingProvider);
    return Column(
      children: [
        _ByeDpiStrategyCard(
          name: desyncStrategyName(appLocalizations, props),
          argsCount: appLocalizations.desyncArgsCount(
            props.strategyArgs.length,
          ),
          onTap: () {
            showExtend(context, builder: (_) => const DesyncStrategyView());
          },
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    showExtend(
                      context,
                      builder: (_) => const DesyncEngineView(),
                    );
                  },
                ),
              ),
            ],
          ),
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
            const SizedBox(height: 18),
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

/// Traffic only matters while the tunnel is up: watching it otherwise would
/// rebuild the orb once a second for numbers nothing is showing.
Traffic? _heroTraffic(WidgetRef ref, HeroStatus status) {
  final running = ref.watch(runTimeProvider.select((value) => value != null));
  if (!running || status == HeroStatus.paused) return null;
  return ref.watch(
    trafficsProvider.select(
      (state) => state.list.isEmpty ? null : state.list.last,
    ),
  );
}

/// The elastic head of the board. Kept apart from its caption because the flow
/// hands the orb a square of its own and measures the caption separately.
class _OrbSlot extends ConsumerWidget {
  const _OrbSlot({
    required this.isReady,
    required this.status,
    required this.health,
    required this.onPhaseChanged,
    this.serviceLogo,
    this.heroRing,
    this.subscriptionExpired = false,
    this.variant = HeroOrbVariant.vpn,
  });

  final bool isReady;
  final HeroStatus status;
  final HeroHealth health;
  final ValueChanged<HeroOrbPhase> onPhaseChanged;
  final String? serviceLogo;
  final List<Color>? heroRing;
  final bool subscriptionExpired;
  final HeroOrbVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = heroActivityOf(_heroTraffic(ref, status));
    return HeroOrbSlot(
      min: heroOrbMinSize,
      max: heroOrbMaxSize,
      builder: (context, size) => HeroOrb(
        size: size,
        enabled: isReady,
        health: health,
        activity: activity,
        serviceLogo: serviceLogo,
        heroRing: heroRing,
        subscriptionExpired: subscriptionExpired,
        variant: variant,
        onPhaseChanged: onPhaseChanged,
      ),
    );
  }
}

String _milestoneRevealText(AppLocalizations localizations, String id) =>
    switch (id) {
      'vigil' => localizations.milestoneRevealVigil,
      'auscultation' => localizations.milestoneRevealAuscultation,
      'fullLadder' => localizations.milestoneRevealFullLadder,
      'silentAutopilot' => localizations.milestoneRevealSilentAutopilot,
      'odometer' => localizations.milestoneRevealOdometer,
      'meridian' => localizations.milestoneRevealMeridian,
      'porcelain' => localizations.milestoneRevealPorcelain,
      'crown' => localizations.milestoneRevealCrown,
      'oscilloscope' => localizations.findingOscilloscopeDesc,
      'marks' => localizations.findingMarksDesc,
      'pi' => localizations.findingPiDesc,
      'turn' => localizations.findingTurnDesc,
      'storm' => localizations.findingStormDesc,
      'loopback' => localizations.findingLoopbackDesc,
      _ => '',
    };

class _OrbCaption extends ConsumerWidget {
  const _OrbCaption({
    required this.displayName,
    required this.status,
    required this.palette,
    required this.metrics,
    this.variant = HeroOrbVariant.vpn,
    this.revealId,
    this.sessionNote,
  });

  final String displayName;
  final HeroStatus status;
  final HeroPalette palette;
  final HeroMetrics metrics;
  final HeroOrbVariant variant;
  final String? revealId;
  final String? sessionNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final activeText = ref.watch(
      sharedStateProvider.select((state) => state.activeText),
    );
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
            HeroStatus.diagnosing => appLocalizations.byedpiChecking,
            HeroStatus.connecting => appLocalizations.byedpiStarting,
            HeroStatus.reconnecting => appLocalizations.byedpiReconnecting,
            HeroStatus.paused => appLocalizations.byedpiPaused,
            HeroStatus.broken => appLocalizations.heroLinkBroken,
            HeroStatus.subscriptionExpired =>
              appLocalizations.dashboardSubscriptionExpired,
            HeroStatus.secured ||
            HeroStatus.degraded => appLocalizations.byedpiActive,
          }
        : switch (status) {
            HeroStatus.offline => appLocalizations.noNetwork,
            HeroStatus.off => appLocalizations.heroNotProtected,
            HeroStatus.checking => appLocalizations.heroChecking,
            HeroStatus.diagnosing => appLocalizations.heroChecking,
            HeroStatus.connecting => appLocalizations.heroConnecting,
            HeroStatus.reconnecting => appLocalizations.heroReconnecting,
            HeroStatus.paused => appLocalizations.heroPaused,
            HeroStatus.broken => appLocalizations.heroLinkBroken,
            HeroStatus.subscriptionExpired =>
              appLocalizations.dashboardSubscriptionExpired,
            HeroStatus.secured || HeroStatus.degraded => activeText,
          };
    final subtitle = variant == HeroOrbVariant.byedpi
        ? switch (status) {
            HeroStatus.offline => appLocalizations.heroNoNetworkHint,
            HeroStatus.off => appLocalizations.byedpiTapToStart,
            HeroStatus.checking => displayName,
            HeroStatus.diagnosing => displayName,
            HeroStatus.connecting => displayName,
            HeroStatus.reconnecting => displayName,
            HeroStatus.paused => appLocalizations.byedpiTapToResume,
            HeroStatus.secured ||
            HeroStatus.degraded => appLocalizations.byedpiActiveFor(
              heroDurationWords(runMinutes ?? 0),
            ),
            HeroStatus.subscriptionExpired => displayName,
            HeroStatus.broken => displayName,
          }
        : switch (status) {
            HeroStatus.offline => appLocalizations.heroNoNetworkHint,
            HeroStatus.off => appLocalizations.heroTapToConnect,
            HeroStatus.checking => appLocalizations.heroCheckingHint,
            HeroStatus.diagnosing => appLocalizations.doctorExaminingTitle,
            HeroStatus.connecting => displayName,
            HeroStatus.reconnecting => appLocalizations.heroReconnectingHint,
            HeroStatus.paused => appLocalizations.heroTapToResume,
            HeroStatus.secured || HeroStatus.degraded =>
              appLocalizations.connectedFor(heroDurationWords(runMinutes ?? 0)),
            HeroStatus.subscriptionExpired => displayName,
            HeroStatus.broken =>
              ref.watch(isStartProvider)
                  ? appLocalizations.stop
                  : appLocalizations.heroTapToConnect,
          };
    final accent = status.isAlert ? palette.accent : null;
    final decorationsVisible =
        status == HeroStatus.secured &&
        ref.watch(milestoneSettingProvider).findingsEnabled &&
        PageActivityScope.isActiveOf(context) &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    final lastTraffic = _heroTraffic(ref, status);

    return Column(
      children: [
        SizedBox(height: metrics.gapCaption),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: metrics.captionMinHeight),
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
        if (decorationsVisible)
          AnimatedSwitcher(
            duration: context.motionDuration(const Duration(milliseconds: 320)),
            child: revealId == null
                ? const SizedBox.shrink()
                : Padding(
                    key: ValueKey(revealId),
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _milestoneRevealText(appLocalizations, revealId!),
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        if (decorationsVisible)
          AnimatedSwitcher(
            duration: context.motionDuration(const Duration(milliseconds: 240)),
            child: sessionNote == 'pi'
                ? Text(
                    '3:14:15',
                    key: const ValueKey('pi-session-note'),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontFamily: FontFamily.jetBrainsMono.value,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        SizedBox(height: metrics.gapCard),
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

class _SubscriptionStrip extends StatelessWidget {
  const _SubscriptionStrip({
    super.key,
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
    final progress = unlimited ? 0.0 : (used / total).clamp(0.0, 1.0);
    final barColor = progress > 0.9
        ? colorScheme.error
        : progress > 0.7
        ? const Color(0xFFC57F0A)
        : colorScheme.primary;

    final expireDate = subscriptionExpireDate(sub.expire);
    final now = DateTime.now();
    final expired = subscriptionIsExpired(expire: sub.expire, now: now);
    final expiresIn = expireDate?.difference(now).inDays;
    final daysLeft = expired
        ? null
        : expiresIn == null || expiresIn > 0
        ? expiresIn
        : 0;
    final daysUrgent = daysLeft != null && daysLeft <= heroRenewDaysThreshold;
    final daysColor = daysUrgent ? colorScheme.error : colorScheme.primary;

    final free = unlimited ? 0 : (total - used).clamp(0, total);
    final offers = heroBuyOffers(
      hasPlanUrl: buyPlanUrl?.isNotEmpty ?? false,
      hasTrafficUrl: buyTrafficUrl?.isNotEmpty ?? false,
      daysLeft: daysLeft,
      total: total,
      used: used,
    );
    final valueStyle = context.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontFamily: FontFamily.jetBrainsMono.value,
    );

    return HeroSurface(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // A wrap instead of a row: at large text scales the caption and
              // the pill no longer share one line, and neither may be clipped.
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      appLocalizations.subscriptionCaption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (expired)
                      _SubscriptionExpiredPill(color: colorScheme.error)
                    else if (daysLeft != null)
                      _DaysPill(days: daysLeft, color: daysColor),
                  ],
                ),
              ),
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
              style: valueStyle,
            )
          else
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: free.traffic.show, style: valueStyle),
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
            _SubscriptionBar(
              progress: progress <= 0 ? 0.0 : progress,
              color: barColor,
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

class _SubscriptionExpiredPill extends StatelessWidget {
  const _SubscriptionExpiredPill({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(heroPillRadius),
      color: color.withValues(alpha: 0.14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.event_busy_rounded, size: 14, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            context.appLocalizations.dashboardSubscriptionExpired,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DaysPill extends StatelessWidget {
  const _DaysPill({required this.days, required this.color});

  final int days;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(heroPillRadius),
      color: color.withValues(alpha: 0.14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.event_rounded, size: 14, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            '${context.appLocalizations.remaining} $days ${heroDaysWord(days)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SubscriptionBar extends StatelessWidget {
  const _SubscriptionBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final trackColor = context.colorScheme.surfaceContainerHighest;
    final gradient = LinearGradient(
      colors: [color.withValues(alpha: 0.7), color],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(heroInlayRadius),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: progress, end: progress),
        duration: context.motionDuration(const Duration(milliseconds: 420)),
        curve: Easing.standard,
        builder: (context, value, _) => CustomPaint(
          size: const Size(double.infinity, 8),
          painter: _SubscriptionBarPainter(
            progress: value,
            trackColor: trackColor,
            gradient: gradient,
          ),
        ),
      ),
    );
  }
}

class _SubscriptionBarPainter extends CustomPainter {
  const _SubscriptionBarPainter({
    required this.progress,
    required this.trackColor,
    required this.gradient,
  });

  final double progress;
  final Color trackColor;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..color = trackColor;
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(
        rect,
        const Radius.circular(heroInlayRadius),
      ),
      paint,
    );
    if (progress <= 0) return;
    final fillPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(
        Offset.zero & Size(size.width * progress, size.height),
        const Radius.circular(heroInlayRadius),
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_SubscriptionBarPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.gradient != gradient;
}

class _BuyChip extends StatelessWidget {
  const _BuyChip({required this.offer, required this.url});

  final HeroBuyOffer offer;
  final String url;

  @override
  Widget build(BuildContext context) {
    final view = heroBuyOfferViewOf(context.appLocalizations, offer);
    return _ActionChip(
      icon: view.icon,
      label: view.label,
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
  Widget build(BuildContext context) {
    final panel = Column(
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
        HeroServiceRow(
          status: status,
          accent: accent ?? context.colorScheme.onSurfaceVariant,
        ),
      ],
    );
    return HeroSurface(
      accent: accent,
      child: context.motionDuration(commonDuration) == Duration.zero
          ? panel
          : AnimatedSize(
              duration: context.motionDuration(commonDuration),
              curve: Easing.standard,
              alignment: Alignment.topCenter,
              child: panel,
            ),
    );
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
    final title = displayName.isNotEmpty ? displayName : '—';

    return FocusableTap(
      borderRadius: heroCardRadius,
      onTap: () {
        if (smartRouting) {
          showExtend(context, builder: (_) => const RoutingOverviewView());
          return;
        }
        ref
            .read(currentPageLabelProvider.notifier)
            .toPage(PageLabel.proxies, returnable: true);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            _FlagCircle(
              countryCode: code,
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
    this.otherCodes = const [],
    this.stackCount = 0,
    this.size = 52,
  });

  final String countryCode;
  final List<String> otherCodes;
  final int stackCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    final colorScheme = context.colorScheme;
    final cc = countryCode.trim().toLowerCase();

    // The emoji stands in until the image lands, so no frame shows a grey disc.
    Widget emojiFill(double side, String code) {
      final emoji = countryCodeToEmoji(code);
      return Container(
        width: side,
        height: side,
        color: colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: emoji == null
            ? Icon(
                Icons.public_rounded,
                size: side * 0.5,
                color: colorScheme.onSurfaceVariant,
              )
            : EmojiText(emoji, style: TextStyle(fontSize: side * 0.5)),
      );
    }

    Widget fallback() => ClipOval(child: emojiFill(size, cc));

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
      color = dim;
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
  const _EmptyHero({
    required this.hasSavedProfiles,
    required this.scrollController,
  });

  final bool hasSavedProfiles;
  final ScrollController? scrollController;

  void _showAddProfile(BuildContext context) {
    showExtend(
      context,
      builder: (context) => AdaptiveSheetScaffold(
        title: context.appLocalizations.addProfile,
        body: Builder(
          builder: (chooserContext) => AddProfileView(
            onProfileAdded: (_) => closeProfileImportRoute(chooserContext),
          ),
        ),
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
    return DashboardCenteredScrollView(
      controller: scrollController,
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
          if (ref.watch(byeDpiSupportedProvider)) ...[
            const SizedBox(height: 12),
            FocusableTap(
              borderRadius: heroCardRadius,
              onTap: () => changeDashboardMode(ref, DashboardMode.byedpi),
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
          ],
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

/// The split board turns update and support off: the right column already
/// carries them on the provider actions card.
class _HeroActionRow extends ConsumerWidget {
  const _HeroActionRow({
    this.isUpdating = false,
    this.onUpdate,
    this.supportUrl,
    this.showUpdate = true,
  });

  final bool isUpdating;
  final VoidCallback? onUpdate;
  final String? supportUrl;
  final bool showUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final hasSupport = supportUrl != null && supportUrl!.isNotEmpty;
    final showPauseChip =
        ref.watch(isStartProvider) &&
        (ref.watch(tunEnabledProvider) || ref.watch(pausedProvider));
    final chips = <Widget>[
      if (showUpdate)
        Expanded(
          child: _ActionChip(
            icon: Icons.refresh_rounded,
            label: appLocalizations.update,
            busy: isUpdating,
            onTap: onUpdate,
          ),
        ),
      if (hasSupport)
        Expanded(
          child: _ActionChip(
            icon: Icons.support_agent_rounded,
            label: appLocalizations.support,
            onTap: () => unawaited(dialogs.openUrl(supportUrl!)),
          ),
        ),
      if (showPauseChip) const _PauseChip(),
      const _ModeChip(),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < chips.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          chips[i],
        ],
      ],
    );
  }
}

class _PauseChip extends ConsumerWidget {
  const _PauseChip();

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
        onLongPress: () => showSmartPauseNetworkSheet(context, ref),
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

  void _selectOutboundMode(WidgetRef ref, UiOutboundMode mode) {
    final lifecycle = ref.read(heroLifecycleProvider);
    if (lifecycle == HeroOrbPhase.connecting ||
        lifecycle == HeroOrbPhase.reconnecting) {
      return;
    }
    ref.read(setupActionProvider.notifier).changeUiMode(mode);
    changeDashboardMode(ref, DashboardMode.vpn);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final dashboardMode = ref.watch(dashboardModeProvider);
    final outboundMode = ref.watch(uiOutboundModeProvider);
    final byedpi = dashboardMode == DashboardMode.byedpi;
    final label = byedpi
        ? connectionModeLabel(appLocalizations, dashboardMode)
        : outboundMode.label;
    final icon = byedpi
        ? connectionModeIcon(dashboardMode)
        : _modeIcon(outboundMode);
    return CommonPopupBox(
      targetBuilder: (open) => Tooltip(
        message: label,
        child: FocusableTap(
          borderRadius: heroPillRadius,
          onTap: () => open(offset: const Offset(0, 20)),
          child: HeroSurface(
            radius: heroPillRadius,
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
        ),
      ),
      popupBuilder: (_) => CommonPopupMenu(
        items: [
          for (final item in UiOutboundMode.values)
            CommonPopupMenuItem(
              icon: _modeIcon(item),
              label: item.label,
              onPressed: () => _selectOutboundMode(ref, item),
            ),
          if (ref.watch(byeDpiSupportedProvider))
            CommonPopupMenuItem(
              icon: connectionModeIcon(DashboardMode.byedpi),
              label: connectionModeLabel(
                appLocalizations,
                DashboardMode.byedpi,
              ),
              onPressed: () => changeDashboardMode(ref, DashboardMode.byedpi),
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

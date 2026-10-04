import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/ip_quality/ip_quality_text.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/desync.dart';
import 'package:reclash/views/config/smart_pause_network_picker.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/announce.dart';
import 'package:reclash/views/dashboard/widgets/connection_mode.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_centered_scroll_view.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero/details_elastic_flow.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_elastic_flow.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_layout.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_offers.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_routing.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_surface.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_words.dart';
import 'package:reclash/views/dashboard/widgets/hero/subscription_bits.dart';
import 'package:reclash/views/dashboard/widgets/hero/subscription_sheet.dart';
import 'package:reclash/views/dashboard/widgets/provider_summary_page.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:reclash/widgets/widgets.dart';

part 'hero_connect_byedpi.dart';
part 'hero_connect_orb_slot.dart';
part 'hero_connect_server_zone.dart';
part 'hero_connect_states.dart';
part 'hero_connect_subscription.dart';

/// `splitLeft` is the left half of the two-column board: the orb keeps its
/// caption and the connection chips, while the panels move to the right column.
enum HeroLayoutMode { column, splitLeft }

class HeroConnect extends ConsumerStatefulWidget {
  const HeroConnect({
    super.key,
    this.scrollController,
    this.mode = HeroLayoutMode.column,
    this.splitViewportHeight,
    this.onRequestAfterTailFocus,
  });

  final ScrollController? scrollController;
  final HeroLayoutMode mode;
  final double? splitViewportHeight;
  final VoidCallback? onRequestAfterTailFocus;

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
    unawaited(showSubscriptionSheet(context));
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
      return _HeroCrossFade(
        slot: 'hero-empty',
        child: _EmptyHero(
          hasSavedProfiles: hasSavedProfiles,
          scrollController: widget.scrollController,
          onRequestAfterTailFocus: widget.onRequestAfterTailFocus,
        ),
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
      return _HeroCrossFade(
        slot: 'hero-board',
        expand: widget.splitViewportHeight == null,
        child: _HeroBoard(
          controller: widget.scrollController,
          split: split,
          splitViewportHeight: widget.splitViewportHeight,
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
            _TailEdgeFocus(
              onDown: widget.onRequestAfterTailFocus,
              child: const _HeroActionRow(showUpdate: false),
            ),
          ],
        ),
      );
    }

    final activeProfile = profile!;
    final panelMeta = activeProfile.panelMeta;
    final announce = panelMeta?.announce?.trim();
    final serviceName = panelMeta?.serviceName?.trim();
    final subscriptionName = serviceName == null || serviceName.isEmpty
        ? activeProfile.realLabel
        : serviceName;
    final sub = activeProfile.subscriptionInfo;
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

    return _HeroCrossFade(
      slot: 'hero-board',
      expand: widget.splitViewportHeight == null,
      child: _HeroBoard(
        controller: widget.scrollController,
        split: split,
        splitViewportHeight: widget.splitViewportHeight,
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
          if (!split)
            _ServerSlot(
              server: activeServer,
              status: status,
              accent: accent,
              profileUpdatingKey: activeProfile.updatingKey,
              gap: metrics.gapCard,
            ),
          _HeroReveal(
            child: Column(
              key: const ValueKey('hero-sub'),
              mainAxisSize: MainAxisSize.min,
              children: [
                _SubscriptionStrip(
                  key: const ValueKey('hero-subscription-strip'),
                  sub: sub ?? const SubscriptionInfo(),
                  serviceName: subscriptionName,
                  buyPlanUrl: buyPlanUrl,
                  buyTrafficUrl: buyTrafficUrl,
                  hasAnnounce:
                      !split && announce != null && announce.isNotEmpty,
                  onTap: _handleShowSubscription,
                ),
                SizedBox(height: metrics.gapCard),
              ],
            ),
          ),
          _TailEdgeFocus(
            onDown: widget.onRequestAfterTailFocus,
            child: _HeroActionRow(
              isUpdating: isUpdating,
              onUpdate: () => unawaited(
                ref
                    .read(profilesActionProvider.notifier)
                    .updateProfile(activeProfile, showLoading: true),
              ),
              supportUrl: panelMeta?.supportUrl,
            ),
          ),
        ],
      ),
    );
  }
}

/// The right column of the two-column board: what the pager would otherwise
/// hide behind its second page, in one scroll.
class HeroSplitDetails extends ConsumerWidget {
  const HeroSplitDetails({
    super.key,
    this.scrollController,
    this.splitViewportHeight,
  });

  final ScrollController? scrollController;
  final double? splitViewportHeight;

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
    final server = _ServerPanel(
      displayName: activeServer.displayName,
      nameCountryCode: activeServer.countryCode,
      delay: activeServer.delay,
      status: status,
      accent: accent,
      otherCodes: activeServer.otherCodes,
      otherLocations: activeServer.otherLocations,
      smartRouting: activeServer.smartRouting,
    );
    if (profile == null) {
      return _DetailsScroll(
        controller: scrollController,
        bottomInset: bottomInset,
        children: (metrics) => [AnnounceMorphBoundary(child: server)],
      );
    }
    return _DetailsFill(
      controller: scrollController,
      bottomInset: bottomInset,
      splitViewportHeight: splitViewportHeight,
      server: server,
    );
  }
}

class _DetailsFill extends StatelessWidget {
  const _DetailsFill({
    required this.controller,
    required this.bottomInset,
    required this.splitViewportHeight,
    required this.server,
  });

  final ScrollController? controller;
  final double bottomInset;
  final double? splitViewportHeight;
  final Widget server;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final metrics = HeroMetrics.of(
          box.copyWith(minHeight: 0, maxHeight: splitViewportHeight),
          MediaQuery.textScalerOf(context),
          split: true,
        );
        final matched = splitViewportHeight != null;
        final top = matched ? 0.0 : metrics.gapEdge;
        final bottom = matched ? 0.0 : metrics.gapCard + bottomInset;
        final height = box.hasBoundedHeight ? box.maxHeight : 0.0;
        final width = box.hasBoundedWidth ? box.maxWidth : 0.0;
        return SingleChildScrollView(
          controller: controller,
          primary: false,
          padding: EdgeInsets.only(top: top, bottom: bottom),
          child: DashboardWidgetMetrics(
            unitHeight: dashboardUnitHeight(width),
            child: Builder(
              builder: (context) => AnnounceMorphBoundary(
                child: DetailsElasticFlow(
                  viewportHeight: math.max(0, height - top - bottom),
                  flexIndex: 2,
                  flexMin: DashboardWidgetMetrics.heightOf(context, 1),
                  children: [
                    server,
                    SizedBox(height: metrics.gapCard),
                    const Announce(fill: true),
                    SizedBox(height: metrics.gapCard),
                    ...providerStatusTail(metrics.gapCard),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

class _TailEdgeFocus extends StatelessWidget {
  const _TailEdgeFocus({required this.child, this.onDown});

  final Widget child;
  final VoidCallback? onDown;

  @override
  Widget build(BuildContext context) {
    final onDown = this.onDown;
    if (onDown == null) return child;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent ||
            event.logicalKey != LogicalKeyboardKey.arrowDown) {
          return KeyEventResult.ignored;
        }
        onDown();
        return KeyEventResult.handled;
      },
      child: child,
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
    this.splitViewportHeight,
    required this.head,
    required this.tail,
  });

  final ScrollController? controller;
  final bool split;
  final double? splitViewportHeight;
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
          box.copyWith(minHeight: 0, maxHeight: splitViewportHeight),
          MediaQuery.textScalerOf(context),
          split: split,
          portrait: portrait,
        );
        final top = metrics.gapEdge;
        final bottom = metrics.gapCard + bottomInset;
        final height =
            splitViewportHeight ?? (box.hasBoundedHeight ? box.maxHeight : 0.0);
        final flow = HeroElasticFlow(
          viewportHeight: math.max(0, height - top - bottom),
          headMin: metrics.orbMin,
          headMax: metrics.orbMax,
          shrinkWrap: splitViewportHeight != null,
          head: head,
          tail: tail(metrics),
        );
        if (splitViewportHeight != null) return flow;
        final scroll = SingleChildScrollView(
          controller: controller,
          primary: false,
          padding: EdgeInsets.only(top: top, bottom: bottom),
          child: flow,
        );
        final scrollController = controller;
        if (scrollController == null) return scroll;
        return FocusedScrollView(controller: scrollController, child: scroll);
      },
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

/// Cross-fades the whole board when it swaps between the empty state and a
/// live profile, so a profile blinking away during a switch reads as a fade
/// rather than the entire layout snapping to a different tree.
class _HeroCrossFade extends StatelessWidget {
  const _HeroCrossFade({
    required this.slot,
    this.expand = true,
    required this.child,
  });

  final String slot;
  final bool expand;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: context.motionDuration(commonDuration),
      switchInCurve: Easing.emphasizedDecelerate,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.center,
        fit: expand ? StackFit.expand : StackFit.loose,
        children: <Widget>[...previousChildren, ?currentChild],
      ),
      child: KeyedSubtree(key: ValueKey(slot), child: child),
    );
  }
}

/// A tail card that fades and collapses instead of popping. The child carries
/// its own trailing gap so an absent slot leaves no double spacing behind, and
/// the size animation follows the fade so the board settles in one motion.
class _HeroReveal extends StatelessWidget {
  const _HeroReveal({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = context.motionDuration(commonDuration);
    return AnimatedSize(
      duration: duration,
      curve: Easing.standard,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Easing.emphasizedDecelerate,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[...previousChildren, ?currentChild],
        ),
        child: child,
      ),
    );
  }
}

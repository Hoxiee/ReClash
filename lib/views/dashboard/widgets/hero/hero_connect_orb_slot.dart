part of 'hero_connect.dart';

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
      'singularity' => localizations.findingSingularityDesc,
      'marks' => localizations.findingMarksDesc,
      'pi' => localizations.findingPiDesc,
      'turn' => localizations.findingTurnDesc,
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
            HeroStatus.blocked => appLocalizations.heroBlockedTitle,
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
            HeroStatus.blocked => appLocalizations.heroBlockedTitle,
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
            HeroStatus.blocked => appLocalizations.heroBlockedHint,
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
            HeroStatus.blocked => appLocalizations.heroBlockedHint,
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
                    icon: AppGlyphs.arrowDown,
                    value: lastTraffic?.down,
                    accent: accent,
                  ),
                  const SizedBox(width: 22),
                  _SpeedEntry(
                    icon: AppGlyphs.arrowUp,
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

  final Glyph icon;
  final num? value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final show = value?.traffic;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlyphIcon(icon, size: 15, color: accent ?? colorScheme.onSurfaceVariant),
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

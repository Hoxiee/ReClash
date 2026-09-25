part of 'hero_connect.dart';

enum _ServerCardPhase { server, loading, none }

/// The change-server card as a three-phase slot. It shows the picked server,
/// a loading shell while the subscription is refreshing without one yet, or
/// nothing at all. A short hold guards the collapse so a proxy list that
/// blinks empty during a reload — a common thing when the tab is shown again —
/// does not fold the card away and immediately reopen it.
class _ServerSlot extends ConsumerStatefulWidget {
  const _ServerSlot({
    required this.server,
    required this.status,
    required this.accent,
    required this.profileUpdatingKey,
    required this.gap,
  });

  final ActiveServerInfo server;
  final HeroStatus status;
  final Color? accent;
  final String profileUpdatingKey;
  final double gap;

  @override
  ConsumerState<_ServerSlot> createState() => _ServerSlotState();
}

class _ServerSlotState extends ConsumerState<_ServerSlot> {
  static const _collapseHold = Duration(milliseconds: 600);

  late _ServerCardPhase _shown = _targetPhase();
  Timer? _collapseTimer;

  _ServerCardPhase _targetPhase() {
    if (widget.server.displayName.isNotEmpty) {
      return _ServerCardPhase.server;
    }
    final busy =
        ref.read(loadingProvider(LoadingTag.proxies)) ||
        ref.read(isUpdatingProvider(widget.profileUpdatingKey)) ||
        ref.read(groupsProvider).isNotEmpty;
    return busy ? _ServerCardPhase.loading : _ServerCardPhase.none;
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasServer = widget.server.displayName.isNotEmpty;
    final busy =
        !hasServer &&
        (ref.watch(loadingProvider(LoadingTag.proxies)) ||
            ref.watch(isUpdatingProvider(widget.profileUpdatingKey)) ||
            ref.watch(groupsProvider.select((state) => state.isNotEmpty)));
    final target = hasServer
        ? _ServerCardPhase.server
        : busy
        ? _ServerCardPhase.loading
        : _ServerCardPhase.none;

    if (target != _ServerCardPhase.none) {
      _collapseTimer?.cancel();
      _collapseTimer = null;
      _shown = target;
    } else if (_shown != _ServerCardPhase.none && _collapseTimer == null) {
      _collapseTimer = Timer(_collapseHold, () {
        _collapseTimer = null;
        if (mounted) setState(() => _shown = _ServerCardPhase.none);
      });
    }

    return _HeroReveal(child: _content(_shown));
  }

  Widget _content(_ServerCardPhase phase) {
    switch (phase) {
      case _ServerCardPhase.none:
        return const SizedBox.shrink(key: ValueKey('server-none'));
      case _ServerCardPhase.loading:
        return Column(
          key: const ValueKey('server-loading'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ServerLoadingCard(),
            SizedBox(height: widget.gap),
          ],
        );
      case _ServerCardPhase.server:
        final server = widget.server;
        return Column(
          key: const ValueKey('server-ready'),
          mainAxisSize: MainAxisSize.min,
          children: [
            _ServerPanel(
              displayName: server.displayName,
              nameCountryCode: server.countryCode,
              delay: server.delay,
              status: widget.status,
              accent: widget.accent,
              otherCodes: server.otherCodes,
              otherLocations: server.otherLocations,
              smartRouting: server.smartRouting,
            ),
            SizedBox(height: widget.gap),
          ],
        );
    }
  }
}

/// The change-server card while servers are still loading: same surface as the
/// real card so the swap grows into place instead of appearing from nowhere.
class _ServerLoadingCard extends StatelessWidget {
  const _ServerLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return HeroSurface(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CommonCircleLoading(color: colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                context.appLocalizations.loading,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
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
            const SizedBox(width: AppSpacing.md),
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
            GlyphIcon(
              AppGlyphs.chevronForward,
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
            ? GlyphIcon(
                AppGlyphs.language,
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

part of 'hero_connect.dart';

class _EmptyHero extends ConsumerWidget {
  const _EmptyHero({
    required this.hasSavedProfiles,
    required this.scrollController,
    this.onRequestAfterTailFocus,
  });

  final bool hasSavedProfiles;
  final ScrollController? scrollController;
  final VoidCallback? onRequestAfterTailFocus;

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
    final hasByeDpiCard = ref.watch(byeDpiAvailableProvider);
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
          _TailEdgeFocus(
            onDown: hasByeDpiCard ? null : onRequestAfterTailFocus,
            child: HeroSurface(
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
                    icon: GlyphIcon(
                      hasSavedProfiles
                          ? AppGlyphs.folder
                          : AppGlyphs.add,
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
                      icon: const GlyphIcon(AppGlyphs.add),
                      label: Text(appLocalizations.addProfile),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (hasByeDpiCard) ...[
            const SizedBox(height: 12),
            _TailEdgeFocus(
              onDown: onRequestAfterTailFocus,
              child: FocusableTap(
                borderRadius: heroCardRadius,
                onTap: () => changeDashboardMode(ref, DashboardMode.byedpi),
                child: HeroSurface(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const _ByeDpiCardIcon(
                        icon: AppGlyphs.shield,
                        size: 44,
                      ),
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
                      GlyphIcon(
                        AppGlyphs.chevronForward,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
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
          GlyphIcon(AppGlyphs.announce, size: 20, color: colorScheme.primary),
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
          GlyphIcon(
            AppGlyphs.chevronForward,
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
            icon: AppGlyphs.refresh,
            label: appLocalizations.update,
            busy: isUpdating,
            onTap: onUpdate,
          ),
        ),
      if (hasSupport)
        Expanded(
          child: _ActionChip(
            icon: AppGlyphs.support,
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
          child: GlyphIcon(
            paused ? AppGlyphs.play : AppGlyphs.pause,
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

  Glyph _modeIcon(UiOutboundMode mode) => switch (mode) {
    UiOutboundMode.auto => AppGlyphs.autoMode,
    UiOutboundMode.rule => AppGlyphs.rules,
    UiOutboundMode.global => AppGlyphs.language,
    UiOutboundMode.direct => AppGlyphs.bolt,
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
            child: GlyphIcon(icon, size: 18, color: colorScheme.primary),
          ),
        ),
      ),
      popupBuilder: (_) => CommonPopupMenu(
        items: [
          for (final item in UiOutboundMode.values)
            CommonPopupMenuItem(
              glyph: _modeIcon(item),
              label: item.label,
              onPressed: () => _selectOutboundMode(ref, item),
            ),
          if (ref.watch(byeDpiAvailableProvider))
            CommonPopupMenuItem(
              glyph: connectionModeIcon(DashboardMode.byedpi),
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

  final Glyph icon;
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
                  : GlyphIcon(icon, size: iconSize, color: colorScheme.primary),
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

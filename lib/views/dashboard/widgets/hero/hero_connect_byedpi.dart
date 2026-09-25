part of 'hero_connect.dart';

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
                  icon: AppGlyphs.bolt,
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
                  icon: AppGlyphs.settings,
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
            const _ByeDpiCardIcon(icon: AppGlyphs.shield, size: 46),
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
            GlyphIcon(
              AppGlyphs.chevronForward,
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

  final Glyph icon;
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
                GlyphIcon(
                  AppGlyphs.chevronForward,
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

  final Glyph icon;
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
      child: GlyphIcon(
        icon,
        size: size * 0.48,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets.dart';

class AppearanceLayoutTab extends ConsumerWidget {
  const AppearanceLayoutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final newDashboard = ref.watch(newDashboardEnabledProvider);
    final textScale = ref.watch(
      themeSettingProvider.select((state) => state.textScale),
    );
    final isMobileView = ref.watch(isMobileViewProvider);
    return CustomScrollView(
      primary: false,
      slivers: [
        appearanceSection(
          title: appLocalizations.dashboardStyle,
          items: [
            Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DashboardStyleCard(
                    label: appLocalizations.classicDashboard,
                    desc: appLocalizations.classicDashboardDesc,
                    isSelected: !newDashboard,
                    onPressed: () => ref
                        .read(appSettingProvider.notifier)
                        .update((state) => state.copyWith(newDashboard: false)),
                    child: const _ClassicSketch(),
                  ),
                ),
                Expanded(
                  child: _DashboardStyleCard(
                    label: appLocalizations.newDashboardTitle,
                    desc: appLocalizations.newDashboardDesc,
                    isSelected: newDashboard,
                    onPressed: () => ref
                        .read(appSettingProvider.notifier)
                        .update((state) => state.copyWith(newDashboard: true)),
                    child: const _NewSketch(),
                  ),
                ),
              ],
            ),
          ],
        ),
        appearanceSection(
          items: [
            // Подписи рисует только боковая панель, поэтому на телефоне
            // настройке нечем управлять.
            if (!isMobileView) const _SidebarLabelsItem(),
            AppearanceSwitchItem(
              leading: const Icon(Icons.text_fields),
              title: appLocalizations.textScale,
              value: textScale.enable,
              onChanged: (value) => ref
                  .read(themeSettingProvider.notifier)
                  .update((state) => state.copyWith.textScale(enable: value)),
            ),
            AppearanceSliderItem(
              valueLabel: '${(textScale.scale * 100).round()}%',
              min: minTextScale,
              max: maxTextScale,
              value: textScale.scale,
              enabled: textScale.enable,
              onChanged: (value) => ref
                  .read(themeSettingProvider.notifier)
                  .update((state) => state.copyWith.textScale(scale: value)),
            ),
          ],
        ),
        appearanceBottomInset(context),
      ],
    );
  }
}

class _SidebarLabelsItem extends ConsumerWidget {
  const _SidebarLabelsItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppearanceSwitchItem(
      leading: const Icon(Icons.menu),
      title: context.appLocalizations.showLabels,
      value: ref.watch(appSettingProvider.select((state) => state.showLabel)),
      onChanged: (value) => ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(showLabel: value)),
    );
  }
}

class _DashboardStyleCard extends StatelessWidget {
  const _DashboardStyleCard({
    required this.label,
    required this.desc,
    required this.isSelected,
    required this.onPressed,
    required this.child,
  });

  final String label;
  final String desc;
  final bool isSelected;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      radius: AppCorner.lg,
      isSelected: isSelected,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Center(
              child: SizedBox(
                height: 132,
                child: AspectRatio(aspectRatio: 0.72, child: child),
              ),
            ),
            Text(label, style: context.textTheme.labelLarge),
            Text(
              desc,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sketch extends StatelessWidget {
  const _Sketch({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.sm,
      ),
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    );
  }
}

class _SketchBar extends StatelessWidget {
  const _SketchBar({required this.width, this.height = 4});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colorScheme.onSurfaceVariant.opacity30,
        borderRadius: AppRadius.full,
      ),
    );
  }
}

class _SketchBlock extends StatelessWidget {
  const _SketchBlock({this.height, this.radius = AppCorner.xs, this.child});

  final double? height;
  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppRadius.all(radius),
      ),
      child: child,
    );
  }
}

class _ClassicSketch extends StatelessWidget {
  const _ClassicSketch();

  @override
  Widget build(BuildContext context) {
    return _Sketch(
      child: Stack(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              _SketchBar(width: 26, height: 5),
              Expanded(
                child: Column(
                  spacing: 6,
                  children: [
                    Expanded(child: _SketchTileRow()),
                    Expanded(child: _SketchTileRow()),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SketchTileRow extends StatelessWidget {
  const _SketchTileRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      spacing: 6,
      children: [
        Expanded(child: _SketchTile()),
        Expanded(child: _SketchTile()),
      ],
    );
  }
}

class _SketchTile extends StatelessWidget {
  const _SketchTile();

  @override
  Widget build(BuildContext context) {
    return const _SketchBlock(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Align(
          alignment: Alignment.topLeft,
          child: _SketchBar(width: 12, height: 3),
        ),
      ),
    );
  }
}

class _NewSketch extends StatelessWidget {
  const _NewSketch();

  @override
  Widget build(BuildContext context) {
    return _Sketch(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colorScheme.primary,
                    width: 4,
                  ),
                ),
              ),
            ),
          ),
          const Center(child: _SketchBar(width: 34)),
          const Center(child: _SketchBar(width: 20)),
          const SizedBox(height: 2),
          const _SketchBlock(height: 24),
          const _SketchBlock(height: 14, radius: AppCorner.full),
        ],
      ),
    );
  }
}

import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Both previews are drawn in these units — a phone-sized canvas at roughly
/// 0.29 of the real dashboard, so card spans and heights keep their ratios.
const _previewSize = Size(112, 170);
const _screenInset = 6.0;
const _gap = 4.0;
const _tallCard = 44.0;
const _shortCard = 20.0;

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
        SettingSection.sliver(
          title: appLocalizations.dashboardStyle,
          items: [
            IntrinsicHeight(
              child: Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _DashboardStyleCard(
                      label: appLocalizations.classicDashboard,
                      desc: appLocalizations.classicDashboardDesc,
                      isSelected: !newDashboard,
                      onPressed: () => ref
                          .read(appSettingProvider.notifier)
                          .update(
                            (state) => state.copyWith(newDashboard: false),
                          ),
                      child: const _ClassicPreview(),
                    ),
                  ),
                  Expanded(
                    child: _DashboardStyleCard(
                      label: appLocalizations.newDashboardTitle,
                      desc: appLocalizations.newDashboardDesc,
                      isSelected: newDashboard,
                      onPressed: () => ref
                          .read(appSettingProvider.notifier)
                          .update(
                            (state) => state.copyWith(newDashboard: true),
                          ),
                      child: const _HeroPreview(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SettingSection.sliver(
          items: [
            // Подписи рисует только боковая панель, поэтому на телефоне
            // настройке нечем управлять.
            if (!isMobileView) const _SidebarLabelsItem(),
            DecorationListItem.toggle(
              leading: const Icon(Icons.text_fields),
              title: Text(appLocalizations.textScale),
              value: textScale.enable,
              onChanged: (value) => ref
                  .read(themeSettingProvider.notifier)
                  .update((state) => state.copyWith.textScale(enable: value)),
            ),
            if (textScale.enable)
              SettingSliderItem(
                valueLabel: '${(textScale.scale * 100).round()}%',
                min: minTextScale,
                max: maxTextScale,
                value: textScale.scale,
                resetValue: 1,
                onChanged: (value) => ref
                    .read(themeSettingProvider.notifier)
                    .update((state) => state.copyWith.textScale(scale: value)),
              ),
          ],
        ),
        const SettingBottomInset.sliver(),
      ],
    );
  }
}

class _SidebarLabelsItem extends ConsumerWidget {
  const _SidebarLabelsItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecorationListItem.toggle(
      leading: const Icon(Icons.menu),
      title: Text(context.appLocalizations.showLabels),
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
          spacing: 10,
          children: [
            Center(
              // A tight box keeps the intrinsic height of both cards equal and
              // scaleDown saves the sketch on very narrow windows.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox.fromSize(size: _previewSize, child: child),
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

/// Phone frame every sketch sits in: the app background with the real screen
/// padding scaled down.
class _Screen extends StatelessWidget {
  const _Screen({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRSuperellipse(
      borderRadius: AppRadius.sm,
      child: ColoredBox(
        color: context.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(_screenInset),
          child: child,
        ),
      ),
    );
  }
}

/// Stand-in for a line of text.
class _Bar extends StatelessWidget {
  const _Bar({this.width, this.height = 3, this.color});

  final double? width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? context.colorScheme.onSurfaceVariant.opacity30,
        borderRadius: AppRadius.full,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, this.color, this.borderWidth});

  final double size;
  final Color? color;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.colorScheme.onSurfaceVariant.opacity30;
    final borderWidth = this.borderWidth;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: borderWidth == null ? color : null,
        border: borderWidth == null
            ? null
            : Border.all(color: color, width: borderWidth),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// One dashboard card.
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.height});

  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppRadius.all(AppCorner.xs + 2),
      ),
      child: child,
    );
  }
}

/// Icon plus label, the header every classic card carries.
class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.labelWidth, this.trailing});

  final double labelWidth;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 3,
      children: [
        const _Dot(size: 4),
        _Bar(width: labelWidth),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

/// Classic dashboard: app bar, the default widget mosaic — one full-width
/// speed card over a two-column grid whose tall and short cards alternate —
/// and the start button floating over it.
class _ClassicPreview extends StatelessWidget {
  const _ClassicPreview();

  @override
  Widget build(BuildContext context) {
    return const _Screen(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: _gap,
            children: [
              _TitleBar(),
              _SpeedPanel(),
              Row(
                spacing: _gap,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      spacing: _gap,
                      children: [_ModePanel(), _ValuePanel(labelWidth: 13)],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: _gap,
                      children: [_ValuePanel(labelWidth: 17), _TrafficPanel()],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(right: 0, bottom: 3, child: _StartButton()),
        ],
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 14,
      child: Row(
        children: [
          _Bar(width: 24, height: 4),
          Spacer(),
          _Dot(size: 4),
          SizedBox(width: 5),
          _Dot(size: 4),
        ],
      ),
    );
  }
}

class _SpeedPanel extends StatelessWidget {
  const _SpeedPanel();

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return _Panel(
      height: _tallCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 3,
        children: [
          _PanelHeader(
            labelWidth: 21,
            trailing: _Bar(width: 11, color: primary.opacity60),
          ),
          Expanded(
            child: CustomPaint(painter: _SparkPainter(color: primary)),
          ),
        ],
      ),
    );
  }
}

class _ModePanel extends StatelessWidget {
  const _ModePanel();

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return _Panel(
      height: _tallCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3,
        children: [
          const _PanelHeader(labelWidth: 15),
          for (final (index, width) in const [13.0, 16.0, 11.0].indexed)
            Row(
              spacing: 3,
              children: [
                _Dot(
                  size: 4,
                  color: index == 0 ? primary : null,
                  borderWidth: index == 0 ? null : 1,
                ),
                _Bar(width: width),
              ],
            ),
        ],
      ),
    );
  }
}

/// A short card: header on top, its value pinned to the bottom.
class _ValuePanel extends StatelessWidget {
  const _ValuePanel({required this.labelWidth});

  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      height: _shortCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(labelWidth: labelWidth),
          const Spacer(),
          _Bar(
            width: 22,
            height: 3.5,
            color: context.colorScheme.onSurface.opacity30,
          ),
        ],
      ),
    );
  }
}

class _TrafficPanel extends StatelessWidget {
  const _TrafficPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return _Panel(
      height: _tallCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3,
        children: [
          const _PanelHeader(labelWidth: 17),
          Row(
            spacing: 4,
            children: [
              _Dot(
                size: 13,
                color: colorScheme.primary.opacity60,
                borderWidth: 3.5,
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  _Bar(width: 10, height: 2.5),
                  _Bar(width: 7, height: 2.5),
                ],
              ),
            ],
          ),
          for (final color in [
            colorScheme.primary.opacity60,
            colorScheme.secondary.opacity60,
          ])
            Row(
              spacing: 3,
              children: [
                _Dot(size: 3, color: color),
                const _Bar(width: 14, height: 2.5),
              ],
            ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: AppRadius.all(AppCorner.xs + 1),
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        size: 11,
        color: colorScheme.onPrimary,
      ),
    );
  }
}

/// The speed card's line chart: a smoothed spark line with the same gradient
/// fill underneath.
class _SparkPainter extends CustomPainter {
  const _SparkPainter({required this.color});

  final Color color;

  static const _values = [0.3, 0.52, 0.28, 0.66, 0.46, 0.82, 0.6];

  @override
  void paint(Canvas canvas, Size size) {
    final step = size.width / (_values.length - 1);
    double y(int index) => size.height * (1 - _values[index]);
    final line = Path()..moveTo(0, y(0));
    for (var index = 1; index < _values.length; index++) {
      final x = step * index;
      line.cubicTo(
        x - step / 2,
        y(index - 1),
        x - step / 2,
        y(index),
        x,
        y(index),
      );
    }
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.opacity30, color.opacity0],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter oldDelegate) => oldDelegate.color != color;
}

/// New dashboard: no app bar and no start button, the orb carries the state
/// and the server card, subscription and action pills stack under it.
class _HeroPreview extends StatelessWidget {
  const _HeroPreview();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return _Screen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 2),
          const Center(child: _Orb()),
          const SizedBox(height: 5),
          Center(
            child: _Bar(
              width: 44,
              height: 5,
              color: colorScheme.onSurface.opacity30,
            ),
          ),
          const SizedBox(height: 4),
          const Center(child: _Bar(width: 28)),
          const SizedBox(height: 5),
          const _HeroSpeedRow(),
          const SizedBox(height: 5),
          const _HeroServerPanel(),
          const SizedBox(height: _gap),
          const _HeroTrafficPanel(),
          const SizedBox(height: _gap),
          const _HeroActionRow(),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb();

  static const _size = 52.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox.square(
      dimension: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colorScheme.primary.opacity0,
                  colorScheme.primary.opacity15,
                ],
              ),
            ),
            child: const SizedBox.square(dimension: _size),
          ),
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 2.4),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outlineVariant.opacity60),
            ),
            child: Icon(
              Icons.power_settings_new_rounded,
              size: 19,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSpeedRow extends StatelessWidget {
  const _HeroSpeedRow();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 7,
      children: [
        for (final color in [colorScheme.primary, colorScheme.secondary])
          Row(
            spacing: 2,
            children: [
              _Dot(size: 3.5, color: color.opacity60),
              const _Bar(width: 13),
            ],
          ),
      ],
    );
  }
}

class _HeroServerPanel extends StatelessWidget {
  const _HeroServerPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return _Panel(
      height: 22,
      child: Row(
        spacing: 4,
        children: [
          _Dot(size: 10, color: colorScheme.primary.opacity30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                _Bar(
                  width: 24,
                  height: 3.5,
                  color: colorScheme.onSurface.opacity30,
                ),
                Row(
                  spacing: 3,
                  children: [
                    _Dot(size: 3, color: colorScheme.primary),
                    const _Bar(width: 15, height: 2.5),
                  ],
                ),
              ],
            ),
          ),
          const _Bar(width: 8),
        ],
      ),
    );
  }
}

class _HeroTrafficPanel extends StatelessWidget {
  const _HeroTrafficPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return _Panel(
      height: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 2,
        children: [
          Row(
            children: [
              const _Bar(width: 15),
              const Spacer(),
              _Bar(width: 11, height: 4, color: colorScheme.primary.opacity30),
            ],
          ),
          _Bar(width: 22, height: 4, color: colorScheme.onSurface.opacity30),
          ClipRSuperellipse(
            borderRadius: AppRadius.full,
            child: Stack(
              children: [
                Container(
                  height: 3,
                  color: colorScheme.surfaceContainerHighest,
                ),
                FractionallySizedBox(
                  widthFactor: 0.58,
                  child: Container(
                    height: 3,
                    color: colorScheme.primary.opacity60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionRow extends StatelessWidget {
  const _HeroActionRow();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      spacing: 3,
      children: [
        for (var index = 0; index < 3; index++)
          Expanded(
            child: Container(
              height: 11,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: AppRadius.full,
              ),
              child: _Bar(
                width: 9,
                height: 2.5,
                color: index == 2
                    ? colorScheme.primary.opacity60
                    : colorScheme.onSurfaceVariant.opacity30,
              ),
            ),
          ),
      ],
    );
  }
}

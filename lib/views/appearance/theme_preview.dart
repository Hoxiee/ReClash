import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/theme/wallpaper.dart' show WallpaperLayer;
import 'package:reclash/widgets/theme/wallpaper_scope.dart';
import 'package:reclash/widgets/widgets.dart';

// Every sketch is drawn on this canvas — a phone at roughly 0.29 of the real
// dashboard, so card spans and heights keep their ratios — then scaled to fit.
const _previewSize = Size(112, 170);
const _screenInset = 6.0;
const _gap = 4.0;
const _tallCard = 44.0;
const _shortCard = 20.0;

class PreviewChoice<T> {
  const PreviewChoice({
    required this.value,
    required this.label,
    required this.pictogram,
  });

  final T value;
  final String label;
  final Widget pictogram;
}

class PreviewChoiceGroup<T> extends StatelessWidget {
  const PreviewChoiceGroup({
    super.key,
    required this.info,
    required this.choices,
    required this.value,
    required this.onChanged,
  });

  final Info info;
  final List<PreviewChoice<T>> choices;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoHeader(info: info),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final choice in choices)
                _ChoiceButton(
                  label: choice.label,
                  isSelected: choice.value == value,
                  onPressed: () => onChanged(choice.value),
                  pictogram: choice.pictogram,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.pictogram,
  });

  static const double _height = 48;

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Widget pictogram;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _height),
        child: CommonCard(
          isSelected: isSelected,
          onPressed: onPressed,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              ExcludeSemantics(child: pictogram),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The real dashboard, drawn in the ambient [ColorScheme]: the classic tile
/// grid or, with [hero], the connection ring. Pass [wallpaper] so card, hero
/// and orb surfaces dim by the same readability knobs the live app applies.
class DashboardSketch extends StatelessWidget {
  const DashboardSketch({super.key, required this.hero, this.wallpaper});

  final bool hero;
  final WallpaperProps? wallpaper;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_screenInset),
      child: hero ? _HeroBody(wallpaper: wallpaper) : const _ClassicBody(),
    );
  }
}

/// A phone frame rendering a [DashboardSketch] in [colorScheme], optionally
/// behind a wallpaper drawn exactly as the app would.
class PreviewDevice extends StatelessWidget {
  const PreviewDevice({
    super.key,
    required this.colorScheme,
    required this.hero,
    this.wallpaperImage,
    this.wallpaperSettings,
    this.width = 172,
  });

  final ColorScheme colorScheme;
  final bool hero;
  final ImageProvider? wallpaperImage;
  final WallpaperProps? wallpaperSettings;
  final double width;

  @override
  Widget build(BuildContext context) {
    final corner = AppCorner.fit(width);
    final settings = wallpaperImage == null ? null : wallpaperSettings;
    Widget sketch = SizedBox.fromSize(
      size: _previewSize,
      child: DashboardSketch(hero: hero, wallpaper: settings),
    );
    if (settings != null) {
      sketch = WallpaperSurfaceScope(
        opacity: settings.cardOpacity,
        child: sketch,
      );
    }
    return Theme(
      data: ThemeData(colorScheme: colorScheme, useMaterial3: true),
      child: SizedBox(
        width: width,
        height: width * _previewSize.height / _previewSize.width,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: ShapeDecoration(
            shape: AppShape.all(
              corner,
            ).copyWith(side: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: ClipRSuperellipse(
            borderRadius: AppRadius.all(corner),
            child: ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (settings != null)
                    Positioned.fill(
                      child: WallpaperLayer(
                        image: wallpaperImage!,
                        settings: settings,
                      ),
                    ),
                  FittedBox(child: sketch),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const double _thumbHeight = 34;
double get _thumbWidth =>
    _thumbHeight * _previewSize.width / _previewSize.height;

/// A dashboard sketch shrunk to icon size, for a choice's pictogram.
class SketchThumb extends StatelessWidget {
  const SketchThumb({super.key, required this.colorScheme, required this.hero});

  final ColorScheme colorScheme;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return _ThumbFrame(
      outline: context.colorScheme.outlineVariant,
      child: _ThumbSketch(colorScheme: colorScheme, hero: hero),
    );
  }
}

/// The "follow system" pictogram: light and dark sketches split on a diagonal.
class SketchSplitThumb extends StatelessWidget {
  const SketchSplitThumb({
    super.key,
    required this.light,
    required this.dark,
    required this.hero,
  });

  final ColorScheme light;
  final ColorScheme dark;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return _ThumbFrame(
      outline: context.colorScheme.outlineVariant,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ThumbSketch(colorScheme: light, hero: hero),
          ClipPath(
            clipper: _DiagonalClipper(),
            child: _ThumbSketch(colorScheme: dark, hero: hero),
          ),
        ],
      ),
    );
  }
}

class _ThumbSketch extends StatelessWidget {
  const _ThumbSketch({required this.colorScheme, required this.hero});

  final ColorScheme colorScheme;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(colorScheme: colorScheme, useMaterial3: true),
      child: ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: FittedBox(
          child: SizedBox.fromSize(
            size: _previewSize,
            child: DashboardSketch(hero: hero),
          ),
        ),
      ),
    );
  }
}

class _ThumbFrame extends StatelessWidget {
  const _ThumbFrame({required this.outline, required this.child});

  final Color outline;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _thumbWidth,
      height: _thumbHeight,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(
          shape: AppShape.sm.copyWith(side: BorderSide(color: outline)),
        ),
        child: ClipRSuperellipse(borderRadius: AppRadius.sm, child: child),
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.62, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.38, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}

Brightness liveBrightness(BuildContext context, ThemeMode themeMode) {
  return switch (themeMode) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => MediaQuery.platformBrightnessOf(context),
  };
}

class _ColorSchemeTween extends Tween<ColorScheme> {
  _ColorSchemeTween({super.end});

  @override
  ColorScheme lerp(double t) => ColorScheme.lerp(begin!, end!, t);
}

/// The home page as the settings would render it: the live theme colours over
/// the currently chosen layout, morphing whenever either changes.
class ThemeLivePreview extends ConsumerWidget {
  const ThemeLivePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    final pureBlack = ref.watch(
      themeSettingProvider.select((state) => state.pureBlack),
    );
    final hero = ref.watch(newDashboardEnabledProvider);
    final colorScheme = ref
        .watch(genColorSchemeProvider(liveBrightness(context, themeMode)))
        .toPureBlack(pureBlack);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerLow,
        shape: AppShape.xxl,
      ),
      child: TweenAnimationBuilder<ColorScheme>(
        tween: _ColorSchemeTween(end: colorScheme),
        duration: const Duration(milliseconds: 300),
        builder: (context, scheme, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.96, end: 1.0).animate(animation),
              child: child,
            ),
          ),
          child: PreviewDevice(
            key: ValueKey(hero),
            colorScheme: scheme,
            hero: hero,
          ),
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

/// One dashboard card; its surface dims under a [WallpaperSurfaceScope].
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.height});

  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: AppInsets.xs,
      decoration: BoxDecoration(
        color: WallpaperSurfaceScope.colorOf(
          context,
          context.colorScheme.surface,
        ),
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
class _ClassicBody extends StatelessWidget {
  const _ClassicBody();

  @override
  Widget build(BuildContext context) {
    return const Stack(
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
      child: GlyphIcon(AppGlyphs.play, size: 11, color: colorScheme.onPrimary),
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
/// and the server card, subscription and action pills stack under it. The
/// stacked panels dim by the hero readability knob, the orb by its own.
class _HeroBody extends StatelessWidget {
  const _HeroBody({this.wallpaper});

  final WallpaperProps? wallpaper;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final wallpaper = this.wallpaper;
    const panels = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroServerPanel(),
        SizedBox(height: _gap),
        _HeroTrafficPanel(),
        SizedBox(height: _gap),
        _HeroActionRow(),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxs),
        Center(child: _Orb(orbOpacity: wallpaper?.orbOpacity)),
        const SizedBox(height: 5),
        Center(
          child: _Bar(
            width: 44,
            height: 5,
            color: colorScheme.onSurface.opacity30,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Center(child: _Bar(width: 28)),
        const SizedBox(height: 5),
        const _HeroSpeedRow(),
        const SizedBox(height: 5),
        if (wallpaper != null)
          WallpaperSurfaceScope(opacity: wallpaper.heroOpacity, child: panels)
        else
          panels,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({this.orbOpacity});

  static const _size = 52.0;

  final double? orbOpacity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final face = orbOpacity == null
        ? colorScheme.surface
        : colorScheme.surface.withValues(alpha: orbOpacity!);
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
              color: face,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outlineVariant.opacity60),
            ),
            child: GlyphIcon(
              AppGlyphs.power,
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
                color: WallpaperSurfaceScope.colorOf(
                  context,
                  colorScheme.surface,
                ),
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

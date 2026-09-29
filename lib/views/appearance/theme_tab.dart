import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';

import 'color_sections.dart';
import 'theme_preview.dart';

const _defaultDarkAt = '22:00';
const _defaultLightAt = '07:00';
const _headerButtonHeight = 32.0;

class AppearanceThemeTab extends ConsumerWidget {
  const AppearanceThemeTab({super.key});

  void _update(WidgetRef ref, ThemeProps Function(ThemeProps) f) {
    ref.read(themeSettingProvider.notifier).update(f);
  }

  Future<void> _editTime(
    BuildContext context,
    WidgetRef ref, {
    required bool isDark,
  }) async {
    final current = ref.read(
      themeSettingProvider.select(
        (state) =>
            (isDark ? state.darkAt : state.lightAt) ??
            (isDark ? _defaultDarkAt : _defaultLightAt),
      ),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(current),
    );
    if (picked == null) {
      return;
    }
    final value = _formatTime(picked);
    _update(
      ref,
      (state) => isDark
          ? state.copyWith(darkAt: value)
          : state.copyWith(lightAt: value),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = ref.watch(
      themeSettingProvider.select(
        (state) => (
          scheduledTheme: state.scheduledTheme,
          darkAt: state.darkAt ?? _defaultDarkAt,
          lightAt: state.lightAt ?? _defaultLightAt,
          pureBlack: state.pureBlack,
          contrastLevel: state.contrastLevel,
        ),
      ),
    );
    final contrast = theme.contrastLevel.clamp(-1.0, 1.0);
    // Group the visual pickers first (layout, mode, pure black), then the
    // list-style controls, so the tab stops alternating between card and row.
    return SettingsScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        const _LayoutChoice(),
        const _ThemeModeChoice(),
        const _PureBlackChoice(),
        SettingSection.sliver(
          items: [
            DecorationListItem.toggle(
              leading: const GlyphIcon(AppGlyphs.clock),
              title: Text(appLocalizations.schedule),
              subtitle: Text(
                appLocalizations.scheduleDesc(theme.darkAt, theme.lightAt),
              ),
              value: theme.scheduledTheme,
              onChanged: (value) => _update(
                ref,
                (state) => value
                    ? state.copyWith(
                        scheduledTheme: true,
                        darkAt: state.darkAt ?? _defaultDarkAt,
                        lightAt: state.lightAt ?? _defaultLightAt,
                      )
                    : state.copyWith(scheduledTheme: false),
              ),
            ),
            if (theme.scheduledTheme) ...[
              DecorationListItem(
                leading: const GlyphIcon(AppGlyphs.moon),
                title: Text(appLocalizations.darkAt),
                trailing: Text(
                  theme.darkAt,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.opacity60,
                  ),
                ),
                onPressed: () => _editTime(context, ref, isDark: true),
              ),
              DecorationListItem(
                leading: const GlyphIcon(AppGlyphs.sun),
                title: Text(appLocalizations.lightAt),
                trailing: Text(
                  theme.lightAt,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.opacity60,
                  ),
                ),
                onPressed: () => _editTime(context, ref, isDark: false),
              ),
            ],
          ],
        ),
        SettingSection.sliver(
          items: [
            SettingSliderItem(
              leading: Tooltip(
                message: theme.pureBlack
                    ? appLocalizations.contrastAmoledHint
                    : '',
                child: const GlyphIcon(AppGlyphs.contrast),
              ),
              title: appLocalizations.contrast,
              valueLabel: _percent(contrast),
              min: -1,
              max: 1,
              value: contrast,
              resetValue: 0,
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(contrastLevel: value)),
            ),
          ],
        ),
        const _TextScaleItem(),
        const AppearanceColorSections(),
        const SettingBottomInset.sliver(),
      ],
    );
  }
}

class _LayoutChoice extends ConsumerWidget {
  const _LayoutChoice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final hero = ref.watch(newDashboardEnabledProvider);
    final (themeMode: themeMode, pureBlack: pureBlack) = ref.watch(
      themeSettingProvider.select(
        (state) => (themeMode: state.themeMode, pureBlack: state.pureBlack),
      ),
    );
    final brightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
    final scheme = ref
        .watch(genColorSchemeProvider(brightness))
        .toPureBlack(pureBlack);
    void select(bool value) => ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(newDashboard: value));
    return SliverToBoxAdapter(
      child: FadeSlideEnterBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoHeader(
              info: Info(
                label: appLocalizations.dashboardStyle,
                glyph: AppGlyphs.dashboard,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _LayoutCard(
                      label: appLocalizations.classicDashboard,
                      description: appLocalizations.classicDashboardDesc,
                      isSelected: !hero,
                      onPressed: () => select(false),
                      scheme: scheme,
                      hero: false,
                    ),
                  ),
                  Expanded(
                    child: _LayoutCard(
                      label: appLocalizations.newDashboardTitle,
                      description: appLocalizations.newDashboardDesc,
                      isSelected: hero,
                      onPressed: () => select(true),
                      scheme: scheme,
                      hero: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A big dashboard-style option: a framed [MiniScreen] over its name and a
/// one-line description, selectable as a whole card.
class _LayoutCard extends StatelessWidget {
  const _LayoutCard({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onPressed,
    required this.scheme,
    required this.hero,
  });

  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onPressed;
  final ColorScheme scheme;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      child: CommonCard(
        radius: AppCorner.lg,
        isSelected: isSelected,
        onPressed: onPressed,
        padding: AppInsets.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Center(
              child: SizedBox(
                height: 138,
                child: AspectRatio(
                  aspectRatio: 0.62,
                  child: ExcludeSemantics(
                    child: MiniScreenFrame(
                      screen: MiniScreen(colorScheme: scheme, hero: hero),
                    ),
                  ),
                ),
              ),
            ),
            Text(label, style: context.textTheme.labelLarge),
            Text(
              description,
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

class _ThemeModeChoice extends ConsumerWidget {
  const _ThemeModeChoice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final hero = ref.watch(newDashboardEnabledProvider);
    final (themeMode: themeMode, scheduledTheme: scheduled) = ref.watch(
      themeSettingProvider.select(
        (state) =>
            (themeMode: state.themeMode, scheduledTheme: state.scheduledTheme),
      ),
    );
    final light = MiniScreen(
      colorScheme: ref.watch(genColorSchemeProvider(Brightness.light)),
      hero: hero,
    );
    final dark = MiniScreen(
      colorScheme: ref.watch(genColorSchemeProvider(Brightness.dark)),
      hero: hero,
    );
    return SliverToBoxAdapter(
      child: FadeSlideEnterBox(
        child: PreviewChoiceGroup<ThemeMode?>(
          info: Info(label: appLocalizations.themeMode, glyph: AppGlyphs.sun),
          value: scheduled ? null : themeMode,
          choices: [
            PreviewChoice(
              value: ThemeMode.system,
              label: appLocalizations.auto,
              pictogram: MiniScreenThumb(
                screen: MiniSplitScreen(light: light, dark: dark),
              ),
            ),
            PreviewChoice(
              value: ThemeMode.light,
              label: appLocalizations.light,
              pictogram: MiniScreenThumb(screen: light),
            ),
            PreviewChoice(
              value: ThemeMode.dark,
              label: appLocalizations.dark,
              pictogram: MiniScreenThumb(screen: dark),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }
            ref
                .read(themeSettingProvider.notifier)
                .update(
                  (state) =>
                      state.copyWith(scheduledTheme: false, themeMode: value),
                );
          },
        ),
      ),
    );
  }
}

class _PureBlackChoice extends ConsumerWidget {
  const _PureBlackChoice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final hero = ref.watch(newDashboardEnabledProvider);
    final pureBlack = ref.watch(
      themeSettingProvider.select((state) => state.pureBlack),
    );
    final darkScheme = ref.watch(genColorSchemeProvider(Brightness.dark));
    Widget preview(bool value) => MiniScreenThumb(
      screen: MiniScreen(
        colorScheme: darkScheme.toPureBlack(value),
        hero: hero,
      ),
    );
    return SliverToBoxAdapter(
      child: FadeSlideEnterBox(
        child: PreviewChoiceGroup<bool>(
          info: Info(
            label: appLocalizations.pureBlackMode,
            glyph: AppGlyphs.pureBlack,
          ),
          value: pureBlack,
          choices: [
            PreviewChoice(
              value: false,
              label: appLocalizations.standard,
              pictogram: preview(false),
            ),
            PreviewChoice(
              value: true,
              label: appLocalizations.pureBlack,
              pictogram: preview(true),
            ),
          ],
          onChanged: (value) => ref
              .read(themeSettingProvider.notifier)
              .update((state) => state.copyWith(pureBlack: value)),
        ),
      ),
    );
  }
}

class _TextScaleItem extends ConsumerStatefulWidget {
  const _TextScaleItem();

  static const _step = 0.05;

  @override
  ConsumerState<_TextScaleItem> createState() => _TextScaleItemState();
}

class _TextScaleItemState extends ConsumerState<_TextScaleItem> {
  double? _draft;

  void _update(TextScale Function(TextScale textScale) update) {
    setState(() => _draft = null);
    ref
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(textScale: update(state.textScale)));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final textScale = ref.watch(
      themeSettingProvider.select((state) => state.textScale),
    );
    final systemScale = defaultTextScaleFactor
        .clamp(minTextScale, maxTextScale)
        .toDouble();
    final scale = _draft ?? (textScale.enable ? textScale.scale : systemScale);
    final percent = '${(scale * 100).round()}%';
    final divisions = ((maxTextScale - minTextScale) / _TextScaleItem._step)
        .round();
    return SliverToBoxAdapter(
      child: FadeSlideEnterBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoHeader(
              info: Info(
                label: appLocalizations.textScale,
                glyph: AppGlyphs.textSize,
              ),
              actions: [
                if (textScale.enable && textScale.scale != 1)
                  ElasticButton(
                    child: IconButton.filledTonal(
                      tooltip: appLocalizations.reset,
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: _headerButtonHeight,
                        height: _headerButtonHeight,
                      ),
                      visualDensity: VisualDensity.standard,
                      onPressed: () =>
                          _update((state) => state.copyWith(scale: 1)),
                      icon: const GlyphIcon(AppGlyphs.reset, fill: 1),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                spacing: 8,
                children: [
                  _SegmentedToggle(
                    value: textScale.enable,
                    offLabel: appLocalizations.followSystem,
                    onLabel: appLocalizations.custom,
                    onChanged: (value) =>
                        _update((state) => state.copyWith(enable: value)),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: ShapeDecoration(
                      color: colorScheme.surfaceContainerLow,
                      shape: AppShape.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            Expanded(
                              child: AnimatedSize(
                                duration: context.motionDuration(
                                  const Duration(milliseconds: 200),
                                ),
                                curve: Curves.easeOutCubic,
                                alignment: Alignment.topLeft,
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    textScaler: TextScaler.linear(scale),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        'Aa',
                                        style: context.textTheme.titleLarge,
                                      ),
                                      Text(
                                        appLocalizations.textScalePreview,
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: ShapeDecoration(
                                color: colorScheme.secondaryContainer,
                                shape: AppShape.full,
                              ),
                              child: Text(
                                percent,
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        MediaQuery.withNoTextScaling(
                          child: Row(
                            spacing: 12,
                            children: [
                              ExcludeSemantics(
                                child: Text(
                                  'A',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderDefaultsM3(context),
                                  child: Slider(
                                    padding: EdgeInsets.zero,
                                    min: minTextScale,
                                    max: maxTextScale,
                                    divisions: divisions,
                                    value: scale,
                                    label: percent,
                                    onChanged: textScale.enable
                                        ? (value) =>
                                              setState(() => _draft = value)
                                        : null,
                                    onChangeEnd: (value) => _update(
                                      (state) => state.copyWith(scale: value),
                                    ),
                                  ),
                                ),
                              ),
                              ExcludeSemantics(
                                child: Text(
                                  'A',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.value,
    required this.offLabel,
    required this.onLabel,
    required this.onChanged,
  });

  static const double _height = 44;
  static const double _inset = 4;

  final bool value;
  final String offLabel;
  final String onLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      height: _height,
      padding: const EdgeInsets.all(_inset),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHigh,
        shape: AppShape.full,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: context.motionDuration(const Duration(milliseconds: 250)),
            curve: Curves.easeOutCubic,
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: colorScheme.secondaryContainer,
                  shape: AppShape.full,
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final (option, label) in [
                (false, offLabel),
                (true, onLabel),
              ])
                Expanded(
                  child: Semantics(
                    selected: option == value,
                    button: true,
                    child: Material(
                      type: MaterialType.transparency,
                      shape: AppShape.full,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        customBorder: AppShape.full,
                        onTap: option == value ? null : () => onChanged(option),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: context.motionDuration(
                              const Duration(milliseconds: 200),
                            ),
                            style: context.textTheme.labelLarge!.copyWith(
                              color: option == value
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: option == value
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _percent(double value) {
  final percent = (value * 100).round();
  return percent > 0 ? '+$percent%' : '$percent%';
}

TimeOfDay _parseTime(String value) {
  final parts = value.split(':');
  return TimeOfDay(
    hour: int.tryParse(parts.first) ?? 0,
    minute: parts.length > 1 ? int.tryParse(parts.last) ?? 0 : 0,
  );
}

String _formatTime(TimeOfDay value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

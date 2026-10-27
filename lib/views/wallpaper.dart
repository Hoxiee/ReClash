import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/tool_route.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/ui/wallpaper_image.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/theme_preview.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WallpaperView extends ConsumerStatefulWidget {
  const WallpaperView({super.key});

  @override
  ConsumerState<WallpaperView> createState() => _WallpaperViewState();
}

class _WallpaperViewState extends ConsumerState<WallpaperView> {
  late final ScrollController _controller = sheetScrollController(context);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final wallpaper = ref.watch(
      themeSettingProvider.select((theme) => theme.wallpaper),
    );
    final selected = wallpaper.fileName;
    final imageState = ref.watch(wallpaperImageProvider);
    final image = imageState.asData?.value;
    final busy = ref.watch(wallpaperActionProvider);
    final editable = selected != null && image != null && !busy;
    const defaults = WallpaperProps();
    final framingChanged =
        wallpaper.fit != defaults.fit ||
        wallpaper.scale != defaults.scale ||
        wallpaper.positionX != defaults.positionX ||
        wallpaper.positionY != defaults.positionY;
    final effectsChanged =
        wallpaper.opacity != defaults.opacity ||
        wallpaper.dimming != defaults.dimming ||
        wallpaper.blur != defaults.blur ||
        wallpaper.cardOpacity != defaults.cardOpacity;
    return SingleChildScrollView(
      key: const PageStorageKey('theme-tab-background'),
      controller: _controller,
      padding: context.bodyInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: context.appBarInset),
          if (showThemeLivePreview &&
              ViewScope.sizeOf(context).width <= maxMobileWidth) ...const [
            ThemeLivePreview(),
            SizedBox(height: 16),
          ],
          _WallpaperSection(
            info: Info(label: l.wallpaperTitle, glyph: AppGlyphs.photos),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                const _WallpaperGallery(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    generateGroup([
                      _WallpaperControl(
                        enabled: editable,
                        child: ConfigToggleItem(
                          setting: wallpaperToolSettings[0],
                          selector: themeSettingProvider.select(
                            (theme) => theme.wallpaper.enabled,
                          ),
                          title: (l) => l.wallpaperEnabled,
                          leading: const GlyphIcon(AppGlyphs.photos),
                          onChanged: (ref, value) => _updateWallpaper(
                            ref,
                            (wallpaper) => wallpaper.copyWith(enabled: value),
                          ),
                        ),
                      ),
                    ]),
                    ListFooter(
                      text:
                          selected != null &&
                              image == null &&
                              !imageState.isLoading
                          ? l.wallpaperUnavailable
                          : l.wallpaperSelectHint,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _WallpaperSection(
            info: Info(label: l.wallpaperLayout, glyph: AppGlyphs.layers),
            actions: [
              _WallpaperResetButton(
                visible: framingChanged,
                tooltip: l.wallpaperResetLayout,
                onPressed: busy
                    ? null
                    : () => globalState.safeRun(
                        ref.read(wallpaperActionProvider.notifier).resetFraming,
                      ),
              ),
            ],
            child: generateGroup([
              _WallpaperControl(
                enabled: editable,
                child: ConfigOptionsItem<WallpaperFit>(
                  setting: wallpaperToolSettings[1],
                  selector: themeSettingProvider.select(
                    (theme) => theme.wallpaper.fit,
                  ),
                  title: (l) => l.wallpaperFit,
                  options: WallpaperFit.values,
                  textBuilder: (fit) => fit.label,
                  onChanged: (ref, value) => _updateWallpaper(
                    ref,
                    (wallpaper) => wallpaper.copyWith(fit: value),
                  ),
                ),
              ),
              _WallpaperSlider(
                setting: wallpaperToolSettings[2],
                selector: (wallpaper) => wallpaper.scale,
                update: (wallpaper, value) => wallpaper.copyWith(scale: value),
                min: 1,
                max: 3,
                divisions: 40,
                valueLabel: (value) => '${(value * 100).round()}%',
                enabled: editable,
              ),
              _WallpaperSlider(
                setting: wallpaperToolSettings[3],
                selector: (wallpaper) => wallpaper.positionX,
                update: (wallpaper, value) =>
                    wallpaper.copyWith(positionX: value),
                min: -1,
                max: 1,
                divisions: 40,
                valueLabel: (value) => '${(value * 100).round()}%',
                enabled: editable,
              ),
              _WallpaperSlider(
                setting: wallpaperToolSettings[4],
                selector: (wallpaper) => wallpaper.positionY,
                update: (wallpaper, value) =>
                    wallpaper.copyWith(positionY: value),
                min: -1,
                max: 1,
                divisions: 40,
                valueLabel: (value) => '${(value * 100).round()}%',
                enabled: editable,
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _WallpaperSection(
            info: Info(label: l.wallpaperEffects, glyph: AppGlyphs.sliders),
            actions: [
              _WallpaperResetButton(
                visible: effectsChanged,
                tooltip: l.wallpaperReset,
                onPressed: busy
                    ? null
                    : () => globalState.safeRun(
                        ref.read(wallpaperActionProvider.notifier).resetEffects,
                      ),
              ),
            ],
            child: generateGroup([
              _WallpaperSlider(
                setting: wallpaperToolSettings[5],
                selector: (wallpaper) => wallpaper.opacity,
                update: (wallpaper, value) =>
                    wallpaper.copyWith(opacity: value),
                valueLabel: (value) => '${(value * 100).round()}%',
                enabled: editable,
              ),
              _WallpaperSlider(
                setting: wallpaperToolSettings[6],
                selector: (wallpaper) => wallpaper.dimming,
                update: (wallpaper, value) =>
                    wallpaper.copyWith(dimming: value),
                valueLabel: (value) => '${(value * 100).round()}%',
                enabled: editable,
              ),
              _WallpaperSlider(
                setting: wallpaperToolSettings[7],
                selector: (wallpaper) => wallpaper.blur,
                update: (wallpaper, value) => wallpaper.copyWith(blur: value),
                max: 30,
                divisions: 30,
                valueLabel: (value) => value.round().toString(),
                enabled: editable,
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _WallpaperSection(
            info: Info(label: l.wallpaperReadability, glyph: AppGlyphs.eye),
            child: generateGroup([
              _WallpaperSlider(
                setting: wallpaperToolSettings[8],
                selector: (wallpaper) => wallpaper.cardOpacity,
                update: (wallpaper, value) =>
                    wallpaper.copyWith(cardOpacity: value),
                valueLabel: (value) => '${(value * 100).round()}%',
                enabled: editable,
              ),
            ]),
          ),
          SizedBox(height: context.bottomInset + 32),
        ],
      ),
    );
  }
}

class _WallpaperSection extends StatelessWidget {
  const _WallpaperSection({
    required this.info,
    this.actions = const [],
    required this.child,
  });

  final Info info;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      InfoHeader(info: info, actions: actions),
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: child),
    ],
  );
}

class _WallpaperResetButton extends StatelessWidget {
  const _WallpaperResetButton({
    required this.visible,
    required this.tooltip,
    required this.onPressed,
  });

  final bool visible;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FadeScaleBox(
    child: visible
        ? TonalButtonTheme(
            size: TonalButtonSize.section,
            child: ElasticPress(
              child: IconButton(
                tooltip: tooltip,
                onPressed: onPressed,
                icon: const GlyphIcon(AppGlyphs.reset),
              ),
            ),
          )
        : const SizedBox.shrink(),
  );
}

void _updateWallpaper(
  WidgetRef ref,
  WallpaperProps Function(WallpaperProps wallpaper) update,
) {
  if (ref.read(wallpaperActionProvider)) return;
  ref
      .read(themeSettingProvider.notifier)
      .update((theme) => theme.copyWith(wallpaper: update(theme.wallpaper)));
}

class _WallpaperControl extends StatelessWidget {
  const _WallpaperControl({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    enabled: enabled,
    child: ExcludeFocus(
      excluding: !enabled,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Opacity(opacity: enabled ? 1 : 0.5, child: child),
      ),
    ),
  );
}

class _WallpaperSlider extends ConsumerWidget {
  const _WallpaperSlider({
    required this.setting,
    required this.selector,
    required this.update,
    required this.valueLabel,
    required this.enabled,
    this.min = 0,
    this.max = 1,
    this.divisions = 100,
  });

  final SettingSpec setting;
  final double Function(WallpaperProps wallpaper) selector;
  final WallpaperProps Function(WallpaperProps wallpaper, double value) update;
  final String Function(double value) valueLabel;
  final bool enabled;
  final double min;
  final double max;
  final int divisions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(
      themeSettingProvider.select((theme) => selector(theme.wallpaper)),
    );
    final label = valueLabel(value);
    return SettingTarget(
      spec: setting,
      child: CommonCard(
        shape: AppShape.of(
          AppRadius.vertical(
            top: switch (ItemPositionProvider.of(context)?.position) {
              ItemPosition.start || ItemPosition.startAndEnd => AppCorner.xl,
              _ => AppCorner.none,
            },
            bottom: switch (ItemPositionProvider.of(context)?.position) {
              ItemPosition.end || ItemPosition.startAndEnd => AppCorner.xl,
              _ => AppCorner.none,
            },
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Text(
                    setting.title(context.appLocalizations),
                    style: context.listTitleStyle,
                  ),
                ),
                Text(label, style: context.listSubtitleStyle.toTabular),
              ],
            ),
            SliderTheme(
              data: SliderDefaultsM3(context),
              child: Slider(
                key: ValueKey(setting.id),
                padding: EdgeInsets.zero,
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                label: label,
                onChanged: enabled
                    ? (value) => _updateWallpaper(
                        ref,
                        (wallpaper) => update(wallpaper, value),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WallpaperGallery extends ConsumerWidget {
  const _WallpaperGallery();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final library = ref.watch(
      themeSettingProvider.select((theme) => theme.wallpaper.library),
    );
    final full = library.length >= maxWallpaperLibrary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (_, constraints) {
            final columns = constraints.maxWidth >= 480 ? 3 : 2;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var index = 0; index < library.length; index++)
                  SizedBox(
                    width: width,
                    child: _WallpaperTile(
                      fileName: library[index],
                      index: index,
                    ),
                  ),
                if (!full)
                  SizedBox(width: width, child: const _AddWallpaperTile()),
              ],
            );
          },
        ),
        if (full) ListFooter(text: l.wallpaperLibraryFull(maxWallpaperLibrary)),
      ],
    );
  }
}

class _AddWallpaperTile extends ConsumerWidget {
  const _AddWallpaperTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final busy = ref.watch(wallpaperActionProvider);
    return Semantics(
      button: true,
      enabled: !busy,
      child: Material(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.lg,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: AppShape.lg,
          onTap: busy
              ? null
              : () => globalState.safeRun(
                  ref.read(wallpaperActionProvider.notifier).chooseImage,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Center(
                  child: busy
                      ? const CommonCircleLoading()
                      : DecoratedBox(
                          decoration: ShapeDecoration(
                            color: colorScheme.primary,
                            shape: AppShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: GlyphIcon(
                              AppGlyphs.add,
                              fill: 1,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Text(
                  context.appLocalizations.add,
                  style: AppTextStyle.footnote.of(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WallpaperTile extends ConsumerWidget {
  const _WallpaperTile({required this.fileName, required this.index});

  final String fileName;
  final int index;

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      message: TextSpan(text: l.deleteTip(l.wallpaperImageLabel(index + 1))),
      destructive: true,
      confirmText: l.wallpaperRemove,
    );
    if (confirmed != true || !context.mounted) return;
    await globalState.safeRun(
      () => ref.read(wallpaperActionProvider.notifier).removeImage(fileName),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final label = l.wallpaperImageLabel(index + 1);
    final selected = ref.watch(
      themeSettingProvider.select(
        (theme) => theme.wallpaper.fileName == fileName,
      ),
    );
    final busy = ref.watch(wallpaperActionProvider);
    final thumbnail = ref.watch(wallpaperThumbnailProvider(fileName));
    final image = thumbnail.asData?.value;
    return ContextMenuRegion(
      menuItems: busy
          ? null
          : [
              CommonPopupMenuItem(
                label: l.wallpaperRemove,
                glyph: AppGlyphs.delete,
                danger: true,
                onPressed: () => _remove(context, ref),
              ),
            ],
      child: Semantics(
        label: label,
        button: true,
        selected: selected,
        enabled: !busy && image != null,
        child: Material(
          color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
          shape: AppShape.lg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: AppShape.lg,
            onTap: busy || image == null
                ? null
                : () => globalState.safeRun(
                    () => ref
                        .read(wallpaperActionProvider.notifier)
                        .selectImage(fileName),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (image != null)
                        WallpaperImage(image: image)
                      else
                        Center(
                          child: GlyphIcon(
                            AppGlyphs.photos,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (selected)
                        const PositionedDirectional(
                          top: 8,
                          end: 8,
                          child: SelectionBadge(),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Text(
                    image == null && !thumbnail.isLoading
                        ? l.wallpaperUnavailable
                        : label,
                    style: AppTextStyle.footnote.of(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final wallpaperToolSettings = <SettingSpec>[
  SettingSpec(
    id: 'theme.wallpaper.enabled',
    page: ToolPage.theme,
    title: (l) => l.wallpaperEnabled,
    keywords: ['wallpaper', 'background'],
  ),
  SettingSpec(
    id: 'theme.wallpaper.fit',
    page: ToolPage.theme,
    title: (l) => l.wallpaperFit,
    keywords: ['wallpaper', 'framing'],
  ),
  SettingSpec(
    id: 'theme.wallpaper.scale',
    page: ToolPage.theme,
    title: (l) => l.wallpaperScale,
    keywords: ['wallpaper', 'framing'],
  ),
  SettingSpec(
    id: 'theme.wallpaper.positionX',
    page: ToolPage.theme,
    title: (l) => l.wallpaperHorizontalPosition,
    keywords: ['wallpaper', 'framing'],
  ),
  SettingSpec(
    id: 'theme.wallpaper.positionY',
    page: ToolPage.theme,
    title: (l) => l.wallpaperVerticalPosition,
    keywords: ['wallpaper', 'framing'],
  ),
  SettingSpec(
    id: 'theme.wallpaper.opacity',
    page: ToolPage.theme,
    title: (l) => l.wallpaperOpacity,
    keywords: ['wallpaper', 'effects'],
  ),
  SettingSpec(
    id: 'theme.wallpaper.dimming',
    page: ToolPage.theme,
    title: (l) => l.wallpaperDimming,
    keywords: ['wallpaper', 'effects'],
  ),
  SettingSpec(
    id: 'theme.wallpaper.blur',
    page: ToolPage.theme,
    title: (l) => l.wallpaperBlur,
    keywords: ['wallpaper', 'effects'],
  ),
  SettingSpec(
    id: 'theme.wallpaper.cardOpacity',
    page: ToolPage.theme,
    title: (l) => l.wallpaperCardOpacity,
    keywords: ['wallpaper', 'readability'],
  ),
];

import 'dart:async';
import 'package:reclash/icons/icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';

const _tileSpacing = 10.0;
const _tileMaxWidth = 132.0;
const _tileAspect = 1.4;

class AppearanceBackgroundTab extends ConsumerWidget {
  const AppearanceBackgroundTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.appLocalizations;
    final settings = ref.watch(
      themeSettingProvider.select((value) => value.wallpaper),
    );
    final busy = ref.watch(wallpaperActionProvider);
    final hasFile = settings.fileName != null;
    void update(WallpaperProps Function(WallpaperProps) change) {
      ref
          .read(themeSettingProvider.notifier)
          .update(
            (value) => value.copyWith(wallpaper: change(value.wallpaper)),
          );
    }

    String fitLabel(Object? value) => switch (value) {
      WallpaperFit.contain => l10n.wallpaperFitContain,
      WallpaperFit.fill => l10n.wallpaperFitFill,
      _ => l10n.wallpaperFitCover,
    };

    Widget slider(
      String title,
      double value,
      double reset,
      ValueChanged<double> onChanged, {
      double min = 0,
      double max = 1,
      bool percent = true,
    }) => SettingSliderItem(
      title: title,
      valueLabel: percent
          ? '${(value * 100).round()}%'
          : value.round().toString(),
      min: min,
      max: max,
      value: value,
      resetValue: reset,
      onChanged: onChanged,
    );

    return ExcludeFocus(
      excluding: busy,
      child: AbsorbPointer(
        absorbing: busy,
        child: SettingsScrollView(
          slivers: [
            if (busy)
              const SliverToBoxAdapter(child: LinearProgressIndicator()),
            SettingSection.sliver(
              title: l10n.wallpaperTitle,
              subTitle: l10n.wallpaperDescription,
              items: [const _WallpaperGallery()],
            ),
            if (hasFile) ...[
              SettingSection.sliver(
                items: [
                  DecorationListItem.toggle(
                    leading: const GlyphIcon(AppGlyphs.wallpaper),
                    title: Text(l10n.wallpaperEnabled),
                    value: settings.enabled,
                    onChanged: (value) =>
                        update((s) => s.copyWith(enabled: value)),
                  ),
                ],
              ),
              SettingSection.sliver(
                title: l10n.wallpaperLayout,
                items: [
                  DecorationListItem.options(
                    title: Text(l10n.wallpaperFit),
                    subtitle: Text(fitLabel(settings.fit)),
                    dialogTitle: l10n.wallpaperFit,
                    options: WallpaperFit.values,
                    value: settings.fit,
                    textBuilder: fitLabel,
                    onChanged: (value) =>
                        update((s) => s.copyWith(fit: value as WallpaperFit)),
                  ),
                  slider(
                    l10n.wallpaperScale,
                    settings.scale,
                    1,
                    (v) => update((s) => s.copyWith(scale: v)),
                    min: 1,
                    max: 3,
                  ),
                  slider(
                    l10n.wallpaperHorizontalPosition,
                    settings.positionX,
                    0,
                    (v) => update((s) => s.copyWith(positionX: v)),
                    min: -1,
                  ),
                  slider(
                    l10n.wallpaperVerticalPosition,
                    settings.positionY,
                    0,
                    (v) => update((s) => s.copyWith(positionY: v)),
                    min: -1,
                  ),
                ],
              ),
              SettingSection.sliver(
                title: l10n.wallpaperEffects,
                items: [
                  slider(
                    l10n.wallpaperOpacity,
                    settings.opacity,
                    0.35,
                    (v) => update((s) => s.copyWith(opacity: v)),
                  ),
                  slider(
                    l10n.wallpaperDimming,
                    settings.dimming,
                    0,
                    (v) => update((s) => s.copyWith(dimming: v)),
                  ),
                  slider(
                    l10n.wallpaperBlur,
                    settings.blur,
                    0,
                    (v) => update((s) => s.copyWith(blur: v)),
                    max: 30,
                    percent: false,
                  ),
                ],
              ),
              SettingSection.sliver(
                title: l10n.wallpaperReadability,
                items: [
                  slider(
                    l10n.wallpaperCardOpacity,
                    settings.cardOpacity,
                    0.9,
                    (v) => update((s) => s.copyWith(cardOpacity: v)),
                  ),
                  DecorationListItem(
                    leading: const GlyphIcon(AppGlyphs.restore),
                    title: Text(l10n.wallpaperReset),
                    onPressed: () => update(
                      (s) => WallpaperProps(
                        enabled: s.enabled,
                        fileName: s.fileName,
                        library: s.library,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SettingBottomInset.sliver(),
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
    final l10n = context.appLocalizations;
    final (:library, :active, :enabled) = ref.watch(
      themeSettingProvider.select(
        (value) => (
          library: value.wallpaper.library,
          active: value.wallpaper.fileName,
          enabled: value.wallpaper.enabled,
        ),
      ),
    );
    final canAdd = library.length < maxWallpaperLibrary;
    final action = ref.read(wallpaperActionProvider.notifier);
    Future<void> run(Future<void> Function() task) => globalState.safeRun(task);

    final hint = library.isEmpty
        ? l10n.wallpaperSelectHint
        : canAdd
        ? l10n.wallpaperGalleryHint
        : l10n.wallpaperLibraryFull(maxWallpaperLibrary);

    final addTile = _AddTile(
      onTap: () => unawaited(run(action.chooseImage)),
      label: library.isEmpty ? l10n.wallpaperChoose : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (library.isEmpty)
          SizedBox(
            height: _tileMaxWidth,
            width: double.infinity,
            child: addTile,
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  (((constraints.maxWidth - _tileSpacing * 2) / 3).clamp(
                    0.0,
                    _tileMaxWidth,
                  )).floorToDouble();
              final height = (width * _tileAspect).floorToDouble();
              final tiles = <Widget>[
                for (final fileName in library)
                  _WallpaperTile(
                    fileName: fileName,
                    selected: enabled && fileName == active,
                    onTap: () =>
                        unawaited(run(() => action.selectImage(fileName))),
                    onRemove: () =>
                        unawaited(run(() => action.removeImage(fileName))),
                  ),
                if (canAdd) addTile,
              ];
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    for (final (index, tile) in tiles.indexed) ...[
                      if (index > 0) const SizedBox(width: _tileSpacing),
                      SizedBox(width: width, height: height, child: tile),
                    ],
                  ],
                ),
              );
            },
          ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 4),
          child: Text(
            hint,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _WallpaperTile extends ConsumerWidget {
  const _WallpaperTile({
    required this.fileName,
    required this.selected,
    required this.onTap,
    required this.onRemove,
  });

  final String fileName;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final thumbnail = ref.watch(wallpaperThumbnailProvider(fileName));
    final image = thumbnail.asData?.value;
    final missing = thumbnail is AsyncData && image == null;
    return Stack(
      fit: StackFit.expand,
      children: [
        CommonCard(
          isSelected: selected,
          padding: EdgeInsets.zero,
          radius: AppCorner.lg,
          onPressed: onTap,
          child: ClipRSuperellipse(
            borderRadius: AppRadius.lg,
            child: missing
                ? Center(
                    child: GlyphIcon(
                      AppGlyphs.brokenImage,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : image == null
                ? const SizedBox.expand()
                : Image(image: image, fit: BoxFit.cover),
          ),
        ),
        if (selected)
          Positioned(
            left: 6,
            top: 6,
            child: _Badge(
              color: colorScheme.primary,
              child: GlyphIcon(AppGlyphs.check, size: 14, color: colorScheme.onPrimary),
            ),
          ),
        Positioned(
          right: 4,
          top: 4,
          child: IconButton(
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surface.opacity80,
              minimumSize: const Size(28, 28),
              padding: EdgeInsets.zero,
            ),
            tooltip: context.appLocalizations.wallpaperRemove,
            onPressed: onRemove,
            icon: const GlyphIcon(AppGlyphs.close),
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap, this.label});

  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.lg,
      onPressed: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlyphIcon(
              AppGlyphs.addImage,
              color: colorScheme.onSurfaceVariant,
            ),
            if (label != null) ...[
              const SizedBox(height: 8),
              Text(
                label!,
                textAlign: TextAlign.center,
                style: context.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: child,
    );
  }
}

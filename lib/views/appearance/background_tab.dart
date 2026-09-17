import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/wallpaper.dart';
import 'package:reclash/widgets/wallpaper_scope.dart';
import 'package:reclash/widgets/widgets.dart';

class AppearanceBackgroundTab extends ConsumerWidget {
  const AppearanceBackgroundTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.appLocalizations;
    final settings = ref.watch(
      themeSettingProvider.select((value) => value.wallpaper),
    );
    final image = ref.watch(wallpaperImageProvider);
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
              items: [
                ClipRSuperellipse(
                  borderRadius: AppRadius.xl,
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: context.colorScheme.surface),
                        if (image.asData?.value case final image?)
                          WallpaperLayer(image: image, settings: settings),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: WallpaperSurfaceScope(
                              opacity: hasFile ? settings.cardOpacity : 1,
                              child: CommonCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.wallpaper_outlined),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        hasFile
                                            ? l10n.preview
                                            : l10n.wallpaperNoImage,
                                        style: context.textTheme.titleMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DecorationListItem(
                  leading: const Icon(Icons.add_photo_alternate_outlined),
                  title: Text(
                    hasFile ? l10n.wallpaperReplace : l10n.wallpaperChoose,
                  ),
                  subtitle: Text(l10n.wallpaperSelectHint),
                  onPressed: () => unawaited(
                    globalState.safeRun(
                      ref.read(wallpaperActionProvider.notifier).chooseImage,
                    ),
                  ),
                ),
                if (hasFile) ...[
                  if (!image.isLoading && image.asData?.value == null)
                    DecorationListItem(
                      leading: const Icon(Icons.broken_image_outlined),
                      title: Text(l10n.wallpaperMissing),
                    ),
                  DecorationListItem.toggle(
                    leading: const Icon(Icons.wallpaper),
                    title: Text(l10n.wallpaperEnabled),
                    subtitle: Text(l10n.wallpaperDescription),
                    value: settings.enabled,
                    onChanged: (value) =>
                        update((s) => s.copyWith(enabled: value)),
                  ),
                  DecorationListItem(
                    leading: const Icon(Icons.delete_outline),
                    title: Text(l10n.wallpaperRemove),
                    onPressed: () => unawaited(
                      globalState.safeRun(
                        ref.read(wallpaperActionProvider.notifier).removeImage,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (hasFile) ...[
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
                    leading: const Icon(Icons.restore),
                    title: Text(l10n.wallpaperReset),
                    onPressed: () => update(
                      (s) => WallpaperProps(
                        enabled: s.enabled,
                        fileName: s.fileName,
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

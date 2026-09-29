import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';

import 'color_sections.dart';

class AppearanceMotionTab extends ConsumerWidget {
  const AppearanceMotionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final systemReduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final motion = ref.watch(
      appSettingProvider.select(
        (state) => (
          isAnimateToPage: state.isAnimateToPage,
          reduceMotion: state.reduceMotion,
        ),
      ),
    );
    final milestones = ref.watch(milestoneSettingProvider);
    // The back-gesture animation is an Android transition, so it belongs with
    // the other motion controls rather than on the Theme tab.
    final predictiveBackSupported = system.supportsPredictiveBack(
      ref.watch(versionProvider),
    );
    final predictiveBack = ref.watch(
      themeSettingProvider.select((state) => state.predictiveBack),
    );
    return SettingsScrollView(
      slivers: [
        SettingSection.sliver(
          top: 12,
          title: appLocalizations.animations,
          glyph: AppGlyphs.motion,
          items: [
            DecorationListItem.toggle(
              leading: const GlyphIcon(AppGlyphs.motion),
              title: Text(appLocalizations.pageAnimation),
              subtitle: Text(appLocalizations.pageAnimationDesc),
              value: motion.isAnimateToPage,
              onChanged: (value) => ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(isAnimateToPage: value)),
            ),
            DecorationListItem.toggle(
              leading: const GlyphIcon(AppGlyphs.motion),
              title: Text(appLocalizations.reduceMotion),
              // ThemeManager already combines the OS flag with the setting,
              // so keep the user choice untouched and only surface the fact.
              subtitle: Text(
                systemReduced
                    ? appLocalizations.reduceMotionSystemHint
                    : appLocalizations.reduceMotionDesc,
              ),
              value: motion.reduceMotion,
              onChanged: (value) => ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(reduceMotion: value)),
            ),
            if (predictiveBackSupported)
              DecorationListItem.toggle(
                leading: const GlyphIcon(AppGlyphs.dragHandle),
                title: Text(appLocalizations.predictiveBack),
                value: predictiveBack,
                onChanged: (value) => ref
                    .read(themeSettingProvider.notifier)
                    .update((state) => state.copyWith(predictiveBack: value)),
              ),
          ],
        ),
        SettingSection.sliver(
          title: appLocalizations.appearance,
          glyph: AppGlyphs.sparkle,
          items: [
            DecorationListItem.toggle(
              leading: const GlyphIcon(AppGlyphs.snow),
              title: Text(appLocalizations.seasonalDecorations),
              subtitle: Text(appLocalizations.seasonalDecorationsDesc),
              value: milestones.seasonalEnabled,
              onChanged: (value) => ref
                  .read(milestoneSettingProvider.notifier)
                  .update((state) => state.copyWith(seasonalEnabled: value)),
            ),
            DecorationListItem.toggle(
              leading: const GlyphIcon(AppGlyphs.gradient),
              title: Text(appLocalizations.providerEffects),
              subtitle: Text(appLocalizations.providerEffectsDesc),
              value: milestones.providerEffectsEnabled,
              onChanged: (value) => ref
                  .read(milestoneSettingProvider.notifier)
                  .update(
                    (state) => state.copyWith(providerEffectsEnabled: value),
                  ),
            ),
            DecorationListItem.toggle(
              leading: const GlyphIcon(AppGlyphs.sparkle),
              title: Text(appLocalizations.milestoneDecorations),
              subtitle: Text(appLocalizations.milestoneDecorationsDesc),
              value: milestones.findingsEnabled,
              onChanged: (value) => ref
                  .read(milestoneSettingProvider.notifier)
                  .update((state) => state.copyWith(findingsEnabled: value)),
            ),
          ],
        ),
        const AppearanceIconSection(),
        const SettingBottomInset.sliver(),
      ],
    );
  }
}

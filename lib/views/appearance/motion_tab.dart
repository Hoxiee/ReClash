import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';

import 'color_sections.dart';
import 'theme_preview.dart';

class AppearanceMotionTab extends ConsumerWidget {
  const AppearanceMotionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final systemReduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final tabAnimation = ref.watch(
      appSettingProvider.select((state) => state.tabAnimation),
    );
    final reduceMotion = ref.watch(
      appSettingProvider.select((state) => state.reduceMotion),
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
    final colorScheme = context.colorScheme;
    Widget switching(TabAnimation value) => MiniScreenThumb(
      screen: MiniSwitchScreen(colorScheme: colorScheme, tabAnimation: value),
    );
    return SettingsScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: FadeSlideEnterBox(
            child: PreviewChoiceGroup<TabAnimation>(
              info: Info(
                search: const SettingSearch(),
                label: appLocalizations.tabAnimation,
                glyph: AppGlyphs.motion,
              ),
              value: tabAnimation,
              choices: [
                PreviewChoice(
                  value: TabAnimation.slide,
                  label: appLocalizations.slide,
                  pictogram: switching(TabAnimation.slide),
                ),
                PreviewChoice(
                  value: TabAnimation.fade,
                  label: appLocalizations.fade,
                  pictogram: switching(TabAnimation.fade),
                ),
                PreviewChoice(
                  value: TabAnimation.off,
                  label: appLocalizations.off,
                  pictogram: switching(TabAnimation.off),
                ),
              ],
              onChanged: (value) => ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(tabAnimation: value)),
            ),
          ),
        ),
        SettingSection.sliver(
          search: const SettingSearch(),
          title: appLocalizations.animations,
          glyph: AppGlyphs.motion,
          items: [
            DecorationListItem.toggle(
              leading: const GlyphIcon(AppGlyphs.motion),
              search: const SettingSearch(),
              title: Text(appLocalizations.reduceMotion),
              // ThemeManager already combines the OS flag with the setting,
              // so keep the user choice untouched and only surface the fact.
              subtitle: Text(
                systemReduced
                    ? appLocalizations.reduceMotionSystemHint
                    : appLocalizations.reduceMotionDesc,
              ),
              value: reduceMotion,
              onChanged: (value) => ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(reduceMotion: value)),
            ),
            if (predictiveBackSupported)
              DecorationListItem.toggle(
                leading: const GlyphIcon(AppGlyphs.dragHandle),
                search: const SettingSearch(),
                title: Text(appLocalizations.predictiveBack),
                value: predictiveBack,
                onChanged: (value) => ref
                    .read(themeSettingProvider.notifier)
                    .update((state) => state.copyWith(predictiveBack: value)),
              ),
          ],
        ),
        SettingSection.sliver(
          search: const SettingSearch(),
          title: appLocalizations.appearance,
          glyph: AppGlyphs.sparkle,
          items: [
            DecorationListItem.toggle(
              leading: const GlyphIcon(AppGlyphs.snow),
              search: const SettingSearch(),
              title: Text(appLocalizations.seasonalDecorations),
              subtitle: Text(appLocalizations.seasonalDecorationsDesc),
              value: milestones.seasonalEnabled,
              onChanged: (value) => ref
                  .read(milestoneSettingProvider.notifier)
                  .update((state) => state.copyWith(seasonalEnabled: value)),
            ),
            DecorationListItem.toggle(
              leading: const GlyphIcon(AppGlyphs.gradient),
              search: const SettingSearch(),
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
              search: const SettingSearch(),
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

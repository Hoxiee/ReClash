import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return CustomScrollView(
      primary: false,
      slivers: [
        SettingSection.sliver(
          top: 12,
          title: appLocalizations.animations,
          items: [
            DecorationListItem.toggle(
              leading: const Icon(Icons.animation),
              title: Text(appLocalizations.pageAnimation),
              subtitle: Text(appLocalizations.pageAnimationDesc),
              value: motion.isAnimateToPage,
              onChanged: (value) => ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(isAnimateToPage: value)),
            ),
            DecorationListItem.toggle(
              leading: const Icon(Icons.motion_photos_off),
              title: Text(appLocalizations.reduceMotion),
              // Флаг ОС уже складывается с настройкой в ThemeManager, поэтому
              // выбор пользователя не перезаписываем — только сообщаем факт.
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
          ],
        ),
        SettingSection.sliver(
          title: appLocalizations.appearance,
          items: [
            DecorationListItem.toggle(
              leading: const Icon(Icons.ac_unit),
              title: Text(appLocalizations.seasonalDecorations),
              subtitle: Text(appLocalizations.seasonalDecorationsDesc),
              value: milestones.seasonalEnabled,
              onChanged: (value) => ref
                  .read(milestoneSettingProvider.notifier)
                  .update((state) => state.copyWith(seasonalEnabled: value)),
            ),
            DecorationListItem.toggle(
              leading: const Icon(Icons.auto_awesome),
              title: Text(appLocalizations.milestoneDecorations),
              subtitle: Text(appLocalizations.milestoneDecorationsDesc),
              value: milestones.findingsEnabled,
              onChanged: (value) => ref
                  .read(milestoneSettingProvider.notifier)
                  .update((state) => state.copyWith(findingsEnabled: value)),
            ),
          ],
        ),
        const SettingBottomInset.sliver(),
      ],
    );
  }
}

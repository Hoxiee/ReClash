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
    return CustomScrollView(
      primary: false,
      slivers: [
        SettingSection.sliver(
          top: 12,
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
        const SettingBottomInset.sliver(),
      ],
    );
  }
}

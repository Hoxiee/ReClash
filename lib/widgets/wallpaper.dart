import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/ui/page_background.dart';
import 'package:reclash/widgets/wallpaper_backdrop.dart';

export 'package:reclash/widgets/wallpaper_backdrop.dart';

class AppWallpaperScope extends ConsumerWidget {
  const AppWallpaperScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(
      themeSettingProvider.select((value) => value.wallpaper),
    );
    final image = ref.watch(effectiveWallpaperImageProvider);
    return PageBackgroundRegistration(
      builder: (context, baseColor, content) => WallpaperBackdrop(
        image: image,
        settings: settings,
        baseColor: baseColor,
        builder: (_, _) => content,
      ),
      child: child,
    );
  }
}

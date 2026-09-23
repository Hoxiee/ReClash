import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/wallpaper.dart';

import 'wallpaper_scope.dart';

class AppWallpaper extends ConsumerWidget {
  const AppWallpaper({super.key, required this.builder});

  final Widget Function(BuildContext context, bool active) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(
      themeSettingProvider.select((value) => value.wallpaper),
    );
    final image = settings.enabled
        ? ref.watch(wallpaperImageProvider).asData?.value
        : null;
    final active = image != null;
    return WallpaperSurfaceScope(
      opacity: active ? settings.cardOpacity : 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Positioned.fill(
              child: WallpaperLayer(image: image, settings: settings),
            ),
          Builder(builder: (context) => builder(context, active)),
        ],
      ),
    );
  }
}

class WallpaperLayer extends StatelessWidget {
  const WallpaperLayer({
    super.key,
    required this.image,
    required this.settings,
  });

  final ImageProvider image;
  final WallpaperProps settings;

  @override
  Widget build(BuildContext context) {
    final alignment = Alignment(settings.positionX, settings.positionY);
    return RepaintBoundary(
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: ColoredBox(
            color: context.colorScheme.surface.withValues(alpha: 1),
            child: ClipRect(
              child: Opacity(
                opacity: settings.opacity,
                child: ImageFiltered(
                  enabled: settings.blur > 0,
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: settings.blur,
                    sigmaY: settings.blur,
                    tileMode: ui.TileMode.clamp,
                  ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: settings.dimming),
                      BlendMode.srcATop,
                    ),
                    child: Transform.scale(
                      scale: settings.scale,
                      alignment: alignment,
                      child: Image(
                        image: image,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: alignment,
                        fit: switch (settings.fit) {
                          WallpaperFit.cover => BoxFit.cover,
                          WallpaperFit.contain => BoxFit.contain,
                          WallpaperFit.fill => BoxFit.fill,
                        },
                        errorBuilder: (_, _, _) => const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

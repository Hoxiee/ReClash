import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../base/icon.dart';

class PanelProfileBackground extends ConsumerWidget {
  final Widget child;
  final bool enabled;

  const PanelProfileBackground({
    super.key,
    this.enabled = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = enabled ? ref.watch(panelBackgroundProvider) : null;
    if (background == null) {
      return child;
    }
    // The cover image fills the scaffold body, so it must be clipped to those
    // bounds; a rounded side-sheet host does not clip its child, and without
    // this the image bleeds past the panel edges. Mirrors AppWallpaper.
    return ClipRect(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            key: const ValueKey('panel-profile-background'),
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: ImageCacheWidget(
                  src: background.url,
                  fit: BoxFit.cover,
                  defaultWidget: ColoredBox(color: context.colorScheme.surface),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: context.colorScheme.surface.withValues(
                  alpha: 1 - background.opacity,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

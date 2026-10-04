import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/panel_appearance.dart';
import 'package:reclash/providers/providers.dart';

import '../base/icon.dart';

/// Switching profiles swaps the per-profile cover. The child (the scaffold
/// body) stays at a fixed position in a single stack so it is never reparented
/// and rebuilt, while only the cover layer crossfades between profiles.
const _panelFadeDuration = Duration(milliseconds: 360);

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
    // The cover image fills the scaffold body, so it must be clipped to those
    // bounds; a rounded side-sheet host does not clip its child, and without
    // this the image bleeds past the panel edges. Mirrors AppWallpaper.
    return ClipRect(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: AnimatedSwitcher(
                  duration: context.motionDuration(_panelFadeDuration),
                  child: background == null
                      ? const SizedBox.shrink(key: ValueKey('panel-none'))
                      : _PanelCover(
                          key: ValueKey('panel-${background.url}'),
                          background: background,
                        ),
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

class _PanelCover extends StatelessWidget {
  const _PanelCover({super.key, required this.background});

  final PanelBackground background;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          key: const ValueKey('panel-profile-background'),
          child: ImageCacheWidget(
            src: background.url,
            fit: BoxFit.cover,
            defaultWidget: ColoredBox(color: context.colorScheme.surface),
          ),
        ),
        Positioned.fill(
          child: ColoredBox(
            color: context.colorScheme.surface.withValues(
              alpha: 1 - background.opacity,
            ),
          ),
        ),
      ],
    );
  }
}

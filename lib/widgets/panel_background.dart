import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'icon.dart';

class PanelProfileBackground extends ConsumerWidget {
  final Widget child;

  const PanelProfileBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = ref.watch(panelBackgroundProvider);
    if (background == null) return child;
    return Stack(
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
    );
  }
}

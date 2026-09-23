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
    return Stack(
      fit: StackFit.passthrough,
      children: [
        if (background != null) ...[
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
        ],
        child,
      ],
    );
  }
}

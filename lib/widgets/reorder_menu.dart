import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

import 'popup.dart';

/// Dragging the handle reorders through the enclosing list; activating it with
/// keyboard, D-pad or tap opens a move menu, so no reorder needs a drag.
class ReorderMenuHandle extends StatelessWidget {
  const ReorderMenuHandle({
    super.key,
    required this.index,
    required this.count,
    required this.onReorder,
    this.delayedDrag = false,
    this.icon = Icons.drag_indicator_rounded,
    this.color,
  });

  final int index;
  final int count;

  /// Same `(oldIndex, newIndex)` convention as the list's own `onReorderItem`.
  final void Function(int oldIndex, int newIndex) onReorder;

  final bool delayedDrag;
  final IconData icon;
  final Color? color;

  bool get _canMoveUp => index > 0;
  bool get _canMoveDown => index < count - 1;

  List<CommonPopupMenuItem> _items(BuildContext context) {
    final l = context.appLocalizations;
    return [
      if (_canMoveUp)
        CommonPopupMenuItem(
          icon: Icons.keyboard_arrow_up_rounded,
          label: l.moveUp,
          onPressed: () => onReorder(index, index - 1),
        ),
      if (_canMoveDown)
        CommonPopupMenuItem(
          icon: Icons.keyboard_arrow_down_rounded,
          label: l.moveDown,
          onPressed: () => onReorder(index, index + 1),
        ),
      if (_canMoveUp)
        CommonPopupMenuItem(
          icon: Icons.vertical_align_top_rounded,
          label: l.moveToTop,
          onPressed: () => onReorder(index, 0),
        ),
      if (_canMoveDown)
        CommonPopupMenuItem(
          icon: Icons.vertical_align_bottom_rounded,
          label: l.moveToBottom,
          onPressed: () => onReorder(index, count - 1),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final handleColor = color ?? context.colorScheme.onSurfaceVariant;
    if (count <= 1) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: handleColor),
      );
    }
    return CommonPopupBox(
      popupBuilder: (_) => CommonPopupMenu(items: _items(context)),
      targetBuilder: (open) {
        final handle = IconButton(
          tooltip: l.notificationReorder,
          onPressed: () => open(),
          icon: Icon(icon, color: handleColor),
        );
        return delayedDrag
            ? ReorderableDelayedDragStartListener(index: index, child: handle)
            : ReorderableDragStartListener(index: index, child: handle);
      },
    );
  }
}

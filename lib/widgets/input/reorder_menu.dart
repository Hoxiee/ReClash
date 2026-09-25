import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

import '../layout/popup.dart';

/// Dragging the handle reorders through the enclosing list; activating it with
/// keyboard, D-pad or tap opens a move menu, so no reorder needs a drag.
class ReorderMenuHandle extends StatelessWidget {
  const ReorderMenuHandle({
    super.key,
    required this.index,
    required this.count,
    required this.onReorder,
    this.delayedDrag = false,
    this.icon = AppGlyphs.dragHandle,
    this.color,
    this.compact = false,
  });

  final int index;
  final int count;

  /// Same `(oldIndex, newIndex)` convention as the list's own `onReorderItem`.
  final void Function(int oldIndex, int newIndex) onReorder;

  final bool delayedDrag;
  final Glyph icon;
  final Color? color;

  /// Shrinks the tap target to fit a dense fixed-height row without overflow.
  final bool compact;

  bool get _canMoveUp => index > 0;
  bool get _canMoveDown => index < count - 1;

  List<CommonPopupMenuItem> _items(BuildContext context) {
    final l = context.appLocalizations;
    return [
      if (_canMoveUp)
        CommonPopupMenuItem(
          glyph: AppGlyphs.chevronUp,
          label: l.moveUp,
          onPressed: () => onReorder(index, index - 1),
        ),
      if (_canMoveDown)
        CommonPopupMenuItem(
          glyph: AppGlyphs.chevronDown,
          label: l.moveDown,
          onPressed: () => onReorder(index, index + 1),
        ),
      if (_canMoveUp)
        CommonPopupMenuItem(
          glyph: AppGlyphs.scrollToTop,
          label: l.moveToTop,
          onPressed: () => onReorder(index, 0),
        ),
      if (_canMoveDown)
        CommonPopupMenuItem(
          glyph: AppGlyphs.scrollToBottom,
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
        padding: EdgeInsets.all(compact ? 4 : 8),
        child: GlyphIcon(icon, color: handleColor),
      );
    }
    return CommonPopupBox(
      popupBuilder: (_) => CommonPopupMenu(items: _items(context)),
      targetBuilder: (open) {
        final handle = IconButton(
          tooltip: l.notificationReorder,
          onPressed: () => open(),
          visualDensity: compact ? VisualDensity.compact : null,
          padding: compact ? EdgeInsets.zero : null,
          constraints: compact
              ? const BoxConstraints(minWidth: 32, minHeight: 32)
              : null,
          style: compact
              ? IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )
              : null,
          icon: GlyphIcon(icon, color: handleColor),
        );
        return delayedDrag
            ? ReorderableDelayedDragStartListener(index: index, child: handle)
            : ReorderableDragStartListener(index: index, child: handle);
      },
    );
  }
}

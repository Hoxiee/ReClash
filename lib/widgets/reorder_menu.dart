import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

class ReorderMenuButton extends StatelessWidget {
  const ReorderMenuButton({super.key, this.onMoveUp, this.onMoveDown});

  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    if (onMoveUp == null && onMoveDown == null) {
      return const SizedBox.shrink();
    }
    return MenuAnchor(
      menuChildren: [
        if (onMoveUp != null)
          MenuItemButton(
            onPressed: onMoveUp,
            child: Text(appLocalizations.notificationMoveUp),
          ),
        if (onMoveDown != null)
          MenuItemButton(
            onPressed: onMoveDown,
            child: Text(appLocalizations.notificationMoveDown),
          ),
      ],
      builder: (context, controller, _) {
        return IconButton(
          tooltip: appLocalizations.notificationReorder,
          icon: const Icon(Icons.drag_indicator_rounded),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }
}

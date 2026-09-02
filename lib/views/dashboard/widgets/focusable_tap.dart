import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

class FocusableTap extends StatefulWidget {
  const FocusableTap({
    required this.onTap,
    required this.child,
    super.key,
    this.autofocus = false,
    this.borderRadius = 18,
  });

  final VoidCallback? onTap;
  final Widget child;
  final bool autofocus;
  final double borderRadius;

  @override
  State<FocusableTap> createState() => _FocusableTapState();
}

class _FocusableTapState extends State<FocusableTap> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return FocusableActionDetector(
      enabled: enabled,
      autofocus: widget.autofocus && enabled,
      onShowFocusHighlight: (value) {
        if (mounted && value != _focused) setState(() => _focused = value);
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius + 4),
          border: Border.all(
            color: _focused ? context.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
    );
  }
}

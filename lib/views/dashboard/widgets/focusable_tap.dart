import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

const _borderDuration = Duration(milliseconds: 150);

class FocusableTap extends StatefulWidget {
  const FocusableTap({
    required this.onTap,
    required this.child,
    super.key,
    this.onLongPress,
    this.autofocus = false,
    this.borderRadius = 18,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
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
      // A border in the layout would inset every tappable card by 2px.
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: widget.child,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: context.motionDuration(_borderDuration),
                curve: Easing.standard,
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius + 4,
                    ),
                    side: BorderSide(
                      color: _focused
                          ? context.colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

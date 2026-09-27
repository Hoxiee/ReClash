import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';

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
  bool _hovered = false;

  void _handleTap() {
    final onTap = widget.onTap;
    if (onTap == null) return;
    Feedback.forTap(context);
    onTap();
  }

  void _handleLongPress() {
    final onLongPress = widget.onLongPress;
    if (onLongPress == null) return;
    Feedback.forLongPress(context);
    onLongPress();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final colorScheme = context.colorScheme;
    final borderColor = _focused
        ? colorScheme.primary
        : _hovered
        ? colorScheme.primary.opacity60
        : Colors.transparent;
    return FocusableActionDetector(
      enabled: enabled,
      autofocus: widget.autofocus && enabled,
      mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (value) {
        if (mounted && value != _focused) setState(() => _focused = value);
      },
      onShowHoverHighlight: (value) {
        if (mounted && value != _hovered) setState(() => _hovered = value);
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _handleTap();
            return null;
          },
        ),
      },
      // A border in the layout would inset every tappable card by 2px.
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Match the tap feedback the Material-button cards emit; a bare
            // GestureDetector otherwise stays silent where InkWell would click.
            onTap: enabled ? _handleTap : null,
            onLongPress: widget.onLongPress == null ? null : _handleLongPress,
            child: widget.child,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: context.motionDuration(_borderDuration),
                curve: Easing.standard,
                decoration: ShapeDecoration(
                  color: _hovered
                      ? colorScheme.onSurface.withValues(alpha: 0.06)
                      : null,
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius + 4,
                    ),
                    side: BorderSide(color: borderColor, width: 2),
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

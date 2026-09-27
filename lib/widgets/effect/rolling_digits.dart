import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';

class RollingDigits extends StatelessWidget {
  const RollingDigits({
    super.key,
    required this.value,
    this.rolling = true,
    this.style,
  });

  final String value;
  final bool rolling;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? context.textTheme.bodySmall;
    final text = Text(value, key: ValueKey(value), style: baseStyle, maxLines: 1);
    if (!rolling || context.disableAnimations) {
      return text;
    }
    return Semantics(
      label: value,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Keyed from the right so a shorter/longer value keeps each digit
            // slot's identity and only the changed columns roll.
            for (var index = 0; index < value.length; index++)
              ClipRect(
                key: ValueKey(value.length - index),
                child: AnimatedSwitcher(
                  duration: context.motionDuration(
                    const Duration(milliseconds: 280),
                  ),
                  transitionBuilder: (child, animation) {
                    final offset =
                        Tween<Offset>(
                          begin: const Offset(0, 0.9),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        );
                    return SlideTransition(
                      position: offset,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    value[index],
                    key: ValueKey(value[index]),
                    style: baseStyle?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

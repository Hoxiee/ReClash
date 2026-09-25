import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../effect/fade_box.dart';
import 'text.dart';
import '../theme/wallpaper_scope.dart';

const commonCardIconSize = 20.0;

class Info {
  final String label;
  final Glyph? glyph;

  const Info({required this.label, this.glyph});
}

class InfoHeader extends StatelessWidget {
  final Info info;
  final List<Widget> actions;
  final EdgeInsets? padding;

  const InfoHeader({
    super.key,
    required this.info,
    this.padding,
    List<Widget>? actions,
  }) : actions = actions ?? const [];

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry nextPadding = (padding ?? baseInfoEdgeInsets);
    if (actions.isNotEmpty && nextPadding is EdgeInsets) {
      nextPadding = EdgeInsets.only(
        left: nextPadding.left,
        right: nextPadding.right,
        top: max(0, nextPadding.top - 8.mAp),
        bottom: max(0, nextPadding.bottom - 8.mAp),
      );
    }
    return Padding(
      padding: nextPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (info.glyph != null) ...[
                  GlyphIcon(
                    info.glyph!,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  flex: 1,
                  child: TooltipText(
                    text: Text(
                      info.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (actions.isNotEmpty)
            SizedBox(
              height: globalState.measure.titleSmallHeight + 16.ap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [...actions],
              ),
            ),
        ],
      ),
    );
  }
}

class CommonCard extends StatelessWidget {
  const CommonCard({
    super.key,
    bool? isSelected,
    this.type = CommonCardType.plain,
    this.onPressed,
    this.selectWidget,
    this.radius,
    this.padding,
    this.enterAnimated = false,
    this.info,
    this.infoPadding,
    this.infoActions,
    this.onLongPress,
    this.shape,
    this.isError = false,
    this.enterActionsOnRight = false,
    this.skipTraversal = false,
    required this.child,
  }) : isSelected = isSelected ?? false;

  final bool enterAnimated;
  final bool enterActionsOnRight;
  final bool skipTraversal;
  final bool isSelected;
  final bool isError;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final Widget? selectWidget;
  final Widget child;
  final EdgeInsets? padding;
  final Info? info;
  final EdgeInsets? infoPadding;
  final List<Widget>? infoActions;
  final CommonCardType type;
  final double? radius;
  final OutlinedBorder? shape;

  // Flutter keeps `focused` set after a mouse click; honor `:focus-visible`.
  Set<WidgetState> _effectiveStates(Set<WidgetState> states) {
    if (FocusHighlightVisibility.visible.value ||
        !states.contains(WidgetState.focused)) {
      return states;
    }
    return states.difference({WidgetState.focused});
  }

  BorderSide _buildBorderSide(BuildContext context, Set<WidgetState> states) {
    final colorScheme = context.colorScheme;
    final focused = states.contains(WidgetState.focused);
    if (isError) {
      if (type == CommonCardType.filled) {
        if (focused) {
          return BorderSide(color: colorScheme.error, width: 2);
        }
        return BorderSide(color: colorScheme.error);
      }
      final hoverColor = isSelected
          ? colorScheme.error.opacity80
          : colorScheme.error.opacity38;
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused) ||
          states.contains(WidgetState.pressed)) {
        return BorderSide(color: hoverColor);
      }
      return BorderSide(
        color: isSelected
            ? colorScheme.error.opacity60
            : colorScheme.error.opacity30,
      );
    }
    if (type == CommonCardType.filled) {
      if (focused && isSelected) {
        return BorderSide(color: colorScheme.primary);
      }
      return BorderSide.none;
    }
    final hoverColor = isSelected
        ? colorScheme.primary.opacity80
        : colorScheme.primary.opacity60;
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused) ||
        states.contains(WidgetState.pressed)) {
      return BorderSide(color: hoverColor);
    }
    return BorderSide(
      color: isSelected
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest,
    );
  }

  Color? _buildBackgroundColor(BuildContext context, Set<WidgetState> states) {
    final colorScheme = context.colorScheme;
    var color = switch (type) {
      CommonCardType.filled =>
        isSelected
            ? colorScheme.secondaryContainer.opacity80
            : colorScheme.surfaceContainerHigh,
      _ =>
        isSelected
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerLow,
    };
    if (states.contains(WidgetState.focused)) {
      color = Color.alphaBlend(
        colorScheme.primary.withValues(alpha: system.isTV ? 0.22 : 0.12),
        color,
      );
    }
    return WallpaperSurfaceScope.colorOf(context, color);
  }

  // The button paints its own focus overlay while it holds focus, so a mouse
  // click elsewhere leaves it stuck; resolve it through the focus-visible gate.
  Color? _buildOverlayColor(BuildContext context, Set<WidgetState> states) {
    final base =
        _buildForegroundColor(context) ?? context.colorScheme.onSurface;
    if (states.contains(WidgetState.pressed)) {
      return base.withValues(alpha: 0.1);
    }
    if (states.contains(WidgetState.hovered)) {
      return base.withValues(alpha: 0.08);
    }
    if (states.contains(WidgetState.focused)) {
      return base.withValues(alpha: 0.1);
    }
    return null;
  }

  Color? _buildForegroundColor(BuildContext context) {
    final colorScheme = context.colorScheme;
    if (isError) {
      return colorScheme.error;
    }
    if (type == CommonCardType.filled) {
      if (isSelected) {
        return colorScheme.onSecondaryContainer;
      }
      return colorScheme.onSurfaceVariant;
    }
    if (isSelected) {
      return colorScheme.onSecondaryContainer;
    }
    return colorScheme.onSurfaceVariant;
  }

  Color? _buildIconColor(BuildContext context) {
    final colorScheme = context.colorScheme;
    if (isError) {
      return colorScheme.error;
    }
    return colorScheme.primary;
  }

  Widget _buildButton(
    BuildContext context,
    Widget childWidget,
    FocusNode? focusNode,
  ) {
    return switch (type == CommonCardType.filled) {
      true => FilledButton(
        focusNode: focusNode,
        onLongPress: onLongPress,
        clipBehavior: Clip.antiAlias,
        style:
            FilledButton.styleFrom(
              padding: padding ?? EdgeInsets.zero,
              shape: shape ?? AppShape.all(radius ?? AppCorner.md),
              iconSize: commonCardIconSize,
              iconColor: _buildIconColor(context),
              foregroundColor: _buildForegroundColor(context),
              side: BorderSide.none,
              elevation: 0,
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    _buildBackgroundColor(context, _effectiveStates(states)),
              ),
              overlayColor: WidgetStateProperty.resolveWith(
                (states) =>
                    _buildOverlayColor(context, _effectiveStates(states)),
              ),
              side: WidgetStateProperty.resolveWith(
                (states) => _buildBorderSide(context, _effectiveStates(states)),
              ),
            ),
        onPressed: onPressed,
        child: childWidget,
      ),
      false => OutlinedButton(
        focusNode: focusNode,
        onLongPress: onLongPress,
        clipBehavior: Clip.antiAlias,
        style:
            OutlinedButton.styleFrom(
              padding: padding ?? EdgeInsets.zero,
              shape: shape ?? AppShape.all(radius ?? AppCorner.md),
              iconSize: commonCardIconSize,
              iconColor: _buildIconColor(context),
              foregroundColor: _buildForegroundColor(context),
              elevation: 0,
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    _buildBackgroundColor(context, _effectiveStates(states)),
              ),
              overlayColor: WidgetStateProperty.resolveWith(
                (states) =>
                    _buildOverlayColor(context, _effectiveStates(states)),
              ),
              side: WidgetStateProperty.resolveWith(
                (states) => _buildBorderSide(context, _effectiveStates(states)),
              ),
            ),
        onPressed: onPressed,
        child: childWidget,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    var childWidget = child;

    if (info != null) {
      childWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoHeader(
            padding: infoPadding ?? baseInfoEdgeInsets.copyWith(bottom: 0),
            info: info!,
            actions: infoActions,
          ),
          Flexible(flex: 1, child: child),
        ],
      );
    }

    if (selectWidget != null && isSelected) {
      final List<Widget> children = [];
      children.add(childWidget);
      children.add(Positioned.fill(child: selectWidget!));
      childWidget = Stack(children: children);
    }

    final card = ValueListenableBuilder(
      valueListenable: FocusHighlightVisibility.visible,
      builder: (context, _, _) {
        final button = skipTraversal
            ? _SkipTraversalScope(
                builder: (focusNode) =>
                    _buildButton(context, childWidget, focusNode),
              )
            : _buildButton(context, childWidget, null);
        if (!enterActionsOnRight) {
          return button;
        }
        return Focus(
          canRequestFocus: false,
          onKeyEvent: (_, event) {
            if (event is! KeyDownEvent ||
                event.logicalKey != LogicalKeyboardKey.arrowRight) {
              return KeyEventResult.ignored;
            }
            final focusNode = FocusManager.instance.primaryFocus;
            final context = focusNode?.context;
            if (focusNode == null ||
                context == null ||
                context.findAncestorWidgetOfExactType<IconButton>() != null) {
              return KeyEventResult.ignored;
            }
            return focusNode.nextFocus()
                ? KeyEventResult.handled
                : KeyEventResult.ignored;
          },
          child: button,
        );
      },
    );

    return switch (enterAnimated) {
      true => FadeScaleEnterBox(child: card),
      false => card,
    };
  }
}

class _SkipTraversalFocusNode extends FocusNode {
  @override
  bool get skipTraversal => true;
}

class _SkipTraversalScope extends StatefulWidget {
  const _SkipTraversalScope({required this.builder});

  final Widget Function(FocusNode focusNode) builder;

  @override
  State<_SkipTraversalScope> createState() => _SkipTraversalScopeState();
}

class _SkipTraversalScopeState extends State<_SkipTraversalScope> {
  final FocusNode _focusNode = _SkipTraversalFocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_focusNode);
  }
}

class SelectIcon extends StatelessWidget {
  const SelectIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.inversePrimary,
      shape: AppShape.circle,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: const GlyphIcon(AppGlyphs.check, size: 16),
      ),
    );
  }
}

class SettingsBlock extends StatelessWidget {
  final String title;
  final List<Widget> settings;

  const SettingsBlock({super.key, required this.title, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          InfoHeader(info: Info(label: title)),
          Card(
            color: context.colorScheme.surfaceContainer,
            child: Column(children: settings),
          ),
        ],
      ),
    );
  }
}

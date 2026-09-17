import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';

class TvFocusOutline extends StatefulWidget {
  const TvFocusOutline({super.key, required this.child});

  final Widget child;

  @override
  State<TvFocusOutline> createState() => _TvFocusOutlineState();
}

class _TvFocusOutlineState extends State<TvFocusOutline> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    if (!system.isTV) return widget.child;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (value) => setState(() => _focused = value),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(
          shape: AppShape.md.copyWith(
            side: BorderSide(
              color: _focused
                  ? context.colorScheme.onSurface
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

class PageFocusScope extends StatefulWidget {
  final Widget child;
  final bool autofocus;

  const PageFocusScope({
    super.key,
    this.autofocus = false,
    required this.child,
  });

  @override
  State<PageFocusScope> createState() => _PageFocusScopeState();
}

class _PageFocusScopeState extends State<PageFocusScope> {
  final FocusScopeNode _node = FocusScopeNode()
    ..traversalEdgeBehavior = TraversalEdgeBehavior.parentScope
    ..directionalTraversalEdgeBehavior = TraversalEdgeBehavior.parentScope;

  @override
  void initState() {
    super.initState();
    _autofocus();
  }

  @override
  void didUpdateWidget(covariant PageFocusScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.autofocus && widget.autofocus) _autofocus();
  }

  void _autofocus() {
    if (!widget.autofocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.autofocus) return;
      FocusTraversalGroup.of(
        context,
      ).findFirstFocus(_node, ignoreCurrentFocus: true)?.requestFocus();
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope.withExternalFocusNode(
      focusScopeNode: _node,
      child: widget.child,
    );
  }
}

class FocusedScrollView extends StatefulWidget {
  const FocusedScrollView({
    super.key,
    required this.controller,
    required this.child,
    this.alignmentPolicy = ScrollPositionAlignmentPolicy.explicit,
    this.alignment = 0.5,
  });

  final ScrollController controller;
  final ScrollPositionAlignmentPolicy alignmentPolicy;
  final double alignment;
  final Widget child;

  @override
  State<FocusedScrollView> createState() => _FocusedScrollViewState();
}

class _FocusedScrollViewState extends State<FocusedScrollView> {
  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_revealPrimaryFocus);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_revealPrimaryFocus);
    super.dispose();
  }

  void _revealPrimaryFocus() {
    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext == null || !focusContext.mounted) return;
    final scrollContext = context;
    var isInside = false;
    focusContext.visitAncestorElements((element) {
      if (element == scrollContext) {
        isInside = true;
        return false;
      }
      return true;
    });
    if (!isInside) return;
    final focusRenderObject = focusContext.findRenderObject();
    if (focusRenderObject == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !widget.controller.hasClients ||
          !focusRenderObject.attached ||
          FocusManager.instance.primaryFocus?.context != focusContext) {
        return;
      }
      unawaited(
        widget.controller.position.ensureVisible(
          focusRenderObject,
          alignment: widget.alignment,
          alignmentPolicy: widget.alignmentPolicy,
          duration: const Duration(milliseconds: 140),
          curve: Easing.standardDecelerate,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class PageTraversalPolicy extends ReadingOrderTraversalPolicy {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final scope = currentNode.nearestScope;
    if (super.inDirection(currentNode, direction)) {
      return true;
    }

    final parent = scope?.enclosingScope;
    if (parent == null || parent == FocusManager.instance.rootScope) {
      return false;
    }
    return switch (direction) {
      TraversalDirection.down || TraversalDirection.right => parent.nextFocus(),
      TraversalDirection.up ||
      TraversalDirection.left => parent.previousFocus(),
    };
  }
}

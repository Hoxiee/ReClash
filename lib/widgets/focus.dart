import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';

class TvFocusOutline extends StatefulWidget {
  const TvFocusOutline({
    super.key,
    this.shape = AppShape.md,
    this.color,
    this.enabled = true,
    required this.child,
  }) : builder = null;

  const TvFocusOutline.builder({
    super.key,
    this.shape = AppShape.md,
    this.color,
    this.enabled = true,
    required this.builder,
  }) : child = null;

  final Widget? child;
  final Widget Function(FocusNode focusNode)? builder;
  final OutlinedBorder shape;
  final Color? color;
  final bool enabled;

  @override
  State<TvFocusOutline> createState() => _TvFocusOutlineState();
}

class _TvFocusOutlineState extends State<TvFocusOutline> {
  late final FocusNode _node = FocusNode(
    canRequestFocus: widget.builder != null,
    skipTraversal: widget.builder == null,
  );
  bool _highlighted = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(_updateHighlight);
    FocusHighlightVisibility.visible.addListener(_updateHighlight);
  }

  void _updateHighlight() {
    final focused = widget.builder == null
        ? _node.hasFocus
        : _node.hasPrimaryFocus;
    final highlighted = focused && FocusHighlightVisibility.visible.value;
    if (mounted && highlighted != _highlighted) {
      setState(() => _highlighted = highlighted);
    }
  }

  @override
  void dispose() {
    FocusHighlightVisibility.visible.removeListener(_updateHighlight);
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child =
        widget.builder?.call(_node) ??
        Focus.withExternalFocusNode(focusNode: _node, child: widget.child!);
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: ShapeDecoration(
        shape: widget.shape.copyWith(
          side: BorderSide(
            color: widget.enabled && _highlighted
                ? widget.color ?? context.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: child,
    );
  }
}

class DirectionalSlider extends StatelessWidget {
  const DirectionalSlider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TvFocusOutline(
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(navigationMode: NavigationMode.directional),
        child: child,
      ),
    );
  }
}

class FocusTraversalPage<T> extends Page<T> {
  const FocusTraversalPage({super.key, required this.child});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => _FocusTraversalRoute<T>(this);
}

class _FocusTraversalRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _FocusTraversalRoute(FocusTraversalPage<T> page)
    : super(
        settings: page,
        directionalTraversalEdgeBehavior: TraversalEdgeBehavior.parentScope,
      );

  @override
  bool get maintainState => true;

  @override
  Widget buildContent(BuildContext context) =>
      (settings as FocusTraversalPage<T>).child;
}

class PageFocusScope extends StatefulWidget {
  final Widget child;
  final bool autofocus;
  final TraversalEdgeBehavior directionalTraversalEdgeBehavior;

  const PageFocusScope({
    super.key,
    this.autofocus = false,
    this.directionalTraversalEdgeBehavior = TraversalEdgeBehavior.parentScope,
    required this.child,
  });

  @override
  State<PageFocusScope> createState() => _PageFocusScopeState();
}

class _PageFocusScopeState extends State<PageFocusScope> {
  late final FocusScopeNode _node = FocusScopeNode(
    traversalEdgeBehavior: TraversalEdgeBehavior.parentScope,
    directionalTraversalEdgeBehavior: widget.directionalTraversalEdgeBehavior,
  );

  @override
  void initState() {
    super.initState();
    _autofocus();
  }

  @override
  void didUpdateWidget(covariant PageFocusScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _node.directionalTraversalEdgeBehavior =
        widget.directionalTraversalEdgeBehavior;
    if (!oldWidget.autofocus && widget.autofocus) _autofocus();
  }

  void _autofocus() {
    if (!widget.autofocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.autofocus) return;
      final target = FocusTraversalGroup.of(context).findFirstFocus(_node);
      if (target != null) {
        FocusTraversalPolicy.defaultTraversalRequestFocusCallback(target);
      }
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

/// Page-style initial focus for a modal: the deferred frame lets an inner
/// autofocus win, and requestFocus (no ensureVisible) keeps a picker's scroll.
class ModalFocusScope extends StatefulWidget {
  const ModalFocusScope({super.key, required this.child});

  final Widget child;

  @override
  State<ModalFocusScope> createState() => _ModalFocusScopeState();
}

class _ModalFocusScopeState extends State<ModalFocusScope> {
  late final FocusScopeNode _node = FocusScopeNode(
    traversalEdgeBehavior: TraversalEdgeBehavior.parentScope,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_settleFocus);
  }

  Future<void> _settleFocus(Duration _) async {
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted || _node.focusedChild != null) return;
    FocusTraversalGroup.of(context).findFirstFocus(_node)?.requestFocus();
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: PageTraversalPolicy(),
      child: FocusScope.withExternalFocusNode(
        focusScopeNode: _node,
        child: widget.child,
      ),
    );
  }
}

class FocusedScrollView extends StatefulWidget {
  const FocusedScrollView({
    super.key,
    required this.controller,
    required this.child,
    this.alignmentPolicy = ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
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
    var isInside = false;
    focusContext.visitAncestorElements((element) {
      if (element == context) {
        isInside = true;
        return false;
      }
      return true;
    });
    if (!isInside) return;
    final target = focusContext.findRenderObject();
    if (target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !widget.controller.hasClients ||
          !target.attached ||
          FocusManager.instance.primaryFocus?.context != focusContext) {
        return;
      }
      final position = widget.controller.position;
      var policy = widget.alignmentPolicy;
      if (policy != ScrollPositionAlignmentPolicy.explicit) {
        final viewport = RenderAbstractViewport.maybeOf(target);
        if (viewport == null) return;
        final start = viewport.getOffsetToReveal(target, 0).offset;
        final end = viewport.getOffsetToReveal(target, 1).offset;
        if (start < position.pixels) {
          policy = ScrollPositionAlignmentPolicy.keepVisibleAtStart;
        } else if (end > position.pixels) {
          policy = ScrollPositionAlignmentPolicy.keepVisibleAtEnd;
        } else {
          return;
        }
      }
      unawaited(
        position.ensureVisible(
          target,
          alignment: widget.alignment,
          alignmentPolicy: policy,
          duration: context.motionDuration(const Duration(milliseconds: 140)),
          curve: Easing.standardDecelerate,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class PageTraversalPolicy extends ReadingOrderTraversalPolicy {}

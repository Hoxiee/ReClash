import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';

class AppTooltip extends StatefulWidget {
  const AppTooltip({
    super.key,
    required this.message,
    this.preferBelow = false,
    this.triggerMode = TooltipTriggerMode.longPress,
    this.hoverDelayScale = 1,
    required this.child,
  });

  final String? message;
  final bool preferBelow;
  final TooltipTriggerMode triggerMode;

  /// Scales the hover delay for this tooltip only, leaving the shared
  /// [AppTooltipTiming] untouched. 2 waits twice as long before showing.
  final double hoverDelayScale;
  final Widget child;

  @override
  State<AppTooltip> createState() => _AppTooltipState();
}

class _AppTooltipState extends State<AppTooltip>
    with SingleTickerProviderStateMixin {
  static final _session = _TooltipSession();

  final _tooltipKey = GlobalKey<RawTooltipState>();
  late final _entry = AnimationController(vsync: this);
  late final _entrance = CurvedAnimation(
    parent: _entry,
    curve: Curves.easeOutCubic,
  );
  Animation<double>? _nativeAnimation;
  ScrollPosition? _scrollPosition;
  Timer? _wait;
  bool _enabled = true;
  bool _hovered = false;
  bool _focused = false;

  bool get _keyboardFocused =>
      _focused && FocusHighlightVisibility.visible.value;

  @override
  void initState() {
    super.initState();
    _session.attach(this);
    FocusHighlightVisibility.visible.addListener(_updateFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _entry.duration = context.motionDuration(AppTooltipTiming.enterAnimation);
    _enabled =
        TooltipVisibility.of(context) &&
        (ModalRoute.isCurrentOf(context) ?? true);
    if (!_enabled) _session.cancel(this);
    final position = Scrollable.maybeOf(context)?.position;
    if (_scrollPosition != position) {
      _scrollPosition?.isScrollingNotifier.removeListener(_handleScroll);
      _scrollPosition = position;
      position?.isScrollingNotifier.addListener(_handleScroll);
    }
  }

  @override
  void didUpdateWidget(covariant AppTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message?.isEmpty ?? true) _session.cancel(this);
  }

  void _handleScroll() {
    if (_scrollPosition?.isScrollingNotifier.value ?? false) {
      _session.interrupt();
    }
  }

  void _request({bool keyboard = false}) {
    if (!_enabled || (widget.message?.isEmpty ?? true)) return;
    if (!keyboard && !_session.allowHover) return;
    if (_session.pending == this || _session.active == this) return;
    if (!_session.claim(this)) return;
    _entry.reset();
    final hoverDelay = widget.hoverDelayScale == 1
        ? _session.hoverDelay
        : _session.hoverDelay * widget.hoverDelayScale;
    _wait = Timer(keyboard ? AppTooltipTiming.wait : hoverDelay, () {
      _wait = null;
      if (_enabled && (_hovered || _keyboardFocused)) _show();
    });
  }

  void _show({bool fromTouch = false}) {
    if (!_enabled) return;
    _wait?.cancel();
    _wait = null;
    _session.activate(this);
    if (!fromTouch) _tooltipKey.currentState?.ensureTooltipVisible();
    _entry.forward(from: 0);
  }

  void _cancelPresentation() {
    _wait?.cancel();
    _wait = null;
    _entry.reset();
  }

  void _enter(PointerEnterEvent event) {
    _hovered = true;
    _request();
  }

  void _hover(PointerHoverEvent event) {
    _session.allowHover = true;
    _request();
  }

  void _exit(PointerExitEvent event) {
    _hovered = false;
    if (_keyboardFocused) {
      scheduleMicrotask(() {
        if (mounted && _keyboardFocused && _session.active == this) {
          _tooltipKey.currentState?.ensureTooltipVisible();
        }
      });
    } else if (_session.pending == this) {
      _session.cancel(this);
    }
  }

  void _updateFocus() {
    if (_keyboardFocused) {
      _request(keyboard: true);
    } else if (!_hovered) {
      _session.cancel(this);
    }
  }

  void _nativeStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) _session.release(this);
  }

  Widget _buildTooltip(BuildContext context, Animation<double> animation) {
    if (_nativeAnimation != animation) {
      _nativeAnimation?.removeStatusListener(_nativeStatusChanged);
      _nativeAnimation = animation..addStatusListener(_nativeStatusChanged);
    }
    final defaults = appTooltipTheme(Theme.of(context));
    final theme = TooltipTheme.of(context);
    final surface = Padding(
      padding: AppInsets.sm,
      child: ConstrainedBox(
        constraints: theme.constraints ?? defaults.constraints!,
        child: DecoratedBox(
          decoration: theme.decoration ?? defaults.decoration!,
          child: Padding(
            padding: theme.padding ?? defaults.padding!,
            child: Text(
              widget.message!,
              style: theme.textStyle ?? defaults.textStyle,
              textAlign: theme.textAlign ?? TextAlign.start,
              softWrap: true,
            ),
          ),
        ),
      ),
    );
    return AnimatedBuilder(
      animation: Listenable.merge([animation, _entrance]),
      child: surface,
      builder: (context, child) {
        if (_entry.isDismissed) return const SizedBox.shrink();
        return Opacity(
          opacity: math.min(animation.value, _entrance.value),
          child: Transform.translate(
            offset: Offset(0, (1 - _entrance.value) * 3),
            child: child,
          ),
        );
      },
    );
  }

  Offset _position(TooltipPositionContext context) => positionDependentBox(
    size: context.overlaySize,
    childSize: context.tooltipSize,
    target: context.target,
    verticalOffset: context.targetSize.height / 2,
    preferBelow: widget.preferBelow,
    margin: AppSpacing.sm,
  );

  @override
  Widget build(BuildContext context) {
    if (!TooltipVisibility.of(context) || (widget.message?.isEmpty ?? true)) {
      return widget.child;
    }
    return MouseRegion(
      onEnter: _enter,
      onHover: _hover,
      onExit: _exit,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (focused) {
          _focused = focused;
          _updateFocus();
        },
        child: RawTooltip(
          key: _tooltipKey,
          semanticsTooltip: widget.message,
          tooltipBuilder: _buildTooltip,
          positionDelegate: _position,
          triggerMode: widget.triggerMode,
          onTriggered: () => _show(fromTouch: true),
          touchDelay: AppTooltipTiming.touch,
          dismissDelay: AppTooltipTiming.exit,
          animationStyle: AnimationStyle(
            duration: Duration.zero,
            reverseDuration: context.motionDuration(
              AppTooltipTiming.exitAnimation,
            ),
            curve: Curves.easeOutCubic,
          ),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _wait?.cancel();
    _scrollPosition?.isScrollingNotifier.removeListener(_handleScroll);
    FocusHighlightVisibility.visible.removeListener(_updateFocus);
    _nativeAnimation?.removeStatusListener(_nativeStatusChanged);
    _session.detach(this);
    _entrance.dispose();
    _entry.dispose();
    super.dispose();
  }
}

class _TooltipSession with WidgetsBindingObserver {
  final _members = <_AppTooltipState>{};
  _AppTooltipState? pending;
  _AppTooltipState? active;
  Timer? _cooldown;
  bool _warm = false;
  bool allowHover = true;

  Duration get hoverDelay => active != null || _warm
      ? AppTooltipTiming.adjacent
      : AppTooltipTiming.wait;

  void attach(_AppTooltipState tooltip) {
    if (_members.isEmpty) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_pointer);
      FocusManager.instance.addEarlyKeyEventHandler(_key);
      WidgetsBinding.instance.addObserver(this);
    }
    _members.add(tooltip);
  }

  void detach(_AppTooltipState tooltip) {
    if (pending == tooltip) pending = null;
    if (active == tooltip) active = null;
    _members.remove(tooltip);
    if (_members.isEmpty) {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_pointer);
      FocusManager.instance.removeEarlyKeyEventHandler(_key);
      WidgetsBinding.instance.removeObserver(this);
      _cooldown?.cancel();
      _cooldown = null;
      _warm = false;
      allowHover = true;
    }
  }

  bool claim(_AppTooltipState tooltip) {
    final previous = pending ?? active;
    if (previous != null && previous != tooltip) {
      var ancestor = false;
      previous.context.visitAncestorElements((element) {
        ancestor = element == tooltip.context;
        return !ancestor;
      });
      if (ancestor && previous._hovered) return false;
    }
    pending?._cancelPresentation();
    pending = tooltip;
    return true;
  }

  void activate(_AppTooltipState tooltip) {
    if (pending != tooltip) pending?._cancelPresentation();
    pending = null;
    if (active != tooltip) active?._cancelPresentation();
    RawTooltip.dismissAllToolTips();
    active = tooltip;
  }

  void release(_AppTooltipState tooltip) {
    if (active != tooltip) return;
    active = null;
    _warm = true;
    _cooldown?.cancel();
    _cooldown = Timer(AppTooltipTiming.warm, () => _warm = false);
  }

  void cancel(_AppTooltipState tooltip) {
    if (pending == tooltip) pending = null;
    tooltip._cancelPresentation();
    if (active == tooltip) {
      release(tooltip);
      RawTooltip.dismissAllToolTips();
    }
  }

  void interrupt() {
    pending?._cancelPresentation();
    active?._cancelPresentation();
    pending = null;
    active = null;
    _cooldown?.cancel();
    _cooldown = null;
    _warm = false;
    allowHover = false;
    RawTooltip.dismissAllToolTips();
  }

  void _pointer(PointerEvent event) {
    if (event is PointerDownEvent ||
        event is PointerSignalEvent ||
        event is PointerPanZoomStartEvent) {
      interrupt();
    }
  }

  KeyEventResult _key(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape &&
        (pending != null || active != null)) {
      interrupt();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      interrupt();
    }
    return KeyEventResult.ignored;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) interrupt();
  }
}

Widget _withAppTooltip(Widget child, String? message) {
  if (message == null || message.isEmpty) return child;
  return MergeSemantics(
    child: AppTooltip(
      message: message,
      child: TooltipVisibility(visible: false, child: child),
    ),
  );
}

extension AppIconButtonTooltip on IconButton {
  Widget withAppTooltip() => _withAppTooltip(this, tooltip);
}

extension AppFloatingActionButtonTooltip on FloatingActionButton {
  Widget withAppTooltip() => _withAppTooltip(this, tooltip);
}

extension AppBackButtonTooltip on BackButton {
  Widget withAppTooltip(String message) => _withAppTooltip(this, message);
}

extension AppCloseButtonTooltip on CloseButton {
  Widget withAppTooltip(String message) => _withAppTooltip(this, message);
}

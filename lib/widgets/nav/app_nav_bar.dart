import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/feedback/tooltip.dart';
import 'package:reclash/widgets/nav/nav_motion.dart';
import 'package:reclash/widgets/nav/nav_slots.dart';

const double _barHeight = 64;
const double _barPadding = 4;
const double _edgeMargin = 20;
const double _shadowRoom = 8;
const double _fabGap = 8;
const double _maxItemExtent = 72;
const double _iconSize = 24;
const double _trailingIconSize = 28;
const double _labelGap = 2;
const double _labelInset = 2;
const double _labelSize = 10;
const double _minLabelSize = 9;
const double _pressGrowth = 1 / 8;
const double _maxPressGrowth = 16;
const double _lensGrowth = 14;
const double _lensMagnify = 0.12;
const double _hoverMagnet = 0.2;
const double _hoverParallax = 0.5;
const double _hoverAlpha = 0.08;
const double _hoverSwell = 0.4;
const double _jellySpeed = 8;
const double _jellyStretch = 0.25;
const double _overdrag = 0.35;
const double _pullLimit = 7 / 32;
const double _pullStretch = 0.5;
const _slotDuration = Duration(milliseconds: 500);
const _slotExitDuration = Duration(milliseconds: 220);
const double _slotEnterScale = 0.5;
const double _slotExitScale = 0.7;
const double _slotBlur = 6;
const _slotRevealCurve = Interval(0, 0.5, curve: Curves.easeOut);
// No bounce: an overshoot would drive the slot's width below zero.
final _slotSizeCurve = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 420),
  ),
  seconds: 0.5,
);
final _slotPopCurve = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 400),
    bounce: 0.3,
  ),
  seconds: 0.5,
);
final _trackSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 120),
);
final _liftSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 280),
  bounce: 0.2,
);
final _settleSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 500),
  bounce: 0.32,
);
final _hoverSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 260),
  bounce: 0.18,
);
final _fadeSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 200),
);

// A destination's share of the bar as it enters or leaves. No bounce: an
// overshoot would drive the slot's width below zero.
final _slotWeightSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 420),
);

// A soft, wide drop in the manner of iOS rather than a Material elevation.
List<BoxShadow> _dockShadows(ColorScheme colorScheme) {
  final strength = colorScheme.brightness == Brightness.dark ? 3.0 : 1.0;
  return [
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.08 * strength),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.04 * strength),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];
}

({double width, double height}) _measureLabel(
  BuildContext context,
  String label,
  TextStyle? style,
) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textScaler: MediaQuery.textScalerOf(context),
    textDirection: Directionality.of(context),
    maxLines: 1,
  )..layout();
  final size = (width: painter.width, height: painter.height);
  painter.dispose();
  return size;
}

class NavBarDestination {
  const NavBarDestination({
    required this.id,
    required this.glyph,
    required this.label,
  });

  /// A stable identity that outlives label text, so a slot keeps animating
  /// across a locale change instead of leaving and re-entering.
  final Object id;
  final Glyph glyph;
  final String label;
}

typedef OnToPage = void Function(PageLabel label);

class AppNavBar extends ConsumerWidget {
  const AppNavBar({super.key, this.onToPage, this.trailing});

  final OnToPage? onToPage;

  /// A button held at the dock's trailing edge, such as the start control that
  /// replaces the floating action button on a phone.
  final Widget? trailing;

  static const Key highlightKey = Key('nav-bar-highlight');

  /// Whether [context] sits in the dock's trailing slot, where a button keeps
  /// to a circle the bar's height instead of spreading into a labelled pill.
  static bool isDocked(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DockedMarker>() != null;

  static double heightOf(BuildContext context) {
    return _barHeight +
        MediaQuery.textScalerOf(context).scale(_labelSize) -
        _labelSize;
  }

  static double _bottomMarginOf(BuildContext context) =>
      math.max(_edgeMargin, MediaQuery.paddingOf(context).bottom);

  /// The room content scrolling under the dock leaves at its foot.
  static double insetOf(BuildContext context) =>
      heightOf(context) + _bottomMarginOf(context);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(currentNavigationItemsStateProvider).value;
    if (items.length < 2) {
      return const SizedBox.shrink();
    }
    final currentLabel = ref.watch(currentPageLabelProvider);
    final index = items.indexWhere((item) => item.label == currentLabel);
    final notifier = ref.read(currentPageLabelProvider.notifier);
    void handleSelected(int selected) {
      final label = items[selected].label;
      final onToPage = this.onToPage;
      if (onToPage != null) {
        onToPage(label);
      } else {
        notifier.toPage(label);
      }
    }

    final height = heightOf(context);
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _edgeMargin,
          _shadowRoom,
          _edgeMargin,
          _bottomMarginOf(context),
        ),
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: FloatingNavigationBar(
                  lensKey: highlightKey,
                  selectedIndex: index < 0 ? 0 : index,
                  onSelected: handleSelected,
                  destinations: [
                    for (final item in items)
                      NavBarDestination(
                        id: item.label,
                        glyph: item.glyph,
                        label: item.label.label,
                      ),
                  ],
                ),
              ),
              _DockTrailing(height: height, child: trailing),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockedMarker extends InheritedWidget {
  const _DockedMarker({required super.child});

  @override
  bool updateShouldNotify(_DockedMarker oldWidget) => false;
}

class _DockTrailing extends StatelessWidget {
  const _DockTrailing({required this.height, required this.child});

  final double height;
  final Widget? child;

  ThemeData _dockedTheme(ThemeData theme) {
    return theme.copyWith(
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        shape: AppShape.full,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        sizeConstraints: BoxConstraints.tightFor(width: height, height: height),
        iconSize: _trailingIconSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = this.child;
    return AnimatedSize(
      duration: _slotDuration,
      curve: _slotSizeCurve,
      alignment: AlignmentDirectional.centerEnd,
      clipBehavior: Clip.none,
      child: AnimatedSwitcher(
        duration: _slotDuration,
        reverseDuration: _slotExitDuration,
        transitionBuilder: (child, animation) =>
            _SlotMaterialize(animation: animation, child: child),
        // A leaving button takes no width, so the bar grows into its place
        // while it dissolves instead of waiting for it.
        layoutBuilder: (current, previous) => Stack(
          alignment: AlignmentDirectional.centerEnd,
          clipBehavior: Clip.none,
          children: [
            for (final child in previous)
              SizedBox(
                width: 0,
                child: OverflowBox(
                  alignment: AlignmentDirectional.centerEnd,
                  maxWidth: double.infinity,
                  child: IgnorePointer(child: child),
                ),
              ),
            ?current,
          ],
        ),
        child: child == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsetsDirectional.only(start: _fabGap),
                child: ElasticButton(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: AppShape.full,
                      shadows: _dockShadows(theme.colorScheme),
                    ),
                    child: Builder(
                      builder: (context) => Theme(
                        data: _dockedTheme(Theme.of(context)),
                        child: _DockedMarker(child: child),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SlotMaterialize extends StatelessWidget {
  const _SlotMaterialize({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final entering = animation.status != AnimationStatus.reverse;
        final scale = entering
            ? lerpDouble(_slotEnterScale, 1, _slotPopCurve.transform(t))!
            : lerpDouble(_slotExitScale, 1, Curves.easeOutCubic.transform(t))!;
        final reveal = entering
            ? _slotRevealCurve.transform(t)
            : Curves.easeOut.transform(t);
        final blur = _slotBlur * (1 - reveal);
        return Opacity(
          opacity: reveal,
          child: Transform.scale(
            scale: scale,
            child: ImageFiltered(
              enabled: blur > 0.05,
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Grows under a press and stretches after a dragging finger, springing back
/// on release, as the bar's lens does.
///
/// The press only paints: layout, hit testing, and anything anchored to the
/// child, such as a popup menu or a tooltip, see it at rest.
class ElasticPress extends StatefulWidget {
  const ElasticPress({
    super.key,
    this.enabled = true,
    this.strength = 1,
    required this.child,
  });

  /// Leaves a press on the button inside to the swell alone.
  static const buttonStyle = ButtonStyle(
    splashFactory: NoSplash.splashFactory,
    overlayColor: WidgetStateMapper<Color?>({
      WidgetState.pressed: Colors.transparent,
    }),
  );

  final bool enabled;

  /// Scales the whole visual response (swell, stretch, finger-follow). 1 is the
  /// default feel; a smaller value keeps the interaction but softens the motion.
  final double strength;
  final Widget child;

  @override
  State<ElasticPress> createState() => _ElasticPressState();
}

class _ElasticPressState extends State<ElasticPress>
    with TickerProviderStateMixin {
  late final NavSpring _lift = NavSpring(this, 0);
  late final NavSpring _pullX = NavSpring(this, 0);
  late final NavSpring _pullY = NavSpring(this, 0);
  late final Listenable _motion = Listenable.merge([_lift, _pullX, _pullY]);
  int? _pointer;
  Offset _origin = Offset.zero;

  @override
  void dispose() {
    _lift.dispose();
    _pullX.dispose();
    _pullY.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled ||
        _pointer != null ||
        event.buttons & kPrimaryButton == 0) {
      return;
    }
    _pointer = event.pointer;
    _origin = event.localPosition;
    _lift.springTo(1, _liftSpring);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    final limit = context.size!.shortestSide * _pullLimit;
    final pull = event.localPosition - _origin;
    _pullX.springTo(navRubberBand(pull.dx, limit), _trackSpring);
    _pullY.springTo(navRubberBand(pull.dy, limit), _trackSpring);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    _pointer = null;
    _lift.springTo(0, _settleSpring);
    _pullX.springTo(0, _settleSpring);
    _pullY.springTo(0, _settleSpring);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerEnd,
      onPointerCancel: _handlePointerEnd,
      child: AnimatedBuilder(
        animation: _motion,
        builder: (_, child) => _PressTransform(
          lift: _lift.value,
          pull: Offset(_pullX.value, _pullY.value),
          strength: widget.strength,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Leaves a press on the filled button or FAB inside to [ElasticPress]; one
/// whose style sets a foreground color merges [ElasticPress.buttonStyle].
class ElasticButton extends StatelessWidget {
  const ElasticButton({super.key, this.enabled = true, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElasticPress(
      enabled: enabled,
      child: Theme(
        data: theme.copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: IconTheme(
          data: IconTheme.of(context),
          child: IconButtonTheme(
            data: IconButtonThemeData(
              style: ElasticPress.buttonStyle.merge(
                IconButtonTheme.of(context).style,
              ),
            ),
            child: FilledButtonTheme(
              data: FilledButtonThemeData(
                style: ElasticPress.buttonStyle.merge(
                  FilledButtonTheme.of(context).style,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _PressTransform extends SingleChildRenderObjectWidget {
  const _PressTransform({
    required this.lift,
    required this.pull,
    this.strength = 1,
    super.child,
  });

  final double lift;
  final Offset pull;
  final double strength;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPressTransform(lift: lift, pull: pull, strength: strength);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPressTransform renderObject,
  ) {
    renderObject
      ..lift = lift
      ..pull = pull
      ..strength = strength;
  }
}

class _RenderPressTransform extends RenderProxyBox {
  _RenderPressTransform({
    required double lift,
    required Offset pull,
    required double strength,
  }) : _lift = lift,
       _pull = pull,
       _strength = strength;

  double _lift;
  Offset _pull;
  double _strength;

  set lift(double value) {
    if (value == _lift) {
      return;
    }
    _lift = value;
    markNeedsPaint();
  }

  set pull(Offset value) {
    if (value == _pull) {
      return;
    }
    _pull = value;
    markNeedsPaint();
  }

  set strength(double value) {
    if (value == _strength) {
      return;
    }
    _strength = value;
    markNeedsPaint();
  }

  Matrix4 get _transform {
    final lift = _lift * _strength;
    final pull = _pull * _strength;
    final swell =
        1 +
        lift * math.min(_pressGrowth * 2, _maxPressGrowth / size.longestSide);
    final scaleX = swell * (1 + pull.dx.abs() / size.width * _pullStretch);
    final scaleY = swell * (1 + pull.dy.abs() / size.height * _pullStretch);
    final center = size.center(Offset.zero);
    return Matrix4.diagonal3Values(scaleX, scaleY, 1)..setTranslationRaw(
      center.dx * (1 - scaleX) + pull.dx,
      center.dy * (1 - scaleY) + pull.dy,
      0,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || size.isEmpty || (_lift == 0 && _pull == Offset.zero)) {
      layer = null;
      super.paint(context, offset);
      return;
    }
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      super.paint,
      oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
    );
  }
}

/// A floating pill of destinations whose selection is a lens that springs
/// between them, after iOS's tab bar. Pressing swells the bar as
/// [ElasticPress] does and lifts the lens under the finger; dragging slides
/// the lens across the bar, selecting where it is let go, and stretches the
/// bar past either end.
class FloatingNavigationBar extends StatefulWidget {
  const FloatingNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.lensKey,
  });

  final List<NavBarDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Key? lensKey;

  @override
  State<FloatingNavigationBar> createState() => _FloatingNavigationBarState();
}

class _FloatingNavigationBarState extends State<FloatingNavigationBar>
    with TickerProviderStateMixin {
  late final NavSpring _lens = NavSpring(this, _selectedIndex.toDouble());
  late final NavSpring _lift = NavSpring(this, 0);
  late final NavSpring _hover = NavSpring(this, 0);
  late final NavSpring _hoverShow = NavSpring(this, 0);
  late final NavSpring _swell = NavSpring(this, 0);
  late final NavSpring _stretch = NavSpring(this, 0);
  late final Listenable _barMotion = Listenable.merge([_swell, _stretch]);
  late final Listenable _motion = Listenable.merge([_lens, _lift]);
  late final Listenable _hoverMotion = Listenable.merge([_hover, _hoverShow]);
  int? _pointer;
  int? _pressedIndex;
  double _pressX = 0;
  bool _dragging = false;
  bool _reduceMotion = false;
  Offset? _cursor;
  final ValueNotifier<double?> _hoverAt = ValueNotifier(null);

  late final NavSlots<Object> _slots = NavSlots<Object>(
    vsync: this,
    spring: _slotWeightSpring,
  );

  /// The last-seen destination for every id, so a leaving slot keeps something
  /// to paint while it collapses after its destination has left the widget.
  final Map<Object, NavBarDestination> _destinations = {};

  @override
  void initState() {
    super.initState();
    _cacheDestinations();
    _slots.seed([for (final d in widget.destinations) d.id]);
  }

  void _cacheDestinations() {
    for (final destination in widget.destinations) {
      _destinations[destination.id] = destination;
    }
  }

  int get _lastIndex => math.max(0, widget.destinations.length - 1);

  int get _selectedIndex => widget.selectedIndex.clamp(0, _lastIndex);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = context.disableAnimations;
    _slots.reduceMotion = _reduceMotion;
  }

  void _settle(NavSpring spring, double target, SpringDescription description) {
    if (_reduceMotion) {
      spring.jumpTo(target);
    } else {
      spring.springTo(target, description);
    }
  }

  @override
  void didUpdateWidget(covariant FloatingNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cacheDestinations();
    _slots.sync([for (final d in widget.destinations) d.id]);
    if (_pressedIndex == null && _lens.target != _selectedIndex) {
      _settle(_lens, _selectedIndex.toDouble(), _settleSpring);
    }
  }

  @override
  void dispose() {
    _slots.dispose();
    _lens.dispose();
    _lift.dispose();
    _hover.dispose();
    _hoverShow.dispose();
    _swell.dispose();
    _stretch.dispose();
    _hoverAt.dispose();
    super.dispose();
  }

  double _positionAt(Offset localPosition) {
    final width = context.size!.width;
    final dx = Directionality.of(context) == TextDirection.ltr
        ? localPosition.dx
        : width - localPosition.dx;
    final extent = (width - _barPadding * 2) / widget.destinations.length;
    final position = (dx - _barPadding) / extent - 0.5;
    if (position < 0) {
      return navRubberBand(position, _overdrag);
    }
    if (position > _lastIndex) {
      return _lastIndex + navRubberBand(position - _lastIndex, _overdrag);
    }
    return position;
  }

  int _indexAt(double position) => position.round().clamp(0, _lastIndex);

  void _showHover() {
    final cursor = _cursor;
    if (cursor == null || _pointer != null || widget.destinations.isEmpty) {
      return;
    }
    final position = _positionAt(cursor);
    final index = _indexAt(position);
    final target = index + (position - index) * _hoverMagnet;
    _hoverAt.value = position;
    if (_hoverShow.target == 0 && _hoverShow.value == 0) {
      _hover.jumpTo(target);
    } else {
      _settle(_hover, target, _hoverSpring);
    }
    _settle(_hoverShow, 1, _fadeSpring);
  }

  void _settleSwell() {
    final target = _cursor == null ? 0.0 : _hoverSwell;
    if (_pointer == null && _swell.target != target) {
      _settle(_swell, target, _settleSpring);
    }
  }

  void _handleHover(PointerHoverEvent event) {
    // The engine synthesizes a hover before a touch lands, and the touch
    // pointer lingers until removed, so a tap would leave the highlight on.
    if (event.kind == PointerDeviceKind.touch) {
      return;
    }
    _cursor = event.localPosition;
    _showHover();
    _settleSwell();
  }

  void _handleExit(PointerExitEvent event) {
    _cursor = null;
    _settle(_hoverShow, 0, _fadeSpring);
    _hoverAt.value = null;
    _settleSwell();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer != null || event.buttons & kPrimaryButton == 0) {
      return;
    }
    _pointer = event.pointer;
    _settle(_hoverShow, 0, _fadeSpring);
    _hoverAt.value = null;
    _settle(_swell, 1, _liftSpring);
    _press(event.localPosition);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer == _pointer) {
      _slide(event.localPosition);
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    _pointer = null;
    _release(commit: event is PointerUpEvent);
    _settle(_stretch, 0, _settleSpring);
    if (_cursor != null) {
      _cursor = event.localPosition;
      _showHover();
    }
    _settleSwell();
  }

  void _press(Offset localPosition) {
    if (widget.destinations.isEmpty) {
      return;
    }
    final index = _indexAt(_positionAt(localPosition));
    // ignore: avoid_print
    _pressedIndex = index;
    _pressX = localPosition.dx;
    _dragging = false;
    _settle(_lift, 1, _liftSpring);
    _settle(_lens, index.toDouble(), _settleSpring);
  }

  void _slide(Offset localPosition) {
    if (_pressedIndex == null) {
      return;
    }
    if (!_dragging) {
      if ((localPosition.dx - _pressX).abs() < kTouchSlop) {
        return;
      }
      _dragging = true;
    }
    final size = context.size!;
    final overshoot =
        localPosition.dx - localPosition.dx.clamp(0.0, size.width);
    _settle(
      _stretch,
      navRubberBand(overshoot, size.shortestSide * _pullLimit),
      _trackSpring,
    );
    final position = _positionAt(localPosition);
    _settle(_lens, position, _trackSpring);
    final index = _indexAt(position);
    if (index != _pressedIndex) {
      HapticFeedback.selectionClick();
      _pressedIndex = index;
    }
  }

  void _release({required bool commit}) {
    final index = _pressedIndex;
    if (index == null) {
      return;
    }
    _pressedIndex = null;
    _dragging = false;
    _settle(_lift, 0, _settleSpring);
    if (!commit) {
      _settle(_lens, _selectedIndex.toDouble(), _settleSpring);
      return;
    }
    _settle(_lens, index.toDouble(), _settleSpring);
    if (index != widget.selectedIndex) {
      widget.onSelected(index);
    }
  }

  double _totalWeight() =>
      _slots.slots.fold(0.0, (sum, slot) => sum + slot.weight.value);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final labelStyle = context.textTheme.labelSmall?.copyWith(
      fontSize: _labelSize,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );
    final labels = [
      for (final destination in widget.destinations)
        _measureLabel(context, destination.label, labelStyle),
    ];
    final widest = labels.fold(
      0.0,
      (width, label) => math.max(width, label.width),
    );
    final lineHeight = labels.fold(
      0.0,
      (height, label) => math.max(height, label.height),
    );
    final bar = DecoratedBox(
      decoration: ShapeDecoration(
        shape: AppShape.full,
        shadows: _dockShadows(colorScheme),
      ),
      child: Material(
        color: colorScheme.surfaceContainer,
        shape: AppShape.full,
        // Raw pointers rather than recognizers: a drag has nothing to win the
        // arena from, and a tap waiting on one lifts the lens late.
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerEnd,
          onPointerCancel: _handlePointerEnd,
          child: MouseRegion(
            onHover: _handleHover,
            onExit: _handleExit,
            child: Padding(
              padding: const EdgeInsets.all(_barPadding),
              // Above the LayoutBuilder: rebuilding anything under one relays
              // it out, and that repaint would otherwise reach the whole dock.
              child: RepaintBoundary(
                child: LayoutBuilder(
                  // The width cap animates with the slot weights, so the cap's
                  // changing constraint re-runs this builder every frame of a
                  // slot transition and the geometry below follows.
                  builder: (context, constraints) {
                    final slots = _slots.slots;
                    final innerWidth = constraints.maxWidth;
                    final total = _totalWeight();
                    final unit = total <= 0 ? 0.0 : innerWidth / total;

                    final starts = <double>[];
                    final widths = <double>[];
                    final liveIndexOf = <int>[];
                    final liveCenters = <double>[];
                    final liveWidths = <double>[];
                    var x = 0.0;
                    for (final slot in slots) {
                      final w = slot.weight.value * unit;
                      starts.add(x);
                      widths.add(w);
                      if (slot.leaving) {
                        liveIndexOf.add(liveCenters.length);
                      } else {
                        liveIndexOf.add(liveCenters.length);
                        liveCenters.add(x + w / 2);
                        liveWidths.add(w);
                      }
                      x += w;
                    }
                    final liveCount = liveCenters.length;

                    final avgExtent = liveCount == 0
                        ? innerWidth
                        : innerWidth / liveCount;
                    final room = avgExtent - _labelInset * 2;
                    final labelScale = widest <= room
                        ? 1.0
                        : math.max(room / widest, _minLabelSize / _labelSize);

                    double sampleAt(List<double> values, double pos) {
                      if (values.isEmpty) {
                        return 0;
                      }
                      final last = values.length - 1;
                      final low = pos.floor().clamp(0, last);
                      final high = pos.ceil().clamp(0, last);
                      return lerpDouble(
                        values[low],
                        values[high],
                        (pos - low).clamp(0.0, 1.0),
                      )!;
                    }

                    final ltr = Directionality.of(context) == TextDirection.ltr;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // The slots are all positioned; a sized box gives the
                        // stack a width so the pill is not clipped to its padding.
                        SizedBox(
                          width: innerWidth,
                          height: constraints.maxHeight,
                        ),
                        if (liveCount > 0)
                          AnimatedBuilder(
                            animation: _motion,
                            builder: (_, _) => _Lens(
                              lensKey: widget.lensKey,
                              center: sampleAt(liveCenters, _lens.value),
                              extent: sampleAt(liveWidths, _lens.value),
                              velocity: _lens.velocity,
                              height: constraints.maxHeight,
                              lift: _lift.value,
                            ),
                          ),
                        if (liveCount > 0)
                          AnimatedBuilder(
                            animation: _hoverMotion,
                            builder: (_, _) => _HoverHighlight(
                              center: sampleAt(liveCenters, _hover.value),
                              extent: sampleAt(liveWidths, _hover.value),
                              opacity: _hoverShow.value,
                            ),
                          ),
                        // Plain Positioned, not PositionedDirectional: the lens
                        // is the dock's only PositionedDirectional and a widget
                        // test keys off that.
                        for (var i = 0; i < slots.length; i++)
                          Positioned(
                            left: ltr ? starts[i] : null,
                            right: ltr ? null : starts[i],
                            top: 0,
                            bottom: 0,
                            width: widths[i],
                            child: _SlotBox(
                              reveal: slots[i].weight.value,
                              child: _buildItem(
                                slot: slots[i],
                                liveIndex: liveIndexOf[i],
                                extent: widths[i],
                                labelStyle: labelStyle?.copyWith(
                                  fontSize: _labelSize * labelScale,
                                ),
                                labelHeight: lineHeight,
                                labelScale: labelScale,
                                room: room,
                                labelStyleBase: labelStyle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final capped = AnimatedBuilder(
      animation: _slots,
      builder: (_, child) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _totalWeight() * _maxItemExtent + _barPadding * 2,
        ),
        child: child,
      ),
      child: bar,
    );
    return AnimatedBuilder(
      animation: _barMotion,
      builder: (_, child) => _PressTransform(
        lift: _swell.value,
        pull: Offset(_stretch.value, 0),
        child: child,
      ),
      child: capped,
    );
  }

  Widget _buildItem({
    required NavSlot<Object> slot,
    required int liveIndex,
    required double extent,
    required TextStyle? labelStyle,
    required TextStyle? labelStyleBase,
    required double labelHeight,
    required double labelScale,
    required double room,
  }) {
    final destination = _destinations[slot.key];
    if (destination == null) {
      return const SizedBox.shrink();
    }
    final labelWidth = _measureLabel(
      context,
      destination.label,
      labelStyleBase,
    ).width;
    final item = _FloatingBarItem(
      key: ValueKey(slot.key),
      destination: destination,
      selected: !slot.leaving && liveIndex == _selectedIndex,
      index: liveIndex,
      lens: _lens,
      hoverAt: _hoverAt,
      extent: extent,
      lift: _lift,
      labelStyle: labelStyle,
      labelHeight: labelHeight,
      labelOverflows: labelWidth * labelScale > room,
      onActivate: slot.leaving ? () {} : () => widget.onSelected(liveIndex),
    );
    return slot.leaving ? IgnorePointer(child: item) : item;
  }
}

/// Holds a destination to a slot's current share of the bar, clipping and
/// dissolving it (fade, scale, blur) while it grows in or collapses out so
/// neighbours slide rather than jump.
class _SlotBox extends StatelessWidget {
  const _SlotBox({required this.reveal, required this.child});

  final double reveal;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reveal >= 0.999) {
      return child;
    }
    final scale = lerpDouble(_slotEnterScale, 1, reveal)!;
    final blur = _slotBlur * (1 - reveal);
    return ClipRect(
      child: OverflowBox(
        minWidth: 0,
        maxWidth: _maxItemExtent,
        alignment: Alignment.center,
        child: Opacity(
          opacity: reveal.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: ImageFiltered(
              enabled: blur > 0.05,
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// The pointer's highlight, drawn to the destination under it and leaning a
/// little toward the cursor, as iPadOS highlights a tab bar item; the item
/// under it follows the cursor half as far.
class _HoverHighlight extends StatelessWidget {
  const _HoverHighlight({
    required this.center,
    required this.extent,
    required this.opacity,
  });

  final double center;
  final double extent;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final alpha = _hoverAlpha * opacity.clamp(0.0, 1.0);
    if (alpha == 0) {
      return const SizedBox.shrink();
    }
    return Positioned.directional(
      textDirection: Directionality.of(context),
      start: center - extent / 2,
      top: 0,
      bottom: 0,
      width: extent,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.colorScheme.onSurface.withValues(alpha: alpha),
          shape: AppShape.full,
        ),
      ),
    );
  }
}

class _Lens extends StatelessWidget {
  const _Lens({
    required this.lensKey,
    required this.center,
    required this.velocity,
    required this.extent,
    required this.height,
    required this.lift,
  });

  final Key? lensKey;
  final double center;
  final double velocity;
  final double extent;
  final double height;
  final double lift;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final stretch =
        (velocity.abs() / _jellySpeed).clamp(0.0, 1.0) * _jellyStretch;
    final growth = _lensGrowth * 2 * lift;
    final width = (extent + growth) * (1 + stretch);
    final lensHeight = (height + growth) * (1 - stretch / 2);
    return PositionedDirectional(
      key: lensKey,
      start: center - width / 2,
      top: (height - lensHeight) / 2,
      width: width,
      height: lensHeight,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: Color.alphaBlend(
            colorScheme.onSecondaryContainer.withValues(
              alpha: 0.08 * lift.clamp(0.0, 1.0),
            ),
            colorScheme.secondaryContainer,
          ),
          shape: AppShape.full,
        ),
      ),
    );
  }
}

class _FloatingBarItem extends StatefulWidget {
  const _FloatingBarItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.index,
    required this.lens,
    required this.hoverAt,
    required this.extent,
    required this.lift,
    required this.labelStyle,
    required this.labelHeight,
    required this.labelOverflows,
    required this.onActivate,
  });

  final NavBarDestination destination;
  final bool selected;
  final int index;
  final ValueListenable<double> lens;

  /// Where the pointer hovers, in destinations from the first one's center.
  final ValueListenable<double?> hoverAt;
  final double extent;
  final ValueListenable<double> lift;
  final TextStyle? labelStyle;
  final double labelHeight;
  final bool labelOverflows;
  final VoidCallback onActivate;

  @override
  State<_FloatingBarItem> createState() => _FloatingBarItemState();
}

class _FloatingBarItemState extends State<_FloatingBarItem>
    with SingleTickerProviderStateMixin {
  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onActivate();
        return null;
      },
    ),
  };
  late final NavSpring _parallax = NavSpring(this, 0);
  bool _focused = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    widget.hoverAt.addListener(_followPointer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = context.disableAnimations;
  }

  @override
  void didUpdateWidget(covariant _FloatingBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hoverAt != widget.hoverAt) {
      oldWidget.hoverAt.removeListener(_followPointer);
      widget.hoverAt.addListener(_followPointer);
    }
    _followPointer();
  }

  @override
  void dispose() {
    widget.hoverAt.removeListener(_followPointer);
    _parallax.dispose();
    super.dispose();
  }

  void _followPointer() {
    final hoverAt = widget.hoverAt.value;
    final offset = hoverAt == null ? 0.0 : hoverAt - widget.index;
    final target = offset.abs() > 0.5
        ? 0.0
        : offset * _hoverMagnet * _hoverParallax;
    if (target == _parallax.target) {
      return;
    }
    if (_reduceMotion) {
      _parallax.jumpTo(target);
    } else {
      _parallax.springTo(target, _hoverSpring);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final direction = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: _labelInset),
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.lens, widget.lift, _parallax]),
        builder: (context, _) {
          final emphasis = (1 - (widget.lens.value - widget.index).abs()).clamp(
            0.0,
            1.0,
          );
          final color = Color.lerp(
            colorScheme.onSurfaceVariant,
            colorScheme.primary,
            emphasis,
          )!;
          final column = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlyphIcon(
                widget.destination.glyph,
                size: _iconSize,
                color: color,
                fill: 1,
              ),
              const SizedBox(height: _labelGap),
              SizedBox(
                height: widget.labelHeight,
                child: Center(
                  child: Text(
                    widget.destination.label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: widget.labelStyle?.copyWith(color: color),
                  ),
                ),
              ),
            ],
          );
          return Transform.translate(
            offset: Offset(_parallax.value * widget.extent * direction, 0),
            transformHitTests: false,
            child: Transform.scale(
              scale: 1 + _lensMagnify * emphasis * widget.lift.value,
              child: column,
            ),
          );
        },
      ),
    );
    return FocusableActionDetector(
      actions: _actions,
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      child: Semantics(
        container: true,
        button: true,
        selected: widget.selected,
        label: widget.destination.label,
        excludeSemantics: true,
        onTap: widget.onActivate,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: _focused
                ? colorScheme.onSurface.withValues(alpha: 0.1)
                : Colors.transparent,
            shape: AppShape.full.copyWith(
              side: _focused
                  ? BorderSide(color: colorScheme.secondary, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: widget.labelOverflows
              ? AppTooltip(message: widget.destination.label, child: content)
              : content,
        ),
      ),
    );
  }
}

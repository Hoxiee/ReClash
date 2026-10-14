import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/ui/color.dart';
import 'package:reclash/common/ui/shape.dart';
import 'package:reclash/widgets/layout/drag_back.dart';
import 'package:reclash/widgets/layout/sheet_navigator.dart';

const Duration _bottomSheetEnterDuration = Duration(milliseconds: 300);
const Duration _bottomSheetExitDuration = Duration(milliseconds: 200);
const Curve _modalBottomSheetCurve = Easing.standardDecelerate;

const double _minWidth = 360;
const double _maxWidth = 560;
const double _widthFactor = 0.4;

/// The desktop side sheet floats as a card, inset from the top, trailing, and
/// bottom window edges so its rounded corners and shadow read against the scrim.
const EdgeInsets _sideSheetMargin = EdgeInsets.fromLTRB(0, 16, 16, 16);

double _widthFor(double viewWidth) {
  return (viewWidth * _widthFactor).clamp(_minWidth, _maxWidth);
}

class SideSheet extends StatefulWidget {
  const SideSheet({
    super.key,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    required this.builder,
  }) : assert(elevation == null || elevation >= 0.0);

  final WidgetBuilder builder;

  final Color? backgroundColor;

  final Color? shadowColor;

  final double? elevation;

  final ShapeBorder? shape;

  final Clip? clipBehavior;

  @override
  State<SideSheet> createState() => _SideSheetState();

  static AnimationController createAnimationController(
    TickerProvider vsync, {
    Duration duration = _bottomSheetEnterDuration,
    Duration reverseDuration = _bottomSheetExitDuration,
  }) {
    return AnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: 'SideSheet',
      vsync: vsync,
    );
  }
}

class _SideSheetState extends State<SideSheet> {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'SideSheet child');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color color =
        widget.backgroundColor ?? colorScheme.surfaceContainerLow;
    // A transparent surface means the real card lives one layer in (a paged
    // sheet floats its own inner card); raising, rounding, or clipping an
    // invisible surface here would only stamp a phantom frame around the
    // content, so the card treatment is withheld unless this surface is seen.
    final bool chromeless = color.a == 0;
    // The container role already carries the panel tone; an elevation tint on
    // top only muddies it with a warm cast, so the shadow alone conveys depth.
    const Color surfaceTintColor = Colors.transparent;
    final Color shadowColor =
        widget.shadowColor ??
        (chromeless ? Colors.transparent : colorScheme.shadow);
    final double elevation = widget.elevation ?? (chromeless ? 0 : 3);
    final ShapeBorder shape =
        widget.shape ?? (chromeless ? AppShape.none : AppShape.xl);

    final Clip clipBehavior =
        widget.clipBehavior ?? (chromeless ? Clip.none : Clip.antiAlias);

    return Material(
      key: _childKey,
      color: color,
      elevation: elevation,
      surfaceTintColor: surfaceTintColor,
      shadowColor: shadowColor,
      shape: shape,
      clipBehavior: clipBehavior,
      child: widget.builder(context),
    );
  }
}

typedef _SizeChangeCallback<Size> = void Function(Size);

class _SideSheetLayoutWithSizeListener extends SingleChildRenderObjectWidget {
  const _SideSheetLayoutWithSizeListener({
    required this.onChildSizeChanged,
    required this.animationValue,
    required this.width,
    required this.margin,
    super.child,
  });

  final _SizeChangeCallback<Size> onChildSizeChanged;
  final double animationValue;
  final double width;
  final EdgeInsets margin;

  @override
  _RenderSideSheetLayoutWithSizeListener createRenderObject(
    BuildContext context,
  ) {
    return _RenderSideSheetLayoutWithSizeListener(
      onChildSizeChanged: onChildSizeChanged,
      animationValue: animationValue,
      width: width,
      margin: margin,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSideSheetLayoutWithSizeListener renderObject,
  ) {
    renderObject.onChildSizeChanged = onChildSizeChanged;
    renderObject.animationValue = animationValue;
    renderObject.width = width;
    renderObject.margin = margin;
  }
}

class _RenderSideSheetLayoutWithSizeListener extends RenderShiftedBox {
  _RenderSideSheetLayoutWithSizeListener({
    RenderBox? child,
    required _SizeChangeCallback<Size> onChildSizeChanged,
    required double animationValue,
    required double width,
    required EdgeInsets margin,
  }) : _onChildSizeChanged = onChildSizeChanged,
       _animationValue = animationValue,
       _width = width,
       _margin = margin,
       super(child);

  Size _lastSize = Size.zero;

  _SizeChangeCallback<Size> get onChildSizeChanged => _onChildSizeChanged;
  _SizeChangeCallback<Size> _onChildSizeChanged;

  set onChildSizeChanged(_SizeChangeCallback<Size> newCallback) {
    if (_onChildSizeChanged == newCallback) {
      return;
    }

    _onChildSizeChanged = newCallback;
    markNeedsLayout();
  }

  double get animationValue => _animationValue;
  double _animationValue;

  set animationValue(double newValue) {
    if (_animationValue == newValue) {
      return;
    }

    _animationValue = newValue;
    markNeedsLayout();
  }

  double get width => _width;
  double _width;

  set width(double newValue) {
    if (_width == newValue) {
      return;
    }

    _width = newValue;
    markNeedsLayout();
  }

  EdgeInsets get margin => _margin;
  EdgeInsets _margin;

  set margin(EdgeInsets newValue) {
    if (_margin == newValue) {
      return;
    }

    _margin = newValue;
    markNeedsLayout();
  }

  Size _getSize(BoxConstraints constraints) {
    return constraints.constrain(constraints.biggest);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final double width = _getSize(
      BoxConstraints.tightForFinite(height: height),
    ).width;
    if (width.isFinite) {
      return width;
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final double width = _getSize(
      BoxConstraints.tightForFinite(height: height),
    ).width;
    if (width.isFinite) {
      return width;
    }
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final double height = _getSize(
      BoxConstraints.tightForFinite(width: width),
    ).height;
    if (height.isFinite) {
      return height;
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final double height = _getSize(
      BoxConstraints.tightForFinite(width: width),
    ).height;
    if (height.isFinite) {
      return height;
    }
    return 0.0;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _getSize(constraints);
  }

  BoxConstraints _getConstraintsForChild(BoxConstraints constraints) {
    final double maxWidth = math.max(
      0.0,
      constraints.maxWidth - _margin.horizontal,
    );
    return BoxConstraints.tightFor(
      width: math.min(width, maxWidth),
      height: math.max(0.0, constraints.maxHeight - _margin.vertical),
    );
  }

  Offset _getPositionForChild(Size size, Size childSize) {
    return Offset(
      size.width - (childSize.width + _margin.right) * animationValue,
      _margin.top,
    );
  }

  @override
  void performLayout() {
    size = _getSize(constraints);
    if (child != null) {
      final BoxConstraints childConstraints = _getConstraintsForChild(
        constraints,
      );
      assert(childConstraints.debugAssertIsValid(isAppliedConstraint: true));
      child!.layout(
        childConstraints,
        parentUsesSize: !childConstraints.isTight,
      );
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = _getPositionForChild(
        size,
        childConstraints.isTight ? childConstraints.smallest : child!.size,
      );
      final Size childSize = childConstraints.isTight
          ? childConstraints.smallest
          : child!.size;

      if (_lastSize != childSize) {
        _lastSize = childSize;
        _onChildSizeChanged.call(_lastSize);
      }
    }
  }
}

class _ModalSideSheet<T> extends StatefulWidget {
  const _ModalSideSheet({
    super.key,
    required this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
  });

  final ModalSideSheetRoute<T> route;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;

  @override
  _ModalSideSheetState<T> createState() => _ModalSideSheetState<T>();
}

class _ModalSideSheetState<T> extends State<_ModalSideSheet<T>> {
  ParametricCurve<double> animationCurve = _modalBottomSheetCurve;

  String _getRouteLabel(MaterialLocalizations localizations) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return localizations.dialogLabel;
    }
  }

  EdgeInsets _getNewClipDetails(Size topLayerSize) {
    return EdgeInsets.fromLTRB(0, 0, 0, topLayerSize.height);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String routeLabel = _getRouteLabel(localizations);
    final defaultWidth = _widthFor(MediaQuery.sizeOf(context).width);
    final width =
        widget.route.constraints?.constrainWidth(defaultWidth) ?? defaultWidth;

    final route = widget.route;
    return AnimatedBuilder(
      animation: route.animation!,
      child: route.dragBackDetector(
        SideSheet(
          builder: route.builder,
          backgroundColor: widget.backgroundColor,
          elevation: widget.elevation,
          shape: widget.shape,
          clipBehavior: widget.clipBehavior,
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        final curve = route.isDragBackActive ? Curves.linear : animationCurve;
        final double animationValue = curve.transform(route.animation!.value);
        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: _SideSheetLayoutWithSizeListener(
              onChildSizeChanged: (Size size) {
                widget.route._didChangeBarrierSemanticsClip(
                  _getNewClipDetails(size),
                );
              },
              animationValue: animationValue,
              width: width,
              margin: _sideSheetMargin,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class ModalSideSheetRoute<T> extends PopupRoute<T>
    with DragBackRouteMixin<T>, SheetCoverRouteMixin<T> {
  ModalSideSheetRoute({
    required this.builder,
    this.capturedThemes,
    this.barrierLabel,
    this.barrierOnTapHint,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.modalBarrierColor,
    this.isDismissible = true,
    super.settings,
    this.transitionAnimationController,
    this.anchorPoint,
    this.constraints,
    this.useSafeArea = false,
    super.filter,
  });

  final WidgetBuilder builder;

  final CapturedThemes? capturedThemes;

  final Color? backgroundColor;

  final double? elevation;

  final ShapeBorder? shape;

  final Clip? clipBehavior;

  final Color? modalBarrierColor;

  final bool isDismissible;

  final AnimationController? transitionAnimationController;

  final Offset? anchorPoint;
  final BoxConstraints? constraints;
  final bool useSafeArea;

  bool _disableAnimations = false;

  @override
  void install() {
    _disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(navigator!.context) ?? false;
    super.install();
  }

  final String? barrierOnTapHint;

  final ValueNotifier<EdgeInsets> _clipDetailsNotifier =
      ValueNotifier<EdgeInsets>(EdgeInsets.zero);

  @override
  void dispose() {
    _clipDetailsNotifier.dispose();
    super.dispose();
  }

  bool _didChangeBarrierSemanticsClip(EdgeInsets newClipDetails) {
    if (_clipDetailsNotifier.value == newClipDetails) {
      return false;
    }
    _clipDetailsNotifier.value = newClipDetails;
    return true;
  }

  @override
  Duration get transitionDuration =>
      _disableAnimations ? Duration.zero : _bottomSheetEnterDuration;

  @override
  Duration get reverseTransitionDuration =>
      _disableAnimations ? Duration.zero : _bottomSheetExitDuration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black54;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    if (transitionAnimationController != null) {
      _animationController = transitionAnimationController;
      willDisposeAnimationController = false;
    } else {
      _animationController = SideSheet.createAnimationController(
        navigator!,
        duration: transitionDuration,
        reverseDuration: reverseTransitionDuration,
      );
    }
    return _animationController!;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget content = DisplayFeatureSubScreen(
      anchorPoint: anchorPoint,
      child: Builder(
        builder: (BuildContext context) {
          return _ModalSideSheet<T>(
            route: this,
            backgroundColor: backgroundColor,
            elevation: elevation,
            shape: shape,
            clipBehavior: clipBehavior,
          );
        },
      ),
    );

    final Widget sideSheet = useSafeArea
        ? SafeArea(bottom: false, child: content)
        : MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: content,
          );

    return capturedThemes?.wrap(sideSheet) ?? sideSheet;
  }

  @override
  Widget buildModalBarrier() {
    if (barrierColor.a != 0 && !offstage) {
      assert(barrierColor != barrierColor.opacity0);
      final Animation<Color?> color = animation!.drive(
        ColorTween(
          begin: barrierColor.opacity0,
          end: barrierColor,
        ).chain(CurveTween(curve: barrierCurve)),
      );
      return AnimatedModalBarrier(
        color: color,
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
        clipDetailsNotifier: _clipDetailsNotifier,
        semanticsOnTapHint: barrierOnTapHint,
      );
    } else {
      return ModalBarrier(
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
        clipDetailsNotifier: _clipDetailsNotifier,
        semanticsOnTapHint: barrierOnTapHint,
      );
    }
  }
}

Future<T?> showModalSideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  String? barrierLabel,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool useRootNavigator = false,
  bool isDismissible = true,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
  BoxConstraints? constraints,
  bool useSafeArea = false,
  ImageFilter? filter,
}) {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));

  final navigator = useRootNavigator
      ? Navigator.of(context, rootNavigator: true)
      : sheetNavigatorOf(context);
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);
  return navigator.push(
    ModalSideSheetRoute<T>(
      builder: builder,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      barrierLabel: barrierLabel ?? localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(
        localizations.bottomSheetLabel,
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      isDismissible: isDismissible,
      modalBarrierColor:
          barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      settings: routeSettings,
      transitionAnimationController: transitionAnimationController,
      anchorPoint: anchorPoint,
      constraints: constraints,
      useSafeArea: useSafeArea,
      filter: filter,
    ),
  );
}

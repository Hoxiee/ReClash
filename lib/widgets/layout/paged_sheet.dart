import 'package:material_ui/material_ui.dart';
import 'package:navigator_resizable/navigator_resizable.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/base/inherited.dart';
import 'package:reclash/widgets/base/pop_scope.dart';
import 'package:reclash/widgets/layout/sheet.dart';

Color _sheetColorOf(BuildContext context) {
  final scheme = ColorScheme.of(context);
  // Side and bottom sheets share the floating-card tone; only a full page keeps
  // the plain surface behind it.
  return SheetProvider.of(context)?.type == SheetType.page
      ? scheme.surface
      : scheme.surfaceContainerLow;
}

Future<T?> pushPagedSheet<T>(BuildContext context, PagedSheetRoute<T> route) {
  route._resolveMotionFrom(context);
  return Navigator.of(context).push<T>(route);
}

class PagedSheetRoute<T> extends PageRoute<T> with ObservableRouteMixin<T> {
  PagedSheetRoute({
    super.settings,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.requestFocus,
    this.maintainState = true,
    this.duration = const Duration(milliseconds: 350),
    this.backgroundColor,
    this.transitionsBuilder,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  final Duration duration;
  final Color? backgroundColor;
  final RouteTransitionsBuilder? transitionsBuilder;

  Duration? _resolvedDuration;

  void _resolveMotionFrom(BuildContext context) {
    _resolvedDuration = context.motionDuration(duration);
  }

  @override
  Duration get transitionDuration => _resolvedDuration ?? duration;

  @override
  Duration get reverseTransitionDuration => _resolvedDuration ?? duration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return previousRoute is PagedSheetRoute;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is PagedSheetRoute;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: ResizableNavigatorRouteContentBoundary(child: builder(context)),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (transitionsBuilder case final builder?) {
      return builder(context, animation, secondaryAnimation, child);
    }
    return FadeForwardsPageTransitionsBuilder(
      backgroundColor: backgroundColor ?? _sheetColorOf(context),
    ).buildTransitions(this, context, animation, secondaryAnimation, child);
  }
}

class PagedSheet extends StatelessWidget {
  const PagedSheet({
    super.key,
    this.color,
    this.shape,
    this.clipBehavior = Clip.antiAlias,
    required this.child,
  });

  final Color? color;
  final ShapeBorder? shape;
  final Clip clipBehavior;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final type = SheetProvider.of(context)?.type;
    final bool isSideSheet = type == SheetType.sideSheet;
    return Material(
      animationDuration: Duration.zero,
      color: color ?? _sheetColorOf(context),
      // On desktop the paged sheet is itself the floating card: the enclosing
      // side-sheet surface stays transparent, so the raised rounded treatment
      // has to live here or the card would show no edge, corners, or shadow.
      elevation: isSideSheet ? 3 : 0,
      shadowColor: isSideSheet ? ColorScheme.of(context).shadow : null,
      surfaceTintColor: Colors.transparent,
      shape:
          shape ??
          (type == SheetType.bottomSheet
              ? AppShape.top(AppCorner.xxl)
              : isSideSheet
              ? AppShape.xl
              : AppShape.none),
      clipBehavior: clipBehavior,
      child: NavigatorResizable(child: child),
    );
  }
}

const nestedPagedSheetProps = SheetProps(
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  maxWidth: double.maxFinite,
);

/// Opened with [nestedPagedSheetProps]. [onDismiss] is told whether a page is
/// pushed over the root; with no callbacks, back on the root and a tap outside
/// close the sheet.
class NestedPagedSheet extends StatefulWidget {
  const NestedPagedSheet({
    super.key,
    required this.builder,
    this.onExit,
    this.onDismiss,
  });

  final WidgetBuilder builder;
  final VoidCallback? onExit;
  final ValueChanged<bool>? onDismiss;

  @override
  State<NestedPagedSheet> createState() => _NestedPagedSheetState();
}

class _NestedPagedSheetState extends State<NestedPagedSheet> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  bool get _hasPushedPages => _navigatorKey.currentState?.canPop() ?? false;

  void _close() => Navigator.of(context).pop();

  void _handlePop() {
    if (_hasPushedPages) {
      _navigatorKey.currentState!.pop();
      return;
    }
    (widget.onExit ?? _close)();
  }

  void _handleDismiss() {
    final onDismiss = widget.onDismiss;
    if (onDismiss == null) {
      _close();
      return;
    }
    onDismiss(_hasPushedPages);
  }

  @override
  Widget build(BuildContext context) {
    final sheetProvider = SheetProvider.of(context)!;
    return CommonPopScope(
      onPop: (_) async {
        _handlePop();
        return false;
      },
      child: sheetProvider.copyWith(
        nestedNavigatorPop: ([data]) => Navigator.of(context).pop(data),
        child: SizedBox(
          width: sheetProvider.type == SheetType.sideSheet ? 400 : null,
          height: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: GestureDetector(onTap: _handleDismiss)),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: PagedSheet(
                      child: Navigator(
                        key: _navigatorKey,
                        onGenerateInitialRoutes: (_, _) => [
                          PagedSheetRoute(builder: widget.builder),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

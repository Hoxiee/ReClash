import 'dart:async';

import 'package:flutter/widgets.dart';

import 'inherited.dart';

class CommonPopScope extends StatelessWidget {
  final Widget child;

  /// Any handler vetoes the pop up front, which also turns off the drag back,
  /// so pass one only while there is something to intercept.
  final FutureOr<bool> Function(BuildContext context)? onPop;
  final FutureOr<void> Function()? onPopSuccess;

  const CommonPopScope({
    super.key,
    required this.child,
    this.onPop,
    this.onPopSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final hasBackLayer = route?.willHandlePopInternally == true;
    return _RouteExitRegistration(
      onExit: onPop,
      child: PopScope(
        canPop: onPop == null || hasBackLayer,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) {
            await onPopSuccess?.call();
            return;
          }
          if (onPop == null) return;
          // BackLayerScope adds its entry a frame after this builds, which
          // rebuilds nothing here on a route with another below it.
          if (route?.willHandlePopInternally == true) {
            Navigator.of(context).pop();
            return;
          }
          final res = await onPop!(context);
          if (!context.mounted || !res) return;
          Navigator.of(context).pop();
        },
        child: child,
      ),
    );
  }
}

class BackLayerScope extends StatefulWidget {
  final Widget child;
  final VoidCallback onBack;
  @visibleForTesting
  final void Function(void Function(Duration) callback)?
  schedulePostFrameCallback;

  const BackLayerScope({
    super.key,
    required this.onBack,
    required this.child,
    @visibleForTesting this.schedulePostFrameCallback,
  });

  @override
  State<BackLayerScope> createState() => _BackLayerScopeState();
}

class _BackLayerScopeState extends State<BackLayerScope> {
  ModalRoute<dynamic>? _route;
  LocalHistoryEntry? _entry;
  bool _isDetaching = false;
  bool _isPageActive = true;
  int _syncRevision = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    final isPageActive = PageActivityScope.isActiveOf(context);
    if (identical(_route, route) && _isPageActive == isPageActive) {
      return;
    }
    _detach();
    _route = route;
    _isPageActive = isPageActive;
    final revision = ++_syncRevision;
    final schedulePostFrameCallback =
        widget.schedulePostFrameCallback ??
        WidgetsBinding.instance.addPostFrameCallback;
    schedulePostFrameCallback((_) {
      if (!mounted || revision != _syncRevision) {
        return;
      }
      if (!_isPageActive) {
        widget.onBack();
        return;
      }
      if (route == null) {
        return;
      }
      final entry = LocalHistoryEntry(
        impliesAppBarDismissal: false,
        onRemove: _handleRemove,
      );
      _entry = entry;
      route.addLocalHistoryEntry(entry);
    });
  }

  void _handleRemove() {
    _entry = null;
    if (!_isDetaching && mounted) {
      widget.onBack();
    }
  }

  void _detach() {
    final entry = _entry;
    if (entry == null) {
      return;
    }
    _entry = null;
    _isDetaching = true;
    entry.remove();
    _isDetaching = false;
  }

  @override
  void dispose() {
    _syncRevision++;
    _detach();
    _route = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

final _routeExitGuards = Expando<Set<Future<bool> Function()>>();

Future<bool> canLeaveRoute(Route<dynamic> route) async {
  final guards = _routeExitGuards[route]?.toList().reversed;
  if (guards == null || guards.isEmpty) {
    return route.popDisposition != RoutePopDisposition.doNotPop;
  }
  for (final guard in guards) {
    final allowed = await guard();
    if (!route.isActive) return true;
    if (!allowed) return false;
  }
  return true;
}

class _RouteExitRegistration extends StatefulWidget {
  const _RouteExitRegistration({required this.onExit, required this.child});

  final FutureOr<bool> Function(BuildContext context)? onExit;
  final Widget child;

  @override
  State<_RouteExitRegistration> createState() => _RouteExitRegistrationState();
}

class _RouteExitRegistrationState extends State<_RouteExitRegistration> {
  ModalRoute<dynamic>? _route;

  Future<bool> _check() async =>
      !mounted || widget.onExit == null || await widget.onExit!(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (identical(route, _route)) return;
    _detach();
    _route = route;
    if (route != null && widget.onExit != null) {
      (_routeExitGuards[route] ??= <Future<bool> Function()>{}).add(_check);
    }
  }

  @override
  void didUpdateWidget(covariant _RouteExitRegistration oldWidget) {
    super.didUpdateWidget(oldWidget);
    final route = _route;
    if (route == null) return;
    if (widget.onExit == null) {
      _detach();
    } else {
      (_routeExitGuards[route] ??= <Future<bool> Function()>{}).add(_check);
    }
  }

  void _detach() {
    final route = _route;
    if (route != null) _routeExitGuards[route]?.remove(_check);
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

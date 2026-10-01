import 'dart:async';

import 'package:flutter/widgets.dart';

import 'inherited.dart';

class CommonPopScope extends StatelessWidget {
  final Widget child;
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
    return PopScope(
      canPop: onPop == null || hasBackLayer,
      onPopInvokedWithResult: onPop == null
          ? null
          : (didPop, _) async {
              if (didPop) {
                return;
              }
              final res = await onPop!(context);
              if (!context.mounted) {
                return;
              }
              if (!res) {
                return;
              }
              Navigator.of(context).pop();
              if (onPopSuccess != null) {
                await onPopSuccess!();
              }
            },
      child: child,
    );
  }
}

class BackLayerScope extends StatefulWidget {
  final Widget child;
  final VoidCallback onBack;

  /// Arms the back-gesture entry. Toggling this instead of mounting the scope
  /// lets a caller keep the subtree in place, so a focused field keeps its
  /// keyboard across the change.
  final bool enabled;

  @visibleForTesting
  final void Function(void Function(Duration) callback)?
  schedulePostFrameCallback;

  const BackLayerScope({
    super.key,
    required this.onBack,
    required this.child,
    this.enabled = true,
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
    _sync();
  }

  @override
  void didUpdateWidget(BackLayerScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _sync(force: true);
    }
  }

  void _sync({bool force = false}) {
    final route = ModalRoute.of(context);
    final isPageActive = PageActivityScope.isActiveOf(context);
    if (!force && identical(_route, route) && _isPageActive == isPageActive) {
      return;
    }
    _detach();
    _route = route;
    _isPageActive = isPageActive;
    final revision = ++_syncRevision;
    if (!widget.enabled) {
      return;
    }
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

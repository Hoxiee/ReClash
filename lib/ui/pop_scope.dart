import 'package:flutter/widgets.dart';
import 'package:prism_ui/pop_scope.dart' as prism;

import 'inherited.dart';

typedef CommonPopScope = prism.PopGuard;

/// Keeps a page's own back layer, in the app's [PageActivityScope], between the
/// route and the pop scope that would otherwise pop the page.
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

Future<bool> canLeaveRoute(Route<dynamic> route) => prism.canLeaveRoute(route);

import 'dart:async';

import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/tools.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'catalog.dart';
import 'search.dart';

class ToolsSearchLauncher extends ConsumerStatefulWidget {
  const ToolsSearchLauncher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ToolsSearchLauncher> createState() =>
      _ToolsSearchLauncherState();
}

class _ToolsSearchLauncherState extends ConsumerState<ToolsSearchLauncher> {
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_shortcut);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_shortcut);
    super.dispose();
  }

  bool _shortcut(KeyEvent event) {
    if (event is! KeyDownEvent ||
        !controlSingleActivator(
          LogicalKeyboardKey.keyK,
        ).accepts(event, HardwareKeyboard.instance)) {
      return false;
    }
    unawaited(_open(context));
    return true;
  }

  Future<void> _open(BuildContext caller) async {
    if (_showing || !mounted) return;
    final pageLabel = ref.read(shownPageLabelProvider);
    final pageContext = GlobalObjectKey(pageLabel).currentContext;
    final focused = FocusManager.instance.primaryFocus;
    final focusedContext = focused?.context;
    final origin =
        focusedContext != null &&
            PageActivityScope.isActiveOf(focusedContext) &&
            ModalRoute.of(focusedContext)?.isCurrent == true
        ? focusedContext
        : pageContext ?? caller;
    final originRoute = ModalRoute.of(origin);
    if (originRoute == null ||
        !originRoute.isCurrent ||
        originRoute is PopupRoute) {
      return;
    }
    if (pageLabel == PageLabel.tools) {
      final host = const GlobalObjectKey(PageLabel.tools).currentState;
      if (host is ToolsViewState) {
        _showing = true;
        try {
          await host.openSearch();
        } finally {
          _showing = false;
        }
        return;
      }
    }
    _showing = true;
    try {
      final entry = await showSheet<ToolEntry>(
        context: origin,
        builder: (sheetContext) => ToolsCatalogPanel(
          autofocus: true,
          onDismiss: () => Navigator.of(sheetContext).pop(),
          onSelect: (entry) async => Navigator.of(sheetContext).pop(entry),
        ),
      );
      if (!mounted) return;
      if (entry == null) {
        if (focused?.context != null) focused?.requestFocus();
        return;
      }
      final navigator = originRoute.navigator;
      if (navigator == rootNavigatorKey.currentState &&
          navigator?.canPop() == true) {
        if (!await canLeaveRoute(originRoute) || !mounted) return;
        if (originRoute.isActive) navigator!.pop();
      }
      ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final host = const GlobalObjectKey(PageLabel.tools).currentState;
        if (host is ToolsViewState) {
          unawaited(host.openEntry(entry));
        } else if (entry.command case final command?) {
          ref.read(toolsSessionProvider.notifier).requestCommand(command);
        } else if ((entry.unavailableReason == null
                ? entry.route
                : entry.fallback)
            case final route?) {
          ref.read(toolsSessionProvider.notifier).open(route);
        }
      });
    } finally {
      _showing = false;
    }
  }

  @override
  Widget build(BuildContext context) => GlobalSearchScope(
    open: (context) => unawaited(_open(context)),
    child: widget.child,
  );
}

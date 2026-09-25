import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/widgets/base/inherited.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../base/focus.dart';
import 'scaffold.dart';
import 'side_sheet.dart';
import 'snap_sheet.dart';

@immutable
class SheetProps {
  final double? maxWidth;
  final double? maxHeight;
  final bool isScrollControlled;
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool blur;

  const SheetProps({
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
    this.useSafeArea = true,
    this.isScrollControlled = false,
    this.blur = true,
  });
}

@immutable
class ExtendProps {
  final double? maxWidth;
  final bool useSafeArea;
  final bool blur;
  final bool forceFull;

  const ExtendProps({
    this.maxWidth,
    this.useSafeArea = true,
    this.blur = true,
    this.forceFull = false,
  });
}

enum SheetType { page, bottomSheet, sideSheet }

Future<T?> showSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  SheetProps props = const SheetProps(),
}) {
  final isMobile = context.isMobileView;
  return switch (isMobile) {
    true => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: props.isScrollControlled,
      builder: (_) {
        return SheetProvider(
          type: SheetType.bottomSheet,
          child: builder(context),
        );
      },
      backgroundColor: props.backgroundColor,
      showDragHandle: false,
      useSafeArea: props.useSafeArea,
    ),
    false => showModalSideSheet<T>(
      useSafeArea: props.useSafeArea,
      isScrollControlled: props.isScrollControlled,
      context: context,
      backgroundColor: props.backgroundColor,
      constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
      filter: props.blur ? commonFilter : null,
      builder: (_) {
        return SheetProvider(
          type: SheetType.sideSheet,
          child: builder(context),
        );
      },
    ),
  };
}

Future<T?> showExtend<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  ExtendProps props = const ExtendProps(),
}) {
  final isMobile = context.isMobileView;
  return switch (isMobile || props.forceFull) {
    true => BaseNavigator.push(
      context,
      SheetProvider(type: SheetType.page, child: builder(context)),
    ),
    false => showModalSideSheet<T>(
      useSafeArea: props.useSafeArea,
      context: context,
      constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
      filter: props.blur ? commonFilter : null,
      builder: (context) {
        return SheetProvider(
          type: SheetType.sideSheet,
          child: builder(context),
        );
      },
    ),
  };
}

/// Opens a sheet the reader drags between [detents]; it follows the view across
/// the mobile breakpoint, reopening in the other form and yielding that form.
Future<T?> showSnapSheet<T>(
  BuildContext context, {
  required SnapSheetBuilder builder,
  double initialScrollOffset = 0,
  List<double> detents = snapSheetDetents,
  double? collapsedDetent,
  SnapSheetController? controller,
}) {
  final completer = Completer<T?>();
  final barrierColor = Theme.of(context).bottomSheetTheme.modalBarrierColor;

  void open({required bool isMobile}) {
    var crossed = false;
    Widget home(BuildContext sheetContext, ScrollController? controller) {
      return _SnapSheetHome(
        isMobile: isMobile,
        onCross: () {
          final route = ModalRoute.of(sheetContext);
          if (crossed || route?.isCurrent != true || !context.mounted) {
            return;
          }
          crossed = true;
          Navigator.of(sheetContext).pop();
          open(isMobile: !isMobile);
        },
        child: builder(sheetContext, controller),
      );
    }

    final Future<T?> closed;
    if (isMobile) {
      final navigator = Navigator.of(context);
      closed = navigator.push(
        SnapSheetRoute<T>(
          builder: home,
          detents: detents,
          collapsedDetent: collapsedDetent,
          initialScrollOffset: initialScrollOffset,
          sheetController: controller,
          sheetBarrierColor: barrierColor ?? Colors.black54,
          barrierLabel: MaterialLocalizations.of(
            context,
          ).modalBarrierDismissLabel,
          capturedThemes: InheritedTheme.capture(
            from: context,
            to: navigator.context,
          ),
        ),
      );
    } else {
      controller?.attachSide();
      closed = showModalSideSheet<T>(
        context: context,
        constraints: const BoxConstraints(maxWidth: 360),
        filter: commonFilter,
        aside: controller?.aside,
        builder: (context) {
          return SheetProvider(
            type: SheetType.sideSheet,
            child: home(context, null),
          );
        },
      );
    }
    unawaited(
      closed.then((value) {
        if (!isMobile) {
          controller?.detachSide();
        }
        if (!crossed) {
          completer.complete(value);
        }
      }),
    );
  }

  open(isMobile: context.isMobileView);
  return completer.future;
}

class _SnapSheetHome extends ConsumerWidget {
  const _SnapSheetHome({
    required this.isMobile,
    required this.onCross,
    required this.child,
  });

  final bool isMobile;
  final VoidCallback onCross;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isMobileViewProvider) != isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onCross());
    }
    return child;
  }
}

/// Forwards to [CommonScaffold], which detects the surrounding [SheetType] and
/// draws the matching bar itself; [sheetTransparentToolBar] maps to [floatBody].
class AdaptiveSheetScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool sheetTransparentToolBar;
  final bool? centerTitle;
  final List<IconButtonData> actions;
  final VoidCallback? backAction;

  const AdaptiveSheetScaffold({
    super.key,
    required this.body,
    required this.title,
    this.sheetTransparentToolBar = false,
    this.centerTitle,
    this.actions = const [],
    this.backAction,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: title,
      centerTitle: centerTitle,
      iconActions: actions,
      floatBody: sheetTransparentToolBar,
      backAction: backAction,
      body: ModalFocusScope(child: body),
    );
  }
}

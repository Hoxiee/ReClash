import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/manager/status_manager.dart';
import 'package:reclash/models/state.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/widgets/base/inherited.dart';
import 'package:reclash/widgets/layout/scaffold.dart';
import 'package:reclash/widgets/layout/sheet.dart';

extension BuildContextExtension on BuildContext {
  CommonScaffoldState? get commonScaffoldState {
    return findAncestorStateOfType<CommonScaffoldState>();
  }

  bool get isMobileView {
    return ProviderScope.containerOf(
      this,
      listen: false,
    ).read(isMobileViewProvider);
  }

  void safeNestedPop<T extends Object?>([T? result]) {
    final nestedPop = SheetProvider.of(this)?.nestedNavigatorPop;
    if (nestedPop != null) {
      return nestedPop(result);
    } else {
      return Navigator.of(this).pop(result);
    }
  }

  double get sheetTopPadding {
    final sheetType = SheetProvider.of(this)?.type;
    if (sheetType == SheetType.bottomSheet) {
      return sheetAppBarHeight;
    } else {
      return 10;
    }
  }

  bool get isInBottomSheet =>
      SheetProvider.of(this)?.type == SheetType.bottomSheet;

  bool get isInSheet => SheetProvider.of(this) != null;

  /// Space the floating bar reserves at the top; pages pad their leading edge
  /// by this so the first item clears the bar yet scrolls under its scrim.
  double get appBarInset =>
      FloatingBarScope.of(this) ??
      (isInBottomSheet
          ? sheetAppBarHeight
          : MediaQuery.paddingOf(this).top + pageToolbarHeight);

  double get contentTopPadding =>
      isInBottomSheet ? sheetAppBarHeight : appBarInset + 12;

  void showNotifier(
    String text, {
    MessageLevel level = MessageLevel.info,
    MessageActionState? actionState,
  }) {
    return findAncestorStateOfType<StatusManagerState>()?.message(
      text,
      level: level,
      actionState: actionState,
    );
  }

  void showSnackBar(String message, {SnackBarAction? action}) {
    final width = MediaQuery.sizeOf(this).width;
    EdgeInsets margin;
    if (width < 600) {
      margin = const EdgeInsets.only(bottom: 16, right: 16, left: 16);
    } else {
      margin = EdgeInsets.only(bottom: 16, left: 16, right: width - 316);
    }
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        action: action,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        margin: margin,
      ),
    );
  }

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get disableAnimations => MediaQuery.disableAnimationsOf(this);

  Duration motionDuration(Duration duration) =>
      disableAnimations ? Duration.zero : duration;

  TextTheme get textTheme => Theme.of(this).textTheme;

  AppLocalizations get appLocalizations => AppLocalizations.of(this);

  // A positive delay renders as the number plus its unit (optionally with the
  // approximate marker); anything else is a timeout and localizes rather than
  // hardcoding 'Timeout'. `suffix` keeps each call site's unit intact ('' for
  // no unit, ' ms' for the common case).
  String delayText(int delay, {String suffix = ' ms', bool approx = false}) =>
      delay > 0
      ? '${approx ? '≈' : ''}$delay$suffix'
      : appLocalizations.timeout;

  T? findLastStateOfType<T extends State>() {
    T? state;

    void visitor(Element element) {
      if (!element.mounted) {
        return;
      }
      if (element is StatefulElement) {
        if (element.state is T) {
          state = element.state as T;
        }
      }
      element.visitChildren(visitor);
    }

    visitor(this as Element);
    return state;
  }
}

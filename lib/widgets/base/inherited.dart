import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/widgets/layout/sheet.dart';

class PageActivityScope extends InheritedWidget {
  final bool isActive;

  const PageActivityScope({
    super.key,
    required this.isActive,
    required super.child,
  });

  static bool isActiveOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<PageActivityScope>()
            ?.isActive ??
        true;
  }

  @override
  bool updateShouldNotify(PageActivityScope oldWidget) {
    return isActive != oldWidget.isActive;
  }
}

const double _floatingActionButtonHeight = 56;

class BottomInsetScope extends InheritedWidget {
  static const double floatingActionButtonInset =
      kFloatingActionButtonMargin + _floatingActionButtonHeight;

  static const double dockedSearchHeight = 48;
  static const double dockedSearchMargin = kFloatingActionButtonMargin;
  static const double dockedSearchInset =
      dockedSearchMargin + dockedSearchHeight;

  final double inset;

  const BottomInsetScope({
    super.key,
    required this.inset,
    required super.child,
  });

  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<BottomInsetScope>()
            ?.inset ??
        0;
  }

  @override
  bool updateShouldNotify(BottomInsetScope oldWidget) {
    return inset != oldWidget.inset;
  }
}

class TopInsetScope extends InheritedWidget {
  final double inset;

  const TopInsetScope({super.key, required this.inset, required super.child});

  static double? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TopInsetScope>()?.inset;
  }

  @override
  bool updateShouldNotify(TopInsetScope oldWidget) {
    return inset != oldWidget.inset;
  }
}

class FloatingBarScope extends InheritedWidget {
  final double inset;

  const FloatingBarScope({
    super.key,
    required this.inset,
    required super.child,
  });

  static double? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FloatingBarScope>()
        ?.inset;
  }

  @override
  bool updateShouldNotify(FloatingBarScope oldWidget) {
    return inset != oldWidget.inset;
  }
}

class CommonScaffoldBackActionProvider extends InheritedWidget {
  final VoidCallback? backAction;

  const CommonScaffoldBackActionProvider({
    super.key,
    required this.backAction,
    required super.child,
  });

  static CommonScaffoldBackActionProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CommonScaffoldBackActionProvider>();
  }

  @override
  bool updateShouldNotify(CommonScaffoldBackActionProvider oldWidget) =>
      backAction != oldWidget.backAction;
}

class CommonScaffoldFabExtendedProvider extends InheritedWidget {
  final bool isExtended;

  const CommonScaffoldFabExtendedProvider({
    super.key,
    required this.isExtended,
    required super.child,
  });

  static CommonScaffoldFabExtendedProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
          CommonScaffoldFabExtendedProvider
        >();
  }

  @override
  bool updateShouldNotify(CommonScaffoldFabExtendedProvider oldWidget) =>
      isExtended != oldWidget.isExtended;
}

class ItemPositionProvider extends InheritedWidget {
  final ItemPosition position;

  const ItemPositionProvider({
    super.key,
    required this.position,
    required super.child,
  });

  static ItemPositionProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ItemPositionProvider>();
  }

  @override
  bool updateShouldNotify(ItemPositionProvider oldWidget) =>
      position != oldWidget.position;
}

class ProxyDecoratorProvider extends InheritedWidget {
  final bool isProxyDecorator;

  const ProxyDecoratorProvider({
    super.key,
    required this.isProxyDecorator,
    required super.child,
  });

  static ProxyDecoratorProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProxyDecoratorProvider>();
  }

  @override
  bool updateShouldNotify(ProxyDecoratorProvider oldWidget) =>
      isProxyDecorator != oldWidget.isProxyDecorator;
}

class SheetProvider<T> extends InheritedWidget {
  final SheetType type;
  final void Function([T? result])? nestedNavigatorPop;

  /// The close button's way out of the sheet; [nestedNavigatorPop] only pops.
  final VoidCallback? onClose;

  const SheetProvider({
    super.key,
    required super.child,
    required this.type,
    this.nestedNavigatorPop,
    this.onClose,
  });

  SheetProvider copyWith({
    SheetType? type,
    void Function([T? result])? nestedNavigatorPop,
    VoidCallback? onClose,
    required Widget child,
  }) {
    return SheetProvider<T>(
      type: type ?? this.type,
      nestedNavigatorPop: nestedNavigatorPop ?? this.nestedNavigatorPop,
      onClose: onClose ?? this.onClose,
      child: child,
    );
  }

  static SheetProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SheetProvider>();
  }

  @override
  bool updateShouldNotify(SheetProvider oldWidget) =>
      type != oldWidget.type ||
      nestedNavigatorPop != oldWidget.nestedNavigatorPop ||
      onClose != oldWidget.onClose;
}

class SheetOverhangScope extends InheritedWidget {
  final ValueListenable<double> overhang;
  final bool fitsContent;

  const SheetOverhangScope({
    super.key,
    required this.overhang,
    this.fitsContent = false,
    required super.child,
  });

  static ValueListenable<double>? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SheetOverhangScope>()
        ?.overhang;
  }

  static bool fillsDetentOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SheetOverhangScope>();
    return scope != null && !scope.fitsContent;
  }

  @override
  bool updateShouldNotify(SheetOverhangScope oldWidget) =>
      overhang != oldWidget.overhang || fitsContent != oldWidget.fitsContent;
}

/// Resolves once the content has closed the sheet or decided to keep it.
typedef SheetDismissHandler = Future<void> Function();

/// Lets a sheet's content take over what a drag away or a tap outside does.
class SheetDismissScope extends InheritedWidget {
  final ValueNotifier<SheetDismissHandler?> handler;

  const SheetDismissScope({
    super.key,
    required this.handler,
    required super.child,
  });

  static ValueNotifier<SheetDismissHandler?>? of(BuildContext context) {
    return context.getInheritedWidgetOfExactType<SheetDismissScope>()?.handler;
  }

  @override
  bool updateShouldNotify(SheetDismissScope oldWidget) =>
      handler != oldWidget.handler;
}

class SheetStackScope extends InheritedWidget {
  final ValueNotifier<bool> surfaceClaimed;

  const SheetStackScope({
    super.key,
    required this.surfaceClaimed,
    required super.child,
  });

  static ValueNotifier<bool>? of(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<SheetStackScope>()
        ?.surfaceClaimed;
  }

  @override
  bool updateShouldNotify(SheetStackScope oldWidget) =>
      surfaceClaimed != oldWidget.surfaceClaimed;
}

/// Makes a scroll controller that hands drags to the sheet, one per route
/// inside it: a controller shared by pages kept alive together fails the
/// scrollbar's single position check.
class SheetScrollScope extends InheritedWidget {
  final SheetScrollControllerFactory createController;

  const SheetScrollScope({
    super.key,
    required this.createController,
    required super.child,
  });

  static SheetScrollControllerFactory? of(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<SheetScrollScope>()
        ?.createController;
  }

  @override
  bool updateShouldNotify(SheetScrollScope oldWidget) =>
      createController != oldWidget.createController;
}

typedef SheetScrollControllerFactory =
    ScrollController Function({double initialScrollOffset});

ScrollController sheetScrollController(
  BuildContext context, {
  double initialScrollOffset = 0.0,
}) {
  final createController = SheetScrollScope.of(context);
  if (createController == null) {
    return ScrollController(initialScrollOffset: initialScrollOffset);
  }
  return createController(initialScrollOffset: initialScrollOffset);
}

class SheetSettlingScope extends InheritedWidget {
  final ValueListenable<bool> settling;

  const SheetSettlingScope({
    super.key,
    required this.settling,
    required super.child,
  });

  static ValueListenable<bool>? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SheetSettlingScope>()
        ?.settling;
  }

  @override
  bool updateShouldNotify(SheetSettlingScope oldWidget) =>
      settling != oldWidget.settling;
}

/// When [active], an `open` item drives the detail pane, not a sheet: a
/// selecting scope ([pushes] false) swaps its root, a pushing one drills deeper.
class SettingsPaneScope extends InheritedWidget {
  final bool active;
  final bool pushes;
  final String? selectedId;
  final void Function(SettingsPaneSelection selection) onSelect;

  const SettingsPaneScope({
    super.key,
    required this.active,
    this.pushes = false,
    required this.selectedId,
    required this.onSelect,
    required super.child,
  });

  static SettingsPaneScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsPaneScope>();
  }

  @override
  bool updateShouldNotify(SettingsPaneScope oldWidget) =>
      active != oldWidget.active ||
      pushes != oldWidget.pushes ||
      selectedId != oldWidget.selectedId ||
      onSelect != oldWidget.onSelect;
}

class SettingsPaneSelection {
  final String id;
  final Widget detail;

  /// The row's label, so the pane titles itself instead of the tool drawing one.
  final Widget? title;

  final String? focusTarget;

  const SettingsPaneSelection({
    required this.id,
    required this.detail,
    this.title,
    this.focusTarget,
  });
}

/// Names a setting the enclosing screen should scroll to and pulse once, so a
/// deep search hit lands on its exact row; [nonce] re-fires an open screen.
class SettingFocusScope extends InheritedWidget {
  final String? target;
  final int nonce;

  const SettingFocusScope({
    super.key,
    required this.target,
    this.nonce = 0,
    required super.child,
  });

  static SettingFocusScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingFocusScope>();
  }

  @override
  bool updateShouldNotify(SettingFocusScope oldWidget) =>
      target != oldWidget.target || nonce != oldWidget.nonce;
}

/// Marks a subtree as a list-detail pane body that already has a heading, so a
/// [CommonScaffold]/[BaseScaffold] inside it drops its app bar and top inset
/// instead of stacking a second bar. Scoped to the tool's root; pushed pages
/// regain full chrome.
class ToolsPaneChrome extends InheritedWidget {
  final bool suppressChrome;

  /// Where a chrome-suppressed scaffold publishes the actions it would have
  /// drawn in its own app bar, so the shared pane bar can render them instead
  /// of dropping them with the rest of the chrome.
  final ValueNotifier<Widget?>? actionsSink;

  const ToolsPaneChrome({
    super.key,
    required this.suppressChrome,
    this.actionsSink,
    required super.child,
  });

  static bool suppressOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ToolsPaneChrome>()
            ?.suppressChrome ??
        false;
  }

  static ValueNotifier<Widget?>? actionsSinkOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ToolsPaneChrome>()
        ?.actionsSink;
  }

  @override
  bool updateShouldNotify(ToolsPaneChrome oldWidget) =>
      suppressChrome != oldWidget.suppressChrome ||
      actionsSink != oldWidget.actionsSink;
}

extension SheetHeightExt on WidgetRef {
  double sheetHeight(BuildContext context, double factor) {
    final viewHeight = watch(viewHeightProvider);
    if (SheetProvider.of(context)?.type != SheetType.bottomSheet) {
      return double.maxFinite;
    }
    return viewHeight * factor;
  }
}

class ProfileIdProvider extends InheritedWidget {
  final int profileId;

  const ProfileIdProvider({
    super.key,
    required this.profileId,
    required super.child,
  });

  static ProfileIdProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProfileIdProvider>();
  }

  @override
  bool updateShouldNotify(ProfileIdProvider oldWidget) =>
      profileId != oldWidget.profileId;
}

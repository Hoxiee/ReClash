import 'package:reclash/ui/item_position.dart';
import 'package:reclash/ui/sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

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

class BottomInsetScope extends InheritedWidget {
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

class NavigationDockScope extends InheritedWidget {
  const NavigationDockScope({
    super.key,
    required this.navigation,
    required this.floating,
    required this.held,
    required this.bottomPadding,
    required super.child,
  });

  final Widget navigation;
  final bool floating;

  /// Whether this page shows [navigation], which the shell then leaves out.
  final bool held;
  final double bottomPadding;

  static NavigationDockScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NavigationDockScope>();

  @override
  bool updateShouldNotify(NavigationDockScope oldWidget) =>
      navigation != oldWidget.navigation ||
      floating != oldWidget.floating ||
      held != oldWidget.held ||
      bottomPadding != oldWidget.bottomPadding;
}

/// The room content still has to leave at its top, where the scaffold has
/// already placed something of its own there.
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

/// Insets content while scroll views and their bars span the entire pane.
class BodyInsetScope extends InheritedWidget {
  final double inset;

  const BodyInsetScope({super.key, required this.inset, required super.child});

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BodyInsetScope>()?.inset ?? 0;

  @override
  bool updateShouldNotify(BodyInsetScope oldWidget) => inset != oldWidget.inset;
}

/// Place above the page so its scaffold can read the centered content inset.
class CappedBodyScope extends StatelessWidget {
  const CappedBodyScope({
    super.key,
    required this.maxWidth,
    required this.child,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) => BodyInsetScope(
      inset: constraints.maxWidth > maxWidth
          ? (constraints.maxWidth - maxWidth) / 2
          : 0,
      child: child,
    ),
  );
}

/// How far a page's app bar reaches over the body floating under it.
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
  final double lift;

  const ProxyDecoratorProvider({
    super.key,
    required this.isProxyDecorator,
    required this.lift,
    required super.child,
  });

  static ProxyDecoratorProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProxyDecoratorProvider>();
  }

  @override
  bool updateShouldNotify(ProxyDecoratorProvider oldWidget) =>
      isProxyDecorator != oldWidget.isProxyDecorator || lift != oldWidget.lift;
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

/// How far a sheet's content hangs below the screen at its current detent.
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

class PageNavigationScope extends InheritedWidget {
  const PageNavigationScope({
    super.key,
    required this.canOpen,
    required this.open,
    this.push,
    required super.child,
  });

  final bool Function(Widget page) canOpen;
  final void Function(Widget page) open;

  /// Pushes a page that is not one of the host's own, or returns null when
  /// the host does not own the navigator of `context`.
  final Future<T?>? Function<T>(BuildContext context, Widget page)? push;

  static PageNavigationScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PageNavigationScope>();

  @override
  bool updateShouldNotify(PageNavigationScope oldWidget) =>
      canOpen != oldWidget.canOpen ||
      open != oldWidget.open ||
      push != oldWidget.push;
}

class GlobalSearchScope extends InheritedWidget {
  const GlobalSearchScope({
    super.key,
    required this.open,
    required super.child,
  });

  final void Function(BuildContext context) open;

  static GlobalSearchScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlobalSearchScope>();

  @override
  bool updateShouldNotify(GlobalSearchScope oldWidget) =>
      open != oldWidget.open;
}

class PagePresentationScope extends InheritedWidget {
  const PagePresentationScope({
    super.key,
    this.title,
    this.previousTitle,
    this.transitionTitle,
    this.onTitleSelect,
    this.previousHasBack = false,
    required super.child,
  });

  final Widget? title;
  final String? previousTitle;
  final String? transitionTitle;
  final ValueChanged<int>? onTitleSelect;
  final bool previousHasBack;

  static PagePresentationScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PagePresentationScope>();

  @override
  bool updateShouldNotify(PagePresentationScope oldWidget) =>
      title != oldWidget.title ||
      previousTitle != oldWidget.previousTitle ||
      transitionTitle != oldWidget.transitionTitle ||
      onTitleSelect != oldWidget.onTitleSelect ||
      previousHasBack != oldWidget.previousHasBack;
}

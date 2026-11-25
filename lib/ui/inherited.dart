import 'package:reclash/ui/sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

export 'package:prism_ui/inherited.dart'
    show
        BodyInsetScope,
        BottomInsetScope,
        CappedBodyScope,
        FloatingBarScope,
        GlobalSearchScope,
        ItemPositionProvider,
        NavigationDockScope,
        PageActivityScope,
        PageNavigationScope,
        PagePresentationScope,
        ProxyDecoratorProvider,
        TopInsetScope;

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

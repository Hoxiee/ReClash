part of '../state.dart';

@riverpod
NavigationItemsState navigationItemsState(Ref ref) {
  final openLogs = ref.watch(appSettingProvider).openLogs;
  final hasProfiles = ref.watch(
    profilesProvider.select((state) => state.isNotEmpty),
  );
  final hasProxies = ref.watch(
    currentGroupsStateProvider.select((state) => state.value.isNotEmpty),
  );
  final isInit = ref.watch(initProvider);
  return NavigationItemsState(
    value:
        navigationPort?.getItems(
          openLogs: openLogs,
          hasProxies: !isInit ? hasProfiles : hasProxies,
        ) ??
        const [],
  );
}

@riverpod
NavigationItemsState currentNavigationItemsState(Ref ref) {
  final navigationItemsState = ref.watch(navigationItemsStateProvider);
  final compactBar =
      ref.watch(isBarSurfaceProvider) && ref.watch(isMobileViewProvider);
  final navigationItemMode = compactBar
      ? NavigationItemMode.mobile
      : NavigationItemMode.desktop;
  return NavigationItemsState(
    value: navigationItemsState.value
        .where((element) => element.modes.contains(navigationItemMode))
        .toList(),
  );
}

@riverpod
NavigationState navigationState(Ref ref) {
  final pageLabel = ref.watch(currentPageLabelProvider);
  final navigationItems = ref.watch(currentNavigationItemsStateProvider).value;
  final viewMode = ref.watch(viewModeProvider);
  final locale = ref.watch(appSettingProvider).locale;
  final index = navigationItems.lastIndexWhere(
    (element) => element.label == pageLabel,
  );
  final currentIndex = index == -1 ? 0 : index;
  return NavigationState(
    pageLabel: pageLabel,
    navigationItems: navigationItems,
    viewMode: viewMode,
    locale: locale,
    currentIndex: currentIndex,
  );
}

@riverpod
DashboardState dashboardState(Ref ref) {
  final dashboardWidgets = ref.watch(
    appSettingProvider.select((state) => state.dashboardWidgets),
  );
  return DashboardState(dashboardWidgets: dashboardWidgets);
}

@riverpod
MoreToolsSelectorState moreToolsSelectorState(Ref ref) {
  final stripLabels = {
    for (final item in ref.watch(currentNavigationItemsStateProvider).value)
      item.label,
  };
  final items = ref
      .watch(navigationItemsStateProvider)
      .value
      .where(
        (element) =>
            element.modes.contains(NavigationItemMode.more) &&
            !stripLabels.contains(element.label),
      )
      .toList();

  return MoreToolsSelectorState(navigationItems: items);
}

@riverpod
bool isCurrentPage(
  Ref ref,
  PageLabel pageLabel, {
  bool Function(PageLabel pageLabel, ViewMode viewMode)? handler,
}) {
  final currentPageLabel = ref.watch(currentPageLabelProvider);
  if (pageLabel == currentPageLabel) {
    return true;
  }
  if (handler != null) {
    final viewMode = ref.watch(viewModeProvider);
    return handler(currentPageLabel, viewMode);
  }
  return false;
}

@riverpod
double overlayTopOffset(Ref ref) {
  final isMobileView = ref.watch(isMobileViewProvider);
  final version = ref.watch(versionProvider);
  ref.watch(viewSizeProvider);
  final showsHeader = showsWindowHeader(
    isDesktop: system.isDesktop,
    isMacOS: system.isMacOS,
    version: version,
    isMobileView: isMobileView,
  );
  return kToolbarHeight + (showsHeader ? kHeaderHeight : 0);
}

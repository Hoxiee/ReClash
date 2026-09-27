import 'dart:async';
import 'package:reclash/icons/icons.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessView extends ConsumerStatefulWidget {
  const AccessView({super.key});

  @override
  ConsumerState<AccessView> createState() => _AccessViewState();
}

class _AccessViewState extends ConsumerState<AccessView> {
  late ScrollController _controller;
  late final TextEditingController _searchController;
  List<String>? _pinedList;
  bool _isInit = false;
  bool _installedAppsPermissionGranted = true;

  final _completer = Completer();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _searchController = TextEditingController(
      text: ref.read(queryProvider(QueryTag.access)),
    );
    _completer.complete(_loadPackages());
    final accessControl = ref
        .read(vpnSettingProvider.select((state) => state.accessControlProps))
        .copyWith();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(accessControlStateProvider.notifier).value = accessControl;
      _isInit = true;
      _pinList();
    });
    ref.listenManual(
      accessControlStateProvider.select((state) => state.mode),
      (_, _) => _pinList(),
    );
  }

  Future<void> _loadPackages() async {
    final action = ref.read(systemActionProvider.notifier);
    final packages = await action.getPackages();
    final granted =
        packages.isNotEmpty || await action.isInstalledAppsPermissionGranted();
    if (!mounted || granted == _installedAppsPermissionGranted) {
      return;
    }
    setState(() {
      _installedAppsPermissionGranted = granted;
    });
  }

  Future<void> _handleGrantInstalledAppsPermission() async {
    final appLocalizations = context.appLocalizations;
    final granted = await ref
        .read(systemActionProvider.notifier)
        .requestInstalledAppsPermission();
    if (!mounted) {
      return;
    }
    if (!granted) {
      final res = await dialogs.showMessage(
        message: TextSpan(
          text: appLocalizations.installedAppsPermissionDeniedMessage,
        ),
        confirmText: appLocalizations.settings,
      );
      if (res == true) {
        await app?.openAppSettings();
      }
      return;
    }
    await globalState.loadingRun(_loadPackages, tag: LoadingTag.access);
  }

  void _pinList() {
    if (!_isInit || !mounted) {
      return;
    }
    setState(() {
      _pinedList = ref.read(accessControlStateProvider).currentList;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSelectAllButton({
    required bool isSelectedAll,
    required Set<String> allValues,
  }) {
    void onPressed() {
      ref.read(accessControlStateProvider.notifier).update((state) {
        final newSet = Set<String>.from(state.currentList);
        if (newSet.containsAll(allValues)) {
          newSet.removeAll(allValues);
        } else {
          newSet.addAll(allValues);
        }
        return state.copyWithNewList(newSet.toList());
      });
    }

    final appLocalizations = context.appLocalizations;
    return IconButton(
      tooltip: isSelectedAll
          ? appLocalizations.cancelSelectAll
          : appLocalizations.selectAll,
      onPressed: onPressed,
      icon: GlyphIcon(isSelectedAll ? AppGlyphs.deselect : AppGlyphs.selectAll),
    );
  }

  Widget _buildSmartSelectButton() {
    return IconButton(
      key: const ValueKey('access-intelligent-select'),
      tooltip: context.appLocalizations.intelligentSelected,
      onPressed: _intelligentSelected,
      icon: const GlyphIcon(AppGlyphs.sparkle),
    );
  }

  Future<void> _intelligentSelected() async {
    final packageNames = ref.read(
      packagesProvider.select((state) => state.map((item) => item.packageName)),
    );
    if (packageNames.isEmpty) {
      return;
    }
    final selectedPackageNames =
        (await globalState.loadingRun<List<String>>(() async {
          return await app?.getDomesticPackageNames(
                ref.read(appRegionProvider),
              ) ??
              [];
        }, tag: LoadingTag.access))?.toSet() ??
        {};
    final acceptList = packageNames
        .where((item) => !selectedPackageNames.contains(item))
        .toList();
    final rejectList = packageNames
        .where((item) => selectedPackageNames.contains(item))
        .toList();
    ref
        .read(accessControlStateProvider.notifier)
        .update(
          (state) =>
              state.copyWith(acceptList: acceptList, rejectList: rejectList),
        );
  }

  void _handleSelected(String packageName) {
    ref.read(accessControlStateProvider.notifier).update((state) {
      final newSet = Set<String>.from(state.currentList)
        ..addOrRemove(packageName);
      return state.copyWithNewList(newSet.toList());
    });
  }

  void _handleToggle() {
    ref.read(accessControlStateProvider.notifier).update((state) {
      return state.copyWith(enable: !state.enable);
    });
  }

  Future<void> _handleBack() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.saveChanges),
    );
    if (res == true) {
      _handleSave();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  AccessControlProps _getRealAccessControlProps(
    AccessControlProps accessControl,
  ) {
    final packages = ref.read(packagesProvider);
    if (packages.isEmpty) {
      return accessControl;
    }
    final viewPackageNames = packages
        .getViewList(
          pinedList: [],
          sortType: accessControl.sort,
          isFilterSystemApp: accessControl.isFilterSystemApp,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
        )
        .map((item) => item.packageName)
        .toSet();
    return accessControl.copyWithNewList(
      accessControl.currentList
          .where((item) => viewPackageNames.contains(item))
          .toList()
        ..sort(),
    );
  }

  void _handleSave() {
    final accessControl = ref.read(accessControlStateProvider);
    ref
        .read(vpnSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            accessControlProps: _getRealAccessControlProps(accessControl),
          ),
        );
  }

  Widget _buildConfirm() {
    return Consumer(
      builder: (_, ref, child) {
        final accessControl = ref.watch(accessControlStateProvider);
        final noSave = ref.watch(
          vpnSettingProvider.select((state) {
            final current = _getRealAccessControlProps(
              state.accessControlProps,
            );
            final origin = _getRealAccessControlProps(accessControl);
            return current == origin;
          }),
        );
        if (noSave) {
          return const SizedBox();
        }
        return child!;
      },
      child: CommonPopScope(
        onPop: (_) {
          _handleBack();
          return false;
        },
        child: CommonMinFilledButtonTheme(
          child: FilledButton.tonal(
            onPressed: _handleSave,
            child: Text(context.appLocalizations.save),
          ),
        ),
      ),
    );
  }

  Future<void> _exportToClipboard() async {
    await globalState.safeRun(() {
      final currentList = ref.read(
        accessControlStateProvider.select((state) => state.currentList),
      );
      Clipboard.setData(ClipboardData(text: currentList.join('\n')));
    });
  }

  Future<void> _importFormClipboard() async {
    await globalState.safeRun(() async {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text;
      if (text == null) return;
      final list = text.split('\n');
      ref
          .read(accessControlStateProvider.notifier)
          .update((state) => state.copyWithNewList(list.toSet().toList()));
    });
  }

  List<Widget> _buildActions(BuildContext context, {required bool enable}) {
    final appLocalizations = context.appLocalizations;
    return [
      _buildConfirm(),
      CommonPopupBox(
        targetBuilder: (open) {
          return IconButton(
            tooltip: appLocalizations.more,
            onPressed: () {
              open(offset: const Offset(0, 0));
            },
            icon: const GlyphIcon(AppGlyphs.more),
          );
        },
        popupBuilder: (_) => CommonPopupMenu(
          items: [
            CommonPopupMenuItem(
              glyph: AppGlyphs.swap,
              label: enable
                  ? appLocalizations.turnOff
                  : appLocalizations.turnOn,
              onPressed: _handleToggle,
            ),
            CommonPopupMenuItem(
              glyph: AppGlyphs.emergency,
              label: appLocalizations.action,
              subItems: [
                CommonPopupMenuItem(
                  glyph: AppGlyphs.copy,
                  label: appLocalizations.clipboardExport,
                  onPressed: _exportToClipboard,
                ),
                CommonPopupMenuItem(
                  glyph: AppGlyphs.paste,
                  label: appLocalizations.clipboardImport,
                  onPressed: _importFormClipboard,
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildContent({
    required List<Package> packages,
    required Set<String> valueSet,
    required bool showDockedSearch,
  }) {
    return FutureBuilder(
      future: _completer.future,
      builder: (context, snapshot) {
        final appLocalizations = context.appLocalizations;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CommonCircleLoading());
        }
        final bottomInset = showDockedSearch
            ? BottomInsetScope.dockedSearchInset +
                  MediaQuery.paddingOf(context).bottom
            : 0.0;
        return NullStatusSwitcher(
          isEmpty: packages.isEmpty,
          isSearching: ref.read(queryProvider(QueryTag.access)).isNotEmpty,
          nullStatus: NullStatus(
            label: appLocalizations.noData,
            illustration: NullStatusIllustration.apps,
          ),
          child: CommonScrollBar(
            controller: _controller,
            child: ListView.builder(
              controller: _controller,
              padding: EdgeInsets.only(bottom: bottomInset),
              itemCount: packages.length,
              itemExtent: 72,
              itemBuilder: (_, index) {
                final package = packages[index];
                return PackageListItem(
                  key: Key(package.packageName),
                  package: package,
                  value: valueSet.contains(package.packageName),
                  onChanged: (value) {
                    _handleSelected(package.packageName);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstalledAppsPermissionStatus() {
    final appLocalizations = context.appLocalizations;
    return NullStatus(
      label: appLocalizations.installedAppsPermissionRequired,
      description: appLocalizations.installedAppsPermissionDesc,
      illustration: NullStatusIllustration.permission,
      action: FilledButton.tonalIcon(
        onPressed: _handleGrantInstalledAppsPermission,
        icon: const GlyphIcon(AppGlyphs.lockOpen),
        label: Text(appLocalizations.authorize),
      ),
    );
  }

  Widget _buildModeTabs(AccessControlMode mode) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: CommonTabBar<AccessControlMode>(
        groupValue: mode,
        backgroundColor: colorScheme.surfaceContainerHigh,
        thumbColor: colorScheme.secondaryContainer,
        onValueChanged: (value) {
          if (value == null || value == mode) {
            return;
          }
          ref
              .read(accessControlStateProvider.notifier)
              .update((state) => state.copyWith(mode: value));
        },
        children: {
          AccessControlMode.acceptSelected: CommonTabLabel(
            icon: AppGlyphs.vpn,
            label: appLocalizations.accessControlIncludeInVpn,
            selected: mode == AccessControlMode.acceptSelected,
          ),
          AccessControlMode.rejectSelected: CommonTabLabel(
            icon: AppGlyphs.block,
            label: appLocalizations.accessControlExcludeFromVpn,
            selected: mode == AccessControlMode.rejectSelected,
          ),
        },
      ),
    );
  }

  Glyph _getSortIcon(AccessSortType type) {
    return switch (type) {
      AccessSortType.none => AppGlyphs.sort,
      AccessSortType.name => AppGlyphs.sortAlpha,
      AccessSortType.time => AppGlyphs.update,
    };
  }

  String _getSortLabel(AccessSortType type) {
    final appLocalizations = context.appLocalizations;
    return switch (type) {
      AccessSortType.none => appLocalizations.defaultText,
      AccessSortType.name => appLocalizations.name,
      AccessSortType.time => appLocalizations.time,
    };
  }

  Widget _buildSortButton(AccessControlProps accessControl) {
    final appLocalizations = context.appLocalizations;
    return CommonPopupBox(
      targetBuilder: (open) => IconButton(
        key: const ValueKey('access-sort-chip'),
        tooltip:
            '${appLocalizations.sort}: ${_getSortLabel(accessControl.sort)}',
        onPressed: () => open(offset: Offset.zero),
        icon: GlyphIcon(_getSortIcon(accessControl.sort)),
      ),
      popupBuilder: (_) => CommonPopupMenu(
        items: [
          for (final type in AccessSortType.values)
            CommonPopupMenuItem(
              glyph: accessControl.sort == type
                  ? AppGlyphs.check
                  : _getSortIcon(type),
              label: _getSortLabel(type),
              onPressed: () {
                ref
                    .read(accessControlStateProvider.notifier)
                    .update((state) => state.copyWith(sort: type));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSystemToggle(AccessControlProps accessControl) {
    return IconButton(
      key: const ValueKey('access-system-apps-filter'),
      tooltip: context.appLocalizations.systemApp,
      isSelected: !accessControl.isFilterSystemApp,
      onPressed: () {
        ref
            .read(accessControlStateProvider.notifier)
            .update(
              (state) =>
                  state.copyWith(isFilterSystemApp: !state.isFilterSystemApp),
            );
      },
      icon: const GlyphIcon(AppGlyphs.android),
      selectedIcon: const GlyphIcon(AppGlyphs.android),
    );
  }

  Widget _buildOfflineToggle(AccessControlProps accessControl) {
    return IconButton(
      key: const ValueKey('access-offline-apps-filter'),
      tooltip: context.appLocalizations.noNetworkApp,
      isSelected: !accessControl.isFilterNonInternetApp,
      onPressed: () {
        ref
            .read(accessControlStateProvider.notifier)
            .update(
              (state) => state.copyWith(
                isFilterNonInternetApp: !state.isFilterNonInternetApp,
              ),
            );
      },
      icon: const GlyphIcon(AppGlyphs.wifiOff),
      selectedIcon: const GlyphIcon(AppGlyphs.wifiOff),
    );
  }

  Widget _buildCountPill(int count) {
    return Semantics(
      label: context.appLocalizations.selected,
      value: '$count',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: ShapeDecoration(
          color: context.colorScheme.primaryContainer,
          shape: AppShape.full,
        ),
        child: Text(
          '$count',
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledBanner() {
    final appLocalizations = context.appLocalizations;
    return Row(
      children: [
        GlyphIcon(AppGlyphs.info, color: context.colorScheme.outline),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            appLocalizations.accessControlDisabledDesc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        CommonMinFilledButtonTheme(
          child: FilledButton.tonal(
            onPressed: _handleToggle,
            child: Text(appLocalizations.turnOn),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow({
    required AccessControlProps accessControl,
    required int count,
    Widget? selectAllButton,
    Widget? smartSelectButton,
  }) {
    final hasSelectionActions =
        selectAllButton != null || smartSelectButton != null;
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortButton(accessControl),
                _buildSystemToggle(accessControl),
                _buildOfflineToggle(accessControl),
                if (hasSelectionActions) const SizedBox(width: AppSpacing.sm),
                ?selectAllButton,
                ?smartSelectButton,
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildCountPill(count),
      ],
    );
  }

  Widget _buildControlPanel({
    required AccessControlProps accessControl,
    required int count,
    Widget? selectAllButton,
    Widget? smartSelectButton,
  }) {
    // colorOf only scales the surface toward the card opacity, which still
    // leaves a near-opaque full-width band over a wallpaper; drop the fill
    // entirely so the backdrop shows through behind the tabs and actions.
    final wallpaperActive =
        ref.watch(
          themeSettingProvider.select((value) => value.wallpaper.enabled),
        ) &&
        ref.watch(wallpaperImageProvider).asData?.value != null;
    return Material(
      key: const ValueKey('access-control-panel'),
      color: wallpaperActive ? Colors.transparent : context.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeTabs(accessControl.mode),
            const SizedBox(height: AppSpacing.sm),
            if (accessControl.enable)
              _buildActionRow(
                accessControl: accessControl,
                count: count,
                selectAllButton: selectAllButton,
                smartSelectButton: smartSelectButton,
              )
            else
              _buildDisabledBanner(),
          ],
        ),
      ),
    );
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.access).notifier).value = value
        .trim()
        .toLowerCase();
    _pinList();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider(LoadingTag.access));
    final query = ref.watch(queryProvider(QueryTag.access));
    final packages = ref.watch(packagesProvider);
    final accessControl = ref.watch(accessControlStateProvider);
    final viewPackages = packages
        .getViewList(
          pinedList: _pinedList ?? [],
          sortType: accessControl.sort,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
          isFilterSystemApp: accessControl.isFilterSystemApp,
        )
        .where(
          (package) =>
              package.label.toLowerCase().contains(query) ||
              package.packageName.toLowerCase().contains(query),
        )
        .toList();
    final currentList = accessControl.currentList;
    final viewPackageNameSet = viewPackages.map((e) => e.packageName).toSet();
    final valueSet = currentList.toSet().intersection(viewPackageNameSet);
    final needsInstalledAppsPermission =
        packages.isEmpty && !_installedAppsPermissionGranted;
    // A query with no matches empties viewPackageNameSet; keep the bar while a
    // search is active so the user can clear it instead of getting stuck.
    final showDockedSearch =
        !needsInstalledAppsPermission &&
        (viewPackageNameSet.isNotEmpty || query.isNotEmpty);
    final showSelectionActions =
        viewPackageNameSet.isNotEmpty && accessControl.enable;
    final selectAllButton = showSelectionActions
        ? _buildSelectAllButton(
            isSelectedAll: valueSet.length == viewPackageNameSet.length,
            allValues: viewPackageNameSet,
          )
        : null;
    final canMatch = ref.regionAllows(RegionalFacetId.packageMatcher);
    final smartSelectButton = showSelectionActions && canMatch
        ? _buildSmartSelectButton()
        : null;
    return CommonScaffold(
      isLoading: isLoading,
      title: context.appLocalizations.appAccessControl,
      floatBody: true,
      actions: _buildActions(context, enable: accessControl.enable),
      body: AppBarClearance(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildControlPanel(
                  accessControl: accessControl,
                  count: currentList.length,
                  selectAllButton: selectAllButton,
                  smartSelectButton: smartSelectButton,
                ),
                const Divider(height: 1),
                Expanded(
                  child: needsInstalledAppsPermission
                      ? _buildInstalledAppsPermissionStatus()
                      : DisabledMask(
                          status: !accessControl.enable,
                          child: _buildContent(
                            packages: viewPackages,
                            valueSet: valueSet,
                            showDockedSearch: showDockedSearch,
                          ),
                        ),
                ),
              ],
            ),
            if (showDockedSearch)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DockedSearchBar(
                  key: const ValueKey('access-search-field'),
                  controller: _searchController,
                  onChanged: _onSearch,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PackageListItem extends StatelessWidget {
  final Package package;
  final bool value;
  final void Function(bool?) onChanged;

  const PackageListItem({
    super.key,
    required this.package,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem.checkbox(
      leading: PackageIcon(packageName: package.packageName, size: 48),
      title: Text(
        package.label,
        style: const TextStyle(overflow: TextOverflow.ellipsis),
        maxLines: 1,
      ),
      subtitle: Text(
        package.packageName,
        style: const TextStyle(overflow: TextOverflow.ellipsis),
        maxLines: 1,
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

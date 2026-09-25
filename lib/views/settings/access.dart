import 'dart:async';
import 'package:reclash/icons/icons.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
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

  Widget _buildSelectedAllButton({
    required bool isSelectedAll,
    required Set<String> allValues,
  }) {
    void onPressed() {
      ref.read(accessControlStateProvider.notifier).update((state) {
        final newSet = Set<String>.from(state.currentList);
        final isSelectedAll = newSet.containsAll(allValues);
        if (isSelectedAll) {
          newSet.removeAll(allValues);
        } else {
          newSet.addAll(allValues);
        }
        return state.copyWithNewList(newSet.toList());
      });
    }

    final appLocalizations = context.appLocalizations;
    return FadeRotationScaleBox(
      alignment: Alignment.centerRight,
      child: isSelectedAll
          ? FloatingActionButton.extended(
              key: const ValueKey(true),
              onPressed: onPressed,
              label: Text(appLocalizations.cancelSelectAll),
              icon: const GlyphIcon(AppGlyphs.deselect),
            )
          : FloatingActionButton.extended(
              key: const ValueKey(false),
              tooltip: appLocalizations.selectAll,
              onPressed: onPressed,
              label: Text(appLocalizations.selectAll),
              icon: const GlyphIcon(AppGlyphs.selectAll),
            ),
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
    final canMatch = ref.regionAllows(RegionalFacetId.packageMatcher);
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
                if (canMatch)
                  CommonPopupMenuItem(
                    glyph: AppGlyphs.sparkle,
                    label: appLocalizations.intelligentSelected,
                    onPressed: _intelligentSelected,
                  ),
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
  }) {
    return FutureBuilder(
      future: _completer.future,
      builder: (context, snapshot) {
        final appLocalizations = context.appLocalizations;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CommonCircleLoading());
        }
        return NullStatusSwitcher(
          isEmpty: packages.isEmpty,
          nullStatus: NullStatus(
            label: appLocalizations.noData,
            illustration: NullStatusIllustration.apps,
          ),
          child: CommonScrollBar(
            controller: _controller,
            child: ListView.builder(
              controller: _controller,
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
          AccessControlMode.acceptSelected: _AccessModeTab(
            icon: AppGlyphs.vpn,
            label: appLocalizations.accessControlIncludeInVpn,
            isSelected: mode == AccessControlMode.acceptSelected,
          ),
          AccessControlMode.rejectSelected: _AccessModeTab(
            icon: AppGlyphs.block,
            label: appLocalizations.accessControlExcludeFromVpn,
            isSelected: mode == AccessControlMode.rejectSelected,
          ),
        },
      ),
    );
  }

  Widget _buildSearchField(String query) {
    final appLocalizations = context.appLocalizations;
    return TextField(
      key: const ValueKey('access-search-field'),
      controller: _searchController,
      inputFormatters: TextInputLimits.limit(TextInputLimits.search),
      textInputAction: TextInputAction.search,
      onChanged: _onSearch,
      decoration: InputDecoration(
        hintText: appLocalizations.searchApps,
        prefixIcon: const GlyphIcon(AppGlyphs.search),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: appLocalizations.clearSearch,
                onPressed: () {
                  _searchController.clear();
                  _onSearch('');
                },
                icon: const GlyphIcon(AppGlyphs.close),
              ),
        filled: true,
        fillColor: context.colorScheme.surfaceContainerLow,
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

  Widget _buildFilterBar(AccessControlProps accessControl) {
    final appLocalizations = context.appLocalizations;
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          CommonPopupBox(
            targetBuilder: (open) => IconButton.filledTonal(
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
          ),
          IconButton(
            key: const ValueKey('access-system-apps-filter'),
            tooltip: appLocalizations.systemApp,
            isSelected: !accessControl.isFilterSystemApp,
            onPressed: () {
              ref
                  .read(accessControlStateProvider.notifier)
                  .update(
                    (state) => state.copyWith(
                      isFilterSystemApp: !state.isFilterSystemApp,
                    ),
                  );
            },
            icon: const GlyphIcon(AppGlyphs.android),
            selectedIcon: const GlyphIcon(AppGlyphs.android),
          ),
          IconButton(
            key: const ValueKey('access-offline-apps-filter'),
            tooltip: appLocalizations.noNetworkApp,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required bool enable,
    required AccessControlMode mode,
    required int count,
  }) {
    final appLocalizations = context.appLocalizations;
    final description = mode == AccessControlMode.acceptSelected
        ? appLocalizations.accessControlAllowDesc
        : appLocalizations.accessControlNotAllowDesc;
    final icon = mode == AccessControlMode.acceptSelected
        ? AppGlyphs.vpn
        : AppGlyphs.block;
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            GlyphIcon(
              enable ? icon : AppGlyphs.info,
              color: enable
                  ? context.colorScheme.primary
                  : context.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                enable
                    ? description
                    : appLocalizations.accessControlDisabledDesc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (enable)
              Semantics(
                label: appLocalizations.selected,
                value: '$count',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
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
              )
            else
              FilledButton.tonal(
                onPressed: _handleToggle,
                child: Text(appLocalizations.turnOn),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel({
    required AccessControlProps accessControl,
    required String query,
    required int count,
  }) {
    return Material(
      key: const ValueKey('access-control-panel'),
      color: context.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 840;
            final modeTabs = _buildModeTabs(accessControl.mode);
            final status = _buildStatusCard(
              enable: accessControl.enable,
              mode: accessControl.mode,
              count: count,
            );
            final searchAndFilters = DisabledMask(
              status: !accessControl.enable,
              child: isCompact
                  ? Column(
                      children: [
                        _buildSearchField(query),
                        const SizedBox(height: 8),
                        _buildFilterBar(accessControl),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildSearchField(query)),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: _buildFilterBar(accessControl),
                        ),
                      ],
                    ),
            );
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCompact) ...[
                  modeTabs,
                  const SizedBox(height: 8),
                  status,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: modeTabs),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: status),
                    ],
                  ),
                const SizedBox(height: 12),
                searchAndFilters,
              ],
            );
          },
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
    return CommonScaffold(
      isLoading: isLoading,
      title: context.appLocalizations.appAccessControl,
      floatBody: true,
      actions: _buildActions(context, enable: accessControl.enable),
      body: AppBarClearance(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildControlPanel(
              accessControl: accessControl,
              query: query,
              count: currentList.length,
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
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          accessControl.enable &&
              !needsInstalledAppsPermission &&
              viewPackageNameSet.isNotEmpty
          ? _buildSelectedAllButton(
              isSelectedAll: valueSet.length == viewPackageNameSet.length,
              allValues: viewPackageNameSet,
            )
          : null,
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

class _AccessModeTab extends StatelessWidget {
  const _AccessModeTab({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final Glyph icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;
    return Container(
      alignment: Alignment.center,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlyphIcon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

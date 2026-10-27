import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/models/tool_route.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/regional/region_labels.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessView extends ConsumerStatefulWidget {
  const AccessView({super.key});

  @override
  ConsumerState<AccessView> createState() => _AccessViewState();
}

class _AccessViewState extends ConsumerState<AccessView>
    with RouteSettledMixin<AccessView> {
  late ScrollController _controller;
  List<String>? _pinedList;
  bool _isInit = false;
  (String, int)? _handledReveal;
  bool _installedAppsPermissionGranted = true;

  final _completer = Completer();

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reveal = SettingsRevealScope.maybeOf(context);
    final target = reveal?.targetId;
    if (reveal == null ||
        !reveal.active ||
        target == null ||
        !PageActivityScope.isActiveOf(context) ||
        !accessToolSettings.any((setting) => setting.id == target) ||
        _handledReveal == (target, reveal.nonce)) {
      return;
    }
    _handledReveal = (target, reveal.nonce);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !PageActivityScope.isActiveOf(context)) return;
      unawaited(_handleToSetting(targetId: target, nonce: reveal.nonce));
    });
  }

  @override
  void didSettleRoute() => _completer.complete(_loadPackages());

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
    super.dispose();
  }

  IconButtonData _buildSelectAllAction({
    required bool isSelectedAll,
    required List<String> allValueList,
  }) {
    void onPressed() {
      ref.read(accessControlStateProvider.notifier).update((state) {
        final provided = _providedApps(state.mode);
        final released = state.currentReleased.toSet();
        final selected = _effectiveList(state, provided);
        final shown = allValueList.toSet();
        if (selected.containsAll(shown)) {
          return state
              .copyWithNewList(
                state.currentList
                    .where((name) => !shown.contains(name))
                    .toList(),
              )
              .copyWithReleased(
                {...released, ...shown.intersection(provided)}.toList()..sort(),
              );
        }
        return state
            .copyWithNewList(
              {...state.currentList, ...shown.difference(provided)}.toList(),
            )
            .copyWithReleased(released.difference(shown).toList()..sort());
      });
    }

    final appLocalizations = context.appLocalizations;
    return isSelectedAll
        ? IconButtonData(
            glyph: AppGlyphs.deselect,
            tooltip: appLocalizations.cancelSelectAll,
            onPressed: onPressed,
          )
        : IconButtonData(
            glyph: AppGlyphs.selectAll,
            tooltip: appLocalizations.selectAll,
            onPressed: onPressed,
          );
  }

  Future<void> _intelligentSelected() async {
    if (!mounted || ref.read(loadingProvider(LoadingTag.access))) return;
    final regionCode = sanitizeRegionCode(
      ref.read(appSettingProvider).regionCode,
    );
    final l = context.appLocalizations;
    if (regionCode == null || !hasProfileForCode(regionCode)) {
      dialogs.showNotifier(
        l.regionSelectBeforeApps,
        level: MessageLevel.warning,
      );
      return;
    }
    final initial = ref.read(accessControlStateProvider);
    final packageSnapshot = ref.read(packagesProvider);
    final result = await globalState.loadingRun<List<String>>(
      () => ref
          .read(systemActionProvider.notifier)
          .getDomesticPackageNames(regionCode),
      tag: LoadingTag.access,
    );
    if (!mounted || result == null) return;
    bool isCurrent() =>
        sanitizeRegionCode(ref.read(appSettingProvider).regionCode) ==
            regionCode &&
        ref.read(accessControlStateProvider) == initial &&
        listEquals(ref.read(packagesProvider), packageSnapshot);
    if (!isCurrent()) {
      dialogs.showNotifier(l.regionAppsChanged, level: MessageLevel.warning);
      return;
    }
    final domestic = result.toSet();
    final packages = packageSnapshot.map((item) => item.packageName).toSet();
    final rejected = packages.intersection(domestic).toList();
    if (rejected.isEmpty) {
      dialogs.showNotifier(l.regionAppsEmpty, level: MessageLevel.warning);
      return;
    }
    final accepted = packages.difference(domestic).toList();
    final confirmed = await dialogs.showMessage(
      context: sheetNavigatorOf(context).context,
      title: l.intelligentSelected,
      confirmText: l.replace,
      message: TextSpan(
        text: l.regionAppsPreview(
          regionLabel(l, regionCode),
          rejected.length,
          accepted.length,
        ),
      ),
    );
    if (!mounted || confirmed != true) return;
    if (!isCurrent()) {
      dialogs.showNotifier(l.regionAppsChanged, level: MessageLevel.warning);
      return;
    }
    ref
        .read(accessControlStateProvider.notifier)
        .update(
          (state) => state.copyWith(acceptList: accepted, rejectList: rejected),
        );
  }

  Future<void> _handleToSetting({String? targetId, int nonce = 0}) async {
    await showSheet<int>(
      context: context,
      builder: (context) {
        final appLocalizations = context.appLocalizations;
        return CommonScaffold(
          body: SettingsRevealScope(
            targetId: targetId,
            nonce: nonce,
            child: const AccessControlPanel(),
          ),
          title: appLocalizations.accessControlSettings,
        );
      },
    );
  }

  Set<String> _providedApps(AccessControlMode mode) =>
      ref.read(providerAppsProvider).asData?.value.of(mode) ?? const {};

  static Set<String> _effectiveList(
    AccessControlProps state,
    Set<String> provided,
  ) => {
    ...state.currentList,
    ...provided.difference(state.currentReleased.toSet()),
  };

  /// Unticking one of the provider's apps records that the user wants it the
  /// other way; ticking it again hands it back.
  void _handleSelected(String packageName) {
    ref.read(accessControlStateProvider.notifier).update((state) {
      if (!_providedApps(state.mode).contains(packageName)) {
        final newSet = Set<String>.from(state.currentList)
          ..addOrRemove(packageName);
        return state.copyWithNewList(newSet.toList());
      }
      final released = Set<String>.from(state.currentReleased)
        ..addOrRemove(packageName);
      return state
          .copyWithNewList(
            state.currentList.where((name) => name != packageName).toList(),
          )
          .copyWithReleased(released.toList()..sort());
    });
  }

  void _update(AccessControlProps Function(AccessControlProps state) update) {
    ref.read(accessControlStateProvider.notifier).update(update);
  }

  void _returnToProvider() {
    ref
        .read(accessControlStateProvider.notifier)
        .update((state) => state.copyWithReleased(const []));
  }

  Future<bool> _handleBack() async {
    final res = await dialogs.showSaveChanges();
    if (res == null) {
      return false;
    }
    if (res) {
      _handleSave();
    }
    return mounted;
  }

  AccessControlProps _getRealAccessControlProps(
    AccessControlProps accessControl,
  ) {
    final packages = ref.read(packagesProvider);
    if (packages.isEmpty) {
      return accessControl;
    }
    final viewPackageNames = packages
        .whereVisible(
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

  List<CommonPopupMenuItem> _buildMenuItems(
    BuildContext context,
    AccessControlProps accessControl, {
    required bool isLoading,
    required bool hasReleased,
  }) {
    final appLocalizations = context.appLocalizations;
    String modeText(AccessControlMode mode) => switch (mode) {
      AccessControlMode.acceptSelected => appLocalizations.whitelistMode,
      AccessControlMode.rejectSelected => appLocalizations.blacklistMode,
    };
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.toggleOn,
        label: appLocalizations.turnOn,
        checked: accessControl.enable,
        section: CommonPopupMenuSection(title: appLocalizations.accessControl),
        onPressed: () => _update((state) => state.copyWith(enable: true)),
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.toggle,
        label: appLocalizations.turnOff,
        checked: !accessControl.enable,
        onPressed: () => _update((state) => state.copyWith(enable: false)),
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.sliders,
        label: appLocalizations.settings,
        subtitle: modeText(accessControl.mode),
        section: const CommonPopupMenuSection(),
        subItems: [
          ..._optionsSection(
            title: appLocalizations.mode,
            options: AccessControlMode.values,
            value: accessControl.mode,
            textOf: modeText,
            onSelected: (mode) =>
                _update((state) => state.copyWith(mode: mode)),
          ),
          ..._optionsSection(
            title: appLocalizations.sort,
            options: AccessSortType.values,
            value: accessControl.sort,
            textOf: (type) => switch (type) {
              AccessSortType.none => appLocalizations.defaultText,
              AccessSortType.name => appLocalizations.name,
              AccessSortType.time => appLocalizations.time,
            },
            onSelected: (sort) =>
                _update((state) => state.copyWith(sort: sort)),
          ),
          CommonPopupMenuItem(
            label: appLocalizations.systemApp,
            checked: !accessControl.isFilterSystemApp,
            section: CommonPopupMenuSection(title: appLocalizations.source),
            onPressed: () => _update(
              (state) =>
                  state.copyWith(isFilterSystemApp: !state.isFilterSystemApp),
            ),
          ),
          CommonPopupMenuItem(
            label: appLocalizations.noNetworkApp,
            checked: !accessControl.isFilterNonInternetApp,
            onPressed: () => _update(
              (state) => state.copyWith(
                isFilterNonInternetApp: !state.isFilterNonInternetApp,
              ),
            ),
          ),
        ],
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.moreCircle,
        label: appLocalizations.action,
        subItems: [
          CommonPopupMenuItem(
            glyph: AppGlyphs.sparkle,
            label: appLocalizations.intelligentSelected,
            onPressed: isLoading ? null : _intelligentSelected,
          ),
          if (hasReleased)
            CommonPopupMenuItem(
              glyph: AppGlyphs.undo,
              label: appLocalizations.accessReturnToProvider,
              onPressed: _returnToProvider,
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
    ];
  }

  Widget _buildContent({
    required List<Package> packages,
    required Set<String> selected,
    required Set<String> provided,
    required bool isSearching,
  }) {
    return FutureBuilder(
      future: _completer.future,
      builder: (context, snapshot) {
        final appLocalizations = context.appLocalizations;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CommonCircleLoading.page());
        }
        return NullStatusSwitcher(
          isEmpty: packages.isEmpty,
          isSearching: isSearching,
          nullStatus: NullStatus(
            label: appLocalizations.noData,
            illustration: NullStatusIllustration.apps,
          ),
          child: CommonScrollBar(
            controller: _controller,
            child: ListView.builder(
              controller: _controller,
              padding: EdgeInsets.only(
                top: context.contentTopPadding,
                bottom: context.bottomInset,
              ),
              scrollCacheExtent: arrivalScrollCacheExtent(routeSettled),
              itemCount: packages.length,
              itemExtent: 72,
              itemBuilder: (_, index) {
                final package = packages[index];
                return PackageListItem(
                  key: Key(package.packageName),
                  package: package,
                  value: selected.contains(package.packageName),
                  fromProvider: provided.contains(package.packageName),
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
      action: TonalButton(
        size: TonalButtonSize.bar,
        glyph: AppGlyphs.lockOpen,
        label: appLocalizations.authorize,
        onPressed: _handleGrantInstalledAppsPermission,
      ),
    );
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.access).notifier).value = value;
    _pinList();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider(LoadingTag.access));
    final query = SearchQuery(ref.watch(queryProvider(QueryTag.access)));
    final packages = ref.watch(packagesProvider);
    final accessControl = ref.watch(accessControlStateProvider);
    final viewPackages = packages
        .getViewList(
          pinedList: _pinedList ?? [],
          sortType: accessControl.sort,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
          isFilterSystemApp: accessControl.isFilterSystemApp,
        )
        .whereMatches(query, (package) => [package.label, package.packageName])
        .toList();
    final mode = accessControl.mode;
    final providerApps =
        ref.watch(providerAppsProvider).asData?.value ?? const ProviderApps();
    final provided = providerApps.of(mode);
    final currentList = _effectiveList(accessControl, provided).toList();
    final viewPackageNameList = viewPackages.map((e) => e.packageName).toList();
    final valueList = currentList.intersection(viewPackageNameList);
    final needsInstalledAppsPermission =
        packages.isEmpty && !_installedAppsPermissionGranted;
    final selectAllAction =
        accessControl.enable &&
            !needsInstalledAppsPermission &&
            viewPackageNameList.isNotEmpty
        ? _buildSelectAllAction(
            isSelectedAll: valueList.length == viewPackageNameList.length,
            allValueList: viewPackageNameList,
          )
        : null;
    final hasChanges = ref.watch(
      vpnSettingProvider.select(
        (state) =>
            _getRealAccessControlProps(state.accessControlProps) !=
            _getRealAccessControlProps(accessControl),
      ),
    );
    return CommonPopScope(
      onPop: hasChanges ? (_) => _handleBack() : null,
      child: CommonScaffold(
        isLoading: isLoading,
        searchState: AppBarSearchState(onSearch: _onSearch),
        searchActions: [?selectAllAction],
        searchInBar: true,
        title: context.appLocalizations.appAccessControl,
        confirmationAction: hasChanges
            ? IconButtonData(
                glyph: AppGlyphs.check,
                onPressed: _handleSave,
                tooltip: context.appLocalizations.save,
              )
            : null,
        iconActions: [?selectAllAction],
        menuItems: _buildMenuItems(
          context,
          accessControl,
          isLoading: isLoading,
          hasReleased: accessControl.currentReleased.any(provided.contains),
        ),
        body: needsInstalledAppsPermission
            ? _buildInstalledAppsPermissionStatus()
            : FloatingFootBar(
                bar: _AccessStatus(
                  accessControl: accessControl,
                  selectedCount: valueList.length,
                  onSmartSelect: isLoading ? null : _intelligentSelected,
                  onEnable: () =>
                      _update((state) => state.copyWith(enable: true)),
                ),
                body: DisabledMask(
                  status: !accessControl.enable,
                  child: _buildContent(
                    packages: viewPackages,
                    selected: valueList.toSet(),
                    provided: provided,
                    isSearching: query.isNotEmpty,
                  ),
                ),
              ),
      ),
    );
  }
}

class _AccessStatus extends StatelessWidget {
  const _AccessStatus({
    required this.accessControl,
    required this.selectedCount,
    required this.onSmartSelect,
    required this.onEnable,
  });

  final AccessControlProps accessControl;
  final int selectedCount;
  final VoidCallback? onSmartSelect;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final enabled = accessControl.enable;
    final description = enabled
        ? switch (accessControl.mode) {
            AccessControlMode.acceptSelected =>
              appLocalizations.accessControlAllowDesc,
            AccessControlMode.rejectSelected =>
              appLocalizations.accessControlNotAllowDesc,
          }
        : appLocalizations.accessControlDisabledDesc;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        16,
        6,
        enabled && selectedCount > 0 ? 16 : 8,
        6,
      ),
      child: Row(
        spacing: 12,
        children: [
          GlyphIcon(
            enabled ? AppGlyphs.appsList : AppGlyphs.info,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          Expanded(
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: colorScheme.onSurface),
            ),
          ),
          if (!enabled)
            TonalButton(
              size: TonalButtonSize.compact,
              label: appLocalizations.turnOn,
              onPressed: onEnable,
            )
          else if (selectedCount == 0)
            Flexible(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                heightFactor: 1,
                child: TonalButton(
                  size: TonalButtonSize.compact,
                  glyph: AppGlyphs.sparkle,
                  label: appLocalizations.intelligentSelected,
                  onPressed: onSmartSelect,
                ),
              ),
            )
          else
            TonalChip(
              label: appLocalizations.accessControlSelectedCount(selectedCount),
              color: colorScheme.primary.opacity15,
              foregroundColor: colorScheme.primary,
            ),
        ],
      ),
    );
  }
}

class PackageListItem extends StatelessWidget {
  final Package package;
  final bool value;
  final bool fromProvider;
  final void Function(bool?) onChanged;

  const PackageListItem({
    super.key,
    required this.package,
    required this.value,
    this.fromProvider = false,
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
      subtitle: Row(
        spacing: 6,
        children: [
          Flexible(
            child: Text(
              package.packageName,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
          ),
          if (fromProvider) const ProviderTag(),
        ],
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

List<CommonPopupMenuItem> _optionsSection<T>({
  required String title,
  required List<T> options,
  required T value,
  required String Function(T option) textOf,
  required ValueSetter<T> onSelected,
}) {
  return [
    for (final option in options)
      CommonPopupMenuItem(
        label: textOf(option),
        checked: option == value,
        section: option == options.first
            ? CommonPopupMenuSection(title: title)
            : null,
        onPressed: () => onSelected(option),
      ),
  ];
}

class AccessControlPanel extends StatelessWidget {
  const AccessControlPanel({super.key});

  static ConfigWriter<T> _writer<T>(
    AccessControlProps Function(AccessControlProps state, T value) update,
  ) {
    return (ref, value) => ref
        .read(accessControlStateProvider.notifier)
        .update((state) => update(state, value));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(top: context.sectionsTopPadding, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          generateSection(
            items: [
              ConfigOptionsItem<AccessControlMode>(
                setting: accessToolSettings[0],
                title: accessToolSettings[0].title,
                options: AccessControlMode.values,
                textBuilder: (mode) => switch (mode) {
                  AccessControlMode.acceptSelected =>
                    appLocalizations.whitelistMode,
                  AccessControlMode.rejectSelected =>
                    appLocalizations.blacklistMode,
                },
                selector: accessControlStateProvider.select(
                  (state) => state.mode,
                ),
                onChanged: _writer(
                  (state, value) => state.copyWith(mode: value),
                ),
              ),
              ConfigOptionsItem<AccessSortType>(
                setting: accessToolSettings[1],
                title: accessToolSettings[1].title,
                options: AccessSortType.values,
                textBuilder: (type) => switch (type) {
                  AccessSortType.none => appLocalizations.defaultText,
                  AccessSortType.name => appLocalizations.name,
                  AccessSortType.time => appLocalizations.time,
                },
                selector: accessControlStateProvider.select(
                  (state) => state.sort,
                ),
                onChanged: _writer(
                  (state, value) => state.copyWith(sort: value),
                ),
              ),
            ],
          ),
          generateSection(
            title: appLocalizations.source,
            items: [
              ConfigToggleItem(
                setting: accessToolSettings[2],
                title: accessToolSettings[2].title,
                selector: accessControlStateProvider.select(
                  (state) => !state.isFilterSystemApp,
                ),
                onChanged: _writer(
                  (state, value) => state.copyWith(isFilterSystemApp: !value),
                ),
              ),
              ConfigToggleItem(
                setting: accessToolSettings[3],
                title: accessToolSettings[3].title,
                selector: accessControlStateProvider.select(
                  (state) => !state.isFilterNonInternetApp,
                ),
                onChanged: _writer(
                  (state, value) =>
                      state.copyWith(isFilterNonInternetApp: !value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final accessToolSettings = <SettingSpec>[
  SettingSpec(
    id: 'access.mode',
    page: ToolPage.access,
    title: (l) => l.mode,
    keywords: ['mode'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'access.sort',
    page: ToolPage.access,
    title: (l) => l.sort,
    keywords: ['sort'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'access.systemApp',
    page: ToolPage.access,
    title: (l) => l.systemApp,
    keywords: ['systemApp'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'access.noNetworkApp',
    page: ToolPage.access,
    title: (l) => l.noNetworkApp,
    keywords: ['noNetworkApp'],
    condition: SettingCondition.always,
  ),
];

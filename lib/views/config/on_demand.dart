import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/models/tool_route.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/enum/enum.dart';
import 'on_demand_network_picker.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

class OnDemandView extends ConsumerStatefulWidget {
  const OnDemandView({super.key, this.isAndroid, this.isMacOS, this.isWindows});

  final bool? isAndroid;
  final bool? isMacOS;
  final bool? isWindows;

  @override
  ConsumerState createState() => _OnDemandViewState();
}

class _OnDemandViewState extends ConsumerState<OnDemandView>
    with UniqueKeyStateMixin {
  static const _authorizeButtonPadding = 12.0;
  static const _minAuthorizeButtonWidth = 80.0;

  bool get _isAndroid => widget.isAndroid ?? system.isAndroid;

  bool get _isMacOS => widget.isMacOS ?? system.isMacOS;

  bool get _isWindows => widget.isWindows ?? system.isWindows;

  bool get _needsLocationPermission => _isAndroid || _isMacOS || _isWindows;

  void _handlePermanentlyDeniedLocationPermission() {
    if (_isMacOS) {
      final appLocalizations = context.appLocalizations;
      dialogs.showAlert(
        title: appLocalizations.locationPermissionRequired,
        message: TextSpan(
          style: AppTextStyle.subheadline.of(context),
          text: appLocalizations.locationPermissionGuide(appName),
        ),
      );
    } else if (_isAndroid) {
      app?.openAppSettings();
    } else if (_isWindows) {
      unawaited(_promptLocationSettings());
    }
  }

  Future<void> _promptLocationSettings() async {
    final appLocalizations = context.appLocalizations;
    final needGo = await dialogs.showMessage(
      title: appLocalizations.locationPermissionRequired,
      message: TextSpan(text: appLocalizations.locationPermissionDeniedMessage),
      confirmText: appLocalizations.go,
    );
    if (needGo != true) {
      return;
    }
    if (_isWindows) {
      unawaited(launchUrl(Uri.parse('ms-settings:privacy-location')));
    } else {
      unawaited(app?.openAppSettings());
    }
  }

  Future<void> _handleRequestLocationPermission() async {
    final permission = ref.read(locationPermissionsProvider);
    if (permission == WifiSsidPermission.granted) {
      return;
    }
    if (permission == WifiSsidPermission.permanentlyDenied) {
      _handlePermanentlyDeniedLocationPermission();
      return;
    }
    final WifiSsidPermission? res;
    try {
      res = await ref.read(locationPermissionsProvider.notifier).request();
    } on PlatformException catch (e) {
      commonPrint.log('requestPermission error $e', logLevel: LogLevel.warning);
      return;
    }
    if (res == null || !mounted) {
      return;
    }
    switch (res) {
      case WifiSsidPermission.granted:
        return;
      case WifiSsidPermission.permanentlyDenied:
        _handlePermanentlyDeniedLocationPermission();
        return;
      case WifiSsidPermission.denied:
        await _promptLocationSettings();
    }
  }

  void _handleRequestIgnoreBatteryOptimization() {
    if (ref.read(batteryOptimizationIgnoredProvider).value == true) {
      return;
    }
    unawaited(ref.read(batteryOptimizationIgnoredProvider.notifier).request());
  }

  Future<void> _handleAddOrUpdate([String? ssid]) async {
    if (ssid == null) {
      final selected = await showOnDemandNetworkPicker(
        context,
        selected: ref.read(excludeSSIDsProvider).toSet(),
      );
      if (selected != null && mounted) _addNetwork(selected);
      return;
    }
    await _handleManualEntry(ssid);
  }

  void _addNetwork(String network) {
    ref
        .read(excludeSSIDsProvider.notifier)
        .update(
          (state) => state.contains(network) ? state : [...state, network],
        );
  }

  Future<void> _handleManualEntry([String? ssid]) async {
    final ssids = ref.read(excludeSSIDsProvider);
    final newSSID = await showOnDemandNetworkEntry(
      context,
      selected: ssids.toSet(),
      value: ssid,
    );
    if (!mounted || newSSID == null || ssid == newSSID) {
      return;
    }
    ref.read(excludeSSIDsProvider.notifier).update((state) {
      final newSSIDS = state.toSet();
      if (ssid != null) {
        newSSIDS.remove(ssid);
      }
      return [...newSSIDS, newSSID];
    });
  }

  void _handleReorder(int oldIndex, newIndex) {
    ref.read(excludeSSIDsProvider.notifier).update((value) {
      return value.copyAndReorder(oldIndex, newIndex);
    });
  }

  Widget _buildItem({
    required String ssid,
    required int index,
    required int length,
    required bool isSelected,
    required bool isEditing,
  }) {
    final position = ItemPosition.get(index, length);
    return ReorderableDelayedDragStartListener(
      key: ValueKey(ssid),
      index: index,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16) + context.bodyInsets,
        child: ItemPositionProvider(
          position: position,
          child: SelectedDecorationListItem(
            isEditing: isEditing,
            title: Row(
              children: [
                Expanded(
                  child: TooltipText(
                    text: Text(
                      ssid,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (onDemandIsBroadRule(ssid))
                  Tooltip(
                    message: context.appLocalizations.onDemandBroadNetwork,
                    child: const GlyphIcon(AppGlyphs.warning),
                  ),
              ],
            ),
            isSelected: isSelected,
            onSelected: () {
              ref.read(itemsProvider(key).notifier).update((state) {
                final newState = Set<String>.from(state)..addOrRemove(ssid);
                return newState;
              });
            },
            onPressed: () {
              _handleAddOrUpdate(ssid);
            },
          ),
        ),
      ),
    );
  }

  void _handleSelectAll() {
    final excludeSSIDs = ref.read(excludeSSIDsProvider).toSet();
    ref.read(itemsProvider(key).notifier).update((selected) {
      return selected.containsAll(excludeSSIDs) ? {} : excludeSSIDs;
    });
  }

  void _handleDelete() {
    final selectedItems = ref.read(itemsProvider(key));
    ref.read(excludeSSIDsProvider.notifier).update((excludeSSIDs) {
      return excludeSSIDs
          .where((item) => !selectedItems.contains(item))
          .toList();
    });
    ref.read(itemsProvider(key).notifier).value = {};
  }

  Widget _buildAuthorizeButton({
    required bool authorized,
    required VoidCallback onPressed,
  }) {
    final appLocalizations = context.appLocalizations;
    return CommonMinFilledButtonTheme(
      child: ElasticButton(
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: authorized
                ? null
                : context.colorScheme.errorContainer,
            foregroundColor: authorized
                ? null
                : context.colorScheme.onErrorContainer,
            padding: const EdgeInsets.symmetric(
              horizontal: _authorizeButtonPadding,
            ),
            minimumSize: const Size(_minAuthorizeButtonWidth, 40),
          ),
          onPressed: onPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ExcludeSemantics(
                child: Opacity(
                  opacity: 0,
                  child: Text(
                    authorized
                        ? appLocalizations.tapToAuthorize
                        : appLocalizations.authorized,
                  ),
                ),
              ),
              Text(
                authorized
                    ? appLocalizations.authorized
                    : appLocalizations.tapToAuthorize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrerequisiteItem({
    required String title,
    required Widget action,
  }) {
    return DecorationListItem(title: TooltipLabel(title), trailing: action);
  }

  Widget _buildBatteryOptimizationItem() {
    final appLocalizations = context.appLocalizations;
    final ignored = ref.watch(batteryOptimizationIgnoredProvider);
    final isLoading = ignored.isLoading;
    return SettingTarget(
      spec: onDemandToolSettings[0],
      child: _buildPrerequisiteItem(
        title: onDemandToolSettings[0].title(appLocalizations),
        action: Stack(
          alignment: Alignment.centerRight,
          children: [
            Visibility(
              visible: !isLoading,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: _buildAuthorizeButton(
                authorized: ignored.value ?? false,
                onPressed: _handleRequestIgnoreBatteryOptimization,
              ),
            ),
            if (isLoading) const CommonCircleLoading(size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPermissionItem() {
    final appLocalizations = context.appLocalizations;
    final granted = ref.watch(
      locationPermissionsProvider.select(
        (state) => state == WifiSsidPermission.granted,
      ),
    );
    return SettingTarget(
      spec: onDemandToolSettings[1],
      child: _buildPrerequisiteItem(
        title: onDemandToolSettings[1].title(appLocalizations),
        action: _buildAuthorizeButton(
          authorized: granted,
          onPressed: _handleRequestLocationPermission,
        ),
      ),
    );
  }

  Widget _buildPrerequisites() {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.prerequisites,
      items: [
        if (_isAndroid) _buildBatteryOptimizationItem(),
        if (_needsLocationPermission) _buildLocationPermissionItem(),
      ],
      footer: [
        if (_isAndroid) appLocalizations.batteryOptimizationDesc,
        if (_needsLocationPermission) appLocalizations.locationPermissionDesc,
      ].join('\n'),
    );
  }

  Widget _buildExcludeSsidsHeader() {
    final appLocalizations = context.appLocalizations;
    final hasSelection = ref.watch(itemsProvider(key)).isNotEmpty;
    return ListHeader(
      title: onDemandToolSettings[2].title(appLocalizations),
      actions: [
        if (hasSelection) ...[
          IconButtonData(
            glyph: AppGlyphs.delete,
            tooltip: appLocalizations.delete,
            onPressed: _handleDelete,
          ),
          IconButtonData(
            glyph: AppGlyphs.selectAll,
            tooltip: appLocalizations.selectAll,
            onPressed: _handleSelectAll,
          ),
        ] else
          IconButtonData(
            glyph: AppGlyphs.addCircle,
            tooltip: appLocalizations.add,
            onPressed: _handleAddOrUpdate,
          ),
      ],
    );
  }

  Widget _buildExcludeSsidsList(
    List<String> excludeSSIDs,
    Set<dynamic> selectedItems,
  ) {
    if (excludeSSIDs.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12),
        sliver: SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 48),
            child: NullStatus(
              label: context.appLocalizations.ssidsEmpty,
              illustration: NullStatusIllustration.wifi,
            ),
          ),
        ),
      );
    }
    Widget itemAt(int index) => _buildItem(
      isEditing: selectedItems.isNotEmpty,
      ssid: excludeSSIDs[index],
      index: index,
      isSelected: selectedItems.contains(excludeSSIDs[index]),
      length: excludeSSIDs.length,
    );
    return SliverPadding(
      padding: const EdgeInsets.only(top: 12),
      sliver: SliverReorderableList(
        itemBuilder: (_, index) => itemAt(index),
        proxyDecorator: (child, index, animation) =>
            commonProxyDecorator(itemAt(index), index, animation),
        itemCount: excludeSSIDs.length,
        onReorderItem: _handleReorder,
      ),
    );
  }

  Widget _buildOptions() => generateSection(
    items: [
      ConfigToggleItem(
        selector: vpnSettingProvider.select((s) => s.onDemandEnabled),
        title: (l) => l.onDemand,
        setting: onDemandToolSettings[3],
        onChanged: (ref, value) => ref
            .read(vpnSettingProvider.notifier)
            .update((s) => s.copyWith(onDemandEnabled: value)),
      ),
      ConfigToggleItem(
        selector: vpnSettingProvider.select((s) => s.onDemandFullStop),
        title: (l) => l.onDemandFullStop,
        setting: onDemandToolSettings[4],
        onChanged: (ref, value) => ref
            .read(vpnSettingProvider.notifier)
            .update((s) => s.copyWith(onDemandFullStop: value)),
      ),
      ConfigToggleItem(
        selector: vpnSettingProvider.select((s) => s.onDemandCloseConnections),
        title: (l) => l.onDemandCloseConnections,
        setting: onDemandToolSettings[5],
        onChanged: (ref, value) => ref
            .read(vpnSettingProvider.notifier)
            .update((s) => s.copyWith(onDemandCloseConnections: value)),
      ),
      ConfigToggleItem(
        selector: vpnSettingProvider.select((s) => s.onDemandStrict),
        title: (l) => l.onDemandStrict,
        setting: onDemandToolSettings[6],
        onChanged: (ref, value) => ref
            .read(vpnSettingProvider.notifier)
            .update((s) => s.copyWith(onDemandStrict: value)),
      ),
    ],
    footer: [
      context.appLocalizations.onDemandFullStopDesc,
      context.appLocalizations.closeConnectionsDesc,
      context.appLocalizations.onDemandStrictDesc,
    ].join('\n'),
  );

  @override
  Widget build(BuildContext context) {
    final excludeSSIDs = ref.watch(excludeSSIDsProvider);
    final selectedItems = ref.watch(itemsProvider(key));
    return CommonScaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding:
                EdgeInsets.fromLTRB(16, context.appBarInset, 16, 0) +
                context.bodyInsets,
            sliver: SliverToBoxAdapter(child: _buildOptions()),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: context.sectionsTopPadding) +
                context.bodyInsets,
            sliver: SliverToBoxAdapter(child: _buildPrerequisites()),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16) + context.bodyInsets,
            sliver: SliverToBoxAdapter(
              child: SettingTarget(
                spec: onDemandToolSettings[2],
                child: _buildExcludeSsidsHeader(),
              ),
            ),
          ),
          _buildExcludeSsidsList(excludeSSIDs, selectedItems),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(bottom: 16 + context.bottomInset) +
                context.bodyInsets,
            sliver: SliverToBoxAdapter(
              child: ListFooter(
                text: context.appLocalizations.trustedNetworksDesc,
              ),
            ),
          ),
        ],
      ),
      title: context.appLocalizations.onDemand,
    );
  }
}

final onDemandToolSettings = <SettingSpec>[
  SettingSpec(
    id: 'onDemand.battery',
    page: ToolPage.onDemand,
    title: (l) => l.ignoreBatteryOptimization,
    condition: SettingCondition.android,
  ),
  SettingSpec(
    id: 'onDemand.location',
    page: ToolPage.onDemand,
    title: (l) => l.locationPermission,
    condition: SettingCondition.locationPermission,
  ),
  SettingSpec(
    id: 'onDemand.excludeSSIDs',
    page: ToolPage.onDemand,
    title: (l) => l.trustedNetworks,
    keywords: ['wifi', 'ssid'],
  ),
  SettingSpec(
    id: 'onDemand.enabled',
    page: ToolPage.onDemand,
    title: (l) => l.onDemand,
  ),
  SettingSpec(
    id: 'onDemand.fullStop',
    page: ToolPage.onDemand,
    title: (l) => l.onDemandFullStop,
  ),
  SettingSpec(
    id: 'onDemand.closeConnections',
    page: ToolPage.onDemand,
    title: (l) => l.onDemandCloseConnections,
  ),
  SettingSpec(
    id: 'onDemand.strict',
    page: ToolPage.onDemand,
    title: (l) => l.onDemandStrict,
  ),
];

import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/permission.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/profiles/overwrite/custom/widgets.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

class SmartPauseView extends ConsumerStatefulWidget {
  const SmartPauseView({super.key, this.isAndroid, this.isMacOS});

  final bool? isAndroid;
  final bool? isMacOS;

  @override
  ConsumerState createState() => _SmartPauseViewState();
}

class _SmartPauseViewState extends ConsumerState<SmartPauseView>
  with UniqueKeyStateMixin {
  static const _authorizeButtonPadding = 12.0;
  static const _minAuthorizeButtonWidth = 80.0;

  bool get _isAndroid => widget.isAndroid ?? system.isAndroid;

  bool get _isMacOS => widget.isMacOS ?? system.isMacOS;

  void _handlePermanentlyDeniedLocationPermission() {
    if (_isMacOS) {
      final appLocalizations = context.appLocalizations;
      dialogs.showMessage(
        title: appLocalizations.locationPermissionRequired,
        cancelable: false,
        message: TextSpan(
          style: context.textTheme.bodyMedium,
          text: appLocalizations.locationPermissionGuide(appName),
        ),
      );
    } else if (_isAndroid) {
      app?.openAppSettings();
    }
  }

  Future<void> _handleRequestLocationPermission() async {
    final appLocalizations = context.appLocalizations;
    final permission = ref.read(locationPermissionsProvider);
    if (permission == WifiSsidPermission.granted) {
      return;
    }
    if (permission == WifiSsidPermission.permanentlyDenied) {
      _handlePermanentlyDeniedLocationPermission();
      return;
    }
    final permissionsNotifier = ref.read(locationPermissionsProvider.notifier);
    final res = await wifiSsidManager.requestPermission();
    permissionsNotifier.value = res;
    if (!mounted) {
      return;
    }
    switch (getLocationPermissionFollowUp(res)) {
      case LocationPermissionFollowUp.none:
        return;
      case LocationPermissionFollowUp.openSettings:
        _handlePermanentlyDeniedLocationPermission();
        return;
      case LocationPermissionFollowUp.showDeniedMessage:
        break;
    }
    final needGo = await dialogs.showMessage(
      title: appLocalizations.locationPermissionRequired,
      message: TextSpan(text: appLocalizations.locationPermissionDeniedMessage),
      confirmText: appLocalizations.go,
    );
    if (needGo != true) {
      return;
    }
    unawaited(app?.openAppSettings());
  }

  void _handleOpenBatteryOptimizationSettings() {
    final isDisabled = ref.read(batteryOptimizationDisableProvider);
    if (isDisabled) {
      return;
    }
    permissions.needWaitingBatteryOptimizationSettings = true;
    app?.openBatteryOptimizationSettings();
  }

  Future<void> _handleAddOrUpdate([String? network]) async {
    final networks = ref.read(
      vpnSettingProvider.select((state) => state.smartPauseNetworks),
    );
    final appLocalizations = context.appLocalizations;
    final newNetwork = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: network == null
            ? appLocalizations.addNetwork
            : appLocalizations.editNetwork,
        value: network ?? '',
        maxLength: 64,
        hintText: appLocalizations.networkEntryHint,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return appLocalizations.emptyTip(
              appLocalizations.trustedNetworks,
            ).trim();
          }
          if (networks.contains(value.trim()) && network != value.trim()) {
            return appLocalizations.existsTip(
              appLocalizations.trustedNetworks,
            ).trim();
          }
          return null;
        },
      ),
    );
    if (newNetwork == null) {
      return;
    }
    final trimmed = newNetwork.trim();
    if (trimmed.isEmpty || trimmed == network) {
      return;
    }
    ref.read(vpnSettingProvider.notifier).update((state) {
      final networks = state.smartPauseNetworks.where((item) {
        return item != network && item != trimmed;
      }).toList();
      return state.copyWith(smartPauseNetworks: [...networks, trimmed]);
    });
  }

  void _handleReorder(int oldIndex, int newIndex) {
    ref.read(vpnSettingProvider.notifier).update((state) {
      return state.copyWith(
        smartPauseNetworks: state.smartPauseNetworks.copyAndReorder(
          oldIndex,
          newIndex,
        ),
      );
    });
  }

  Widget _buildItem({
    required String network,
    required int index,
    required int length,
    required bool isSelected,
    required bool isEditing,
  }) {
    final position = ItemPosition.get(index, length);
    return ReorderableDelayedDragStartListener(
      key: ValueKey(network),
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ItemPositionProvider(
          position: position,
          child: SelectedDecorationListItem(
            isEditing: isEditing,
            minVerticalPadding: 8,
            leading: Icon(
              isSubnetRule(network)
                  ? Icons.router_rounded
                  : Icons.wifi_rounded,
              color: context.colorScheme.onSurfaceVariant,
            ),
            title: TooltipText(
              text: Text(network, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            isSelected: isSelected,
            onSelected: () {
              ref.read(itemsProvider(key).notifier).update((state) {
                final newState = Set<String>.from(state)..addOrRemove(network);
                return newState;
              });
            },
            onPressed: () {
              _handleAddOrUpdate(network);
            },
          ),
        ),
      ),
    );
  }

  void _handleSelectAll() {
    final networks = ref.read(
      vpnSettingProvider.select((state) => state.smartPauseNetworks),
    ).toSet();
    ref.read(itemsProvider(key).notifier).update((selected) {
      return selected.containsAll(networks) ? {} : networks;
    });
  }

  void _handleDelete() {
    final selectedItems = ref.read(itemsProvider(key));
    ref.read(vpnSettingProvider.notifier).update((state) {
      return state.copyWith(
        smartPauseNetworks: state.smartPauseNetworks
            .where((item) => !selectedItems.contains(item))
            .toList(),
      );
    });
    ref.read(itemsProvider(key).notifier).value = {};
  }

  Widget _buildAuthorizeButton({
    required bool authorized,
    required VoidCallback onPressed,
  }) {
    final appLocalizations = context.appLocalizations;
    return CommonMinFilledButtonTheme(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: authorized ? null : context.colorScheme.error,
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
    );
  }

  Widget _buildPrerequisiteItem({
    required String title,
    required String desc,
    required Widget action,
  }) {
    return DecorationListItem(
      minVerticalPadding: 0,
      title: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: TooltipLabel(title),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(desc),
            Align(alignment: Alignment.centerRight, child: action),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryOptimizationItem() {
    final appLocalizations = context.appLocalizations;
    final isStart = ref.watch(isStartProvider);
    final isLoading = ref.watch(
      loadingProvider(LoadingTag.batteryOptimization),
    );
    final disabled = ref.watch(batteryOptimizationDisableProvider);
    return _buildPrerequisiteItem(
      title: appLocalizations.ignoreBatteryOptimization,
      desc: appLocalizations.batteryOptimizationDesc,
      action: Stack(
        alignment: Alignment.centerRight,
        children: [
          Visibility(
            visible: !isLoading && !isStart,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: _buildAuthorizeButton(
              authorized: disabled,
              onPressed: _handleOpenBatteryOptimizationSettings,
            ),
          ),
          if (isStart)
            InfoMessageButton(
              message: appLocalizations.batteryOptimizationStatusTip,
            ),
          if (!isStart && isLoading)
            const SizedBox.square(dimension: 32, child: CommonCircleLoading()),
        ],
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
    return _buildPrerequisiteItem(
      title: appLocalizations.locationPermission,
      desc: appLocalizations.locationPermissionDesc,
      action: _buildAuthorizeButton(
        authorized: granted,
        onPressed: _handleRequestLocationPermission,
      ),
    );
  }

  Widget _buildPrerequisites() {
    return generateSectionV3(
      title: context.appLocalizations.prerequisites,
      items: [
        if (_isAndroid) _buildBatteryOptimizationItem(),
        if (_isAndroid || _isMacOS) _buildLocationPermissionItem(),
      ],
    );
  }

  Widget _buildSwitches() {
    final appLocalizations = context.appLocalizations;
    final vpnSetting = ref.watch(vpnSettingProvider);
    return generateSectionV3(
      items: [
        DecorationListItem(
          minVerticalPadding: 8,
          contentPadding: const EdgeInsets.only(left: 16, right: 8),
          title: Text(appLocalizations.smartPause),
          subtitle: Text(appLocalizations.smartPauseDesc),
          onPressed: () {
            _updateSmartPauseEnabled(!vpnSetting.smartPauseEnabled);
          },
          trailing: Switch(
            value: vpnSetting.smartPauseEnabled,
            onChanged: _updateSmartPauseEnabled,
          ),
        ),
        if (vpnSetting.smartPauseEnabled)
          DecorationListItem(
            minVerticalPadding: 8,
            contentPadding: const EdgeInsets.only(left: 16, right: 8),
            title: Text(appLocalizations.smartPauseCloseConnections),
            subtitle: Text(appLocalizations.closeConnectionsDesc),
            onPressed: () {
              ref.read(vpnSettingProvider.notifier).update((state) {
                return state.copyWith(
                  smartPauseCloseConnections: !state.smartPauseCloseConnections,
                );
              });
            },
            trailing: Switch(
              value: vpnSetting.smartPauseCloseConnections,
              onChanged: (value) {
                ref.read(vpnSettingProvider.notifier).update((state) {
                  return state.copyWith(smartPauseCloseConnections: value);
                });
              },
            ),
          ),
      ],
    );
  }

  void _updateSmartPauseEnabled(bool value) {
    ref.read(vpnSettingProvider.notifier).update((state) {
      return state.copyWith(smartPauseEnabled: value);
    });
  }

  Widget _buildStatus() {
    final appLocalizations = context.appLocalizations;
    final vpnSetting = ref.watch(vpnSettingProvider);
    final enabled = vpnSetting.smartPauseEnabled;
    final networks = vpnSetting.smartPauseNetworks;
    if (!enabled || networks.isEmpty) {
      return const SliverPadding(padding: EdgeInsets.zero);
    }
    final colorScheme = context.colorScheme;
    final matched = smartPauseMatches(
      networks,
      ssid: ref.watch(currentSSIDProvider),
      ipv4s: ref.watch(currentIPv4sProvider),
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      sliver: SliverToBoxAdapter(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: AppShape.xl,
            color: matched
                ? colorScheme.primary.withValues(alpha: 0.10)
                : colorScheme.surfaceContainerHigh,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  matched
                      ? Icons.pause_circle_rounded
                      : Icons.location_searching_rounded,
                  size: 18,
                  color: matched
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    matched
                        ? appLocalizations.trustedNow
                        : appLocalizations.notTrustedNow,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: matched
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworksHeader() {
    final appLocalizations = context.appLocalizations;
    final hasSelection = ref.watch(itemsProvider(key)).isNotEmpty;
    return ListHeader(
      title: appLocalizations.trustedNetworks,
      subTitle: appLocalizations.trustedNetworksDesc,
      actions: [
        const SizedBox(width: 8),
        if (hasSelection)
          CommonMinIconButtonTheme(
            child: IconButton.filledTonal(
              tooltip: context.appLocalizations.delete,
              onPressed: _handleDelete,
              icon: const Icon(Icons.delete),
            ),
          ),
        const SizedBox(width: 2),
        CommonMinFilledButtonTheme(
          child: hasSelection
              ? FilledButton(
                  onPressed: _handleSelectAll,
                  child: Text(appLocalizations.selectAll),
                )
              : FilledButton.tonal(
                  onPressed: _handleAddOrUpdate,
                  child: Text(appLocalizations.add),
                ),
        ),
      ],
    );
  }

  Widget _buildNetworksList(
    List<String> networks,
    Set<dynamic> selectedItems,
  ) {
    if (networks.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12),
        sliver: SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 48),
            child: NullStatus(label: context.appLocalizations.networksEmpty),
          ),
        ),
      );
    }
    Widget itemAt(int index) => _buildItem(
      isEditing: selectedItems.isNotEmpty,
      network: networks[index],
      index: index,
      isSelected: selectedItems.contains(networks[index]),
      length: networks.length,
    );
    return SliverPadding(
      padding: const EdgeInsets.only(top: 12),
      sliver: SliverReorderableList(
        itemBuilder: (_, index) => itemAt(index),
        proxyDecorator: (child, index, animation) =>
            commonProxyDecorator(itemAt(index), index, animation),
        itemCount: networks.length,
        onReorderItem: _handleReorder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final networks = ref.watch(
      vpnSettingProvider.select((state) => state.smartPauseNetworks),
    );
    final selectedItems = ref.watch(itemsProvider(key));
    return CommonScaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _buildPrerequisites()),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _buildSwitches()),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _buildNetworksHeader()),
          ),
          _buildStatus(),
          _buildNetworksList(networks, selectedItems),
        ],
      ),
      title: context.appLocalizations.smartPause,
    );
  }
}

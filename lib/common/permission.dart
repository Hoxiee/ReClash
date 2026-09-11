import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid_manager.dart';

enum LocationPermissionFollowUp { none, showDeniedMessage, openSettings }

LocationPermissionFollowUp getLocationPermissionFollowUp(
  WifiSsidPermission permission,
) {
  return switch (permission) {
    WifiSsidPermission.granted => LocationPermissionFollowUp.none,
    WifiSsidPermission.denied => LocationPermissionFollowUp.showDeniedMessage,
    WifiSsidPermission.permanentlyDenied =>
      LocationPermissionFollowUp.openSettings,
  };
}

class Permissions {
  static Permissions? _instance;

  Permissions._internal({
    bool Function()? supportsLocationPermissions,
    Future<bool> Function()? isBatteryOptimizationDisabled,
  }) : _supportsLocationPermissions =
           supportsLocationPermissions ??
           (() => system.isAndroid || system.isMacOS),
       _isBatteryOptimizationDisabled =
           isBatteryOptimizationDisabled ??
           (() async => await app?.isBatteryOptimizationDisabled() ?? false);

  factory Permissions() {
    _instance ??= Permissions._internal();
    return _instance!;
  }

  @visibleForTesting
  factory Permissions.test({
    required bool supportsLocationPermissions,
    Future<bool> Function()? isBatteryOptimizationDisabled,
  }) {
    return Permissions._internal(
      supportsLocationPermissions: () => supportsLocationPermissions,
      isBatteryOptimizationDisabled: isBatteryOptimizationDisabled,
    );
  }

  final bool Function() _supportsLocationPermissions;
  final Future<bool> Function() _isBatteryOptimizationDisabled;

  bool _isRequestingLocation = false;
  bool _autoRequestedLocation = false;
  bool _hadSsidRules = false;
  bool needWaitingBatteryOptimizationSettings = false;
  Future<void>? _batteryOptimizationCheck;

  void check(ProviderReader read) {
    checkLocationPermissions(read);
    checkBatteryOptimizationDisable(read);
  }

  Future<void> checkBatteryOptimizationDisable(ProviderReader read) {
    return _batteryOptimizationCheck ??= _checkBatteryOptimizationDisable(
      read,
    ).whenComplete(() => _batteryOptimizationCheck = null);
  }

  Future<void> _checkBatteryOptimizationDisable(ProviderReader read) async {
    const tag = LoadingTag.batteryOptimization;
    final waitForSettings = needWaitingBatteryOptimizationSettings;
    try {
      if (waitForSettings) {
        read(loadingProvider(tag).notifier).value = true;
      }
      read(
        batteryOptimizationDisableProvider.notifier,
      ).value = await retry<bool>(
        task: _isBatteryOptimizationDisabled,
        retryIf: (res) => res == false,
        delay: const Duration(milliseconds: 500),
        maxAttempts: waitForSettings ? 5 : 1,
      );
    } finally {
      read(loadingProvider(tag).notifier).value = false;
      if (waitForSettings) {
        needWaitingBatteryOptimizationSettings = false;
      }
    }
  }

  Future<void> checkLocationPermissions(ProviderReader read) async {
    if (!_supportsLocationPermissions()) {
      return;
    }
    final res = await WifiSsidManager.instance.checkPermission();
    final current = read(locationPermissionsProvider);
    if (res == WifiSsidPermission.granted ||
        current != WifiSsidPermission.permanentlyDenied) {
      read(locationPermissionsProvider.notifier).value = res;
    }
    final needRequestPermission = read(
      vpnSettingProvider.select(
        (state) =>
            state.smartPauseEnabled &&
            state.smartPauseNetworks.any((network) => !isSubnetRule(network)),
      ),
    );
    if (needRequestPermission && !_hadSsidRules) {
      _autoRequestedLocation = false;
    }
    _hadSsidRules = needRequestPermission;
    if (res == WifiSsidPermission.denied &&
        needRequestPermission &&
        !_autoRequestedLocation &&
        !_isRequestingLocation) {
      _isRequestingLocation = true;
      try {
        final res = await WifiSsidManager.instance.requestPermission();
        _autoRequestedLocation = true;
        read(locationPermissionsProvider.notifier).value = res;
        if (res == WifiSsidPermission.granted) {
          final ssid = await WifiSsidManager.instance.getSsid();
          read(currentSSIDProvider.notifier).value = ssid;
        }
      } on PlatformException catch (e) {
        commonPrint.log(
          'requestPermission error ${e.toString()}',
          logLevel: LogLevel.warning,
        );
      } finally {
        _isRequestingLocation = false;
      }
    }
  }
}

final permissions = Permissions();

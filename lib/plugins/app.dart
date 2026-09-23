import 'dart:async';
import 'dart:io';

import 'package:reclash/common/app/boot_record.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

const _platformProbeTimeout = Duration(seconds: 2);

class AndroidNotificationStatus {
  final bool permissionGranted;
  final bool serviceChannelEnabled;
  final bool subscriptionChannelEnabled;

  const AndroidNotificationStatus({
    required this.permissionGranted,
    required this.serviceChannelEnabled,
    required this.subscriptionChannelEnabled,
  });

  factory AndroidNotificationStatus.fromMap(Map<Object?, Object?>? value) {
    return AndroidNotificationStatus(
      permissionGranted: value?['permissionGranted'] == true,
      serviceChannelEnabled: value?['serviceChannelEnabled'] != false,
      subscriptionChannelEnabled: value?['subscriptionChannelEnabled'] != false,
    );
  }
}

class App {
  static App? _instance;
  late MethodChannel methodChannel;
  Function()? onExit;
  Function()? onPackagesChanged;

  App._internal() {
    methodChannel = const MethodChannel('$packageName/app');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'exit':
          if (onExit != null) {
            await onExit!();
          }
        case 'packagesChanged':
          onPackagesChanged?.call();
        default:
          throw MissingPluginException();
      }
    });
  }

  factory App() {
    _instance ??= App._internal();
    return _instance!;
  }

  Future<bool?> moveTaskToBack() async {
    return methodChannel.invokeMethod<bool>('moveTaskToBack');
  }

  Future<bool?> setIconVariant(String variant) async {
    return methodChannel.invokeMethod<bool>('setIconVariant', variant);
  }

  Future<List<Package>> getPackages() async {
    final packagesString = await methodChannel.invokeMethod<String>(
      'getPackages',
    );
    final List<dynamic> packagesRaw =
        (await packagesString?.decodeJson<List<dynamic>>()) ?? [];
    return packagesRaw.map((e) => Package.fromJson(e)).toSet().toList();
  }

  Future<bool> isInstalledAppsPermissionGranted() async {
    return await methodChannel.invokeMethod<bool>(
          'isInstalledAppsPermissionGranted',
        ) ??
        true;
  }

  Future<bool> requestInstalledAppsPermission() async {
    return await methodChannel.invokeMethod<bool>(
          'requestInstalledAppsPermission',
        ) ??
        false;
  }

  Future<List<String>> getDomesticPackageNames(AppRegion region) async {
    final packageNamesString = await methodChannel.invokeMethod<String>(
      'getDomesticPackageNames',
      {'region': region.wire},
    );
    final List<dynamic> packageNamesRaw =
        await packageNamesString?.decodeJson<List<dynamic>>() ?? [];
    return packageNamesRaw.map((e) => e.toString()).toList();
  }

  Future<RegionSignals> getRegionSignals() async {
    try {
      final raw = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'getRegionSignals',
      );
      return RegionSignals.fromMap(raw);
    } catch (_) {
      return const RegionSignals();
    }
  }

  Future<bool> isNotificationsPermissionGranted() async {
    return await methodChannel.invokeMethod<bool>(
          'isNotificationsPermissionGranted',
        ) ??
        false;
  }

  Future<bool?> requestNotificationsPermission() async {
    return methodChannel.invokeMethod<bool>('requestNotificationsPermission');
  }

  Future<AndroidNotificationStatus> getNotificationStatus({
    String? serviceChannelId,
  }) async {
    final value = await methodChannel.invokeMapMethod<Object?, Object?>(
      'getNotificationStatus',
      {'serviceChannelId': serviceChannelId},
    );
    return AndroidNotificationStatus.fromMap(value);
  }

  Future<bool?> openNotificationSettings({String? channelId}) async {
    if (!Platform.isAndroid) return false;
    return methodChannel.invokeMethod<bool>('openNotificationSettings', {
      'channelId': channelId,
    });
  }

  Future<bool> openFile(String path) async {
    return await methodChannel.invokeMethod<bool>('openFile', {'path': path}) ??
        false;
  }

  final Map<String, ImageProvider?> _packageIcons = {};
  final Map<String, Future<ImageProvider?>> _packageIconTasks = {};

  bool hasPackageIcon(String packageName) {
    return _packageIcons.containsKey(packageName);
  }

  ImageProvider? getCachedPackageIcon(String packageName) {
    return _packageIcons[packageName];
  }

  Future<ImageProvider?> getPackageIcon(String packageName) {
    if (_packageIcons.containsKey(packageName)) {
      return Future.value(_packageIcons[packageName]);
    }
    return _packageIconTasks[packageName] ??= _loadPackageIcon(packageName);
  }

  Future<ImageProvider?> _loadPackageIcon(String packageName) async {
    var icon = await _requestPackageIcon(packageName);
    if (icon == null && packageName.isNotEmpty) {
      icon = await getPackageIcon('');
    }
    _packageIcons[packageName] = icon;
    unawaited(_packageIconTasks.remove(packageName));
    return icon;
  }

  Future<ImageProvider?> _requestPackageIcon(String packageName) async {
    try {
      final path = await methodChannel.invokeMethod<String>('getPackageIcon', {
        'packageName': packageName,
      });
      if (path == null || path.isEmpty) {
        return null;
      }
      return FileImage(File(path));
    } catch (error) {
      commonPrint.log('getPackageIcon error: $error');
      return null;
    }
  }

  @visibleForTesting
  void clearPackageIconCache() {
    _packageIcons.clear();
    _packageIconTasks.clear();
  }

  Future<bool?> tip(String? message) async {
    return methodChannel.invokeMethod<bool>('tip', {'message': '$message'});
  }

  Future<bool?> initShortcuts() async {
    return methodChannel.invokeMethod<bool>(
      'initShortcuts',
      currentAppLocalizations.toggle,
    );
  }

  Future<bool?> updateExcludeFromRecents(bool value) async {
    return methodChannel.invokeMethod<bool>('updateExcludeFromRecents', {
      'value': value,
    });
  }

  Future<bool?> isBatteryOptimizationDisabled() async {
    if (!Platform.isAndroid) return true;
    return methodChannel.invokeMethod<bool>('isBatteryOptimizationDisabled');
  }

  Future<bool?> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return false;
    return methodChannel.invokeMethod<bool>('openBatteryOptimizationSettings');
  }

  Future<bool?> openAppSettings() async {
    if (!Platform.isAndroid) return false;
    return methodChannel.invokeMethod<bool>('openAppSettings');
  }

  Future<bool> didCrashOnPreviousExecution() async {
    try {
      final value = await methodChannel
          .invokeMethod<bool>('didCrashOnPreviousExecution')
          .timeout(_platformProbeTimeout);
      return value ?? false;
    } catch (error) {
      commonPrint.log(
        'Failed to read the previous-execution crash flag: '
        '${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  Future<AppExitInfo?> getLastExitInfo() async {
    try {
      final raw = await methodChannel
          .invokeMapMethod<String, Object?>('getLastExitInfo')
          .timeout(_platformProbeTimeout);
      return AppExitInfo.fromJson(raw);
    } catch (error) {
      commonPrint.log(
        'Failed to read the last process exit info: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  Future<bool> canRequestPackageInstalls() async {
    return await methodChannel.invokeMethod<bool>(
          'canRequestPackageInstalls',
        ) ??
        false;
  }

  Future<bool> installApk(String path) async {
    try {
      return await methodChannel.invokeMethod<bool>('installApk', {
            'path': path,
          }) ??
          false;
    } catch (error) {
      commonPrint.log(
        'installApk failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  Future<bool> showNotice({
    required String channelName,
    required String notificationKey,
    required String title,
    required String message,
    String? actionLabel,
    String? actionUrl,
  }) async {
    try {
      return await methodChannel.invokeMethod<bool>('showNotice', {
            'channelName': channelName,
            'notificationKey': notificationKey,
            'title': title,
            'message': message,
            'actionLabel': actionLabel,
            'actionUrl': actionUrl,
          }) ??
          false;
    } catch (error) {
      commonPrint.log(
        'showNotice failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  Future<String?> getAndroidId() async {
    try {
      return await methodChannel
          .invokeMethod<String>('getAndroidId')
          .timeout(_platformProbeTimeout);
    } catch (error) {
      commonPrint.log(
        'Failed to read ANDROID_ID: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }
}

final app = system.isAndroid ? App() : null;

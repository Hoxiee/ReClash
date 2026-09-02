import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/state.dart';
import 'package:win32_registry/win32_registry.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

const _coreVersionTimeout = Duration(seconds: 2);

class DeviceIdentityInfo {
  const DeviceIdentityInfo({
    required this.hwid,
    required this.os,
    required this.osVersion,
    required this.model,
  });

  final String hwid;
  final String os;
  final String osVersion;
  final String model;
}

class DeviceIdentity {
  static DeviceIdentity? _instance;

  DeviceIdentity._internal();

  factory DeviceIdentity() {
    _instance ??= DeviceIdentity._internal();
    return _instance!;
  }

  Future<DeviceIdentityInfo>? _pendingInfo;
  String? _coreVersion;
  Future<String?>? _pendingCoreVersion;

  @visibleForTesting
  static String hwidFromSource(String source) {
    return sha256.convert(utf8.encode('reclash-device:$source')).toString();
  }

  Future<DeviceIdentityInfo> get info => _pendingInfo ??= _loadInfo();  Future<DeviceIdentityInfo> _loadInfo() async {
    try {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      final (source, model) = switch (deviceInfo) {
        AndroidDeviceInfo(:final manufacturer, :final model) => (
          await app?.getAndroidId(),
          '$manufacturer $model',
        ),
        IosDeviceInfo(
          :final identifierForVendor,
          :final modelName,
          :final utsname,
        ) => (
          identifierForVendor,
          modelName.takeFirstValid([utsname.machine]),
        ),
        MacOsDeviceInfo(:final systemGUID, :final modelName) => (
          systemGUID,
          modelName,
        ),
        WindowsDeviceInfo(:final computerName) => (
          _windowsMachineGuid(),
          computerName,
        ),
        _ => (await _linuxMachineId(), Platform.localHostname),
      };
      var hwidSource = source?.trim();
      if (hwidSource == null || hwidSource.isEmpty) {
        hwidSource = Platform.localHostname;
      }
      return DeviceIdentityInfo(
        hwid: hwidFromSource(hwidSource),
        os: Platform.operatingSystem,
        osVersion: Platform.operatingSystemVersion,
        model: model,
      );
    } catch (error) {
      // Hosts without a device-info plugin (tests, embedders) still need a
      // stable id; the hostname keeps it deterministic per host.
      commonPrint.log(
        'Failed to read device info: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return DeviceIdentityInfo(
        hwid: hwidFromSource(Platform.localHostname),
        os: Platform.operatingSystem,
        osVersion: Platform.operatingSystemVersion,
        model: Platform.localHostname,
      );
    }
  }

  String? _windowsMachineGuid() {
    if (!system.isWindows) return null;
    try {
      return LOCAL_MACHINE.getString(
        'MachineGuid',
        path: r'SOFTWARE\Microsoft\Cryptography',
      );
    } catch (error) {
      commonPrint.log(
        'Failed to read MachineGuid: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  Future<String?> _linuxMachineId() async {
    if (!system.isLinux) return null;
    for (final path in ['/etc/machine-id', '/var/lib/dbus/machine-id']) {
      try {
        final id = (await File(path).readAsString()).trim();
        if (id.isNotEmpty) return id;
      } catch (_) {}
    }
    return null;
  }

  Future<String?> get coreVersion async {
    if (_coreVersion != null) return _coreVersion;
    return _pendingCoreVersion ??= _readCoreVersion().then((version) {
      if (version != null) {
        _coreVersion = version;
      } else {
        _pendingCoreVersion = null;
      }
      return version;
    });
  }

  Future<String?> _readCoreVersion() async {
    try {
      return await coreController.getVersion().timeout(_coreVersionTimeout);
    } catch (error) {
      // The UA ships without the core segment until the core answers once.
      commonPrint.log(
        'Failed to read core version: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  Future<String> subscriptionUserAgent() async {
    final packageInfo = globalState.packageInfo;
    final coreVersion = await this.coreVersion;
    return [
      '${packageInfo.appName}/v${packageInfo.version}',
      if (coreVersion != null) 'core/v$coreVersion',
      'Platform/${Platform.operatingSystem}',
    ].join(' ');
  }

  Future<Map<String, String>> subscriptionHeaders({
    required bool includeDeviceIdentity,
  }) async {
    final headers = <String, String>{
      'User-Agent': globalState.configuredUa ?? await subscriptionUserAgent(),
    };
    if (includeDeviceIdentity) {
      final identity = await info;
      headers.addAll({
        'x-hwid': identity.hwid,
        'x-device-os': identity.os,
        'x-ver-os': identity.osVersion,
        'x-device-model': identity.model,
      });
    }
    return headers;
  }
}

final deviceIdentity = DeviceIdentity();

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:reclash/common/boot_record.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/system_dns.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/plugins/app.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

typedef ProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

class System {
  static System? _instance;
  bool _isTV = false;

  System._internal();

  factory System() {
    _instance ??= System._internal();
    return _instance!;
  }

  bool get isDesktop => isWindows || isMacOS || isLinux;

  bool get isWindows => Platform.isWindows;

  bool get isMacOS => Platform.isMacOS;

  bool get isAndroid => Platform.isAndroid;

  bool get isLinux => Platform.isLinux;

  bool get isTV => _isTV;

  Future<int> init() async {
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    _isTV = switch (deviceInfo) {
      AndroidDeviceInfo(:final systemFeatures) => systemFeatures.any(
        const {
          'android.hardware.type.television',
          'android.software.leanback',
        }.contains,
      ),
      _ => false,
    };
    return switch (Platform.operatingSystem) {
      'macos' => (deviceInfo as MacOsDeviceInfo).majorVersion,
      'android' => (deviceInfo as AndroidDeviceInfo).version.sdkInt,
      'windows' => (deviceInfo as WindowsDeviceInfo).majorVersion,
      String() => 0,
    };
  }

  Future<AppExitInfo?> lastExitInfo() async {
    if (!isAndroid) return null;
    return app?.getLastExitInfo();
  }

  bool get isAppImage =>
      isLinux && Platform.environment.containsKey('APPIMAGE');

  Future<void> back() async {
    await app?.moveTaskToBack();
  }

  Future<void> exit() async {
    if (system.isAndroid) {
      await SystemNavigator.pop();
    }
  }
}

final system = System();

class Windows {
  static Windows? _instance;
  static const _swHide = 0;
  static const _swShowNormal = 1;
  late DynamicLibrary _shell32;

  Windows._internal() {
    _shell32 = DynamicLibrary.open('shell32.dll');
  }

  factory Windows() {
    _instance ??= Windows._internal();
    return _instance!;
  }

  bool runas(String command, String arguments, {bool showWindow = true}) {
    final commandPtr = command.toNativeUtf16();
    final argumentsPtr = arguments.toNativeUtf16();
    final operationPtr = 'runas'.toNativeUtf16();

    final shellExecute = _shell32
        .lookupFunction<
          Int32 Function(
            Pointer<Utf16> hwnd,
            Pointer<Utf16> lpOperation,
            Pointer<Utf16> lpFile,
            Pointer<Utf16> lpParameters,
            Pointer<Utf16> lpDirectory,
            Int32 nShowCmd,
          ),
          int Function(
            Pointer<Utf16> hwnd,
            Pointer<Utf16> lpOperation,
            Pointer<Utf16> lpFile,
            Pointer<Utf16> lpParameters,
            Pointer<Utf16> lpDirectory,
            int nShowCmd,
          )
        >('ShellExecuteW');

    final result = shellExecute(
      nullptr,
      operationPtr,
      commandPtr,
      argumentsPtr,
      nullptr,
      showWindow ? _swShowNormal : _swHide,
    );

    calloc.free(commandPtr);
    calloc.free(argumentsPtr);
    calloc.free(operationPtr);

    commonPrint.log(
      'windows runas: $command $arguments resultCode:$result',
      logLevel: LogLevel.warning,
    );

    if (result <= 32) {
      return false;
    }
    return true;
  }
}

final windows = system.isWindows ? Windows() : null;

class MacOS implements SystemDnsPort {
  static MacOS? _instance;

  @visibleForTesting
  ProcessRunner runProcess = Process.run;

  MacOS._internal();

  factory MacOS() {
    _instance ??= MacOS._internal();
    return _instance!;
  }

  @visibleForTesting
  static String? parseDefaultInterface(String routeOutput) {
    final deviceLine = routeOutput
        .split('\n')
        .firstWhere((s) => s.contains('interface:'), orElse: () => '');
    final lineSplits = deviceLine.trim().split(' ');
    if (lineSplits.length != 2) {
      return null;
    }
    return lineSplits[1];
  }

  @visibleForTesting
  static String? parseServiceName(String serviceOrderOutput, String device) {
    final currentService = serviceOrderOutput
        .split('\n\n')
        .firstWhere((s) => s.contains('Device: $device'), orElse: () => '');
    if (currentService.isEmpty) {
      return null;
    }
    final nameLine = currentService
        .split('\n')
        .firstWhere(
          (line) => RegExp(r'^\(\d+\).*').hasMatch(line),
          orElse: () => '',
        );
    final name = RegExp(
      r'^\(\d+\)\s+(.+)$',
    ).firstMatch(nameLine.trim())?.group(1)?.trim();
    if (name == null || name.isEmpty) {
      return null;
    }
    return name;
  }

  @visibleForTesting
  static List<String> parseDnsServers(String getDnsServersOutput) {
    final output = getDnsServersOutput.trim();
    if (output.startsWith("There aren't any DNS Servers set on")) {
      return [];
    }
    return output.split('\n');
  }

  @override
  Future<String?> resolveDefaultService() async {
    final result = await _run('route', ['-n', 'get', 'default']);
    if (result == null) {
      return null;
    }
    final device = parseDefaultInterface(result.stdout.toString());
    if (device == null) {
      return null;
    }
    final serviceResult = await _run('networksetup', [
      '-listnetworkserviceorder',
    ]);
    if (serviceResult == null) {
      return null;
    }
    return parseServiceName(serviceResult.stdout.toString(), device);
  }

  @override
  Future<List<String>?> readDnsServers(String service) async {
    final result = await _run('networksetup', ['-getdnsservers', service]);
    if (result == null) {
      return null;
    }
    return parseDnsServers(result.stdout.toString());
  }

  @override
  Future<bool> writeDnsServers(String service, List<String> servers) async {
    final result = await _run('networksetup', [
      '-setdnsservers',
      service,
      if (servers.isEmpty) 'Empty',
      if (servers.isNotEmpty) ...servers,
    ], logLevel: LogLevel.error);
    return result != null;
  }

  Future<ProcessResult?> _run(
    String executable,
    List<String> arguments, {
    LogLevel logLevel = LogLevel.warning,
  }) async {
    final label = '$executable ${arguments.first}';
    try {
      final result = await runProcess(executable, arguments);
      if (result.exitCode != 0) {
        commonPrint.log(
          '$label exited with ${result.exitCode}: ${result.stderr.toString().trim()}',
          logLevel: logLevel,
        );
        return null;
      }
      return result;
    } catch (error) {
      commonPrint.log(
        '$label failed: ${compactError(error)}',
        logLevel: logLevel,
      );
      return null;
    }
  }
}

final macOS = system.isMacOS ? MacOS() : null;

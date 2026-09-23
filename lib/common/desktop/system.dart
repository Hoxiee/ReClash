import 'dart:ffi';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ffi/ffi.dart';
import 'package:reclash/common/app/boot_record.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/net/system_dns.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/linux_helper.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/plugins/app.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

typedef ProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

class System {
  static System? _instance;
  bool _isTV = false;

  @visibleForTesting
  ProcessRunner runProcess = Process.run;

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

  @visibleForTesting
  set isTVForTesting(bool value) => _isTV = value;

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

  Future<bool> didCrashOnPreviousExecution() async {
    if (!isAndroid) return false;
    return await app?.didCrashOnPreviousExecution() ?? false;
  }

  Future<AppExitInfo?> lastExitInfo() async {
    if (!isAndroid) return null;
    return app?.getLastExitInfo();
  }

  bool Function() hasSystemd = () =>
      Directory('/run/systemd/system').existsSync();

  Future<HelperReadiness> Function() helperReadiness = () =>
      helperClient.readiness();

  bool get hasHelperService => isLinux && hasSystemd();

  Future<bool> checkIsAdmin() async {
    if (hasHelperService) {
      return await helperReadiness() == HelperReadiness.ready;
    }
    if (system.isMacOS || system.isLinux) {
      return false;
    }
    return true;
  }

  static const _inheritedAclPermissions =
      'list,search,add_file,add_subdirectory,delete,delete_child,'
      'file_inherit,directory_inherit';

  @visibleForTesting
  static List<String> aclArguments(String homeDirPath, String userName) {
    return [
      '-R',
      '+a',
      'user:$userName allow $_inheritedAclPermissions',
      homeDirPath,
    ];
  }

  Future<void> grantHomeDirAccess(String homeDirPath) async {
    if (!isMacOS) {
      return;
    }
    final userName = Platform.environment['USER'];
    if (userName == null || userName.isEmpty) {
      return;
    }
    try {
      final result = await runProcess(
        'chmod',
        aclArguments(homeDirPath, userName),
      );
      if (result.exitCode != 0) {
        commonPrint.log(
          'chmod +a exited with ${result.exitCode}: ${result.stderr.toString().trim()}',
          logLevel: LogLevel.warning,
        );
      }
    } catch (error) {
      commonPrint.log(
        'chmod +a failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
  }

  Future<AuthorizeCode> authorizeCore() async {
    if (isLinux && hasHelperService) {
      return Linux().registerService();
    }
    return AuthorizeCode.error;
  }

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
  late DynamicLibrary _shell32;

  Windows._internal() {
    _shell32 = DynamicLibrary.open('shell32.dll');
  }

  factory Windows() {
    _instance ??= Windows._internal();
    return _instance!;
  }

  bool runas(String command, String arguments) {
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
      1,
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

  Future<AuthorizeCode> registerService() {
    return registerHelperService(
      () async => runas(appPath.helperPath, 'install'),
    );
  }
}

typedef ElevatedHelperInstaller = Future<bool> Function();

@visibleForTesting
Future<AuthorizeCode> registerHelperService(
  ElevatedHelperInstaller install,
) async {
  final readiness = await helperClient.readiness();
  switch (readiness) {
    case HelperReadiness.ready:
      commonPrint.log('helper service is ready');
      return AuthorizeCode.none;
    case HelperReadiness.manifestMissing:
      commonPrint.log(
        'Core manifest is missing or invalid; Helper service unavailable, '
        'falling back to direct Core',
        logLevel: LogLevel.warning,
      );
      dialogs.showNotifier(
        currentAppLocalizations.helperCorruptTip,
        level: MessageLevel.error,
      );
      return AuthorizeCode.error;
    case HelperReadiness.notReady:
      break;
  }

  commonPrint.log(
    'helper service is unavailable, requesting elevated installation',
    logLevel: LogLevel.warning,
  );
  if (!await install()) {
    commonPrint.log(
      'failed to launch elevated helper installation',
      logLevel: LogLevel.error,
    );
    return AuthorizeCode.error;
  }

  final isRunning = await _waitForHelperService();
  commonPrint.log(
    isRunning
        ? 'helper service installation completed'
        : 'helper service did not become ready after installation',
    logLevel: isRunning ? LogLevel.info : LogLevel.error,
  );
  return isRunning ? AuthorizeCode.success : AuthorizeCode.error;
}

Future<bool> _waitForHelperService() async {
  const timeout = Duration(seconds: 6);
  const interval = Duration(seconds: 1);
  const maxAttempts = 6;
  final stopwatch = Stopwatch()..start();
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    final remaining = timeout - stopwatch.elapsed;
    if (remaining <= Duration.zero) return false;
    final isRunning =
        await helperClient.readiness(timeout: remaining, logFailure: false) ==
        HelperReadiness.ready;
    if (isRunning) return true;
    final delay = timeout - stopwatch.elapsed;
    if (delay <= Duration.zero || attempt == maxAttempts - 1) return false;
    await Future.delayed(delay < interval ? delay : interval);
  }
  return false;
}

final windows = system.isWindows ? Windows() : null;

enum LinuxHelperInstallResult {
  ready,
  installed,
  cancelled,
  systemdUnavailable,
  pkexecUnavailable,
  agentUnavailable,
  bundleInvalid,
  failed,
  notReady,
}

class Linux {
  static Linux? _instance;

  @visibleForTesting
  ProcessRunner runProcess = Process.run;

  Linux._internal();

  factory Linux() {
    _instance ??= Linux._internal();
    return _instance!;
  }

  Future<AuthorizeCode> registerService() async {
    return switch (await registerWithResult()) {
      LinuxHelperInstallResult.ready => AuthorizeCode.none,
      LinuxHelperInstallResult.installed => AuthorizeCode.success,
      _ => AuthorizeCode.error,
    };
  }

  @visibleForTesting
  Future<bool> Function() waitForHelperService = _waitForHelperService;

  Future<LinuxHelperInstallResult> registerWithResult() async {
    if (!system.hasSystemd()) {
      return LinuxHelperInstallResult.systemdUnavailable;
    }
    try {
      switch (await system.helperReadiness()) {
        case HelperReadiness.ready:
          return LinuxHelperInstallResult.ready;
        case HelperReadiness.manifestMissing:
          return LinuxHelperInstallResult.bundleInvalid;
        case HelperReadiness.notReady:
          break;
      }
      final result = await installWithResult();
      if (result != LinuxHelperInstallResult.installed) return result;
      return await waitForHelperService()
          ? LinuxHelperInstallResult.installed
          : LinuxHelperInstallResult.notReady;
    } catch (error) {
      commonPrint.log(
        'Linux Helper registration failed: ${compactError(error)}',
        logLevel: LogLevel.error,
      );
      return LinuxHelperInstallResult.failed;
    }
  }

  @visibleForTesting
  Future<Directory> Function() stageHelperBundle = () =>
      LinuxHelperEnvironment().stageBundle();

  @visibleForTesting
  Future<bool> installService() async =>
      await installWithResult() == LinuxHelperInstallResult.installed;

  Future<LinuxHelperInstallResult> installWithResult() async {
    if (!system.hasSystemd()) {
      return LinuxHelperInstallResult.systemdUnavailable;
    }
    Directory? stage;
    try {
      try {
        stage = await stageHelperBundle();
      } on FormatException catch (error) {
        commonPrint.log(
          'Linux Helper bundle is invalid: ${compactError(error)}',
          logLevel: LogLevel.error,
        );
        return LinuxHelperInstallResult.bundleInvalid;
      }
      final helperPath = '${stage.path}/$appHelperService';
      final chmod = await runProcess('chmod', ['700', helperPath]);
      if (chmod.exitCode != 0) {
        commonPrint.log(
          'chmod helper exited with ${chmod.exitCode}: '
          '${chmod.stderr.toString().trim()}',
          logLevel: LogLevel.error,
        );
        return LinuxHelperInstallResult.failed;
      }
      final ProcessResult result;
      try {
        result = await runProcess('pkexec', [
          '--disable-internal-agent',
          helperPath,
          'install',
        ]);
      } on ProcessException catch (error) {
        commonPrint.log(
          'pkexec helper install failed: ${compactError(error)}',
          logLevel: LogLevel.error,
        );
        return error.errorCode == 2
            ? LinuxHelperInstallResult.pkexecUnavailable
            : LinuxHelperInstallResult.failed;
      }
      if (result.exitCode == 0) {
        return LinuxHelperInstallResult.installed;
      }
      final stderr = result.stderr.toString();
      commonPrint.log(
        'pkexec helper install exited with ${result.exitCode}: '
        '${stderr.trim()}',
        logLevel: LogLevel.error,
      );
      if (result.exitCode == 126) return LinuxHelperInstallResult.cancelled;
      final diagnostic = stderr.toLowerCase();
      if (diagnostic.contains('no authentication agent found') ||
          diagnostic.contains('no authentication agent available') ||
          diagnostic.contains('no authentication agent is available')) {
        return LinuxHelperInstallResult.agentUnavailable;
      }
    } catch (error) {
      commonPrint.log(
        'Linux Helper installation failed: ${compactError(error)}',
        logLevel: LogLevel.error,
      );
    } finally {
      if (stage != null) {
        try {
          await stage.delete(recursive: true);
        } catch (error) {
          commonPrint.log(
            'Linux Helper staging cleanup failed: ${compactError(error)}',
            logLevel: LogLevel.warning,
          );
        }
      }
    }
    return LinuxHelperInstallResult.failed;
  }
}

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

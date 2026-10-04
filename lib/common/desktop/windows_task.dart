import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart' as p;
import 'package:win32_registry/win32_registry.dart';

import '../storage/path.dart';
import '../util/string.dart';
import 'system.dart';

enum AutoLaunchMechanism { none, runKey, scheduledTask }

/// The Run-key entry and the scheduled task are mutually exclusive; both active
/// at once would launch two instances. The task is Windows-only and only earns
/// its keep when autostart is on.
AutoLaunchMechanism resolveLaunchMechanism({
  required bool isWindows,
  required bool autoLaunch,
  required bool highPriority,
}) {
  if (!autoLaunch) {
    return AutoLaunchMechanism.none;
  }
  if (isWindows && highPriority) {
    return AutoLaunchMechanism.scheduledTask;
  }
  return AutoLaunchMechanism.runKey;
}

@visibleForTesting
String escapeXml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

/// `InteractiveToken` + `LeastPrivilege` keep the GUI in the user session with
/// no UAC prompt; the earlier `LogonTrigger` and `<Priority>7</Priority>` are
/// what beat the plain Run-key start, while `ExecutionTimeLimit=PT0S` and
/// `AllowHardTerminate=false` stop the scheduler from killing the GUI. A
/// [userId] scopes the task to the account that created it.
String buildAutoLaunchTaskXml({
  required String executablePath,
  String? userId,
}) {
  final command = escapeXml(executablePath);
  final trigger = userId == null
      ? '<LogonTrigger><Delay>PT0S</Delay></LogonTrigger>'
      : '<LogonTrigger><Delay>PT0S</Delay><UserId>${escapeXml(userId)}</UserId>'
            '</LogonTrigger>';
  final principal = userId == null
      ? '<Principal id="Author"><LogonType>InteractiveToken</LogonType>'
            '<RunLevel>LeastPrivilege</RunLevel></Principal>'
      : '<Principal id="Author"><UserId>${escapeXml(userId)}</UserId>'
            '<LogonType>InteractiveToken</LogonType>'
            '<RunLevel>LeastPrivilege</RunLevel></Principal>';
  return '<?xml version="1.0" encoding="UTF-16"?>\n'
      '<Task version="1.2" '
      'xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">\n'
      '  <Principals>$principal</Principals>\n'
      '  <Triggers>$trigger</Triggers>\n'
      '  <Settings>\n'
      '    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>\n'
      '    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>\n'
      '    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>\n'
      '    <AllowHardTerminate>false</AllowHardTerminate>\n'
      '    <StartWhenAvailable>false</StartWhenAvailable>\n'
      '    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>\n'
      '    <AllowStartOnDemand>true</AllowStartOnDemand>\n'
      '    <Enabled>true</Enabled><Hidden>false</Hidden>\n'
      '    <RunOnlyIfIdle>false</RunOnlyIfIdle><WakeToRun>false</WakeToRun>\n'
      '    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>\n'
      '    <Priority>7</Priority>\n'
      '  </Settings>\n'
      '  <Actions Context="Author"><Exec><Command>$command</Command></Exec>'
      '</Actions>\n'
      '</Task>';
}

@visibleForTesting
String? currentUserId(Map<String, String> environment) {
  final user = environment['USERNAME'];
  if (user == null || user.isEmpty) {
    return null;
  }
  final domain = environment['USERDOMAIN'];
  if (domain == null || domain.isEmpty) {
    return user;
  }
  return '$domain\\$user';
}

typedef ElevatedRunner = bool Function(String command, String arguments);

/// A per-user task needs no elevation, so plain `schtasks.exe` is tried first;
/// the [elevate] `runas` fallback covers policies that force a UAC prompt.
class WindowsTaskScheduler {
  WindowsTaskScheduler({
    ProcessRunner? runProcess,
    ElevatedRunner? elevate,
    Future<String> Function()? tempDirPath,
    Map<String, String>? environment,
  }) : runProcess = runProcess ?? Process.run,
       elevate = elevate ?? _defaultElevate,
       tempDirPath = tempDirPath ?? (() => appPath.tempPath),
       environment = environment ?? Platform.environment;

  final ProcessRunner runProcess;
  final ElevatedRunner elevate;
  final Future<String> Function() tempDirPath;
  final Map<String, String> environment;

  static bool _defaultElevate(String command, String arguments) {
    return windows?.runas(command, arguments) ?? false;
  }

  Future<bool> isRegistered(String taskName) async {
    final result = await runProcess('schtasks.exe', [
      '/Query',
      '/TN',
      taskName,
    ]);
    return result.exitCode == 0 && result.stdout.toString().contains(taskName);
  }

  Future<bool> register(String taskName, String executablePath) async {
    final xml = buildAutoLaunchTaskXml(
      executablePath: executablePath,
      userId: currentUserId(environment),
    );
    final taskPath = p.join(await tempDirPath(), 'reclash_autolaunch_task.xml');
    await File(taskPath).writeAsBytes(xml.encodeUtf16LeWithBom, flush: true);
    final arguments = ['/Create', '/TN', taskName, '/XML', taskPath, '/F'];
    final result = await runProcess('schtasks.exe', arguments);
    if (result.exitCode == 0) {
      return true;
    }
    return elevate('schtasks.exe', _quoteArguments(arguments));
  }

  Future<bool> unregister(String taskName) async {
    if (!await isRegistered(taskName)) {
      return true;
    }
    final arguments = ['/Delete', '/TN', taskName, '/F'];
    final result = await runProcess('schtasks.exe', arguments);
    if (result.exitCode == 0) {
      return true;
    }
    return elevate('schtasks.exe', _quoteArguments(arguments));
  }

  static String _quoteArguments(List<String> arguments) {
    return arguments.map((arg) => arg.contains(' ') ? '"$arg"' : arg).join(' ');
  }
}

const _runKeyPath = r'Software\Microsoft\Windows\CurrentVersion\Run';
const _startupApprovedPath =
    r'Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run';

/// The HKCU Run command and its StartupApproved flag an autostart entry needs,
/// abstracted so the enable/disable sequencing is testable off Windows.
abstract class WindowsRunKeyStore {
  String? readCommand(String name);
  void writeCommand(String name, String value);
  void removeCommand(String name);
  Uint8List? readApproval(String name);
  void writeApproval(String name, Uint8List value);
  void removeApproval(String name);
}

class RegistryRunKeyStore implements WindowsRunKeyStore {
  const RegistryRunKeyStore();

  R? _read<R>(String path, R? Function(RegistryKey key) action) {
    RegistryKey? key;
    try {
      key = CURRENT_USER.open(
        path,
        config: const RegistryOpenConfig(access: RegistryAccess.all),
      );
      return action(key);
    } catch (_) {
      return null;
    } finally {
      key?.close();
    }
  }

  void _mutate(String path, void Function(RegistryKey key) action) {
    _read<void>(path, (key) {
      action(key);
    });
  }

  @override
  String? readCommand(String name) =>
      _read(_runKeyPath, (key) => key.getString(name));

  @override
  void writeCommand(String name, String value) => _mutate(
    _runKeyPath,
    (key) => key.setValue(name, RegistryValue.string(value)),
  );

  @override
  void removeCommand(String name) => _mutate(_runKeyPath, (key) {
    if (key.getValue(name) != null) {
      key.removeValue(name);
    }
  });

  @override
  Uint8List? readApproval(String name) =>
      _read(_startupApprovedPath, (key) => key.getBinary(name));

  @override
  void writeApproval(String name, Uint8List value) => _mutate(
    _startupApprovedPath,
    (key) => key.setValue(name, RegistryValue.binary(value)),
  );

  @override
  void removeApproval(String name) => _mutate(_startupApprovedPath, (key) {
    if (key.getValue(name) != null) {
      key.removeValue(name);
    }
  });
}

/// Owns the HKCU Run autostart entry so the path is quoted, unlike the upstream
/// package. The scheduled task and this key are mutually exclusive, so
/// [disable] clears both the command and its StartupApproved flag.
class WindowsRunKey {
  WindowsRunKey({WindowsRunKeyStore store = const RegistryRunKeyStore()})
    : _store = store;

  final WindowsRunKeyStore _store;

  @visibleForTesting
  static String commandFor(String executablePath) => '"$executablePath"';

  bool isEnabled(String name, String executablePath) {
    if (_store.readCommand(name) != commandFor(executablePath)) {
      return false;
    }
    // StartupApproved's first byte is odd when Task Manager disabled the entry;
    // an absent value means approved.
    final approval = _store.readApproval(name);
    return approval == null || approval.isEmpty || approval[0].isEven;
  }

  void enable(String name, String executablePath) {
    _store.writeCommand(name, commandFor(executablePath));
    _store.writeApproval(name, Uint8List(12)..[0] = 2);
  }

  void disable(String name) {
    _store.removeCommand(name);
    _store.removeApproval(name);
  }
}

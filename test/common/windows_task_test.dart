import 'dart:io';

import 'package:reclash/common/desktop/windows_task.dart';
import 'package:flutter_test/flutter_test.dart';

ProcessResult _result(int exitCode, String stdout) =>
    ProcessResult(0, exitCode, stdout, '');

void main() {
  group('resolveLaunchMechanism', () {
    test('autostart off means no mechanism', () {
      expect(
        resolveLaunchMechanism(
          isWindows: true,
          autoLaunch: false,
          highPriority: true,
        ),
        AutoLaunchMechanism.none,
      );
    });

    test('high priority on Windows uses the scheduled task', () {
      expect(
        resolveLaunchMechanism(
          isWindows: true,
          autoLaunch: true,
          highPriority: true,
        ),
        AutoLaunchMechanism.scheduledTask,
      );
    });

    test('autostart without high priority uses the Run key', () {
      expect(
        resolveLaunchMechanism(
          isWindows: true,
          autoLaunch: true,
          highPriority: false,
        ),
        AutoLaunchMechanism.runKey,
      );
    });

    test('high priority off Windows falls back to the Run key', () {
      expect(
        resolveLaunchMechanism(
          isWindows: false,
          autoLaunch: true,
          highPriority: true,
        ),
        AutoLaunchMechanism.runKey,
      );
    });
  });

  group('buildAutoLaunchTaskXml', () {
    test('carries the high-priority markers', () {
      final xml = buildAutoLaunchTaskXml(
        executablePath: r'C:\Program Files\ReClash\reclash.exe',
      );
      expect(xml, contains('<Priority>7</Priority>'));
      expect(xml, contains('<LogonType>InteractiveToken</LogonType>'));
      expect(xml, contains('<RunLevel>LeastPrivilege</RunLevel>'));
      expect(xml, contains('<AllowHardTerminate>false</AllowHardTerminate>'));
      expect(xml, contains('<ExecutionTimeLimit>PT0S</ExecutionTimeLimit>'));
      expect(xml, contains('<LogonTrigger>'));
      expect(
        xml,
        contains(r'<Command>C:\Program Files\ReClash\reclash.exe</Command>'),
      );
    });

    test('scopes to the user when a userId is given', () {
      final xml = buildAutoLaunchTaskXml(
        executablePath: r'C:\app.exe',
        userId: r'DOMAIN\user',
      );
      expect(xml, contains(r'<UserId>DOMAIN\user</UserId>'));
    });

    test('escapes XML-significant characters in the path', () {
      final xml = buildAutoLaunchTaskXml(executablePath: r'C:\a & b<>.exe');
      expect(xml, contains('C:\\a &amp; b&lt;&gt;.exe'));
    });
  });

  group('currentUserId', () {
    test('joins domain and user', () {
      expect(
        currentUserId({'USERNAME': 'me', 'USERDOMAIN': 'CORP'}),
        r'CORP\me',
      );
    });

    test('falls back to bare user without a domain', () {
      expect(currentUserId({'USERNAME': 'me'}), 'me');
    });

    test('returns null without a user name', () {
      expect(currentUserId({}), isNull);
    });
  });

  group('WindowsTaskScheduler', () {
    test('register writes the XML and calls schtasks /Create', () async {
      final calls = <List<String>>[];
      final scheduler = WindowsTaskScheduler(
        runProcess: (executable, arguments) async {
          calls.add([executable, ...arguments]);
          return _result(0, '');
        },
        elevate: (_, _) => false,
        tempDirPath: () async => Directory.systemTemp.path,
        environment: const {'USERNAME': 'me'},
      );
      expect(await scheduler.register('ReClash', r'C:\app.exe'), isTrue);
      expect(calls.single.first, 'schtasks.exe');
      expect(calls.single, contains('/Create'));
      expect(calls.single, contains('/TN'));
      expect(calls.single, contains('ReClash'));
    });

    test('register falls back to elevation on failure', () async {
      var elevated = false;
      final scheduler = WindowsTaskScheduler(
        runProcess: (_, _) async => _result(1, ''),
        elevate: (_, _) {
          elevated = true;
          return true;
        },
        tempDirPath: () async => Directory.systemTemp.path,
        environment: const {},
      );
      expect(await scheduler.register('ReClash', r'C:\app.exe'), isTrue);
      expect(elevated, isTrue);
    });

    test('unregister is a no-op when the task is absent', () async {
      var deleteCalled = false;
      final scheduler = WindowsTaskScheduler(
        runProcess: (executable, arguments) async {
          if (arguments.contains('/Delete')) {
            deleteCalled = true;
          }
          return _result(1, '');
        },
        elevate: (_, _) => false,
        tempDirPath: () async => Directory.systemTemp.path,
        environment: const {},
      );
      expect(await scheduler.unregister('ReClash'), isTrue);
      expect(deleteCalled, isFalse);
    });

    test('unregister deletes an existing task', () async {
      final calls = <String>[];
      final scheduler = WindowsTaskScheduler(
        runProcess: (executable, arguments) async {
          calls.add(arguments.first);
          if (arguments.contains('/Query')) {
            return _result(0, 'ReClash');
          }
          return _result(0, '');
        },
        elevate: (_, _) => false,
        tempDirPath: () async => Directory.systemTemp.path,
        environment: const {},
      );
      expect(await scheduler.unregister('ReClash'), isTrue);
      expect(calls, containsAll(['/Query', '/Delete']));
    });

    test('isRegistered matches the task name in query output', () async {
      final scheduler = WindowsTaskScheduler(
        runProcess: (_, _) async => _result(0, 'Folder: \\\nReClash Ready'),
        elevate: (_, _) => false,
        tempDirPath: () async => Directory.systemTemp.path,
        environment: const {},
      );
      expect(await scheduler.isRegistered('ReClash'), isTrue);
    });
  });
}

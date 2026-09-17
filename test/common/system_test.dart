import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

class _RecordedRun {
  const _RecordedRun(this.executable, this.arguments);

  final String executable;
  final List<String> arguments;

  String get key =>
      arguments.isEmpty ? executable : '$executable ${arguments.first}';
}

/// Stands in for `Process.run`, keyed by executable plus its first argument so
/// the several `networksetup` subcommands can answer differently.
class _FakeProcesses {
  final List<_RecordedRun> runs = [];
  final Map<String, String> _stdout = {};
  final Map<String, int> _exitCodes = {};
  final Set<String> _failures = {};

  void stub(String key, String stdout, {int exitCode = 0}) {
    _stdout[key] = stdout;
    _exitCodes[key] = exitCode;
  }

  void stubThrow(String key) {
    _failures.add(key);
  }

  Future<ProcessResult> run(String executable, List<String> arguments) async {
    final recorded = _RecordedRun(executable, arguments);
    runs.add(recorded);
    if (_failures.contains(recorded.key) || _failures.contains(executable)) {
      throw ProcessException(executable, arguments);
    }
    return ProcessResult(
      0,
      _exitCodes[recorded.key] ?? _exitCodes[executable] ?? 0,
      _stdout[recorded.key] ?? _stdout[executable] ?? '',
      '',
    );
  }

  List<String> argumentsFor(String key) => runs
      .firstWhere((run) => run.key == key || run.executable == key)
      .arguments;

  bool ran(String key) =>
      runs.any((run) => run.key == key || run.executable == key);
}

const _routeOutput = '''
   route to: default
destination: default
       mask: default
  interface: en0
      flags: <UP,GATEWAY,DONE,STATIC,PRCLONING,GLOBAL>
''';

const _serviceOrderOutput =
    '''An asterisk (*) denotes that a network service is disabled.
(1) Wi-Fi
(Hardware Port: Wi-Fi, Device: en0)

(2) Thunderbolt Bridge
(Hardware Port: Thunderbolt Bridge, Device: bridge0)

(3) iPhone USB
(Hardware Port: iPhone USB, Device: en5)
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late _FakeProcesses processes;
  final originalHasSystemd = system.hasSystemd;
  final originalReadiness = system.helperReadiness;
  final originalStage = Linux().stageHelperBundle;

  setUpAll(() {
    root = Directory.systemTemp.createTempSync('system_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
  });

  tearDownAll(() {
    // The shared system temp dir is not exclusively ours; another suite running
    // alongside this one can take the tree out from under the teardown.
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  setUp(() {
    processes = _FakeProcesses();
    system.runProcess = processes.run;
    MacOS().runProcess = processes.run;
    Linux().runProcess = processes.run;
    system.hasSystemd = () => false;
    system.helperReadiness = () async => HelperReadiness.notReady;
  });

  tearDown(() {
    system.runProcess = Process.run;
    MacOS().runProcess = Process.run;
    Linux().runProcess = Process.run;
    system.hasSystemd = originalHasSystemd;
    system.helperReadiness = originalReadiness;
    Linux().stageHelperBundle = originalStage;
  });

  group('aclArguments', () {
    test('grants the inheriting user access to the whole tree', () {
      final arguments = System.aclArguments('/Users/a/Support', 'alice');

      expect(arguments.first, '-R');
      expect(arguments[1], '+a');
      expect(arguments[2], startsWith('user:alice allow '));
      expect(arguments.last, '/Users/a/Support');
      expect(
        arguments[2].split(' allow ').last.split(','),
        unorderedEquals(const [
          'list',
          'search',
          'add_file',
          'add_subdirectory',
          'delete',
          'delete_child',
          'file_inherit',
          'directory_inherit',
        ]),
      );
    });

    test('never hands out ownership or the ACL itself', () {
      final arguments = System.aclArguments('/Users/a/Support', 'alice');

      expect(arguments[2], isNot(contains('writesecurity')));
      expect(arguments[2], isNot(contains('chown')));
    });

    test('passes a path containing spaces through untouched', () {
      const path = '/Users/a b/Library/Application Support/com.reclash';

      final arguments = System.aclArguments(path, 'alice');

      expect(arguments.last, path);
      expect(arguments.last, isNot(contains(r'\')));
    });
  });

  group('grantHomeDirAccess', () {
    test('only touches the filesystem on macOS', () async {
      await system.grantHomeDirAccess('/Users/a/Support');

      final userName = Platform.environment['USER'];
      expect(
        processes.ran('chmod'),
        system.isMacOS && userName != null && userName.isNotEmpty,
      );
    });

    test('survives a chmod that cannot apply an ACL', () async {
      processes.stub('chmod', '', exitCode: 1);

      await expectLater(
        system.grantHomeDirAccess('/Users/a/Support'),
        completes,
      );

      processes.stubThrow('chmod');

      await expectLater(
        system.grantHomeDirAccess('/Users/a/Support'),
        completes,
      );
    });
  });

  test(
    'Windows Helper stays disabled until privileged IPC is authenticated',
    () {
      expect(system.hasHelperService, isFalse);
    },
  );

  group('Unix Core authorization', () {
    test('never recognizes a setuid binary as supported', () async {
      expect(await system.checkIsAdmin(), isFalse);
      expect(processes.runs, isEmpty);
    });

    test('never invokes an elevation command', () async {
      expect(await system.authorizeCore(), AuthorizeCode.error);
      expect(processes.runs, isEmpty);
    });
  }, skip: system.isMacOS || system.isLinux ? false : 'Unix only');

  group('Linux Helper availability', () {
    test('requires systemd, including for AppImage launches', () {
      expect(system.hasHelperService, isFalse);
      system.hasSystemd = () => true;
      expect(system.hasHelperService, isTrue);
    });

    test('authorization requires a verified running Helper', () async {
      system.hasSystemd = () => true;
      expect(await system.checkIsAdmin(), isFalse);
      system.helperReadiness = () async => HelperReadiness.ready;
      expect(await system.checkIsAdmin(), isTrue);
      expect(processes.runs, isEmpty);
    });
  }, skip: !Platform.isLinux);

  group('Linux Helper installation', () {
    late Directory stage;
    late bool staged;
    late bool waited;
    final originalWait = Linux().waitForHelperService;

    setUp(() async {
      stage = await root.createTemp('helper-stage-');
      staged = false;
      waited = false;
      system.hasSystemd = () => true;
      Linux().stageHelperBundle = () async {
        staged = true;
        return stage;
      };
      Linux().waitForHelperService = () async {
        waited = true;
        return true;
      };
    });

    tearDown(() {
      Linux().waitForHelperService = originalWait;
      if (staged) {
        expect(stage.existsSync(), isFalse);
      } else {
        stage.deleteSync(recursive: true);
      }
    });

    test('asks pkexec to install without its internal agent', () async {
      expect(await Linux().installService(), isTrue);
      final helperPath = '${stage.path}/$appHelperService';
      expect(processes.argumentsFor('chmod'), ['700', helperPath]);
      expect(processes.argumentsFor('pkexec'), [
        '--disable-internal-agent',
        helperPath,
        'install',
      ]);
    });

    test('does not request elevation when chmod fails', () async {
      processes.stub('chmod', '', exitCode: 1);
      expect(
        await Linux().installWithResult(),
        LinuxHelperInstallResult.failed,
      );
      expect(processes.ran('pkexec'), isFalse);
    });

    test('does not report a chmod launch failure as missing pkexec', () async {
      Linux().runProcess = (executable, arguments) async {
        throw ProcessException(executable, arguments, 'Not found', 2);
      };
      expect(
        await Linux().installWithResult(),
        LinuxHelperInstallResult.failed,
      );
    });

    test('reports an installation the user dismissed', () async {
      processes.stub('pkexec', '', exitCode: 126);
      expect(
        await Linux().registerWithResult(),
        LinuxHelperInstallResult.cancelled,
      );
      expect(waited, isFalse);
    });

    test('keeps cancellation false through the legacy bool seam', () async {
      processes.stub('pkexec', '', exitCode: 126);
      expect(await Linux().installService(), isFalse);
    });

    test('reports a host with no pkexec at all', () async {
      Linux().runProcess = (executable, arguments) async {
        if (executable == 'pkexec') {
          throw ProcessException(executable, arguments, 'Not found', 2);
        }
        return processes.run(executable, arguments);
      };
      expect(
        await Linux().installWithResult(),
        LinuxHelperInstallResult.pkexecUnavailable,
      );
    });

    test('keeps other pkexec launch errors as failures', () async {
      Linux().runProcess = (executable, arguments) async {
        if (executable == 'pkexec') {
          throw ProcessException(
            executable,
            arguments,
            'Permission denied',
            13,
          );
        }
        return processes.run(executable, arguments);
      };
      expect(
        await Linux().installWithResult(),
        LinuxHelperInstallResult.failed,
      );
    });

    for (final diagnostic in [
      'No authentication agent found.',
      'No authentication agent available',
      'No authentication agent is available',
    ]) {
      test('recognizes the agent diagnostic: $diagnostic', () async {
        Linux().runProcess = (executable, arguments) async {
          if (executable == 'pkexec') {
            return ProcessResult(0, 127, '', diagnostic);
          }
          return processes.run(executable, arguments);
        };
        expect(
          await Linux().installWithResult(),
          LinuxHelperInstallResult.agentUnavailable,
        );
      });
    }

    for (final diagnostic in [
      '',
      'Not authorized',
      'Error executing command',
      'No session for cookie',
    ]) {
      test('keeps ambiguous exit 127 as failed: $diagnostic', () async {
        Linux().runProcess = (executable, arguments) async {
          if (executable == 'pkexec') {
            return ProcessResult(0, 127, '', diagnostic);
          }
          return processes.run(executable, arguments);
        };
        expect(
          await Linux().installWithResult(),
          LinuxHelperInstallResult.failed,
        );
      });
    }

    test('reports a failed installer without waiting', () async {
      processes.stub('pkexec', '', exitCode: 1);
      expect(
        await Linux().registerWithResult(),
        LinuxHelperInstallResult.failed,
      );
      expect(waited, isFalse);
    });

    test('checks systemd before staging or requesting elevation', () async {
      system.hasSystemd = () => false;
      expect(
        await Linux().registerWithResult(),
        LinuxHelperInstallResult.systemdUnavailable,
      );
      expect(
        await Linux().installWithResult(),
        LinuxHelperInstallResult.systemdUnavailable,
      );
      expect(processes.runs, isEmpty);
      expect(staged, isFalse);
      expect(waited, isFalse);
    });

    test('does not reinstall an already ready Helper', () async {
      system.helperReadiness = () async => HelperReadiness.ready;
      expect(
        await Linux().registerWithResult(),
        LinuxHelperInstallResult.ready,
      );
      expect(await Linux().registerService(), AuthorizeCode.none);
      expect(processes.runs, isEmpty);
      expect(staged, isFalse);
      expect(waited, isFalse);
    });

    test('rejects an invalid manifest before installation', () async {
      system.helperReadiness = () async => HelperReadiness.manifestMissing;
      expect(
        await Linux().registerWithResult(),
        LinuxHelperInstallResult.bundleInvalid,
      );
      expect(processes.runs, isEmpty);
      expect(staged, isFalse);
      expect(waited, isFalse);
    });

    test('rejects an invalid staged bundle without elevation', () async {
      Linux().stageHelperBundle = () async {
        throw const FormatException('Linux Helper bundle hash mismatch');
      };
      expect(
        await Linux().registerWithResult(),
        LinuxHelperInstallResult.bundleInvalid,
      );
      expect(processes.runs, isEmpty);
      expect(waited, isFalse);
    });

    test('requires readiness after successful installation', () async {
      expect(
        await Linux().registerWithResult(),
        LinuxHelperInstallResult.installed,
      );
      expect(waited, isTrue);
    });

    test(
      'keeps successful installation compatible with AuthorizeCode',
      () async {
        expect(await Linux().registerService(), AuthorizeCode.success);
        expect(waited, isTrue);
      },
    );

    test('reports a Helper that never becomes ready', () async {
      Linux().waitForHelperService = () async => false;
      expect(
        await Linux().registerWithResult(),
        LinuxHelperInstallResult.notReady,
      );
    });

    test('reports unexpected readiness failures without elevation', () async {
      system.helperReadiness = () async => throw StateError('Probe failed');
      expect(
        await Linux().registerWithResult(),
        LinuxHelperInstallResult.failed,
      );
      expect(processes.runs, isEmpty);
      expect(staged, isFalse);
    });
  });

  group('parseDefaultInterface', () {
    test('reads the interface off route output', () {
      expect(MacOS.parseDefaultInterface(_routeOutput), 'en0');
    });

    test('returns null when there is no default route', () {
      expect(
        MacOS.parseDefaultInterface('route: writing to routing socket'),
        isNull,
      );
    });

    test('returns null when the interface line carries extra fields', () {
      expect(MacOS.parseDefaultInterface('  interface: en0 en1\n'), isNull);
    });
  });

  group('parseServiceName', () {
    test('reads a single-word service name', () {
      expect(MacOS.parseServiceName(_serviceOrderOutput, 'en0'), 'Wi-Fi');
    });

    test('keeps every word of a multi-word service name', () {
      expect(
        MacOS.parseServiceName(_serviceOrderOutput, 'bridge0'),
        'Thunderbolt Bridge',
      );
      expect(MacOS.parseServiceName(_serviceOrderOutput, 'en5'), 'iPhone USB');
    });

    test('returns null for a device no service claims', () {
      expect(MacOS.parseServiceName(_serviceOrderOutput, 'utun0'), isNull);
    });

    test('returns null when the block carries no numbered name line', () {
      expect(
        MacOS.parseServiceName('(Hardware Port: Wi-Fi, Device: en0)', 'en0'),
        isNull,
      );
    });
  });

  group('parseDnsServers', () {
    test('maps the empty notice onto an empty list', () {
      expect(
        MacOS.parseDnsServers("There aren't any DNS Servers set on Wi-Fi.\n"),
        isEmpty,
      );
    });

    test('splits a configured list', () {
      expect(MacOS.parseDnsServers('1.1.1.1\n8.8.8.8\n'), [
        '1.1.1.1',
        '8.8.8.8',
      ]);
    });
  });

  group('resolveDefaultService', () {
    test('joins the route lookup to the service order listing', () async {
      processes.stub('route', _routeOutput);
      processes.stub(
        'networksetup -listnetworkserviceorder',
        _serviceOrderOutput,
      );

      expect(await MacOS().resolveDefaultService(), 'Wi-Fi');
    });

    test('stops before listing services without a default route', () async {
      expect(await MacOS().resolveDefaultService(), isNull);
      expect(processes.ran('networksetup -listnetworkserviceorder'), isFalse);
    });

    test('reports a failing route lookup as unresolved', () async {
      processes.stub('route', '', exitCode: 1);

      expect(await MacOS().resolveDefaultService(), isNull);
      expect(processes.ran('networksetup -listnetworkserviceorder'), isFalse);
    });

    test('survives a missing executable', () async {
      processes.stubThrow('route');

      expect(await MacOS().resolveDefaultService(), isNull);
    });
  });

  group('readDnsServers', () {
    test('reads the servers of the requested service', () async {
      processes.stub('networksetup -getdnsservers', '1.1.1.1\n8.8.8.8\n');

      expect(await MacOS().readDnsServers('Wi-Fi'), ['1.1.1.1', '8.8.8.8']);
      expect(processes.argumentsFor('networksetup -getdnsservers'), [
        '-getdnsservers',
        'Wi-Fi',
      ]);
    });

    test('returns null when the lookup fails', () async {
      processes.stub('networksetup -getdnsservers', '', exitCode: 1);

      expect(await MacOS().readDnsServers('Wi-Fi'), isNull);
    });
  });

  group('writeDnsServers', () {
    test('writes the requested servers', () async {
      expect(await MacOS().writeDnsServers('Wi-Fi', ['1.1.1.1']), isTrue);
      expect(processes.argumentsFor('networksetup -setdnsservers'), [
        '-setdnsservers',
        'Wi-Fi',
        '1.1.1.1',
      ]);
    });

    test('clears the servers with the literal networksetup keyword', () async {
      expect(await MacOS().writeDnsServers('Wi-Fi', []), isTrue);
      expect(processes.argumentsFor('networksetup -setdnsservers'), [
        '-setdnsservers',
        'Wi-Fi',
        'Empty',
      ]);
    });

    test('reports a rejected write instead of assuming success', () async {
      processes.stub('networksetup -setdnsservers', '', exitCode: 1);

      expect(await MacOS().writeDnsServers('Wi-Fi', ['1.1.1.1']), isFalse);
    });
  });
}

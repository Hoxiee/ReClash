import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_paths.dart';

class _RecordedRun {
  const _RecordedRun(this.executable, this.arguments);

  final String executable;
  final List<String> arguments;

  String get key =>
      arguments.isEmpty ? executable : '$executable ${arguments.first}';

  String get commandLine => [executable, ...arguments].join(' ');
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
      _exitCodes[recorded.commandLine] ??
          _exitCodes[recorded.key] ??
          _exitCodes[executable] ??
          0,
      _stdout[recorded.commandLine] ??
          _stdout[recorded.key] ??
          _stdout[executable] ??
          '',
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

  setUpAll(() async {
    root = Directory.systemTemp.createTempSync('system_test');
    await useAppPaths(root);
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
    MacOS().runProcess = processes.run;
  });

  tearDown(() {
    MacOS().runProcess = Process.run;
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

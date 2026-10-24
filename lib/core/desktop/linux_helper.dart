import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:reclash/common/constant.dart';
import 'package:reclash/common/print.dart';
import 'package:reclash/enum/enum.dart';

import 'core_manifest.dart';
import 'helper_client.dart';

typedef LinuxHelperProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

enum LinuxHelperInstallResult {
  ready,
  installed,
  cancelled,
  denied,
  systemdUnavailable,
  pkexecUnavailable,
  agentUnavailable,
  bundleInvalid,
  registrationConflict,
  systemdFailed,
  installBusy,
  stopFailed,
  protocolMismatch,
  failed,
  notReady,
  unsupported,
}

final class LinuxHelperEnvironment {
  final int? _uid;
  final String? _bundleDirectory;

  LinuxHelperEnvironment({int? uid, String? bundleDirectory})
    : _uid = uid,
      _bundleDirectory = bundleDirectory;

  int get uid {
    final value = _uid ?? _currentUid();
    if (value <= 0 || value >= 0xffffffff) {
      throw StateError('Linux Helper requires a non-root owner');
    }
    return value;
  }

  String get bundleDirectory =>
      _bundleDirectory ?? p.dirname(Platform.resolvedExecutable);

  String get socketPath => '/run/reclash-helper-$uid/helper.sock';

  String get manifestPath => p.join(bundleDirectory, coreManifestName);

  String? get nativePackage {
    final marker = File(p.join(bundleDirectory, 'reclash-package'));
    try {
      if (FileSystemEntity.typeSync(marker.path, followLinks: false) !=
              FileSystemEntityType.file ||
          marker.lengthSync() > 4) {
        return null;
      }
      return nativePackageFor(bundleDirectory, marker.readAsStringSync());
    } on FileSystemException {
      return null;
    }
  }

  static String? nativePackageFor(String directory, String marker) =>
      switch ((p.normalize(p.absolute(directory)), marker)) {
        ('/opt/ReClash', 'deb\n') => 'deb',
        ('/usr/share/ReClash', 'rpm\n') => 'rpm',
        _ => null,
      };

  Future<String> installedHelperPath() async {
    final core = await CoreManifest.readCoreSha256(path: manifestPath);
    final helper = await CoreManifest.readHelperSha256(path: manifestPath);
    if (core == null || helper == null) {
      throw const FormatException('Linux Helper bundle manifest is invalid');
    }
    return '/var/lib/reclash-helper/$uid/bundles/$core-$helper/$appHelperService';
  }

  Future<Directory> stageBundle() async {
    final directory = bundleDirectory;
    final owner = uid;
    final path = await Isolate.run(() => _stageBundle(directory, owner));
    return Directory(path);
  }

  static int _currentUid() {
    if (!Platform.isLinux) {
      throw UnsupportedError('Linux Helper is available only on Linux');
    }
    final libc = DynamicLibrary.process();
    final getuid = libc.lookupFunction<Uint32 Function(), int Function()>(
      'getuid',
    );
    final geteuid = libc.lookupFunction<Uint32 Function(), int Function()>(
      'geteuid',
    );
    final real = getuid();
    if (real != geteuid()) {
      throw StateError('The ReClash GUI must not run setuid');
    }
    return real;
  }
}

Future<String> _stageBundle(String directory, int uid) async {
  final source = Directory(directory);
  final resolved = await source.resolveSymbolicLinks();
  if (!p.equals(p.normalize(p.absolute(directory)), resolved)) {
    throw const FormatException('Bundle source contains a symbolic link');
  }
  final manifestPath = p.join(resolved, coreManifestName);
  await _requireRegularFile(manifestPath);
  final manifestFile = File(manifestPath);
  if (await manifestFile.length() > 4096) {
    throw const FormatException('Bundle manifest is too large');
  }
  final value = jsonDecode(await manifestFile.readAsString());
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Bundle manifest must be an object');
  }
  final core = value['coreSha256'];
  final helper = value['helperSha256'];
  final protocol = value['helperProtocolVersion'];
  if (core is! String ||
      helper is! String ||
      !RegExp(r'^[0-9a-f]{64}$').hasMatch(core) ||
      !RegExp(r'^[0-9a-f]{64}$').hasMatch(helper) ||
      protocol != '9') {
    throw const FormatException('Bundle hashes or protocol are invalid');
  }
  final staged = await Directory.systemTemp.createTemp('reclash-helper-$uid-');
  try {
    await _setMode(staged.path, '0700');
    for (final entry in {
      appHelperService: helper,
      'ReClashCore': core,
    }.entries) {
      final input = p.join(resolved, entry.key);
      await _requireRegularFile(input);
      final output = p.join(staged.path, entry.key);
      await File(input).copy(output);
      await _setMode(output, '0500');
      final actual = await sha256.bind(File(output).openRead()).first;
      if (actual.toString() != entry.value) {
        throw const FormatException('Staged executable SHA256 mismatch');
      }
      final file = await File(output).open();
      try {
        final magic = await file.read(4);
        if (magic.length != 4 ||
            magic[0] != 0x7f ||
            magic[1] != 0x45 ||
            magic[2] != 0x4c ||
            magic[3] != 0x46) {
          throw const FormatException(
            'Helper and Core must be ELF executables',
          );
        }
      } finally {
        await file.close();
      }
    }
    final manifest = File(p.join(staged.path, coreManifestName));
    await manifest.writeAsString(
      jsonEncode({
        'coreSha256': core,
        'helperSha256': helper,
        'helperProtocolVersion': '9',
      }),
      flush: true,
    );
    await _setMode(manifest.path, '0400');
    return staged.path;
  } on Object {
    await staged.delete(recursive: true);
    rethrow;
  }
}

Future<void> _requireRegularFile(String path) async {
  if (await FileSystemEntity.type(path, followLinks: false) !=
      FileSystemEntityType.file) {
    throw const FormatException('Bundle members must be regular files');
  }
}

Future<void> _setMode(String path, String mode) async {
  final result = await Process.run('/usr/bin/chmod', [mode, '--', path]);
  if (result.exitCode != 0) {
    throw FileSystemException('Could not secure staged Helper bundle', path);
  }
}

final class LinuxHelperInstaller {
  final LinuxHelperEnvironment? _providedEnvironment;
  final LinuxHelperProcessRunner _runProcess;
  final bool Function() _hasSystemd;
  final bool _isLinux;
  final HelperReadinessProbe? _helperReadiness;
  final Future<bool> Function()? _waitForHelperService;
  final Future<Directory> Function()? _stageHelperBundle;
  LinuxHelperEnvironment? _environment;
  HelperClient? _client;
  Future<LinuxHelperInstallResult>? _operation;
  String? _lastDiagnostic;

  String? get lastDiagnostic => _lastDiagnostic;

  LinuxHelperInstaller({
    LinuxHelperEnvironment? environment,
    LinuxHelperProcessRunner? runProcess,
    bool Function()? hasSystemd,
    bool? isLinux,
    HelperReadinessProbe? helperReadiness,
    Future<bool> Function()? waitForHelperService,
    Future<Directory> Function()? stageHelperBundle,
  }) : _providedEnvironment = environment,
       _runProcess = runProcess ?? Process.run,
       _hasSystemd = hasSystemd ?? _systemdAvailable,
       _isLinux = isLinux ?? Platform.isLinux,
       _helperReadiness = helperReadiness,
       _waitForHelperService = waitForHelperService,
       _stageHelperBundle = stageHelperBundle;

  LinuxHelperEnvironment get _env =>
      _environment ??= _providedEnvironment ?? LinuxHelperEnvironment();

  static bool _systemdAvailable() =>
      Directory('/run/systemd/system').existsSync();

  bool get systemdAvailable => _isLinux && _hasSystemd();

  Future<HelperReadiness> _readiness() {
    final probe = _helperReadiness;
    if (probe != null) return probe();
    final client = _client ??= HelperClient(
      socketPath: _env.socketPath,
      expectedHelperPath: _env.installedHelperPath,
      readCoreSha256: () async =>
          (await CoreManifest.readCoreSha256(path: _env.manifestPath)) ?? '',
    );
    return client.readiness(
      timeout: const Duration(seconds: 2),
      logFailure: false,
    );
  }

  Future<LinuxHelperInstallResult> ensureReady() async {
    if (!_isLinux) return LinuxHelperInstallResult.unsupported;
    if (!_hasSystemd()) return LinuxHelperInstallResult.systemdUnavailable;
    try {
      return switch (await _readiness()) {
        HelperReadiness.ready => LinuxHelperInstallResult.ready,
        HelperReadiness.manifestMissing =>
          LinuxHelperInstallResult.bundleInvalid,
        HelperReadiness.notReady => LinuxHelperInstallResult.notReady,
      };
    } on Object {
      return LinuxHelperInstallResult.bundleInvalid;
    }
  }

  Future<LinuxHelperInstallResult> install() {
    final current = _operation;
    if (current != null) return current;
    final operation = _install();
    _operation = operation;
    unawaited(
      operation.then((_) {
        if (identical(_operation, operation)) _operation = null;
      }),
    );
    return operation;
  }

  Future<LinuxHelperInstallResult> _install() async {
    _lastDiagnostic = null;
    final readiness = await ensureReady();
    if (readiness != LinuxHelperInstallResult.notReady) return readiness;
    final Directory staged;
    try {
      staged = await (_stageHelperBundle?.call() ?? _env.stageBundle());
    } on Object catch (error) {
      _recordDiagnostic('Bundle staging failed: $error');
      return LinuxHelperInstallResult.bundleInvalid;
    }
    try {
      final ProcessResult result;
      try {
        result = await _runProcess('/usr/bin/pkexec', [
          '--disable-internal-agent',
          p.join(staged.path, appHelperService),
          'install',
          '--bundle',
          staged.path,
          '--replace-owned',
          if (_env.nativePackage case final package?) ...['--package', package],
        ]);
      } on ProcessException catch (error) {
        _recordDiagnostic('pkexec launch failed: $error');
        return error.errorCode == 2
            ? LinuxHelperInstallResult.pkexecUnavailable
            : LinuxHelperInstallResult.failed;
      }
      if (result.exitCode != 0) {
        _recordDiagnostic('pkexec exit=${result.exitCode}; ${result.stderr}');
      }
      if (result.exitCode == 126) return LinuxHelperInstallResult.cancelled;
      if (result.exitCode == 127) {
        final diagnostics = '${result.stderr}'.toLowerCase();
        return diagnostics.contains('no authentication agent') ||
                diagnostics.contains('no polkit authentication agent') ||
                diagnostics.contains('no authentication agent found')
            ? LinuxHelperInstallResult.agentUnavailable
            : LinuxHelperInstallResult.denied;
      }
      if (result.exitCode != 0) {
        final code = RegExp(
          r'^reclash-helper-error: ([a-z_]+)$',
          multiLine: true,
        ).firstMatch('${result.stderr}')?.group(1);
        return switch (code) {
          'registration_conflict' =>
            LinuxHelperInstallResult.registrationConflict,
          'bundle_invalid' => LinuxHelperInstallResult.bundleInvalid,
          'systemd_failed' => LinuxHelperInstallResult.systemdFailed,
          'install_busy' => LinuxHelperInstallResult.installBusy,
          'stop_failed' => LinuxHelperInstallResult.stopFailed,
          _ => LinuxHelperInstallResult.failed,
        };
      }
      if (await (_waitForHelperService?.call() ?? _waitUntilReady())) {
        return LinuxHelperInstallResult.installed;
      }
      final failure = _client?.readinessFailure;
      _recordDiagnostic(
        'Helper did not become ready after installation: ${failure ?? 'no readiness witness'}',
      );
      return failure?.code == 'protocolMismatch'
          ? LinuxHelperInstallResult.protocolMismatch
          : LinuxHelperInstallResult.notReady;
    } on Object catch (error) {
      _recordDiagnostic('Helper installation failed: $error');
      return LinuxHelperInstallResult.failed;
    } finally {
      await _removeStaging(staged);
    }
  }

  void _recordDiagnostic(String message) {
    final bounded = message.length > 4096
        ? message.substring(0, 4096)
        : message;
    _lastDiagnostic = bounded.replaceAll(
      RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'),
      '',
    );
    commonPrint.log(
      'Linux Helper installation: $lastDiagnostic',
      logLevel: LogLevel.error,
    );
  }

  Future<bool> _waitUntilReady() async {
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    do {
      if (await _readiness() == HelperReadiness.ready) return true;
      await Future<void>.delayed(const Duration(milliseconds: 150));
    } while (DateTime.now().isBefore(deadline));
    return false;
  }

  Future<void> _removeStaging(Directory directory) async {
    try {
      for (final name in [appHelperService, 'ReClashCore', coreManifestName]) {
        final path = p.join(directory.path, name);
        final type = await FileSystemEntity.type(path, followLinks: false);
        if (type == FileSystemEntityType.file) await File(path).delete();
        if (type == FileSystemEntityType.link) await Link(path).delete();
      }
      await directory.delete();
    } on FileSystemException {
      // Never recursively remove a directory provided by an installer hook.
    }
  }
}

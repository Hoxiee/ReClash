import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'tool/prepare.dart';
import 'tool/src/release_version.dart';
import 'tool/src/windows_bundle.dart';

const _appImageToolRelease = '12';
const _appImageToolSha256 = <String, String>{
  'aarch64': 'c9d058310a4e04b9fbbd81340fff2b5fb44943a630b31881e321719f271bd41a',
  'x86_64': 'd918b4df547b388ef253f3c9e7f6529ca81a885395c31f619d9aaf7030499a13',
};

const _allTargets = <String, String>{
  'android': 'apk',
  'linux': 'deb,appimage,rpm,pacman',
  'macos': 'dmg',
  'windows': 'exe,zip',
};

const _androidFlutterTarget = {
  'arm': 'android-arm',
  'arm64': 'android-arm64',
  'amd64': 'android-x64',
};

const _hostPlatform = {
  'linux': 'linux',
  'macos': 'macos',
  'windows': 'windows',
};

Future<void> main(List<String> args) async {
  final parser = createSetupArgParser();

  if (args.contains('--help') || args.contains('-h')) {
    _showHelp(parser);
    exit(0);
  }

  final results = parser.parse(args);
  final rest = results.rest;

  final hostOs = Platform.operatingSystem;
  final host = _hostPlatform[hostOs];
  if (host == null) {
    stderr.writeln('Unsupported host platform: $hostOs');
    exit(1);
  }

  final platform = rest.isNotEmpty ? rest.first : host;

  if (platform != host && platform != 'android') {
    stderr.writeln(
      'Cannot build "$platform" on $hostOs. Allowed: $host, android',
    );
    _showHelp(parser);
    exit(1);
  }

  final env = results['env'] as String;
  final rootDir = Directory.current.path;
  final skipped = packagesNotBuildingAssets(
    File(p.join(rootDir, 'pubspec.yaml')).readAsStringSync(),
  );
  if (skipped.isNotEmpty) {
    stderr.writeln(
      'pubspec.yaml sets hooks.user_defines.<package>.build_assets: false '
      'for ${skipped.join(', ')}; a package built this way would ship '
      'whatever is left in libclash/ and no Rust library. '
      'Restore "build_assets: true".',
    );
    exit(1);
  }
  final arch = _detectArch();
  final targets = createPackageTargets(
    platform,
    results['targets'],
    arch: arch,
  );
  final androidArch = results['arch'] as String?;
  final verbose = results['verbose'] as bool;

  final prepared = await prepareProject(rootDir);
  if (prepared != 0) exit(prepared);

  final exitCode = await _package(
    platform,
    env,
    targets,
    rootDir,
    arch,
    androidArch: androidArch,
    verbose: verbose,
  );
  exit(exitCode);
}

ArgParser createSetupArgParser() {
  return ArgParser()
    ..addOption(
      'env',
      defaultsTo: 'pre',
      allowed: ['dev', 'pre', 'stable'],
      help: 'Application environment',
    )
    ..addOption(
      'targets',
      valueHelp: 'exe,zip,dmg,apk,...',
      help: 'Package targets (default: all for platform)',
    )
    ..addOption(
      'arch',
      valueHelp: 'arm,arm64,amd64',
      allowed: ['arm', 'arm64', 'amd64'],
      help: 'Target architecture (Android only)',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Enable verbose Flutter build output',
    );
}

List<String> createFlutterBuildArgs({
  required String platform,
  required bool verbose,
  String? buildNumber,
}) {
  final flutterBuildArgs = <String>[
    if (verbose) 'verbose',
    'dart-define-from-file=env.json',
  ];
  if (platform == 'android') {
    flutterBuildArgs
      ..add('split-per-abi')
      ..add('build-number=${buildNumber ?? '1'}');
  }
  return flutterBuildArgs;
}

Map<String, String> createBuildEnvironment(String env) {
  return {'APP_ENV': env};
}

/// Packages whose build hook `pubspec.yaml` turns into a no-op.
List<String> packagesNotBuildingAssets(String pubspec) {
  final document = loadYaml(pubspec);
  if (document is! Map) return const [];
  final defines = (document['hooks'] as Map?)?['user_defines'];
  if (defines is! Map) return const [];
  return [
    for (final MapEntry(:key, :value) in defines.entries)
      if (value is Map && value['build_assets'] == false) key.toString(),
  ]..sort();
}

String createPackageTargets(
  String platform,
  String? customTargets, {
  String? arch,
}) {
  if (customTargets != null) return customTargets;
  if (platform == 'linux' && arch == 'arm64') return 'deb,rpm,pacman';
  return _allTargets[platform]!;
}

void _showHelp(ArgParser parser) {
  stderr.writeln('Usage: dart setup.dart [platform] [options]');
  stderr.writeln('Platform: current host platform (default) or android');
  stderr.writeln();
  stderr.writeln('Default package targets:');
  _allTargets.forEach((p, t) => stderr.writeln('  $p: $t'));
  stderr.writeln();
  stderr.writeln(parser.usage);
}

Future<int> _package(
  String platform,
  String env,
  String targets,
  String rootDir,
  String arch, {
  String? androidArch,
  required bool verbose,
}) async {
  final file = File(p.join(rootDir, 'env.json'));
  await file.writeAsString(jsonEncode(createBuildEnvironment(env)));

  final flutterBuildArgs = createFlutterBuildArgs(
    platform: platform,
    verbose: verbose,
    buildNumber: platform == 'android'
        ? ReleaseVersion.read(rootDir).flutterBuildNumber
        : null,
  );
  final descriptionArgs = <String>[];
  if (platform != 'android') {
    descriptionArgs.addAll(['--description', arch]);
  }

  final depExit = await _ensureDependencies(platform, rootDir, targets);
  if (depExit != 0) return depExit;
  if (platform == 'linux') await prepareLinuxVersionTools(rootDir, targets);

  final activateResult = await Process.run('dart', [
    'pub',
    'global',
    'activate',
    '-s',
    'git',
    'https://github.com/chen08209/flutter_distributor.git',
    '--git-ref',
    'v0.6.11-flclash.4',
    '--git-path',
    'packages/flutter_distributor',
  ]);
  if (activateResult.exitCode != 0) {
    stderr.write(activateResult.stderr);
    return activateResult.exitCode;
  }

  final process = await Process.start(
    'flutter_distributor',
    [
      'package',
      '--skip-clean',
      '--platform',
      platform,
      '--targets',
      targets,
      if (androidArch != null)
        '--build-target-platform=${_androidFlutterTarget[androidArch]!}',
      if (flutterBuildArgs.isNotEmpty)
        '--flutter-build-args=${flutterBuildArgs.join(',')}',
      if (platform == 'windows')
        '--hook-pre=${createWindowsPackageHook(rootDir, arch)}',
      ...descriptionArgs,
    ],
    includeParentEnvironment: true,
    environment: createPackageProcessEnvironment(
      rootDir: rootDir,
      platform: platform,
      androidArch: androidArch,
    ),
    workingDirectory: rootDir,
    runInShell: Platform.isWindows,
  );

  process.stdout.listen((data) {
    stdout.write(utf8.decode(data));
  });
  process.stderr.listen((data) {
    stderr.write(utf8.decode(data));
  });
  final exitCode = await process.exitCode;
  if (exitCode == 0 &&
      platform == 'linux' &&
      targets.split(',').contains('pacman')) {
    await renamePacmanArtifacts(rootDir);
  }
  if (exitCode == 0 && platform == 'windows') {
    validateWindowsArtifacts(
      rootDir,
      arch,
      targets,
      ReleaseVersion.read(rootDir).name,
    );
  }
  return exitCode;
}

String createWindowsPackageHook(String rootDir, String arch) {
  String quote(String value) => "'${value.replaceAll("'", "'\"'\"'")}'";
  String shellPath(String value) => value.replaceAll('\\', '/');
  return '${quote(shellPath(Platform.resolvedExecutable))} '
      '${quote(shellPath(p.join(rootDir, 'tool', 'windows_package.dart')))} '
      '--arch $arch --from-environment';
}

void validateWindowsArtifacts(
  String rootDir,
  String arch,
  String targets,
  String version,
) {
  for (final target in targets.split(',')) {
    final suffix = switch (target) {
      'exe' => '-setup.exe',
      'zip' => '.zip',
      _ => null,
    };
    if (suffix == null) continue;
    final file = File(
      p.join(rootDir, 'dist', 'ReClash-$version-windows-$arch$suffix'),
    );
    if (!file.existsSync() || file.lengthSync() == 0) {
      throw StateError('Missing Windows package: ${file.path}');
    }
    if (target == 'zip') {
      final report = WindowsBundle.zip(
        file,
      ).validate(machine: windowsMachine(arch));
      stdout.writeln('Final Windows ZIP verified: $report');
    }
  }
}

String _detectArch() {
  if (Platform.isWindows) {
    final pa = Platform.environment['PROCESSOR_ARCHITECTURE'] ?? 'AMD64';
    return pa.toUpperCase() == 'ARM64' ? 'arm64' : 'amd64';
  }
  final result = Process.runSync('uname', ['-m']);
  final machine = (result.stdout as String).trim();
  if (machine == 'aarch64') return 'arm64';
  if (machine == 'x86_64') return 'amd64';
  return machine;
}

Future<bool> _hasCommand(String cmd) async {
  if (Platform.isWindows) {
    final result = await Process.run('where', [cmd]);
    return result.exitCode == 0;
  }
  final result = await Process.run('/bin/sh', [
    '-c',
    'command -v -- "\$1" >/dev/null 2>&1',
    'sh',
    cmd,
  ]);
  return result.exitCode == 0;
}

/// Native tool wrappers live here so the packager resolves them first on PATH.
/// `tool/linux_package.dart` normalizes the metadata each maker writes
/// (pacman `.PKGINFO` into libalpm form, deb/rpm version epochs) before
/// delegating to the real tool.
/// `dart pub global activate` drops the executable into the pub cache bin,
/// which is commonly absent from PATH (it is on this machine). Prepend it so
/// the `flutter_distributor` invocation below resolves anywhere.
String _pubCacheBin() {
  final override = Platform.environment['PUB_CACHE'];
  if (override != null && override.isNotEmpty) {
    return p.join(override, 'bin');
  }
  if (Platform.isWindows) {
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return p.join(localAppData, 'Pub', 'Cache', 'bin');
    }
  } else {
    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      return p.join(home, '.pub-cache', 'bin');
    }
  }
  return '';
}

Map<String, String> createPackageProcessEnvironment({
  required String rootDir,
  required String platform,
  String? androidArch,
}) {
  final path = [
    if (platform == 'linux')
      p.join(rootDir, '.dart_tool', 'release_tools', 'bin'),
    _pubCacheBin(),
    Platform.environment['PATH'] ?? '',
  ].join(platform == 'windows' ? ';' : ':');
  return {'ANDROID_ARCH': ?androidArch, 'PATH': path};
}

/// Renames the maker's `.pacman` output to the manifest's `.pkg.tar.xz`.
Future<void> renamePacmanArtifacts(String rootDir) async {
  final dist = Directory(p.join(rootDir, 'dist'));
  if (!dist.existsSync()) return;
  const suffix = '.pacman';
  for (final entity in dist.listSync()) {
    if (entity is! File || !entity.path.endsWith(suffix)) continue;
    final base = entity.path.substring(0, entity.path.length - suffix.length);
    await entity.rename('$base.pkg.tar.xz');
  }
}

Future<void> prepareLinuxVersionTools(String rootDir, String targets) async {
  final directory = Directory(
    p.join(rootDir, '.dart_tool', 'release_tools', 'bin'),
  );
  await directory.create(recursive: true);
  for (final entry in {
    'deb': 'dpkg-deb',
    'rpm': 'rpmbuild',
    'pacman': 'bsdtar',
  }.entries) {
    if (!targets.split(',').contains(entry.key)) continue;
    final result = await Process.run('which', [entry.value]);
    final executable = (result.stdout as String).trim();
    if (result.exitCode != 0 ||
        !p.isAbsolute(executable) ||
        p.isWithin(directory.path, executable)) {
      throw StateError('Cannot resolve native ${entry.value}');
    }
    final wrapper = File(p.join(directory.path, entry.value));
    String quote(String value) => "'${value.replaceAll("'", "'\\''")}'";
    await wrapper.writeAsString(
      '#!/bin/sh\nexec ${quote(Platform.resolvedExecutable)} '
      '${quote(p.join(rootDir, 'tool', 'linux_package.dart'))} '
      '${quote(executable)} "\$@"\n',
    );
    final chmod = await Process.run('chmod', ['+x', wrapper.path]);
    if (chmod.exitCode != 0) throw StateError('Cannot enable ${wrapper.path}');
  }
}

Future<int> _ensureDependencies(
  String platform,
  String rootDir,
  String targets,
) async {
  switch (platform) {
    case 'macos':
      return _ensureMacosDependencies();
    case 'linux':
      return _ensureLinuxDependencies(rootDir, targets);
    default:
      return 0;
  }
}

Future<int> _ensureMacosDependencies() async {
  if (await _hasCommand('appdmg')) {
    stdout.writeln('appdmg already installed, skipping.');
    return 0;
  }
  stdout.writeln('Installing appdmg (DMG creator)...');
  final result = await Process.run('npm', ['install', '-g', 'appdmg']);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
  }
  return result.exitCode;
}

/// Debian package names for the Linux build dependencies. Per-target tools
/// (rpm, AppImage, pacman) are only required when their format is selected.
List<List<String>> linuxDependencyPackageGroups(
  String targets, {
  String family = 'debian',
}) {
  final selectedTargets = targets.split(',').toSet();
  final groups = <List<String>>[
    ['ninja-build', 'libgtk-3-dev'],
    ['libayatana-appindicator3-dev'],
    ['libsecret-1-dev'],
    ['locate'],
    if (selectedTargets.contains('rpm')) ['rpm', 'patchelf'],
    if (selectedTargets.contains('appimage')) ['libfuse2'],
    if (selectedTargets.contains('pacman')) ['libarchive-tools', 'xz-utils'],
  ];
  if (family == 'arch') {
    return [
      for (final group in groups)
        [for (final pkg in group) _debianToArchPackages[pkg] ?? pkg],
    ];
  }
  return groups;
}

/// Same dependencies, Arch names. `rpm-tools`/`patchelf` only matter when the
/// rpm target is selected, `fuse2` for AppImage, `libarchive`/`xz` for pacman.
const _debianToArchPackages = <String, String>{
  'ninja-build': 'ninja',
  'libgtk-3-dev': 'gtk3',
  'libayatana-appindicator3-dev': 'libayatana-appindicator',
  'libsecret-1-dev': 'libsecret',
  'locate': 'mlocate',
  'rpm': 'rpm-tools',
  'patchelf': 'patchelf',
  'libfuse2': 'fuse2',
  'libarchive-tools': 'libarchive',
  'xz-utils': 'xz',
};

/// Anything with `arch` in ID or ID_LIKE (Arch, Manjaro, EndeavourOS, ...)
/// installs through pacman; everything else keeps the Debian/Ubuntu apt path.
Future<String> _linuxDistroFamily() async {
  try {
    final osRelease = await File('/etc/os-release').readAsString();
    final values = <String>{};
    for (final match in RegExp(
      r'^(ID|ID_LIKE)=(.*)$',
      multiLine: true,
    ).allMatches(osRelease)) {
      values.addAll(match.group(2)!.replaceAll('"', '').split(RegExp(r'\s+')));
    }
    if (values.contains('arch')) return 'arch';
  } catch (_) {}
  return 'debian';
}

Future<int> _ensureLinuxDependencies(String rootDir, String targets) async {
  final family = await _linuxDistroFamily();
  final pkgGroups = linuxDependencyPackageGroups(targets, family: family);

  final missingGroups = <List<String>>[];
  for (final group in pkgGroups) {
    final missingPkgs = <String>[];
    for (final pkg in group) {
      if (!await _isLinuxPackageInstalled(pkg, family)) {
        missingPkgs.add(pkg);
      }
    }
    if (missingPkgs.isNotEmpty) {
      missingGroups.add(missingPkgs);
    }
  }

  if (missingGroups.isEmpty) {
    stdout.writeln('All Linux build dependencies already installed, skipping.');
  } else {
    if (family == 'arch') {
      stdout.writeln('Synchronizing pacman databases...');
      final syncExit = await _runLinuxDependencyCommand([
        'pacman',
        '-Sy',
        '--noconfirm',
      ], debian: false);
      if (syncExit != 0) {
        stderr.writeln(
          'pacman -Sy exited with $syncExit; continuing and verifying '
          'dependency installation directly.',
        );
      }
    } else {
      stdout.writeln('Updating apt package lists...');
      final updateExit = await _runLinuxDependencyCommand([
        'apt-get',
        'update',
        '-y',
      ]);
      if (updateExit != 0) {
        stderr.writeln(
          'apt-get update exited with $updateExit; continuing and verifying '
          'dependency installation directly.',
        );
      }
    }

    for (final missingPkgs in missingGroups) {
      stdout.writeln(
        'Installing Linux build dependencies: ${missingPkgs.join(', ')}...',
      );
      final installExit = await _installLinuxPackages(missingPkgs, family);
      if (installExit != 0) return installExit;
    }
  }

  if (!targets.split(',').contains('appimage')) return 0;

  if (await _hasCommand('appimagetool')) {
    stdout.writeln('appimagetool already installed, skipping.');
    return 0;
  }
  final appimagetool = p.join(
    rootDir,
    '.dart_tool',
    'release_tools',
    'bin',
    'appimagetool',
  );
  final stagedAppimagetool = '$appimagetool.download';
  await File(appimagetool).parent.create(recursive: true);
  final stagedFile = File(stagedAppimagetool);
  if (await stagedFile.exists()) await stagedFile.delete();
  stdout.writeln('Downloading appimagetool...');
  final hostArch = _detectArch();
  final downloadName = 'appimagetool-${appImageToolArch(hostArch)}.AppImage';
  final dlResult = await Process.run('wget', [
    '-O',
    stagedAppimagetool,
    appImageToolUrl(hostArch),
  ]);
  if (dlResult.exitCode != 0) {
    if (await stagedFile.exists()) await stagedFile.delete();
    stderr.write(dlResult.stderr);
    return dlResult.exitCode;
  }
  final actualSha256 = await fileSha256(stagedFile);
  final expectedSha256 = appImageToolSha256(hostArch);
  if (actualSha256 != expectedSha256) {
    await stagedFile.delete();
    stderr.writeln(
      '$downloadName SHA256 mismatch: expected $expectedSha256, '
      'got $actualSha256',
    );
    return 1;
  }
  final chmodResult = await Process.run('chmod', ['+x', stagedAppimagetool]);
  if (chmodResult.exitCode != 0) {
    await stagedFile.delete();
    stderr.write(chmodResult.stderr);
    return chmodResult.exitCode;
  }
  final targetFile = File(appimagetool);
  if (await targetFile.exists()) await targetFile.delete();
  await stagedFile.rename(appimagetool);
  return 0;
}

String appImageToolArch(String arch) {
  return arch == 'arm64' ? 'aarch64' : 'x86_64';
}

String appImageToolUrl(String arch) {
  final toolArch = appImageToolArch(arch);
  return 'https://github.com/AppImage/AppImageKit/releases/download/'
      '$_appImageToolRelease/appimagetool-$toolArch.AppImage';
}

String appImageToolSha256(String arch) {
  return _appImageToolSha256[appImageToolArch(arch)]!;
}

Future<String> fileSha256(File file) async {
  return sha256.bind(file.openRead()).first.then((digest) => '$digest');
}

/// Ubuntu 24.04 ships libfuse2 under its time64 name, which `dpkg -s libfuse2` cannot see.
const _debianPackageAliases = <String, List<String>>{
  'libfuse2': ['libfuse2t64'],
};

Future<bool> _isDebianPackageInstalled(String pkg) async {
  for (final name in [pkg, ...?_debianPackageAliases[pkg]]) {
    final result = await Process.run('dpkg', ['-s', name]);
    if (result.exitCode == 0 &&
        (result.stdout as String).contains('Status: install ok installed')) {
      return true;
    }
  }
  return false;
}

Future<bool> _isLinuxPackageInstalled(String pkg, String family) async {
  if (family == 'arch') {
    final result = await Process.run('pacman', ['-Q', pkg]);
    return result.exitCode == 0;
  }
  return _isDebianPackageInstalled(pkg);
}

Future<bool> _areLinuxPackagesInstalled(
  List<String> pkgs,
  String family,
) async {
  for (final pkg in pkgs) {
    if (!await _isLinuxPackageInstalled(pkg, family)) {
      return false;
    }
  }
  return true;
}

Future<int> _installLinuxPackages(List<String> pkgs, String family) async {
  final exitCode = family == 'arch'
      ? await _runLinuxDependencyCommand([
          'pacman',
          '-S',
          '--noconfirm',
          '--needed',
          ...pkgs,
        ], debian: false)
      : await _runLinuxDependencyCommand(['apt-get', 'install', '-y', ...pkgs]);
  if (exitCode == 0) return 0;

  if (await _areLinuxPackagesInstalled(pkgs, family)) {
    stderr.writeln(
      'Package install exited with $exitCode, but all requested packages are '
      'installed; continuing.',
    );
    return 0;
  }

  return exitCode;
}

Future<int> _runLinuxDependencyCommand(
  List<String> command, {
  bool debian = true,
}) async {
  final sudoCommand = [
    if (debian) ...[
      'env',
      'DEBIAN_FRONTEND=noninteractive',
      'NEEDRESTART_MODE=a',
    ],
    ...command,
  ];
  stdout.writeln('exec: sudo ${sudoCommand.join(' ')}');
  final result = await Process.start('sudo', sudoCommand);
  result.stdout.listen((data) {
    stdout.write(utf8.decode(data));
  });
  result.stderr.listen((data) {
    stderr.write(utf8.decode(data));
  });
  final exitCode = await result.exitCode;
  if (exitCode != 0) {
    stderr.writeln('Linux dependency command failed with exit code $exitCode.');
  }
  return exitCode;
}

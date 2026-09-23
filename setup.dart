import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'tool/src/release_version.dart';

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
  final rootDir = setupRootDirectory();

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
  final arch = _detectArch();
  final targets = createPackageTargets(
    platform,
    results['targets'],
    arch: arch,
  );
  final androidArch = results['arch'] as String?;
  final verbose = results['verbose'] as bool;

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
  ReleaseVersion? version,
}) {
  final flutterBuildArgs = <String>[
    if (verbose) 'verbose',
    'dart-define-from-file=env.json',
    if (platform == 'macos' && version != null) ...[
      'build-name=${version.base}',
      'build-number=${version.macosBuildNumber}',
    ],
  ];
  if (platform == 'android') {
    flutterBuildArgs.add('split-per-abi');
  }
  return flutterBuildArgs;
}

Map<String, String> createBuildEnvironment(
  String env, {
  ReleaseVersion? version,
}) {
  return {
    'APP_ENV': env,
    if (version != null) ...{
      'APP_VERSION': version.name,
      'APP_BUILD_NUMBER': version.buildNumber,
    },
  };
}

Map<String, String> createPackageProcessEnvironment({
  required String rootDir,
  required String platform,
  String? androidArch,
}) {
  return {
    'ANDROID_ARCH': ?androidArch,
    if (platform == 'linux')
      'PATH': [
        p.join(rootDir, '.dart_tool', 'release_tools', 'bin'),
        Platform.environment['PATH'] ?? '',
      ].join(':'),
  };
}

String setupRootDirectory() => p.dirname(Platform.script.toFilePath());

String createPackageTargets(
  String platform,
  String? customTargets, {
  required String arch,
}) {
  if (platform == 'linux' && arch == 'arm64') {
    if (customTargets?.split(',').contains('appimage') ?? false) {
      throw UnsupportedError(
        'ARM64 AppImage packaging is disabled because the pinned packager '
        'forces ARCH=x86_64.',
      );
    }
    return customTargets ?? 'deb,rpm,pacman';
  }
  return customTargets ?? _allTargets[platform]!;
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
  final version = ReleaseVersion.read(rootDir);
  final file = File(p.join(rootDir, 'env.json'));
  await file.writeAsString(
    jsonEncode(createBuildEnvironment(env, version: version)),
  );

  final flutterBuildArgs = createFlutterBuildArgs(
    platform: platform,
    verbose: verbose,
    version: version,
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
    '7fea25d4c531ce6e778db14e3c47f076027a1008',
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
  return exitCode;
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

Future<bool> hasCommand(String cmd) async {
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
  if (await hasCommand('appdmg')) {
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

List<List<String>> linuxDependencyPackageGroups(String targets) {
  final selectedTargets = targets.split(',').toSet();
  return [
    ['ninja-build', 'libgtk-3-dev'],
    ['libayatana-appindicator3-dev'],
    ['libkeybinder-3.0-dev'],
    ['libsecret-1-dev'],
    ['locate'],
    if (selectedTargets.contains('rpm')) ['rpm', 'patchelf'],
    if (selectedTargets.contains('appimage')) ['libfuse2'],
    if (selectedTargets.contains('pacman')) ['libarchive-tools', 'xz-utils'],
  ];
}

Future<int> _ensureLinuxDependencies(String rootDir, String targets) async {
  final selectedTargets = targets.split(',').toSet();
  final pkgGroups = linuxDependencyPackageGroups(targets);

  final missingGroups = <List<String>>[];
  for (final group in pkgGroups) {
    final missingPkgs = <String>[];
    for (final pkg in group) {
      if (!await _isDebianPackageInstalled(pkg)) {
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

    for (final missingPkgs in missingGroups) {
      stdout.writeln(
        'Installing Linux build dependencies: ${missingPkgs.join(', ')}...',
      );
      final installExit = await _installLinuxPackages(missingPkgs);
      if (installExit != 0) return installExit;
    }
  }

  if (!selectedTargets.contains('appimage')) return 0;

  if (await hasCommand('appimagetool')) {
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

Future<bool> _areDebianPackagesInstalled(List<String> pkgs) async {
  for (final pkg in pkgs) {
    if (!await _isDebianPackageInstalled(pkg)) {
      return false;
    }
  }
  return true;
}

Future<int> _installLinuxPackages(List<String> pkgs) async {
  final exitCode = await _runLinuxDependencyCommand([
    'apt-get',
    'install',
    '-y',
    ...pkgs,
  ]);
  if (exitCode == 0) return 0;

  if (await _areDebianPackagesInstalled(pkgs)) {
    stderr.writeln(
      'apt-get install exited with $exitCode, but all requested packages are '
      'installed; continuing.',
    );
    return 0;
  }

  return exitCode;
}

Future<int> _runLinuxDependencyCommand(List<String> command) async {
  final sudoCommand = [
    'env',
    'DEBIAN_FRONTEND=noninteractive',
    'NEEDRESTART_MODE=a',
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

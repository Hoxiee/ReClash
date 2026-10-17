import 'dart:io';

import 'package:path/path.dart' as p;

import 'src/release_version.dart';

String normalizePackageMetadata(
  String source,
  ReleaseVersion version, {
  required bool rpm,
}) {
  final identity = RegExp(
    rpm ? r'^Name: ReClash$' : r'^Package: reclash$',
    multiLine: true,
  );
  final field = RegExp(r'^Version: .+$', multiLine: true);
  if (!identity.hasMatch(source) || field.allMatches(source).length != 1) {
    throw const FormatException('Unexpected ReClash package metadata');
  }
  final normalized = source.replaceFirst(
    field,
    rpm
        ? 'Epoch: 1\nVersion: ${version.linuxVersion}'
        : 'Version: ${version.debianVersion}',
  );
  if (rpm && RegExp(r'^Epoch:', multiLine: true).hasMatch(source)) {
    throw const FormatException('RPM epoch is already set');
  }
  return normalized;
}

/// The maker writes `key=value` lines libalpm cannot read: it needs `key = value`,
/// a single combined `epoch:pkgver-pkgrel`, and repeated singular array keys
/// instead of the maker's `(a, b)`. Rewrite `.PKGINFO` into that form before
/// `.MTREE` seals it. A fixed point, so the maker's second bsdtar pass is a no-op.
String normalizePacmanPkgInfo(
  String source,
  ReleaseVersion version, {
  int? installedSize,
}) {
  const rename = {
    'depends': 'depend',
    'optdepends': 'optdepend',
    'conflicts': 'conflict',
    'groups': 'group',
  };
  const recognized = {
    'pkgname',
    'pkgbase',
    'pkgver',
    'pkgdesc',
    'url',
    'builddate',
    'packager',
    'size',
    'arch',
    'license',
    'replaces',
    'group',
    'depend',
    'optdepend',
    'conflict',
    'provides',
    'backup',
    'xdata',
  };
  final output = <String>[];
  var sawName = false;
  var sawSize = false;
  for (final line in source.split('\n')) {
    if (line.trim().isEmpty) continue;
    final split = line.indexOf('=');
    if (split < 0) throw const FormatException('Malformed pacman metadata');
    final key =
        rename[line.substring(0, split).trim()] ??
        line.substring(0, split).trim();
    if (!recognized.contains(key)) continue;
    var value = line.substring(split + 1).trim();
    if (key == 'pkgname') {
      if (value != 'reclash') {
        throw const FormatException('Unexpected ReClash pacman metadata');
      }
      sawName = true;
    }
    if (key == 'pkgver') {
      value = '1:${version.pacmanVersion}-${version.pacmanRelease}';
    }
    if (key == 'size' && installedSize != null) {
      value = '$installedSize';
      sawSize = true;
    }
    if (value.startsWith('(') && value.endsWith(')')) {
      for (final item in value.substring(1, value.length - 1).split(',')) {
        if (item.trim().isNotEmpty) output.add('$key = ${item.trim()}');
      }
    } else {
      output.add('$key = $value');
    }
  }
  if (!sawName) {
    throw const FormatException('Unexpected ReClash pacman metadata');
  }
  if (installedSize != null && !sawSize) output.add('size = $installedSize');
  return '${output.join('\n')}\n';
}

/// Forces root ownership since the maker runs bsdtar without fakeroot.
List<String> withRootOwnership(List<String> arguments) {
  if (arguments.length < 2 || !arguments.first.startsWith('-c')) {
    return arguments;
  }
  return [
    arguments[0],
    arguments[1],
    '--uid',
    '0',
    '--gid',
    '0',
    '--uname',
    'root',
    '--gname',
    'root',
    ...arguments.skip(2),
  ];
}

/// pacman `size` is installed bytes; the maker copies a KB figure, so recompute.
int installedSizeBytes(Directory root) {
  var total = 0;
  for (final entity in root.listSync()) {
    if (entity is! Directory) continue;
    for (final file in entity.listSync(recursive: true, followLinks: false)) {
      if (file is File) total += file.lengthSync();
    }
  }
  return total;
}

Future<void> main(List<String> args) async {
  final root = p.dirname(p.dirname(Platform.script.toFilePath()));
  final executable = args.first;
  var arguments = args.skip(1).toList();
  final tool = p.basename(executable);
  final rpm = tool == 'rpmbuild';
  if (tool == 'bsdtar') {
    final pkgInfo = File('.PKGINFO');
    if (pkgInfo.existsSync()) {
      await pkgInfo.writeAsString(
        normalizePacmanPkgInfo(
          await pkgInfo.readAsString(),
          ReleaseVersion.read(root),
          installedSize: installedSizeBytes(Directory.current),
        ),
      );
      arguments = withRootOwnership(arguments);
    }
  } else {
    File? metadata;
    if (rpm && arguments.contains('-bb')) {
      metadata = File(arguments.last);
    } else if (!rpm && arguments.contains('--build')) {
      metadata = File(
        p.join(arguments[arguments.length - 2], 'DEBIAN', 'control'),
      );
    }
    if (metadata != null) {
      final source = await metadata.readAsString();
      await metadata.writeAsString(
        normalizePackageMetadata(source, ReleaseVersion.read(root), rpm: rpm),
      );
    }
  }
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}

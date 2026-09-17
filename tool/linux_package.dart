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

Future<void> main(List<String> args) async {
  final root = p.dirname(p.dirname(Platform.script.toFilePath()));
  final executable = args.first;
  final arguments = args.skip(1).toList();
  final rpm = p.basename(executable) == 'rpmbuild';
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
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}

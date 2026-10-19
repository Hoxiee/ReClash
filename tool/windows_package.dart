import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'src/windows_bundle.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('arch', mandatory: true, allowed: ['amd64', 'x64', 'arm64'])
    ..addOption('bundle')
    ..addOption('zip')
    ..addOption('compare-installed')
    ..addFlag('from-environment', negatable: false)
    ..addFlag('finalize-manifest', negatable: false)
    ..addFlag('require-signed', negatable: false)
    ..addOption('write-hashes');
  try {
    final args = parser.parse(arguments);
    final bundlePath =
        args['bundle'] as String? ??
        (args['from-environment'] as bool
            ? Platform.environment['BUILD_OUTPUT_DIRECTORY']
            : null);
    final zipPath = args['zip'] as String?;
    if ((bundlePath == null) == (zipPath == null)) {
      throw ArgumentError(
        'Provide exactly one of --bundle, --zip, or --from-environment',
      );
    }
    if (args['finalize-manifest'] as bool) {
      if (bundlePath == null) {
        throw ArgumentError(
          'Manifest finalization requires a staging directory',
        );
      }
      final core = File(p.join(bundlePath, 'ReClashCore.exe'));
      final manifest = File(p.join(bundlePath, 'manifest.json'));
      final value = jsonDecode(await manifest.readAsString());
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid Core manifest');
      }
      value['coreSha256'] = (await sha256.bind(core.openRead()).first)
          .toString();
      await manifest.writeAsString('${jsonEncode(value)}\n', flush: true);
    }
    final bundle = bundlePath == null
        ? WindowsBundle.zip(File(zipPath!))
        : WindowsBundle.directory(Directory(bundlePath));
    final report = bundle.validate(
      machine: windowsMachine(args['arch'] as String),
      requireSigned: args['require-signed'] as bool,
    );
    final installedPath = args['compare-installed'] as String?;
    if (installedPath != null) {
      final installed = WindowsBundle.directory(Directory(installedPath));
      installed.validate(machine: windowsMachine(args['arch'] as String));
      final expected = bundle.hashes;
      final actual = installed.hashes;
      for (final entry in expected.entries) {
        if (actual[entry.key] != entry.value) {
          throw StateError('Installed payload differs: ${entry.key}');
        }
      }
      final unexpected = actual.keys.where(
        (name) =>
            !expected.containsKey(name) &&
            !RegExp(r'^unins\d+\.(exe|dat|msg)$').hasMatch(name),
      );
      if (unexpected.isNotEmpty) {
        throw StateError(
          'Unexpected installed payload: ${unexpected.join(', ')}',
        );
      }
    }
    final hashesPath = args['write-hashes'] as String?;
    if (hashesPath != null) {
      await File(hashesPath).writeAsString('${jsonEncode(bundle.hashes)}\n');
    }
    stdout.writeln('Windows bundle verified: $report');
  } on Object catch (error) {
    stderr.writeln('Windows package validation failed: $error');
    exitCode = 1;
  }
}

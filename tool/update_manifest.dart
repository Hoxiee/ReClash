import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;
import 'package:reclash/common/update_manifest.dart';

const _usage = '''
Usage:
  dart run tool/update_manifest.dart keygen --out <file>
  dart run tool/update_manifest.dart sign --tag <tag> --notes <file> --dist <dir> --base-url <url> [--prerelease] [--out <file>]
  dart run tool/update_manifest.dart verify <manifest-file> [--key <base64-public-key>...]

sign reads the base64 Ed25519 seed from UPDATE_MANIFEST_KEY.''';

const _excluded = {'SHA256SUMS', updateManifestFileName};

class _UsageError implements Exception {
  const _UsageError(this.message);

  final String message;
}

Future<void> main(List<String> args) async {
  try {
    exitCode = await _run(args);
  } on _UsageError catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(_usage);
    exitCode = 64;
  }
}

Future<int> _run(List<String> args) async {
  if (args.isEmpty) throw const _UsageError('Missing command');
  final command = args.first;
  final options = _Options.parse(args.skip(1));
  return switch (command) {
    'keygen' => _keygen(options),
    'sign' => _sign(options),
    'verify' => _verify(options),
    _ => throw _UsageError('Unknown command: $command'),
  };
}

class _Options {
  _Options(this.values, this.flags, this.positional);

  factory _Options.parse(Iterable<String> args) {
    const valued = {'out', 'tag', 'notes', 'dist', 'base-url', 'key'};
    const switches = {'prerelease'};
    final values = <String, List<String>>{};
    final flags = <String>{};
    final positional = <String>[];
    final iterator = args.iterator;
    while (iterator.moveNext()) {
      final arg = iterator.current;
      if (!arg.startsWith('--')) {
        positional.add(arg);
        continue;
      }
      final name = arg.substring(2);
      if (switches.contains(name)) {
        flags.add(name);
      } else if (valued.contains(name)) {
        if (!iterator.moveNext()) throw _UsageError('Missing value for $arg');
        values.putIfAbsent(name, () => []).add(iterator.current);
      } else {
        throw _UsageError('Unknown option: $arg');
      }
    }
    return _Options(values, flags, positional);
  }

  final Map<String, List<String>> values;
  final Set<String> flags;
  final List<String> positional;

  String? optional(String name) => values[name]?.last;

  String required(String name) =>
      optional(name) ?? (throw _UsageError('Missing --$name'));
}

Future<int> _keygen(_Options options) async {
  final out = File(options.required('out'));
  if (out.existsSync()) {
    stderr.writeln('Refusing to overwrite ${out.path}');
    return 1;
  }
  if (!out.parent.existsSync()) {
    out.parent.createSync(recursive: true);
    if (!Platform.isWindows) {
      await Process.run('chmod', ['700', out.parent.path]);
    }
  }
  // Restricted before the seed is written, so it is never world-readable.
  out.createSync(exclusive: true);
  if (!Platform.isWindows) await Process.run('chmod', ['600', out.path]);
  final random = Random.secure();
  final seed = List<int>.generate(32, (_) => random.nextInt(256));
  out.writeAsStringSync('${base64.encode(seed)}\n');
  stdout.writeln(await updateManifestPublicKey(seed));
  return 0;
}

List<int>? _seedFromEnvironment() {
  try {
    final seed = base64.decode(
      (Platform.environment['UPDATE_MANIFEST_KEY'] ?? '').trim(),
    );
    return seed.length == 32 ? seed : null;
  } on FormatException {
    return null;
  }
}

Future<int> _sign(_Options options) async {
  final tag = options.required('tag');
  final notes = File(options.required('notes')).readAsStringSync();
  final dist = Directory(options.required('dist'));
  final baseUrl = options.required('base-url').replaceFirst(RegExp(r'/+$'), '');
  final prerelease = options.flags.contains('prerelease');
  final out = File(
    options.optional('out') ?? '${dist.path}/$updateManifestFileName',
  );

  final seed = _seedFromEnvironment();
  if (seed == null) {
    stderr.writeln('UPDATE_MANIFEST_KEY must be the base64 of a 32 byte seed');
    return 2;
  }

  final files =
      dist
          .listSync(followLinks: false)
          .whereType<File>()
          .where((file) => !_excluded.contains(_name(file)))
          .toList()
        ..sort((a, b) => _name(a).compareTo(_name(b)));
  final assets = <UpdateManifestAsset>[
    for (final file in files)
      (
        name: _name(file),
        size: file.lengthSync(),
        sha256: (await crypto.sha256.bind(file.openRead()).first).toString(),
      ),
  ];

  final String signature;
  try {
    signature = await signUpdateManifestMessage(
      updateManifestMessage(
        tag: tag,
        prerelease: prerelease,
        notes: notes,
        assets: assets,
      ),
      seed,
    );
  } on UpdateManifestException catch (error) {
    stderr.writeln(error);
    return 1;
  }
  final manifest = {
    'releases': [
      {
        'tag': tag,
        'prerelease': prerelease,
        'notes': notes,
        'assets': [
          for (final asset in assets)
            {
              'name': asset.name,
              'size': asset.size,
              'sha256': asset.sha256,
              'url': '$baseUrl/${Uri.encodeComponent(asset.name)}',
            },
        ],
        'signature': signature,
      },
    ],
  };
  out.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest));

  final publicKey = await updateManifestPublicKey(seed);
  final releases = await parseUpdateManifest(
    out.readAsBytesSync(),
    keys: [publicKey],
  );
  if (releases.length != 1 || releases.single['tag_name'] != tag) {
    stderr.writeln('Written manifest does not verify as $tag');
    return 1;
  }
  stdout.writeln('Signed $tag with ${assets.length} assets: ${out.path}');
  return 0;
}

Future<int> _verify(_Options options) async {
  if (options.positional.length != 1) {
    throw const _UsageError('Expected one manifest file');
  }
  final keys = options.values['key'] ?? updateManifestKeys;
  try {
    final releases = await parseUpdateManifest(
      File(options.positional.single).readAsBytesSync(),
      keys: keys,
    );
    for (final release in releases) {
      final kind = release['prerelease'] == true ? 'prerelease' : 'stable';
      stdout.writeln(
        '${release['tag_name']} $kind ${(release['assets'] as List).length}',
      );
    }
    return 0;
  } on UpdateManifestException catch (error) {
    stderr.writeln(error);
    return 1;
  } on FileSystemException catch (error) {
    stderr.writeln('Could not read manifest: $error');
    return 1;
  }
}

String _name(File file) => file.uri.pathSegments.last;

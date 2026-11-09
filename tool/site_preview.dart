import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'prepare.dart';

const _usage = '''
Builds the website builder runtime from ReClash sources:
  build/site_preview/kernel.js   manifest parser for the form (dart2js)
  build/site_preview/preview/    live preview iframe (Flutter web)

Usage: dart run tool/site_preview.dart [--out <dir>]
  --out <dir>  also copy kernel.js and preview/ into <dir>,
               e.g. ../reclash-site/public/runtime''';

const _baseHref = '/runtime/preview/';
const _robotoWeights = {'Medium': 500, 'Bold': 700};

Future<void> main(List<String> args) async {
  String? out;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '-h' || '--help':
        stdout.writeln(_usage);
        return;
      case '--out' when i + 1 < args.length:
        out = p.absolute(args[++i]);
      default:
        _fail('Unknown argument ${args[i]}.\n\n$_usage');
    }
  }

  final root = p.dirname(p.dirname(p.fromUri(Platform.script)));
  final package = p.join(root, 'site_preview');
  final build = Directory(p.join(root, 'build', 'site_preview'));

  final prepared = await prepareProject(root, pubGet: false, quiet: true);
  if (prepared != 0) exit(prepared);
  // The preview resolves its own dependencies; starting from the app's
  // lockfile keeps it on the exact versions the app is built and tested with.
  File(p.join(root, 'pubspec.lock')).copySync(p.join(package, 'pubspec.lock'));
  await _run('flutter', ['pub', 'get'], package);

  if (build.existsSync()) build.deleteSync(recursive: true);
  build.createSync(recursive: true);
  final kernel = p.join(build.path, 'kernel.js');
  await _run(Platform.resolvedExecutable, [
    'compile',
    'js',
    '-O2',
    '--no-source-maps',
    '-o',
    kernel,
    'lib/kernel.dart',
  ], package);
  for (final extra in ['$kernel.deps', '$kernel.map']) {
    if (File(extra).existsSync()) File(extra).deleteSync();
  }

  final web = Directory(p.join(package, 'build', 'web'));
  if (web.existsSync()) web.deleteSync(recursive: true);
  // A wasm build ships skwasm to browsers with WasmGC and keeps the dart2js
  // and CanvasKit build for the rest; both paths load less than CanvasKit.
  await _run('flutter', [
    'build',
    'web',
    '--wasm',
    '--release',
    '--no-web-resources-cdn',
    '--no-source-maps',
    '--base-href',
    _baseHref,
    '--dart-define=RECLASH_VERSION=${_appVersion(root)}',
  ], package);
  final preview = p.join(build.path, 'preview');
  _copyTree(web, preview);
  _prune(preview);
  _bundleFonts(preview);

  if (out != null) {
    final target = Directory(out)..createSync(recursive: true);
    File(kernel).copySync(p.join(target.path, 'kernel.js'));
    final previewOut = Directory(p.join(target.path, 'preview'));
    if (previewOut.existsSync()) previewOut.deleteSync(recursive: true);
    _copyTree(Directory(preview), previewOut.path);
  }

  _report(build.path, out);
}

String _appVersion(String root) {
  final pubspec = File(p.join(root, 'pubspec.yaml')).readAsStringSync();
  final match = RegExp(
    r'^version:\s*([^+\s]+)',
    multiLine: true,
  ).firstMatch(pubspec);
  if (match == null) _fail('No version in pubspec.yaml.');
  return match.group(1)!;
}

/// Drops what the preview never loads: the experimental renderers, debug
/// symbols, the service worker and every app asset.
void _prune(String preview) {
  bool unused(String path) {
    final relative = p.posix.joinAll(p.split(p.relative(path, from: preview)));
    if (relative.startsWith('assets/packages/reclash/')) return true;
    if (relative.startsWith('canvaskit/')) {
      return !const {
        'canvaskit/canvaskit.js',
        'canvaskit/canvaskit.wasm',
        'canvaskit/chromium/canvaskit.js',
        'canvaskit/chromium/canvaskit.wasm',
        'canvaskit/skwasm.js',
        'canvaskit/skwasm.wasm',
        'canvaskit/skwasm_heavy.js',
        'canvaskit/skwasm_heavy.wasm',
      }.contains(relative);
    }
    return const {
      'flutter_service_worker.js',
      '.last_build_id',
    }.contains(relative);
  }

  final files = Directory(preview).listSync(recursive: true);
  for (final file in files.whereType<File>().where((f) => unused(f.path))) {
    file.deleteSync();
  }
  for (final dir in files.whereType<Directory>().toList().reversed) {
    if (dir.existsSync() && dir.listSync().isEmpty) dir.deleteSync();
  }
}

/// The build bundles Roboto Regular only; the preview's text also asks for
/// Medium and Bold, which the engine would otherwise fake from Regular.
void _bundleFonts(String preview) {
  final manifestFile = File(p.join(preview, 'assets', 'FontManifest.json'));
  final manifest = (jsonDecode(manifestFile.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final materialFonts = p.join(
    p.dirname(p.dirname(p.dirname(Platform.resolvedExecutable))),
    'artifacts',
    'material_fonts',
  );
  final roboto = manifest.firstWhere(
    (family) => family['family'] == 'Roboto',
    orElse: () => _fail('No bundled Roboto; is --no-web-resources-cdn on?'),
  );
  final fonts = (roboto['fonts'] as List).cast<Map<String, dynamic>>();
  final folder = p.posix.dirname(fonts.first['asset'] as String);
  for (final MapEntry(key: style, value: weight) in _robotoWeights.entries) {
    final asset = '$folder/Roboto-$style.ttf';
    File(
      p.join(materialFonts, 'Roboto-$style.ttf'),
    ).copySync(p.join(preview, 'assets', asset));
    fonts.add({'asset': asset, 'weight': weight});
  }
  final updated = [
    for (final family in manifest)
      if (!(family['family'] as String).startsWith('packages/reclash/')) family,
  ];
  manifestFile.writeAsStringSync(jsonEncode(updated));
}

void _copyTree(Directory from, String to) {
  for (final entity in from.listSync(recursive: true)) {
    final target = p.join(to, p.relative(entity.path, from: from.path));
    if (entity is Directory) {
      Directory(target).createSync(recursive: true);
    } else if (entity is File) {
      Directory(p.dirname(target)).createSync(recursive: true);
      entity.copySync(target);
    }
  }
}

void _report(String build, String? out) {
  final sorted =
      Directory(build).listSync(recursive: true).whereType<File>().toList()
        ..sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
  var raw = 0;
  var packed = 0;
  for (final file in sorted) {
    final size = file.lengthSync();
    final gzipped = gzip.encode(file.readAsBytesSync()).length;
    raw += size;
    packed += gzipped;
    if (size >= 16 << 10) {
      stdout.writeln(
        '${_size(size).padLeft(9)} ${_size(gzipped).padLeft(9)} gz  '
        '${p.posix.joinAll(p.split(p.relative(file.path, from: build)))}',
      );
    }
  }
  stdout
    ..writeln('${_size(raw).padLeft(9)} ${_size(packed).padLeft(9)} gz  total')
    ..writeln('Built $build${out == null ? '' : ', copied to $out'}.');
}

String _size(int bytes) => bytes >= 1 << 20
    ? '${(bytes / (1 << 20)).toStringAsFixed(2)} MB'
    : '${(bytes / 1024).toStringAsFixed(1)} KB';

Future<void> _run(
  String executable,
  List<String> arguments,
  String workingDirectory,
) async {
  final code = await runPreparationCommand(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    quiet: true,
  );
  if (code != 0) _fail('$executable ${arguments.join(' ')} failed ($code).');
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  late Directory root;
  late String script;

  setUp(() {
    root = Directory.systemTemp.createTempSync('reclash-update-manifest-');
    script = File('tool/update_manifest.dart').absolute.path;
    Directory('${root.path}/dist').createSync();
    File('${root.path}/dist/app-one.apk').writeAsStringSync('apk-bytes');
    File('${root.path}/dist/app.zip').writeAsStringSync('zip-bytes');
    File('${root.path}/dist/SHA256SUMS').writeAsStringSync('ignored');
    File('${root.path}/notes.md').writeAsStringSync('Release notes\n');
  });

  tearDown(() {
    root.deleteSync(recursive: true);
  });

  Future<ProcessResult> run(List<String> args, {String? key}) {
    return Process.run(
      'dart',
      [script, ...args],
      workingDirectory: root.path,
      environment: {'UPDATE_MANIFEST_KEY': ?key},
    );
  }

  Future<ProcessResult> sign({String? key, bool prerelease = false}) => run([
    'sign',
    '--tag',
    'v0.1.0',
    '--notes',
    'notes.md',
    '--dist',
    'dist',
    '--base-url',
    'https://example.com/dl/',
    if (prerelease) '--prerelease',
  ], key: key);

  Future<String> publicKey() async {
    final result = await run(['keygen', '--out', 'seed.key']);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    return (result.stdout as String).trim();
  }

  test('keygen prints a public key and refuses to overwrite', () async {
    final key = await publicKey();
    expect(key, hasLength(44));
    expect(File('${root.path}/seed.key').existsSync(), isTrue);
    final again = await run(['keygen', '--out', 'seed.key']);
    expect(again.exitCode, 1);
    expect(again.stdout, isNot(contains(key)));
  });

  test('keygen creates a missing directory for the seed', () async {
    final result = await run(['keygen', '--out', 'secrets/nested/seed.key']);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    final seed = File('${root.path}/secrets/nested/seed.key');
    expect(seed.existsSync(), isTrue);
    if (!Platform.isWindows) {
      expect(seed.statSync().modeString(), 'rw-------');
    }
  });

  test('sign then verify round trip', () async {
    final seedFile = File('${root.path}/seed.key');
    final generated = await run(['keygen', '--out', seedFile.path]);
    final key = (generated.stdout as String).trim();
    final result = await sign(key: seedFile.readAsStringSync().trim());
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(result.stdout, isNot(contains(seedFile.readAsStringSync().trim())));

    final manifest = File('${root.path}/dist/update-manifest.json');
    final json = jsonDecode(manifest.readAsStringSync()) as Map;
    final assets = ((json['releases'] as List).single as Map)['assets'] as List;
    expect(assets.map((asset) => (asset as Map)['name']), [
      'app-one.apk',
      'app.zip',
    ]);
    expect((assets.first as Map)['url'], 'https://example.com/dl/app-one.apk');

    final verified = await run(['verify', manifest.path, '--key', key]);
    expect(verified.exitCode, 0, reason: '${verified.stderr}');
    expect((verified.stdout as String).trim(), 'v0.1.0 stable 2');
  });

  test('sign without a valid key exits 2', () async {
    expect((await sign()).exitCode, 2);
    expect((await sign(key: 'AAAA')).exitCode, 2);
  });

  test('tampered asset size fails verification', () async {
    final seedFile = File('${root.path}/seed.key');
    final key = (await run([
      'keygen',
      '--out',
      seedFile.path,
    ])).stdout.toString().trim();
    expect(
      (await sign(
        key: seedFile.readAsStringSync().trim(),
        prerelease: true,
      )).exitCode,
      0,
    );
    final manifest = File('${root.path}/dist/update-manifest.json');
    final json = jsonDecode(manifest.readAsStringSync()) as Map;
    final release = (json['releases'] as List).single as Map;
    ((release['assets'] as List).first as Map)['size'] = 1;
    manifest.writeAsStringSync(jsonEncode(json));

    final result = await run(['verify', manifest.path, '--key', key]);
    expect(result.exitCode, 1);
  });

  test('unknown command exits 64', () async {
    expect((await run(['bogus'])).exitCode, 64);
  });
}

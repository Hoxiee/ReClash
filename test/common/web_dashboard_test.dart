import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:reclash/common/task.dart';
import 'package:reclash/common/web_dashboard/access.dart';
import 'package:reclash/common/web_dashboard/archive.dart';
import 'package:reclash/common/web_dashboard/dashboard.dart';
import 'package:reclash/common/web_dashboard/installation.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:yaml/yaml.dart';

Matcher _failure(WebDashboardFailure failure) =>
    isA<WebDashboardException>().having((e) => e.failure, 'failure', failure);

Uint8List _zip(List<ArchiveFile> files) {
  final output = OutputMemoryStream();
  final encoder = ZipEncoder()..startEncode(output);
  for (final file in files) {
    encoder.add(file);
  }
  encoder.endEncode();
  return output.getBytes();
}

Uint8List _tar(List<ArchiveFile> files) {
  final output = OutputMemoryStream();
  final encoder = TarEncoder()..start(output);
  for (final file in files) {
    encoder.add(file);
  }
  encoder.finish();
  return output.getBytes();
}

Uint8List _tgz(List<ArchiveFile> files) =>
    const GZipEncoder().encodeBytes(_tar(files));

WebDashboardRelease _release(List<int> bytes) => WebDashboardRelease(
  version: 'fixture-1',
  url: 'https://dashboard.invalid/release.zip',
  sha256: sha256.convert(bytes).toString(),
);

void _seed(Directory home, WebDashboardFlavor flavor) {
  final directory = Directory(
    p.join(home.path, webDashboardDirectoryName, flavor.name),
  )..createSync(recursive: true);
  File(
    p.join(directory.path, webDashboardEntryName),
  ).writeAsStringSync('<html>old</html>');
  File(p.join(directory.path, webDashboardManifestName)).writeAsStringSync(
    jsonEncode({'panel': flavor.name, 'version': 'old', 'sha256': 'a' * 64}),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory home;
  setUp(() => home = Directory.systemTemp.createTempSync('reclash-dashboard-'));
  tearDown(() => home.deleteSync(recursive: true));

  group('dashboard addresses', () {
    for (final flavor in WebDashboardFlavor.values) {
      test('${flavor.name} receives escaped credentials in the fragment', () {
        const secret = 'a&b ?#/%+ü';
        final endpoint = WebDashboardEndpoint(
          controller: Uri.parse('http://127.0.0.1:19090'),
          secret: secret,
        );
        final uri = endpoint.uriFor(flavor);
        expect(uri.origin, 'http://127.0.0.1:19090');
        expect(uri.path, '/ui/${flavor.name}/');
        expect(uri.query, isEmpty);
        final setup = Uri.parse(uri.fragment);
        expect(setup.path, '/setup');
        expect(setup.queryParameters['secret'], secret);
        expect(setup.queryParameters['hostname'], '127.0.0.1');
        expect(setup.queryParameters['port'], '19090');
        if (flavor == WebDashboardFlavor.zashboard) {
          expect(setup.queryParameters['protocol'], 'http');
          expect(setup.queryParameters['disableUpgradeCore'], '1');
          expect(setup.queryParameters['disableTunMode'], '1');
        } else {
          expect(setup.queryParameters['http'], '1');
        }
        expect(endpoint.toString(), isNot(contains(secret)));
        expect(flavor.release.url, isNot(contains('/latest/')));
        expect(flavor.release.sha256, matches(r'^[a-f0-9]{64}$'));
      });
    }

    test('navigation stays inside the selected dashboard and origin', () {
      final dashboard = Uri.parse('http://127.0.0.1:19090/ui/zashboard/');
      for (final path in [
        '/ui/zashboard/',
        '/ui/zashboard/index.html',
        '/ui/zashboard/assets/main.js',
        '/ui/zashboard/#/proxies',
      ]) {
        expect(
          isWebDashboardNavigation(dashboard, dashboard.resolve(path)),
          isTrue,
        );
      }
      for (final target in [
        'http://127.0.0.1:19090/version',
        'http://127.0.0.1:19090/ui/metacubexd/',
        'http://127.0.0.1:19090/ui/zashboard-other/',
        'http://127.0.0.1:19090/ui/zashboard/%2e%2e/%2e%2e/configs',
        'http://127.0.0.1:19090/ui/zashboard/%5c..%5c..%5cconfigs',
        'http://user@127.0.0.1:19090/ui/zashboard/',
        'http://127.0.0.1:19091/ui/zashboard/',
        'https://127.0.0.1:19090/ui/zashboard/',
        'http://localhost:19090/ui/zashboard/',
        'https://example.com/ui/zashboard/',
        'file:///ui/zashboard/index.html',
        'javascript:alert(1)',
      ]) {
        expect(
          isWebDashboardNavigation(dashboard, Uri.parse(target)),
          isFalse,
          reason: target,
        );
      }
    });

    test('saved controller settings win over runtime access', () {
      const closed = PatchClashConfig();
      final temporary = webDashboardEffectiveConfig(
        closed,
        temporarySecret: 'temporary',
        safeMode: false,
      );
      expect(temporary.externalController, ExternalControllerStatus.open);
      expect(temporary.secret, 'temporary');
      expect(closed.externalController, ExternalControllerStatus.close);
      expect(closed.secret, isEmpty);
      const saved = PatchClashConfig(
        externalController: ExternalControllerStatus.open,
        secret: 'saved',
      );
      expect(
        webDashboardEffectiveConfig(
          saved,
          temporarySecret: 'temporary',
          safeMode: false,
        ),
        same(saved),
      );
      expect(
        webDashboardEffectiveConfig(
          saved,
          temporarySecret: 'temporary',
          safeMode: true,
        ).externalController,
        ExternalControllerStatus.close,
      );
      expect(
        webDashboardEffectiveConfig(
          const PatchClashConfig(
            externalController: ExternalControllerStatus.open,
          ),
          temporarySecret: 'temporary',
          safeMode: false,
        ).externalController,
        ExternalControllerStatus.close,
      );
    });
  });

  group('archive extraction', () {
    void extract(
      List<int> bytes, {
      bool cancelled = false,
      bool occupied = false,
    }) {
      final work = Directory(p.join(home.path, 'archive'))..createSync();
      final staging = Directory(p.join(home.path, 'staging'))..createSync();
      final archive = File(p.join(work.path, 'download'))
        ..writeAsBytesSync(bytes);
      final cancel = File(p.join(work.path, 'cancelled'));
      if (cancelled) cancel.writeAsStringSync('');
      if (occupied) {
        File(p.join(staging.path, 'keep')).writeAsStringSync('keep');
      }
      extractWebDashboard((
        archivePath: archive.path,
        stagingPath: staging.path,
        cancelPath: cancel.path,
      ));
    }

    for (final tar in [false, true]) {
      test(
        'extracts ${tar ? 'tgz' : 'zip'} with one stripped distribution root',
        () {
          final files = [
            ArchiveFile.directory('dist/'),
            ArchiveFile.string('dist/index.html', '<html>dashboard</html>'),
            ArchiveFile.string('dist/assets/main.js', 'local asset'),
            ArchiveFile.string('README.md', 'not served'),
          ];
          extract(tar ? _tgz(files) : _zip(files));
          expect(
            File(p.join(home.path, 'staging', 'index.html')).readAsStringSync(),
            '<html>dashboard</html>',
          );
          expect(
            File(
              p.join(home.path, 'staging', 'assets', 'main.js'),
            ).readAsStringSync(),
            'local asset',
          );
          expect(
            File(p.join(home.path, 'staging', 'README.md')).existsSync(),
            isFalse,
          );
        },
      );

      for (final name in [
        '../escaped',
        '/absolute',
        r'C:\escaped',
        r'dist\..\escaped',
        'dist/CON.js',
        'dist/assets/aux',
        'dist/trailing.',
        'dist/trailing ',
        'dist/control\u0000.js',
      ]) {
        test('${tar ? 'tgz' : 'zip'} rejects unsafe entry $name', () {
          final files = [
            ArchiveFile.string('dist/index.html', '<html></html>'),
            ArchiveFile.string(name, 'unsafe'),
          ];
          expect(
            () => extract(tar ? _tgz(files) : _zip(files)),
            throwsA(_failure(WebDashboardFailure.archive)),
          );
          expect(File(p.join(home.path, 'escaped')).existsSync(), isFalse);
        });
      }

      test('${tar ? 'tgz' : 'zip'} rejects duplicate normalized paths', () {
        final files = [
          ArchiveFile.string('dist/index.html', '<html></html>'),
          ArchiveFile.string('dist/assets/file.js', 'a'),
          ArchiveFile.string('dist/assets/./FILE.js', 'b'),
        ];
        expect(
          () => extract(tar ? _tgz(files) : _zip(files)),
          throwsA(_failure(WebDashboardFailure.archive)),
        );
      });
      test('${tar ? 'tgz' : 'zip'} rejects ambiguous dashboard roots', () {
        final files = [
          ArchiveFile.string('one/index.html', '<html></html>'),
          ArchiveFile.string('two/index.html', '<html></html>'),
        ];
        expect(
          () => extract(tar ? _tgz(files) : _zip(files)),
          throwsA(_failure(WebDashboardFailure.archive)),
        );
      });
      test('${tar ? 'tgz' : 'zip'} requires a nonempty index', () {
        final files = [ArchiveFile.string('index.html', '')];
        expect(
          () => extract(tar ? _tgz(files) : _zip(files)),
          throwsA(_failure(WebDashboardFailure.archive)),
        );
      });
    }

    test('CRC matches compressed and stored ZIP data across output chunks', () {
      final content = Uint8List.fromList(
        List.generate(2 * 1024 * 1024 + 31, (index) => index % 251),
      );
      extract(
        _zip([
          ArchiveFile.string('index.html', '<html></html>'),
          ArchiveFile.bytes('compressed.bin', content),
          ArchiveFile.noCompress('stored.bin', content.length, content),
        ]),
      );
      for (final name in ['compressed.bin', 'stored.bin']) {
        expect(
          File(p.join(home.path, 'staging', name)).readAsBytesSync(),
          content,
        );
      }
    });
    test('rejects ZIP CRC corruption', () {
      final bytes = _zip([ArchiveFile.string('index.html', '<html></html>')]);
      final data = ByteData.sublistView(bytes);
      for (var offset = 0; offset + 46 < bytes.length; offset++) {
        if (data.getUint32(offset, Endian.little) == 0x02014b50) {
          data.setUint32(offset + 16, 0, Endian.little);
          break;
        }
      }
      expect(
        () => extract(bytes),
        throwsA(_failure(WebDashboardFailure.archive)),
      );
    });
    test('rejects an oversized ZIP file before decompression', () {
      final bytes = _zip([ArchiveFile.string('index.html', '<html></html>')]);
      final data = ByteData.sublistView(bytes);
      for (var offset = 0; offset + 46 < bytes.length; offset++) {
        if (data.getUint32(offset, Endian.little) == 0x02014b50) {
          data.setUint32(
            offset + 24,
            webDashboardMaxFileBytes + 1,
            Endian.little,
          );
          break;
        }
      }
      expect(
        () => extract(bytes),
        throwsA(_failure(WebDashboardFailure.tooLarge)),
      );
      expect(Directory(p.join(home.path, 'staging')).listSync(), isEmpty);
    });
    test('rejects too many ZIP headers before reading the directory', () {
      final bytes = _zip([ArchiveFile.string('index.html', '<html></html>')]);
      final data = ByteData.sublistView(bytes);
      data.setUint16(
        bytes.length - 14,
        webDashboardMaxFiles + 1,
        Endian.little,
      );
      data.setUint16(
        bytes.length - 12,
        webDashboardMaxFiles + 1,
        Endian.little,
      );
      expect(
        () => extract(bytes),
        throwsA(_failure(WebDashboardFailure.tooLarge)),
      );
    });
    test('rejects tar symlinks', () {
      expect(
        () => extract(
          _tgz([
            ArchiveFile.string('index.html', '<html></html>'),
            ArchiveFile.symlink('link', '../../escaped'),
          ]),
        ),
        throwsA(_failure(WebDashboardFailure.archive)),
      );
    });
    test('rejects gzip CRC corruption', () {
      final bytes = _tgz([ArchiveFile.string('index.html', '<html></html>')]);
      bytes[bytes.length - 8] ^= 1;
      expect(
        () => extract(bytes),
        throwsA(_failure(WebDashboardFailure.archive)),
      );
    });
    test('rejects gzip content that is not a tar', () {
      expect(
        () =>
            extract(const GZipEncoder().encodeBytes(utf8.encode('not a tar'))),
        throwsA(_failure(WebDashboardFailure.archive)),
      );
    });
    test('requires an index', () {
      expect(
        () => extract(_zip([ArchiveFile.string('main.js', 'x')])),
        throwsA(_failure(WebDashboardFailure.archive)),
      );
    });
    test('cancellation runs before any write', () {
      expect(
        () => extract(
          _zip([ArchiveFile.string('index.html', 'x')]),
          cancelled: true,
        ),
        throwsA(_failure(WebDashboardFailure.cancelled)),
      );
      expect(Directory(p.join(home.path, 'staging')).listSync(), isEmpty);
    });
    test('never extracts into a populated staging directory', () {
      expect(
        () => extract(
          _zip([ArchiveFile.string('index.html', 'x')]),
          occupied: true,
        ),
        throwsA(_failure(WebDashboardFailure.storage)),
      );
      expect(
        File(p.join(home.path, 'staging', 'keep')).readAsStringSync(),
        'keep',
      );
    });
  });

  group('installation storage', () {
    late WebDashboardStore store;
    late Uint8List bytes;
    late List<WebDashboardPhase> phases;
    setUp(() {
      bytes = _zip([ArchiveFile.string('dist/index.html', '<html>new</html>')]);
      phases = [];
      store = WebDashboardStore(
        homeDirectory: () async => home.path,
        download:
            (
              uri,
              destination, {
              required onProgress,
              required cancelToken,
            }) async {
              await File(destination).writeAsBytes(bytes);
              onProgress(bytes.length, bytes.length);
              return null;
            },
      );
    });
    Future<void> install({
      CancelToken? token,
      WebDashboardRelease? release,
      void Function(WebDashboardProgress)? progress,
    }) => store.install(
      WebDashboardFlavor.zashboard,
      cancelToken: token ?? CancelToken(),
      release: release ?? _release(bytes),
      onProgress: progress ?? (value) => phases.add(value.phase),
    );
    String entry(WebDashboardFlavor flavor) => File(
      p.join(
        home.path,
        webDashboardDirectoryName,
        flavor.name,
        webDashboardEntryName,
      ),
    ).readAsStringSync();
    void noWork() => expect(
      Directory(p.join(home.path, webDashboardWorkDirectoryName)).listSync(),
      isEmpty,
    );

    test('publishes verified staging and preserves the other panel', () async {
      _seed(home, WebDashboardFlavor.zashboard);
      _seed(home, WebDashboardFlavor.metacubexd);
      await install();
      expect(entry(WebDashboardFlavor.zashboard), '<html>new</html>');
      expect(entry(WebDashboardFlavor.metacubexd), '<html>old</html>');
      expect(
        (await store.installations())[WebDashboardFlavor.zashboard]!.version,
        'fixture-1',
      );
      expect(phases, containsAllInOrder(WebDashboardPhase.values));
      expect(
        await webDashboardServedDirectory(home.path),
        webDashboardDirectoryName,
      );
      noWork();
    });
    test('checksum failure preserves the previous installation', () async {
      _seed(home, WebDashboardFlavor.zashboard);
      await expectLater(
        install(
          release: WebDashboardRelease(
            version: 'bad',
            url: 'https://dashboard.invalid/release.zip',
            sha256: '0' * 64,
          ),
        ),
        throwsA(_failure(WebDashboardFailure.checksum)),
      );
      expect(entry(WebDashboardFlavor.zashboard), '<html>old</html>');
      noWork();
      await install();
      expect(entry(WebDashboardFlavor.zashboard), '<html>new</html>');
    });
    test(
      'a verified but unsafe archive cannot replace the previous files',
      () async {
        _seed(home, WebDashboardFlavor.zashboard);
        bytes = _zip([ArchiveFile.string('../index.html', 'unsafe')]);
        await expectLater(
          install(),
          throwsA(_failure(WebDashboardFailure.archive)),
        );
        expect(entry(WebDashboardFlavor.zashboard), '<html>old</html>');
        noWork();
      },
    );
    for (final phase in [
      WebDashboardPhase.verifying,
      WebDashboardPhase.extracting,
    ]) {
      test(
        'cancellation during ${phase.name} preserves the previous panel',
        () async {
          _seed(home, WebDashboardFlavor.zashboard);
          final token = CancelToken();
          await expectLater(
            install(
              token: token,
              progress: (progress) {
                if (progress.phase == phase) token.cancel();
              },
            ),
            throwsA(_failure(WebDashboardFailure.cancelled)),
          );
          expect(entry(WebDashboardFlavor.zashboard), '<html>old</html>');
          noWork();
        },
      );
    }
    test(
      'download size limits abort without replacing the old installation',
      () async {
        _seed(home, WebDashboardFlavor.zashboard);
        store = WebDashboardStore(
          homeDirectory: () async => home.path,
          download:
              (
                uri,
                destination, {
                required onProgress,
                required cancelToken,
              }) async {
                onProgress(1, webDashboardMaxDownloadBytes + 1);
                return '';
              },
        );
        await expectLater(
          install(),
          throwsA(_failure(WebDashboardFailure.tooLarge)),
        );
        expect(entry(WebDashboardFlavor.zashboard), '<html>old</html>');
        noWork();
      },
    );
    test('download deadline cancels transport and resets ownership', () async {
      CancelToken? transport;
      store = WebDashboardStore(
        homeDirectory: () async => home.path,
        downloadTimeout: const Duration(milliseconds: 20),
        download:
            (
              uri,
              destination, {
              required onProgress,
              required cancelToken,
            }) async {
              transport = cancelToken;
              await cancelToken.whenCancel;
              return '';
            },
      );
      await expectLater(
        install(),
        throwsA(_failure(WebDashboardFailure.download)),
      );
      expect(transport!.isCancelled, isTrue);
      noWork();
      await store.remove(WebDashboardFlavor.zashboard);
    });
    test('storage refuses concurrent installation and removal', () async {
      final entered = Completer<void>();
      final done = Completer<void>();
      addTearDown(() {
        if (!done.isCompleted) done.complete();
      });
      store = WebDashboardStore(
        homeDirectory: () async => home.path,
        download:
            (
              uri,
              destination, {
              required onProgress,
              required cancelToken,
            }) async {
              entered.complete();
              await done.future;
              await File(destination).writeAsBytes(bytes);
              return null;
            },
      );
      final first = install();
      await entered.future;
      await expectLater(install(), throwsA(_failure(WebDashboardFailure.busy)));
      await expectLater(
        store.remove(WebDashboardFlavor.zashboard),
        throwsA(_failure(WebDashboardFailure.busy)),
      );
      done.complete();
      await first;
      noWork();
    });
    test('failed publication rolls back the previous directory', () async {
      _seed(home, WebDashboardFlavor.zashboard);
      store = WebDashboardStore(
        homeDirectory: store.homeDirectory,
        download: store.download,
        rename: (source, target) async {
          if (p.basename(source) == 'next') {
            throw const FileSystemException('publish failed');
          }
          await Directory(source).rename(target);
        },
      );
      await expectLater(
        install(),
        throwsA(_failure(WebDashboardFailure.storage)),
      );
      expect(entry(WebDashboardFlavor.zashboard), '<html>old</html>');
      noWork();
    });
    test(
      'failed rollback retains the old installation as recoverable files',
      () async {
        _seed(home, WebDashboardFlavor.zashboard);
        store = WebDashboardStore(
          homeDirectory: store.homeDirectory,
          download: store.download,
          rename: (source, target) async {
            if (p.basename(source) != WebDashboardFlavor.zashboard.name) {
              throw const FileSystemException('rename failed');
            }
            await Directory(source).rename(target);
          },
        );
        await expectLater(
          install(),
          throwsA(_failure(WebDashboardFailure.storage)),
        );
        final work = Directory(
          p.join(home.path, webDashboardWorkDirectoryName),
        ).listSync().single.path;
        expect(
          File(p.join(work, 'previous', 'index.html')).readAsStringSync(),
          '<html>old</html>',
        );
        expect(await webDashboardServedDirectory(home.path), isEmpty);
      },
    );
    test('removal and data clearing touch only managed directories', () async {
      _seed(home, WebDashboardFlavor.zashboard);
      _seed(home, WebDashboardFlavor.metacubexd);
      final unrelated = File(p.join(home.path, 'keep'))
        ..writeAsStringSync('keep');
      await store.remove(WebDashboardFlavor.zashboard);
      expect((await store.installations()).keys, [
        WebDashboardFlavor.metacubexd,
      ]);
      Directory(
        p.join(home.path, webDashboardWorkDirectoryName, 'stale'),
      ).createSync(recursive: true);
      await clearWebDashboardFiles(home.path);
      expect(await store.installations(), isEmpty);
      expect(
        Directory(
          p.join(home.path, webDashboardWorkDirectoryName),
        ).existsSync(),
        isFalse,
      );
      expect(unrelated.readAsStringSync(), 'keep');
    });
    test('installed and served state require valid bounded metadata', () async {
      _seed(home, WebDashboardFlavor.zashboard);
      final panel = p.join(home.path, webDashboardDirectoryName, 'zashboard');
      final manifest = File(p.join(panel, webDashboardManifestName));
      for (final metadata in [
        'not json',
        jsonEncode({'panel': 'wrong', 'version': 'old', 'sha256': 'a' * 64}),
        jsonEncode({'panel': 'zashboard', 'version': '', 'sha256': 'a' * 64}),
        ' ' * 4097,
      ]) {
        manifest.writeAsStringSync(metadata);
        expect(await store.installations(), isEmpty);
        expect(await webDashboardServedDirectory(home.path), isEmpty);
      }
      _seed(home, WebDashboardFlavor.zashboard);
      File(p.join(panel, webDashboardEntryName)).writeAsStringSync('');
      expect(await store.installations(), isEmpty);
      expect(await webDashboardServedDirectory(home.path), isEmpty);
    });
    test('managed symlinks never redirect writes or deletion', () async {
      final outside = Directory.systemTemp.createTempSync(
        'reclash-dashboard-outside-',
      );
      addTearDown(() => outside.deleteSync(recursive: true));
      final keep = File(p.join(outside.path, 'keep'))
        ..writeAsStringSync('keep');
      Link(
        p.join(home.path, webDashboardDirectoryName),
      ).createSync(outside.path);
      await expectLater(
        install(),
        throwsA(_failure(WebDashboardFailure.storage)),
      );
      await expectLater(
        store.remove(WebDashboardFlavor.zashboard),
        throwsA(_failure(WebDashboardFailure.storage)),
      );
      await expectLater(
        clearWebDashboardFiles(home.path),
        throwsA(_failure(WebDashboardFailure.storage)),
      );
      expect(await webDashboardServedDirectory(home.path), isEmpty);
      expect(keep.readAsStringSync(), 'keep');
    }, skip: Platform.isWindows);
    test('profile generation serves only installed managed paths', () async {
      Future<YamlMap> config(String directory) async {
        final result = await makeRealProfileTask(
          MakeRealProfileState(
            profilesPath: p.join(home.path, 'profiles'),
            profileId: 1,
            rawConfig: const {
              'external-ui': '/escaped',
              'external-ui-url': 'https://dashboard.invalid',
              'external-ui-name': 'custom',
            },
            realPatchConfig: const PatchClashConfig(),
            appendSystemDns: false,
            proxyGroups: const [],
            rules: const [],
            addedRules: const [],
            defaultUA: 'ReClash-Test',
            webDashboardDirectory: directory,
          ),
        );
        return loadYaml(result.yaml) as YamlMap;
      }

      expect((await config(webDashboardDirectoryName))['external-ui'], '');
      _seed(home, WebDashboardFlavor.zashboard);
      final installed = await config(webDashboardDirectoryName);
      expect(installed['external-ui'], webDashboardDirectoryName);
      expect(installed['external-ui-url'], '');
      expect(installed['external-ui-name'], '');
      expect((await config('/escaped'))['external-ui'], '');
    });
  });

  group('Core probe', () {
    HttpOverrides? previousOverrides;
    setUp(() {
      previousOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
    });
    tearDown(() => HttpOverrides.global = previousOverrides);

    Future<WebDashboardEndpoint> server(
      void Function(HttpRequest) handle,
    ) async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final subscription = server.listen(handle);
      addTearDown(() async {
        await server.close(force: true);
        await subscription.cancel();
      });
      return WebDashboardEndpoint(
        controller: Uri.parse('http://127.0.0.1:${server.port}'),
        secret: 'secret',
      );
    }

    void respond(
      HttpRequest request,
      String body, {
      int status = HttpStatus.ok,
    }) {
      request.response.statusCode = status;
      request.response.write(body);
      unawaited(request.response.close().catchError((Object _) {}));
    }

    for (final flavor in WebDashboardFlavor.values) {
      test(
        '${flavor.name} probes authenticated API then the selected UI',
        () async {
          final paths = <String>[];
          final endpoint = await server((request) {
            paths.add(request.uri.path);
            if (request.uri.path == '/version') {
              expect(
                request.headers.value(HttpHeaders.authorizationHeader),
                'Bearer secret',
              );
              respond(request, '{"version":"test"}');
            } else {
              expect(
                request.headers.value(HttpHeaders.authorizationHeader),
                isNull,
              );
              respond(request, '<!doctype html><html>dashboard</html>');
            }
          });
          await probeWebDashboard(endpoint, flavor);
          expect(paths, ['/version', '/ui/${flavor.name}/']);
        },
      );
    }
    test('reports authentication failure without credentials', () async {
      final endpoint = await server(
        (request) => respond(request, '{}', status: HttpStatus.unauthorized),
      );
      await expectLater(
        probeWebDashboard(
          endpoint,
          WebDashboardFlavor.zashboard,
          timeout: const Duration(milliseconds: 150),
        ),
        throwsA(_failure(WebDashboardFailure.authentication)),
      );
      expect(
        const WebDashboardException(
          WebDashboardFailure.authentication,
        ).toString(),
        isNot(contains(endpoint.secret)),
      );
    });
    test('a valid API does not hide a missing dashboard', () async {
      final endpoint = await server(
        (request) => respond(
          request,
          request.uri.path == '/version' ? '{"version":"test"}' : 'missing',
        ),
      );
      await expectLater(
        probeWebDashboard(
          endpoint,
          WebDashboardFlavor.zashboard,
          timeout: const Duration(milliseconds: 150),
        ),
        throwsA(_failure(WebDashboardFailure.unreachable)),
      );
    });
    test('the deadline includes a server that never responds', () async {
      final endpoint = await server((_) {});
      final elapsed = Stopwatch()..start();
      await expectLater(
        probeWebDashboard(
          endpoint,
          WebDashboardFlavor.zashboard,
          timeout: const Duration(milliseconds: 80),
        ),
        throwsA(_failure(WebDashboardFailure.unreachable)),
      );
      expect(elapsed.elapsed, lessThan(const Duration(seconds: 1)));
    });
    test('bounded response size rejects oversized API bodies', () async {
      final endpoint = await server(
        (request) => respond(request, 'x' * (1024 * 1024 + 1)),
      );
      await expectLater(
        probeWebDashboard(endpoint, WebDashboardFlavor.zashboard),
        throwsA(_failure(WebDashboardFailure.unreachable)),
      );
    });
    test('cancellation closes an unanswered HTTP request', () async {
      final entered = Completer<void>();
      final endpoint = await server((_) {
        if (!entered.isCompleted) entered.complete();
      });
      final token = CancelToken();
      final pending = probeWebDashboard(
        endpoint,
        WebDashboardFlavor.zashboard,
        cancelToken: token,
      );
      await entered.future;
      token.cancel();
      await expectLater(
        pending,
        throwsA(_failure(WebDashboardFailure.cancelled)),
      );
    });
  });
}

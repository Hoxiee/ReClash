import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

Map<String, String> _setupParams(Uri uri) {
  final query = uri.fragment.substring(uri.fragment.indexOf('?') + 1);
  return Uri.splitQueryString(query);
}

void main() {
  late Directory root;
  var archiveIndex = 0;

  setUpAll(() {
    root = Directory.systemTemp.createTempSync('web_dashboard_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
  });

  tearDownAll(() {
    try {
      root.deleteSync(recursive: true);
    } catch (_) {}
  });

  String writeArchive(Map<String, String> entries) {
    final archive = Archive();
    for (final entry in entries.entries) {
      archive.add(ArchiveFile.string(entry.key, entry.value));
    }
    final path = join(root.path, 'archive${archiveIndex++}.zip');
    File(path).writeAsBytesSync(ZipEncoder().encodeBytes(archive));
    return path;
  }

  String writeTarGz(Map<String, String> entries) {
    final archive = Archive();
    for (final entry in entries.entries) {
      archive.add(ArchiveFile.string(entry.key, entry.value));
    }
    final path = join(root.path, 'archive${archiveIndex++}.tgz');
    File(path).writeAsBytesSync(
      const GZipEncoder().encode(TarEncoder().encodeBytes(archive)),
    );
    return path;
  }

  String targetPath(String name) => join(root.path, 'unpack', name);

  group('webDashboardUri', () {
    test('hands the controller host and port to the setup route', () {
      final uri = webDashboardUri('127.0.0.1:9090');

      expect(uri.scheme, 'http');
      expect(uri.host, '127.0.0.1');
      expect(uri.port, 9090);
      expect(uri.path, '/$webDashboardDirName/');
      expect(uri.fragment, startsWith('/setup?'));
      expect(_setupParams(uri), {
        'hostname': '127.0.0.1',
        'port': '9090',
        'protocol': 'http',
        'label': appName,
        'disableUpgradeCore': '1',
        'disableTunMode': '1',
      });
    });

    test('falls back to the default controller when none is configured', () {
      expect(
        webDashboardUri('').toString(),
        webDashboardUri('127.0.0.1:9090').toString(),
      );
    });

    test('omits the port when the controller carries none', () {
      final params = _setupParams(webDashboardUri('localhost'));

      expect(params['hostname'], 'localhost');
      expect(params.containsKey('port'), isFalse);
    });
  });

  group('webDashboardUri metacubexd', () {
    test('hands the controller host and port to the page query', () {
      final uri = webDashboardUri(
        '127.0.0.1:9090',
        flavor: WebDashboardFlavor.metacubexd,
      );

      expect(uri.scheme, 'http');
      expect(uri.host, '127.0.0.1');
      expect(uri.port, 9090);
      expect(uri.path, '/$webDashboardDirName/');
      expect(uri.fragment, isEmpty);
      expect(uri.queryParameters, {'hostname': '127.0.0.1', 'port': '9090'});
    });

    test('carries the secret when one is configured', () {
      final uri = webDashboardUri(
        '127.0.0.1:9090',
        secret: 's3cret',
        flavor: WebDashboardFlavor.metacubexd,
      );

      expect(uri.queryParameters['secret'], 's3cret');
    });

    test('falls back to the default controller when none is configured', () {
      expect(
        webDashboardUri('', flavor: WebDashboardFlavor.metacubexd).toString(),
        webDashboardUri(
          '127.0.0.1:9090',
          flavor: WebDashboardFlavor.metacubexd,
        ).toString(),
      );
    });
  });

  group('webDashboardArchiveRoot', () {
    test('returns the directory of the shallowest entry point', () {
      expect(
        webDashboardArchiveRoot([
          'dist/assets/app.js',
          'dist/sub/index.html',
          'dist/index.html',
        ]),
        'dist',
      );
    });

    test('returns null for an archive that is already flat', () {
      expect(webDashboardArchiveRoot(['index.html', 'assets/app.js']), isNull);
    });

    test('returns null when no entry point is present', () {
      expect(webDashboardArchiveRoot(['dist/assets/app.js']), isNull);
    });
  });

  group('webDashboardEntryPath', () {
    test('strips the archive root', () {
      expect(
        webDashboardEntryPath('/target', 'dist/assets/app.js', 'dist'),
        '/target/assets/app.js',
      );
    });

    test('rejects traversal, absolute, and out-of-root entries', () {
      expect(webDashboardEntryPath('/target', '../evil.txt', 'dist'), isNull);
      expect(webDashboardEntryPath('/target', 'README.md', 'dist'), isNull);
      expect(webDashboardEntryPath('/target', 'dist', 'dist'), isNull);
      expect(webDashboardEntryPath('/target', '/etc/passwd', null), isNull);
      expect(
        webDashboardEntryPath('/target', '../../etc/passwd', null),
        isNull,
      );
    });
  });

  group('unpackWebDashboard', () {
    test('lifts the release directory to the served root', () async {
      final target = targetPath('lifted');
      final archivePath = writeArchive({
        'dist/index.html': '<html>dash</html>',
        'dist/assets/app.js': 'app',
      });

      await unpackWebDashboard((archivePath: archivePath, targetPath: target));

      expect(
        File(join(target, webDashboardEntryName)).readAsStringSync(),
        '<html>dash</html>',
      );
      expect(File(join(target, 'assets', 'app.js')).existsSync(), isTrue);
      expect(Directory(join(target, 'dist')).existsSync(), isFalse);
      expect(Directory('$target.new').existsSync(), isFalse);
      expect(
        isWebDashboardInstalledIn(dirname(target), WebDashboardFlavor.zashboard),
        isFalse,
      );
    });

    test('keeps a flat archive as it is', () async {
      final target = targetPath('flat');
      final archivePath = writeArchive({
        'index.html': 'flat',
        'assets/app.css': 'css',
      });

      await unpackWebDashboard((archivePath: archivePath, targetPath: target));

      expect(File(join(target, 'assets', 'app.css')).existsSync(), isTrue);
    });

    test('unpacks a gzipped tarball with dot-prefixed entries', () async {
      final target = targetPath('tgz');
      final archivePath = writeTarGz({
        './index.html': '<html>metacubexd</html>',
        './_nuxt/app.js': 'app',
      });

      await unpackWebDashboard((archivePath: archivePath, targetPath: target));

      expect(
        File(join(target, webDashboardEntryName)).readAsStringSync(),
        '<html>metacubexd</html>',
      );
      expect(File(join(target, '_nuxt', 'app.js')).existsSync(), isTrue);
      expect(Directory('$target.new').existsSync(), isFalse);
    });

    test('drops entries that sit outside the archive root', () async {
      final target = targetPath('extra');
      final archivePath = writeArchive({
        'dist/index.html': 'dash',
        'README.md': 'notes',
        'dist/../../evil.txt': 'evil',
      });

      await unpackWebDashboard((archivePath: archivePath, targetPath: target));

      expect(File(join(target, 'README.md')).existsSync(), isFalse);
      expect(File(join(root.path, 'evil.txt')).existsSync(), isFalse);
      expect(File(join(target, 'evil.txt')).existsSync(), isFalse);
    });

    test('leaves an installed dashboard untouched when the archive is not '
        'one', () async {
      final target = targetPath('kept');
      File(join(target, webDashboardEntryName))
        ..createSync(recursive: true)
        ..writeAsStringSync('previous');
      final archivePath = writeArchive({'dist/assets/app.js': 'app'});

      await expectLater(
        unpackWebDashboard((archivePath: archivePath, targetPath: target)),
        throwsA(isA<FormatException>()),
      );

      expect(
        File(join(target, webDashboardEntryName)).readAsStringSync(),
        'previous',
      );
      expect(Directory('$target.new').existsSync(), isFalse);
    });
  });

  group('WebDashboard', () {
    test('pins and verifies the downloaded release archives', () async {
      expect(zashboardUrl, contains('/releases/download/v3.26.0/'));
      expect(metacubexdUrl, contains('/releases/download/v1.273.1/'));
      expect(webDashboardUrlOf(WebDashboardFlavor.zashboard), zashboardUrl);
      expect(webDashboardUrlOf(WebDashboardFlavor.metacubexd), metacubexdUrl);
      final archive = File(writeArchive({'index.html': 'dashboard'}));

      expect(await hasWebDashboardDigest(archive, zashboardSha256), isFalse);
      expect(await hasWebDashboardDigest(archive, metacubexdSha256), isFalse);
    });

    test('reports and removes each flavor in its own subdirectory', () async {
      for (final flavor in WebDashboardFlavor.values) {
        expect(await webDashboard.isInstalledFor(flavor), isFalse);
      }

      for (final flavor in WebDashboardFlavor.values) {
        File(
          join(
            webDashboardFlavorDirIn(root.path, flavor),
            webDashboardEntryName,
          ),
        )
          ..createSync(recursive: true)
          ..writeAsStringSync('installed');
      }

      for (final flavor in WebDashboardFlavor.values) {
        expect(await webDashboard.isInstalledFor(flavor), isTrue);
      }

      // Removing one flavor leaves the other and its served path intact.
      await webDashboard.remove(WebDashboardFlavor.zashboard);
      expect(
        await webDashboard.isInstalledFor(WebDashboardFlavor.zashboard),
        isFalse,
      );
      expect(
        await webDashboard.isInstalledFor(WebDashboardFlavor.metacubexd),
        isTrue,
      );
      expect(
        webDashboardServedDirName(root.path, WebDashboardFlavor.metacubexd),
        join(webDashboardDirName, WebDashboardFlavor.metacubexd.name),
      );

      await webDashboard.remove();

      for (final flavor in WebDashboardFlavor.values) {
        expect(await webDashboard.isInstalledFor(flavor), isFalse);
      }
      expect(Directory(webDashboardDirIn(root.path)).existsSync(), isFalse);
    });

    test('removes the empty parent after its last flavor goes', () async {
      File(
        join(
          webDashboardFlavorDirIn(root.path, WebDashboardFlavor.zashboard),
          webDashboardEntryName,
        ),
      )
        ..createSync(recursive: true)
        ..writeAsStringSync('installed');

      await webDashboard.remove(WebDashboardFlavor.zashboard);

      expect(Directory(webDashboardDirIn(root.path)).existsSync(), isFalse);
    });

    test('serves no directory until the selected flavor is installed', () {
      expect(
        webDashboardServedDirName(root.path, WebDashboardFlavor.zashboard),
        isEmpty,
      );

      File(
        join(
          webDashboardFlavorDirIn(root.path, WebDashboardFlavor.zashboard),
          webDashboardEntryName,
        ),
      )
        ..createSync(recursive: true)
        ..writeAsStringSync('installed');

      expect(
        webDashboardServedDirName(root.path, WebDashboardFlavor.zashboard),
        join(webDashboardDirName, WebDashboardFlavor.zashboard.name),
      );
      expect(
        webDashboardServedDirName(root.path, WebDashboardFlavor.metacubexd),
        isEmpty,
      );

      Directory(webDashboardDirIn(root.path)).deleteSync(recursive: true);
    });

    test('lifts a legacy flat install into the zashboard subdirectory', () async {
      final uiDir = webDashboardDirIn(root.path);
      File(join(uiDir, webDashboardEntryName))
        ..createSync(recursive: true)
        ..writeAsStringSync('legacy');
      File(join(uiDir, 'assets', 'app.js'))
        ..createSync(recursive: true)
        ..writeAsStringSync('app');

      await migrateLegacyWebDashboardIn(root.path);

      expect(
        isWebDashboardInstalledIn(root.path, WebDashboardFlavor.zashboard),
        isTrue,
      );
      final zashDir = webDashboardFlavorDirIn(
        root.path,
        WebDashboardFlavor.zashboard,
      );
      expect(
        File(join(zashDir, webDashboardEntryName)).readAsStringSync(),
        'legacy',
      );
      expect(File(join(zashDir, 'assets', 'app.js')).existsSync(), isTrue);
      expect(File(join(uiDir, webDashboardEntryName)).existsSync(), isFalse);
      expect(Directory('$uiDir.legacy').existsSync(), isFalse);

      await webDashboard.remove();
    });

    test('leaves a subdirectory install alone when migrating', () async {
      File(
        join(
          webDashboardFlavorDirIn(root.path, WebDashboardFlavor.zashboard),
          webDashboardEntryName,
        ),
      )
        ..createSync(recursive: true)
        ..writeAsStringSync('fresh');

      await migrateLegacyWebDashboardIn(root.path);

      expect(
        File(
          join(
            webDashboardFlavorDirIn(root.path, WebDashboardFlavor.zashboard),
            webDashboardEntryName,
          ),
        ).readAsStringSync(),
        'fresh',
      );

      await webDashboard.remove();
    });
  });

  group('probeWebDashboard', () {
    Future<HttpServer> serve(int Function(String path) statusFor) async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        request.response.statusCode = statusFor(request.uri.path);
        await request.response.close();
      });
      return server;
    }

    test('reports serving when the core answers the ui root', () async {
      final server = await serve(
        (path) => path == '/$webDashboardDirName/'
            ? HttpStatus.ok
            : HttpStatus.notFound,
      );
      addTearDown(() => server.close(force: true));

      expect(
        await probeWebDashboard(webDashboardUri('127.0.0.1:${server.port}')),
        WebDashboardReadiness.serving,
      );
    });

    test(
      'reports unmounted while the controller answers without a ui',
      () async {
        final server = await serve((_) => HttpStatus.notFound);
        addTearDown(() => server.close(force: true));

        expect(
          await probeWebDashboard(
            webDashboardUri('127.0.0.1:${server.port}'),
            timeout: Duration.zero,
          ),
          WebDashboardReadiness.unmounted,
        );
      },
    );

    test('reports unreachable when nothing listens', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      await server.close(force: true);

      expect(
        await probeWebDashboard(
          webDashboardUri('127.0.0.1:$port'),
          timeout: Duration.zero,
        ),
        WebDashboardReadiness.unreachable,
      );
    });
  });

  group('WebDashboardSession', () {
    ({
      WebDashboardSession session,
      List<String> writes,
      void Function(String status) set,
    })
    build(String initial) {
      var current = initial;
      final writes = <String>[];
      final session = WebDashboardSession(
        status: () => current,
        setStatus: (status) async {
          writes.add(status);
          current = status;
        },
      );
      return (
        session: session,
        writes: writes,
        set: (status) => current = status,
      );
    }

    test('borrows a closed controller and gives it back', () async {
      final fixture = build('');

      await fixture.session.open();
      expect(fixture.session.isBorrowed, isTrue);
      await fixture.session.close();

      expect(fixture.writes, ['127.0.0.1:9090', '']);
      expect(fixture.session.isBorrowed, isFalse);
    });

    test('leaves a controller the user turned on alone', () async {
      final fixture = build('127.0.0.1:9090');

      await fixture.session.open();
      await fixture.session.close();

      expect(fixture.writes, isEmpty);
    });

    test('does not fight a user who closed it during the session', () async {
      final fixture = build('');

      await fixture.session.open();
      fixture.set('');
      await fixture.session.close();

      expect(fixture.writes, ['127.0.0.1:9090']);
    });

    test(
      'leaves a controller the user reconfigured during the session',
      () async {
        final fixture = build('');

        await fixture.session.open();
        fixture.set('0.0.0.0:9091');
        await fixture.session.close();

        expect(fixture.writes, ['127.0.0.1:9090']);
      },
    );

    test('gives the controller back once', () async {
      final fixture = build('');

      await fixture.session.open();
      await fixture.session.close();
      await fixture.session.close();

      expect(fixture.writes, ['127.0.0.1:9090', '']);
    });
  });
}

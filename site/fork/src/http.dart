import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:path/path.dart' as p;

import '../../../tool/src/fork/git.dart';
import '../../../tool/src/fork/model.dart';
import 'repository.dart';

class AtlasServer {
  AtlasServer({required this.root, required this.siteRoot})
    : token = base64Url.encode(
        List.generate(32, (_) => Random.secure().nextInt(256)),
      );

  final String root;
  final String siteRoot;
  final String token;
  HttpServer? _server;

  int get port => _server!.port;

  Future<void> start({int port = 8788}) async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server!.listen(_handle);
  }

  Future<void> close() async => _server?.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    response.headers
      ..set('Cache-Control', 'no-store')
      ..set('X-Content-Type-Options', 'nosniff')
      ..set('Cross-Origin-Resource-Policy', 'same-origin')
      ..set('Referrer-Policy', 'no-referrer')
      ..set(
        'Content-Security-Policy',
        "default-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; base-uri 'none'; frame-ancestors 'none'; form-action 'none'",
      );
    try {
      final host = request.headers.value(HttpHeaders.hostHeader);
      final hosts = {'127.0.0.1:$port', 'localhost:$port'};
      final origin = request.headers.value('Origin');
      if (!hosts.contains(host) ||
          (origin != null &&
              !hosts.map((value) => 'http://$value').contains(origin)) ||
          request.headers.value('Sec-Fetch-Site') == 'cross-site') {
        throw const ForkException(
          'Only this local workspace may read repository data',
          code: 403,
        );
      }
      if (request.method != 'GET') {
        response.headers.set('Allow', 'GET');
        throw const ForkException('This workspace is read-only', code: 405);
      }
      final path = request.uri.path;
      if (path.startsWith('/api/')) {
        if (request.headers.value('X-Atlas-Token') != token) {
          throw const ForkException(
            'Open the local workspace before requesting repository data',
            code: 403,
          );
        }
        if (request.uri.query.length > 4096) {
          reject('Request query exceeds the read limit');
        }
        final query = request.uri.queryParameters;
        final repositoryRoot = root;
        final data = await Isolate.run(
          () => AtlasRepository(repositoryRoot).dispatch(path, query),
        );
        response.headers.contentType = ContentType.json;
        response.write(jsonEncode(data));
      } else if (path == '/' || path == '/fork') {
        response.statusCode = HttpStatus.temporaryRedirect;
        response.headers.set(HttpHeaders.locationHeader, '/fork/');
      } else {
        final files = {
          '/fork/': ('index.html', ContentType.html),
          '/fork/assets/atlas.css': (
            'assets/atlas.css',
            ContentType('text', 'css', charset: 'utf-8'),
          ),
          '/fork/assets/atlas.mjs': (
            'assets/atlas.mjs',
            ContentType('text', 'javascript', charset: 'utf-8'),
          ),
          '/fork/assets/glyph.svg': (
            'assets/glyph.svg',
            ContentType('image', 'svg+xml'),
          ),
          '/fork/assets/model.mjs': (
            'assets/model.mjs',
            ContentType('text', 'javascript', charset: 'utf-8'),
          ),
          '/assets/style.css': (
            '../assets/style.css',
            ContentType('text', 'css', charset: 'utf-8'),
          ),
        };
        final entry = files[path];
        if (entry == null) {
          throw const ForkException('Page not found', code: 404);
        }
        final file = File(p.normalize(p.join(siteRoot, entry.$1)));
        rejectSymlinks(file.path);
        final content = await file.readAsString();
        response.headers.contentType = entry.$2;
        response.write(
          path == '/fork/'
              ? content.replaceAll('__ATLAS_TOKEN__', token)
              : content,
        );
      }
    } on ForkException catch (error) {
      response.statusCode = error.code >= 400 ? error.code : 400;
      response.headers.contentType = ContentType.json;
      response.write(jsonEncode({'error': error.message}));
    } on FileSystemException {
      response.statusCode = 404;
      response.headers.contentType = ContentType.json;
      response.write(
        jsonEncode({'error': 'A local file is missing or cannot be read'}),
      );
    } on FormatException catch (error) {
      response.statusCode = 400;
      response.headers.contentType = ContentType.json;
      response.write(jsonEncode({'error': error.message}));
    } catch (error) {
      response.statusCode = 500;
      response.headers.contentType = ContentType.json;
      response.write(
        jsonEncode({
          'error':
              'Repository read failed. Refresh after the current edit completes.',
          'detail': error.toString(),
        }),
      );
    } finally {
      await response.close();
    }
  }
}

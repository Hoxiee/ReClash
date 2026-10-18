import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reclash/common/constant.dart';
import 'package:reclash/common/request.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/state.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestUpdateSource implements AppUpdateSource {
  _TestUpdateSource(this.id, this.releases, {this.failure});

  @override
  final String id;
  final List<Map<String, dynamic>> releases;
  final Exception? failure;

  @override
  Future<List<Map<String, dynamic>>> fetchReleases({
    required UpdateChannel channel,
  }) async {
    if (failure case final error?) throw error;
    return releases;
  }

  @override
  Uri assetUri(String url) => Uri.parse(url);

  @override
  Uri releasePage(String tag) => Uri.https('updates.example', '/$tag');
}

class _StalledHttpClient extends Fake implements HttpClient {
  @override
  Duration? connectionTimeout;

  @override
  String Function(Uri url)? findProxy;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      Completer<HttpClientRequest>().future;
}

class _HostAdapter implements HttpClientAdapter {
  _HostAdapter(this.byHost);

  final Map<String, ResponseBody Function()> byHost;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return byHost[options.uri.host]!();
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getTextResponseForUrl propagates the typed DioException', () async {
    // flutter_test's mocked HttpClient answers every request with HTTP 400,
    // which Dio surfaces as a badResponse DioException.
    await expectLater(
      request.getTextResponseForUrl('http://127.0.0.1/anything'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });

  test('getFileResponseForUrl propagates the typed DioException', () async {
    await expectLater(
      request.getFileResponseForUrl('http://127.0.0.1/anything'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });

  group('checkForUpdate', () {
    setUp(() {
      globalState.packageInfo = PackageInfo(
        appName: 'ReClash',
        packageName: 'com.reclash',
        version: '0.1.0',
        buildNumber: '1',
      );
    });

    test(
      'returns null only after a source answers without a newer release',
      () async {
        final client = Request();
        client.updateSources
          ..clear()
          ..add(_TestUpdateSource('empty', const []));
        expect(
          await client.checkForUpdate(channel: UpdateChannel.release),
          isNull,
        );
      },
    );

    test(
      'falls through a failed source and retains the answering source',
      () async {
        final client = Request();
        client.updateSources
          ..clear()
          ..addAll([
            _TestUpdateSource(
              'offline',
              const [],
              failure: Exception('offline'),
            ),
            _TestUpdateSource('mirror', [
              {'tag_name': '0.2.0', 'body': 'notes'},
            ]),
          ]);
        final release = await client.checkForUpdate(
          channel: UpdateChannel.release,
        );
        expect(release?.tag, '0.2.0');
        expect(release?.source.id, 'mirror');
      },
    );

    test(
      'throws when every source fails instead of reporting no updates',
      () async {
        final client = Request();
        client.updateSources
          ..clear()
          ..add(
            _TestUpdateSource(
              'offline',
              const [],
              failure: Exception('offline'),
            ),
          );
        await expectLater(
          client.checkForUpdate(channel: UpdateChannel.release),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('downloadUpdateFile', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'reclash-update-download-',
      );
    });

    tearDown(() async {
      if (await directory.exists()) await directory.delete(recursive: true);
    });

    test('renames the completed temporary download into place', () async {
      final client = Request()
        ..updateDownloadAdapter = _HostAdapter({
          'updates.example': () => ResponseBody.fromString('apk-bytes', 200),
        });
      final target = '${directory.path}/update-v1.apk';
      final error = await client.downloadUpdateFile(
        Uri.https('updates.example', '/update.apk'),
        target,
        onProgress: (_, _) {},
        cancelToken: CancelToken(),
      );

      expect(error, isNull);
      expect(await File(target).readAsString(), 'apk-bytes');
      expect(await File('$target.tmp').exists(), isFalse);
    });

    test('removes a partial temporary file after a failed download', () async {
      final client = Request()
        ..updateDownloadAdapter = _HostAdapter({
          'updates.example': () => ResponseBody.fromString('error', 503),
        });
      final target = '${directory.path}/update-v1.apk';
      final error = await client.downloadUpdateFile(
        Uri.https('updates.example', '/update.apk'),
        target,
        onProgress: (_, _) {},
        cancelToken: CancelToken(),
      );

      expect(error, isNotNull);
      expect(await File(target).exists(), isFalse);
      expect(await File('$target.tmp').exists(), isFalse);
    });
  });

  group('latestRelease', () {
    Request requestAnswering(Map<String, ResponseBody Function()> byHost) {
      return Request()..dio.httpClientAdapter = _HostAdapter(byHost);
    }

    test('reads the release from the API', () async {
      final request = requestAnswering({
        'api.github.com': () => ResponseBody.fromString(
          '{"tag_name":"v1.2.3","body":"notes"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      });

      expect(await request.latestRelease(), {
        'tag_name': 'v1.2.3',
        'body': 'notes',
      });
    });

    test(
      'falls back to the release page when the API is rate limited',
      () async {
        final request = requestAnswering({
          'api.github.com': () => ResponseBody.fromString('{}', 403),
          'github.com': () => ResponseBody.fromString(
            '',
            302,
            headers: {
              HttpHeaders.locationHeader: [
                'https://github.com/owner/repo/releases/tag/v1.2.4',
              ],
            },
          ),
        });

        expect(await request.latestRelease(), {'tag_name': 'v1.2.4'});
      },
    );

    test('fails instead of answering when neither endpoint does', () async {
      final request = requestAnswering({
        'api.github.com': () => ResponseBody.fromString('{}', 403),
        'github.com': () => ResponseBody.fromString('', 503),
      });

      await expectLater(request.latestRelease(), throwsA(isA<DioException>()));
    });
  });

  group('downloadTarget', () {
    test('sends a URL without credentials unchanged', () {
      final target = downloadTarget('https://example.com/a.yaml?x=1');

      expect(target.uri.toString(), 'https://example.com/a.yaml?x=1');
      expect(target.headers, isEmpty);
    });

    test('moves decoded credentials into the Authorization header', () {
      for (final url in [
        'https://me@mail.com:p:w@dav.example.com/dav/a.yaml',
        'https://me%40mail.com:p%3Aw@dav.example.com/dav/a.yaml',
      ]) {
        final target = downloadTarget(url);

        expect(target.uri.toString(), 'https://dav.example.com/dav/a.yaml');
        expect(
          target.headers[HttpHeaders.authorizationHeader],
          'Basic ${base64.encode(utf8.encode('me@mail.com:p:w'))}',
        );
      }
    });
  });

  group('decompressUnlabeled', () {
    final yaml = utf8.encode('proxies: []\n');

    test('inflates a gzip or zlib body that arrived unlabeled', () {
      for (final codec in [gzip, zlib]) {
        final body = Uint8List.fromList(codec.encode(yaml));

        expect(decompressUnlabeled(body), yaml);
      }
    });

    test('leaves a plain body untouched', () {
      final body = Uint8List.fromList(yaml);

      expect(decompressUnlabeled(body), same(body));
    });

    test('keeps a body that only starts like gzip', () {
      final body = Uint8List.fromList([0x1f, 0x8b, 1, 2, 3]);

      expect(decompressUnlabeled(body), same(body));
    });
  });

  testWidgets('a stalled download fails at the shared download deadline', (
    tester,
  ) async {
    late final Future<Response<String>> pending;
    HttpOverrides.runZoned(() {
      pending = Request().getTextResponseForUrl('http://127.0.0.1/stalled');
    }, createHttpClient: (_) => _StalledHttpClient());
    var settled = false;
    final outcome = expectLater(
      pending.whenComplete(() => settled = true),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.receiveTimeout,
        ),
      ),
    );

    await tester.pump(downloadTimeoutDuration - const Duration(seconds: 1));
    expect(settled, isFalse);
    await tester.pump(const Duration(seconds: 1));
    await outcome;
  });
}

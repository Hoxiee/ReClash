import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:reclash/common/constant.dart';
import 'package:reclash/common/app_update.dart';
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

class _UpdateAdapter implements HttpClientAdapter {
  _UpdateAdapter(this.respond);

  final FutureOr<ResponseBody> Function(RequestOptions options) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

String _updateDigest(String value) =>
    sha256.convert(utf8.encode(value)).toString();

ResponseBody _updateResponse(
  String value, {
  int status = HttpStatus.ok,
  String? range,
  String? etag,
  String? modified,
}) => ResponseBody.fromString(
  value,
  status,
  headers: {
    HttpHeaders.contentLengthHeader: ['${utf8.encode(value).length}'],
    if (range != null) HttpHeaders.contentRangeHeader: [range],
    if (etag != null) HttpHeaders.etagHeader: [etag],
    if (modified != null) HttpHeaders.lastModifiedHeader: [modified],
  },
);

Future<void> _savePartial(
  String target, {
  required String contents,
  String complete = 'apk-bytes',
  String url = 'https://updates.example/update.apk',
  String? etag = '"apk-1"',
  String? modified,
}) async {
  await File('$target.tmp').writeAsString(contents);
  await File('$target.tmp.json').writeAsString(
    jsonEncode({
      'schemaVersion': 1,
      'url': url,
      'sha256': _updateDigest(complete),
      'size': utf8.encode(complete).length,
      'total': utf8.encode(complete).length,
      'etag': etag,
      'lastModified': modified,
    }),
  );
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

    test('creates the destination directory without resume opt-in', () async {
      final target = '${directory.path}/new/cache/update-v1.apk';
      final client = Request()
        ..updateDownloadAdapter = _UpdateAdapter(
          (_) => _updateResponse('apk-bytes'),
        );
      expect(
        await client.downloadUpdateFile(
          Uri.https('updates.example', '/update.apk'),
          target,
          onProgress: (_, _) {},
          cancelToken: CancelToken(),
        ),
        isNull,
      );
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

    test('resumes a pinned partial with Range and a strong If-Range', () async {
      final target = '${directory.path}/update-v1.apk';
      await _savePartial(target, contents: 'apk-');
      final adapter = _UpdateAdapter(
        (_) => _updateResponse(
          'bytes',
          status: HttpStatus.partialContent,
          range: 'bytes 4-8/9',
          etag: '"apk-1"',
        ),
      );
      final client = Request()..updateDownloadAdapter = adapter;
      final progress = <(int, int)>[];
      final error = await client.downloadUpdateFile(
        Uri.https('updates.example', '/update.apk'),
        target,
        onProgress: (received, total) => progress.add((received, total)),
        cancelToken: CancelToken(),
        resume: true,
        expectedSha256: _updateDigest('apk-bytes'),
        expectedSize: 9,
      );

      expect(error, isNull);
      expect(
        adapter.requests.single.headers[HttpHeaders.rangeHeader],
        'bytes=4-',
      );
      expect(
        adapter.requests.single.headers[HttpHeaders.ifRangeHeader],
        '"apk-1"',
      );
      expect(progress.first, (4, 9));
      expect(progress.last, (9, 9));
      expect(await File(target).readAsString(), 'apk-bytes');
      expect(await File('$target.tmp').exists(), isFalse);
      expect(await File('$target.tmp.json').exists(), isFalse);
    });

    test('uses Last-Modified when no strong ETag was recorded', () async {
      final target = '${directory.path}/update-v1.apk';
      const modified = 'Wed, 21 Oct 2015 07:28:00 GMT';
      await _savePartial(
        target,
        contents: 'apk-',
        etag: null,
        modified: modified,
      );
      final adapter = _UpdateAdapter(
        (_) => _updateResponse(
          'bytes',
          status: HttpStatus.partialContent,
          range: 'bytes 4-8/9',
          modified: modified,
        ),
      );
      final client = Request()..updateDownloadAdapter = adapter;
      expect(
        await client.downloadUpdateFile(
          Uri.https('updates.example', '/update.apk'),
          target,
          onProgress: (_, _) {},
          cancelToken: CancelToken(),
          resume: true,
          expectedSha256: _updateDigest('apk-bytes'),
          expectedSize: 9,
        ),
        isNull,
      );
      expect(
        adapter.requests.single.headers[HttpHeaders.ifRangeHeader],
        modified,
      );
    });

    test(
      'flushes a paused partial and resumes it without redownloading',
      () async {
        final target = '${directory.path}/update-v1.apk';
        final source = StreamController<Uint8List>();
        addTearDown(source.close);
        final adapter = _UpdateAdapter(
          (_) => ResponseBody(
            source.stream,
            HttpStatus.ok,
            headers: {
              HttpHeaders.contentLengthHeader: ['9'],
              HttpHeaders.etagHeader: ['"apk-1"'],
            },
          ),
        );
        final client = Request()..updateDownloadAdapter = adapter;
        final cancellation = CancelToken();
        final receiving = Completer<void>();
        final transfer = client.downloadUpdateFile(
          Uri.https('updates.example', '/update.apk'),
          target,
          onProgress: (received, total) {
            if (received == 0) {
              source.add(Uint8List.fromList(utf8.encode('apk-')));
            }
            if (received == 4 && !receiving.isCompleted) receiving.complete();
          },
          cancelToken: cancellation,
          resume: true,
          expectedSha256: _updateDigest('apk-bytes'),
          expectedSize: 9,
        );
        await receiving.future;
        cancellation.cancel();
        expect(await transfer, '');
        expect(await File('$target.tmp').readAsString(), 'apk-');
        expect(await File('$target.tmp.json').exists(), isTrue);
        expect(await File(target).exists(), isFalse);

        client.updateDownloadAdapter = _UpdateAdapter(
          (_) => _updateResponse(
            'bytes',
            status: HttpStatus.partialContent,
            range: 'bytes 4-8/9',
            etag: '"apk-1"',
          ),
        );
        expect(
          await client.downloadUpdateFile(
            Uri.https('updates.example', '/update.apk'),
            target,
            onProgress: (_, _) {},
            cancelToken: CancelToken(),
            resume: true,
            expectedSha256: _updateDigest('apk-bytes'),
            expectedSize: 9,
          ),
          isNull,
        );
        expect(await File(target).readAsString(), 'apk-bytes');
      },
    );

    test('does not retain a cancelled partial without resume opt-in', () async {
      final target = '${directory.path}/update-v1.apk';
      final source = StreamController<Uint8List>();
      addTearDown(source.close);
      final client = Request()
        ..updateDownloadAdapter = _UpdateAdapter(
          (_) => ResponseBody(
            source.stream,
            HttpStatus.ok,
            headers: {
              HttpHeaders.contentLengthHeader: ['9'],
            },
          ),
        );
      final cancellation = CancelToken();
      final receiving = Completer<void>();
      final transfer = client.downloadUpdateFile(
        Uri.https('updates.example', '/update.apk'),
        target,
        onProgress: (received, total) {
          if (received == 0) {
            source.add(Uint8List.fromList(utf8.encode('apk-')));
          }
          if (received == 4 && !receiving.isCompleted) receiving.complete();
        },
        cancelToken: cancellation,
      );
      await receiving.future;
      cancellation.cancel();
      expect(await transfer, '');
      expect(await File('$target.tmp').exists(), isFalse);
      expect(await File('$target.tmp.json').exists(), isFalse);
      expect(await File(target).exists(), isFalse);
    });

    for (final identity in ['url', 'sha256', 'size']) {
      test('starts over when the saved asset $identity changed', () async {
        final target = '${directory.path}/update-v1.apk';
        await _savePartial(target, contents: 'apk-');
        final metadata = File('$target.tmp.json');
        final saved =
            jsonDecode(await metadata.readAsString()) as Map<String, dynamic>;
        saved[identity] = switch (identity) {
          'url' => 'https://updates.example/another.apk',
          'sha256' => '0' * 64,
          _ => 10,
        };
        await metadata.writeAsString(jsonEncode(saved));
        final adapter = _UpdateAdapter((_) => _updateResponse('apk-bytes'));
        final client = Request()..updateDownloadAdapter = adapter;
        expect(
          await client.downloadUpdateFile(
            Uri.https('updates.example', '/update.apk'),
            target,
            onProgress: (_, _) {},
            cancelToken: CancelToken(),
            resume: true,
            expectedSha256: _updateDigest('apk-bytes'),
            expectedSize: 9,
          ),
          isNull,
        );
        expect(
          adapter.requests.single.headers.containsKey(HttpHeaders.rangeHeader),
          isFalse,
        );
        expect(await File(target).readAsString(), 'apk-bytes');
      });
    }

    test(
      'restarts instead of appending when the server ignores Range',
      () async {
        final target = '${directory.path}/update-v1.apk';
        await _savePartial(target, contents: 'apk-');
        final adapter = _UpdateAdapter((_) => _updateResponse('apk-bytes'));
        final client = Request()..updateDownloadAdapter = adapter;
        expect(
          await client.downloadUpdateFile(
            Uri.https('updates.example', '/update.apk'),
            target,
            onProgress: (_, _) {},
            cancelToken: CancelToken(),
            resume: true,
            expectedSha256: _updateDigest('apk-bytes'),
            expectedSize: 9,
          ),
          isNull,
        );
        expect(await File(target).readAsString(), 'apk-bytes');
      },
    );

    for (final range in [
      'bytes 0-4/9',
      'bytes 4-9/9',
      'bytes 4-8/*',
      'bytes 4-7/9',
      'invalid',
    ]) {
      test('rejects an incompatible Content-Range $range', () async {
        final target = '${directory.path}/update-v1.apk';
        await _savePartial(target, contents: 'apk-');
        final client = Request()
          ..updateDownloadAdapter = _UpdateAdapter(
            (_) => _updateResponse(
              'bytes',
              status: HttpStatus.partialContent,
              range: range,
            ),
          );
        await expectLater(
          client.downloadUpdateFile(
            Uri.https('updates.example', '/update.apk'),
            target,
            onProgress: (_, _) {},
            cancelToken: CancelToken(),
            resume: true,
            expectedSha256: _updateDigest('apk-bytes'),
            expectedSize: 9,
          ),
          throwsA(isA<UpdateDownloadVerificationException>()),
        );
        expect(await File(target).exists(), isFalse);
        expect(await File('$target.tmp').exists(), isFalse);
        expect(await File('$target.tmp.json').exists(), isFalse);
      });
    }

    test('rejects a changed validator on a partial response', () async {
      final target = '${directory.path}/update-v1.apk';
      await _savePartial(target, contents: 'apk-');
      final client = Request()
        ..updateDownloadAdapter = _UpdateAdapter(
          (_) => _updateResponse(
            'bytes',
            status: HttpStatus.partialContent,
            range: 'bytes 4-8/9',
            etag: '"apk-2"',
          ),
        );
      await expectLater(
        client.downloadUpdateFile(
          Uri.https('updates.example', '/update.apk'),
          target,
          onProgress: (_, _) {},
          cancelToken: CancelToken(),
          resume: true,
          expectedSha256: _updateDigest('apk-bytes'),
          expectedSize: 9,
        ),
        throwsA(isA<UpdateDownloadVerificationException>()),
      );
      expect(await File('$target.tmp').exists(), isFalse);
    });

    test(
      'accepts 416 only for a complete pinned file with matching digest',
      () async {
        final target = '${directory.path}/update-v1.apk';
        await _savePartial(target, contents: 'apk-bytes');
        final client = Request()
          ..updateDownloadAdapter = _UpdateAdapter(
            (_) => _updateResponse(
              '',
              status: HttpStatus.requestedRangeNotSatisfiable,
              range: 'bytes */9',
            ),
          );
        expect(
          await client.downloadUpdateFile(
            Uri.https('updates.example', '/update.apk'),
            target,
            onProgress: (_, _) {},
            cancelToken: CancelToken(),
            resume: true,
            expectedSha256: _updateDigest('apk-bytes'),
            expectedSize: 9,
          ),
          isNull,
        );
        expect(await File(target).readAsString(), 'apk-bytes');
      },
    );

    test('retries one rejected range without offset', () async {
      final target = '${directory.path}/update-v1.apk';
      await _savePartial(target, contents: 'apk-');
      final adapter = _UpdateAdapter(
        (options) => options.headers.containsKey(HttpHeaders.rangeHeader)
            ? _updateResponse(
                '',
                status: HttpStatus.requestedRangeNotSatisfiable,
                range: 'bytes */9',
              )
            : _updateResponse('apk-bytes'),
      );
      final client = Request()..updateDownloadAdapter = adapter;
      expect(
        await client.downloadUpdateFile(
          Uri.https('updates.example', '/update.apk'),
          target,
          onProgress: (_, _) {},
          cancelToken: CancelToken(),
          resume: true,
          expectedSha256: _updateDigest('apk-bytes'),
          expectedSize: 9,
        ),
        isNull,
      );
      expect(adapter.requests, hasLength(2));
      expect(
        adapter.requests.last.headers.containsKey(HttpHeaders.rangeHeader),
        isFalse,
      );
    });

    test('does not loop forever when the server always answers 416', () async {
      final target = '${directory.path}/update-v1.apk';
      await _savePartial(target, contents: 'apk-');
      final adapter = _UpdateAdapter(
        (_) => _updateResponse(
          '',
          status: HttpStatus.requestedRangeNotSatisfiable,
          range: 'bytes */9',
        ),
      );
      final client = Request()..updateDownloadAdapter = adapter;
      await expectLater(
        client.downloadUpdateFile(
          Uri.https('updates.example', '/update.apk'),
          target,
          onProgress: (_, _) {},
          cancelToken: CancelToken(),
          resume: true,
          expectedSha256: _updateDigest('apk-bytes'),
          expectedSize: 9,
        ),
        throwsA(isA<UpdateDownloadVerificationException>()),
      );
      expect(adapter.requests, hasLength(2));
      expect(await File(target).exists(), isFalse);
    });

    test(
      'never publishes a digest mismatch over an existing complete target',
      () async {
        final target = '${directory.path}/update-v1.apk';
        await File(target).writeAsString('previous');
        final client = Request()
          ..updateDownloadAdapter = _UpdateAdapter(
            (_) => _updateResponse('bad-bytes'),
          );
        await expectLater(
          client.downloadUpdateFile(
            Uri.https('updates.example', '/update.apk'),
            target,
            onProgress: (_, _) {},
            cancelToken: CancelToken(),
            resume: true,
            expectedSha256: _updateDigest('apk-bytes'),
            expectedSize: 9,
          ),
          throwsA(isA<UpdateDownloadVerificationException>()),
        );
        expect(await File(target).readAsString(), 'previous');
        expect(await File('$target.tmp').exists(), isFalse);
        expect(await File('$target.tmp.json').exists(), isFalse);
      },
    );

    test('keeps a truncated resumable body but never publishes it', () async {
      final target = '${directory.path}/update-v1.apk';
      final client = Request()
        ..updateDownloadAdapter = _UpdateAdapter(
          (_) => ResponseBody.fromString(
            'apk-',
            HttpStatus.ok,
            headers: {
              HttpHeaders.contentLengthHeader: ['9'],
            },
          ),
        );
      expect(
        await client.downloadUpdateFile(
          Uri.https('updates.example', '/update.apk'),
          target,
          onProgress: (_, _) {},
          cancelToken: CancelToken(),
          resume: true,
          expectedSha256: _updateDigest('apk-bytes'),
          expectedSize: 9,
        ),
        isNotNull,
      );
      expect(await File('$target.tmp').readAsString(), 'apk-');
      expect(await File(target).exists(), isFalse);
    });

    test(
      'rejects concurrent writers to the same target across clients',
      () async {
        final target = '${directory.path}/update-v1.apk';
        final source = StreamController<Uint8List>();
        addTearDown(source.close);
        final client = Request()
          ..updateDownloadAdapter = _UpdateAdapter(
            (_) => ResponseBody(
              source.stream,
              HttpStatus.ok,
              headers: {
                HttpHeaders.contentLengthHeader: ['9'],
              },
            ),
          );
        final ready = Completer<void>();
        final cancellation = CancelToken();
        final transfer = client.downloadUpdateFile(
          Uri.https('updates.example', '/update.apk'),
          target,
          onProgress: (received, total) {
            if (!ready.isCompleted) ready.complete();
          },
          cancelToken: cancellation,
          resume: true,
          expectedSha256: _updateDigest('apk-bytes'),
          expectedSize: 9,
        );
        await ready.future;
        final other = Request()
          ..updateDownloadAdapter = _UpdateAdapter(
            (_) => _updateResponse('apk-bytes'),
          );
        expect(
          await other.downloadUpdateFile(
            Uri.https('updates.example', '/update.apk'),
            target,
            onProgress: (_, _) {},
            cancelToken: CancelToken(),
            resume: true,
            expectedSha256: _updateDigest('apk-bytes'),
            expectedSize: 9,
          ),
          contains('already in progress'),
        );
        cancellation.cancel();
        expect(await transfer, '');
      },
    );
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

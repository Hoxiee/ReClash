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
import 'package:reclash/common/update_manifest.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/state.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

class _Exchange {
  _Exchange(this.uri, this.headers);

  final Uri uri;
  final Map<String, String> headers;
}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.respond);

  final ResponseBody Function(_Exchange exchange) respond;
  final requests = <_Exchange>[];

  int count(String fragment) =>
      requests.where((request) => '${request.uri}'.contains(fragment)).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final exchange = _Exchange(options.uri, {
      for (final entry in options.headers.entries)
        entry.key.toLowerCase(): '${entry.value}',
    });
    requests.add(exchange);
    return respond(exchange);
  }

  @override
  void close({bool force = false}) {}
}

const _latestUrl = 'https://api.github.com/repos/$repository/releases/latest';
const _listUrl = 'https://api.github.com/repos/$repository/releases';

String _releaseJson(String tag) => jsonEncode({
  'tag_name': tag,
  'prerelease': false,
  'body': 'n',
  'assets': [],
});

ResponseBody _json(String body, {int status = 200, String? etag}) =>
    ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'etag': ?etag == null ? null : [etag],
      },
    );

class _TestUpdateSource implements AppUpdateSource {
  _TestUpdateSource(this.id, this.releases, {this.failure});

  @override
  final String id;
  final List<Map<String, dynamic>> releases;
  final Exception? failure;

  @override
  Future<List<Map<String, dynamic>>> fetchReleases({
    required UpdateChannel channel,
    required String installedVersion,
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
  bool Function(X509Certificate cert, String host, int port)?
  badCertificateCallback;

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

  group('checkForUpdate against the GitHub API', () {
    late Request client;

    setUp(() {
      globalState.packageInfo = PackageInfo(
        appName: 'ReClash',
        packageName: 'com.reclash',
        version: '0.1.0',
        buildNumber: '1',
      );
      client = Request();
    });

    _ScriptedAdapter serve(ResponseBody Function(_Exchange exchange) respond) {
      final adapter = _ScriptedAdapter(respond);
      client.updateDio.httpClientAdapter = adapter;
      return adapter;
    }

    ResponseBody history(_Exchange exchange) {
      final uri = '${exchange.uri}';
      if (uri == _latestUrl) return _json(_releaseJson('v0.3.0'));
      return _json(
        jsonEncode([
          for (final tag in ['v0.3.0', 'v0.2.0', 'v0.1.0'])
            jsonDecode(_releaseJson(tag)),
        ]),
      );
    }

    test('a probe no newer than the install never reads the list', () async {
      final adapter = serve((_) => _json(_releaseJson('v0.1.0')));
      expect(
        await client.checkForUpdate(channel: UpdateChannel.release),
        isNull,
      );
      expect(adapter.requests.map((request) => '${request.uri}'), [_latestUrl]);
    });

    test('a newer probe reads the list once per newest tag', () async {
      final adapter = serve(history);
      final first = await client.checkForUpdate(channel: UpdateChannel.release);
      final second = await client.checkForUpdate(
        channel: UpdateChannel.release,
      );
      expect(first?.tag, 'v0.3.0');
      expect(first?.skipped.map((release) => release.tag), ['v0.2.0']);
      expect(second?.tag, 'v0.3.0');
      expect(second?.skipped.map((release) => release.tag), ['v0.2.0']);
      expect(adapter.count('per_page=30'), 1);
      expect(adapter.requests, hasLength(3));
    });

    test('a validator is sent back and a 304 reuses the answer', () async {
      final adapter = serve((exchange) {
        if (exchange.headers['if-none-match'] == 'abc') {
          return _json('', status: 304);
        }
        if (exchange.uri.toString() == _latestUrl) {
          return _json(_releaseJson('v0.3.0'), etag: 'abc');
        }
        return history(exchange);
      });
      final first = await client.checkForUpdate(channel: UpdateChannel.release);
      final second = await client.checkForUpdate(
        channel: UpdateChannel.release,
      );
      final probes = adapter.requests
          .where((request) => '${request.uri}' == _latestUrl)
          .toList();
      expect(probes.first.headers, isNot(contains('if-none-match')));
      expect(probes.last.headers['if-none-match'], 'abc');
      expect(second?.tag, first?.tag);
      expect(second?.skipped, hasLength(first!.skipped.length));
    });

    test('a missing latest release is no update, not an error', () async {
      serve((_) => _json('{}', status: 404));
      expect(
        await client.checkForUpdate(channel: UpdateChannel.release),
        isNull,
      );
    });

    test('the pre channel probes the newest single release', () async {
      final adapter = serve(
        (_) => _json(jsonEncode([jsonDecode(_releaseJson('v0.1.0'))])),
      );
      expect(await client.checkForUpdate(channel: UpdateChannel.pre), isNull);
      expect(adapter.requests.map((request) => '${request.uri}'), [
        '$_listUrl?per_page=1',
      ]);
    });

    test('a failing preferred mirror falls back to GitHub', () async {
      final adapter = serve((exchange) {
        if (exchange.uri.host == 'mirror.example') return _json('not json');
        return history(exchange);
      });
      final release = await client.checkForUpdate(
        channel: UpdateChannel.release,
        mirror: Uri.parse('https://mirror.example/update-manifest.json'),
        preferMirror: true,
      );
      expect(release?.tag, 'v0.3.0');
      expect(release?.source.id, 'github');
      expect(adapter.requests.first.uri.host, 'mirror.example');
    });

    test('a preferred mirror without a newer release is final', () async {
      client = Request(mirrorUrls: 'https://cdn.example');
      final adapter = serve((exchange) {
        if (exchange.uri.host == 'mirror.example') {
          return _json('{"releases": []}');
        }
        return history(exchange);
      });
      final release = await client.checkForUpdate(
        channel: UpdateChannel.release,
        mirror: Uri.parse('https://mirror.example/update-manifest.json'),
        preferMirror: true,
      );
      expect(release, isNull);
      expect(adapter.requests.map((request) => request.uri.host), [
        'mirror.example',
      ]);
    });

    test('a mirror without opt-in does not mask an official release', () async {
      final adapter = serve((exchange) {
        if (exchange.uri.host == 'mirror.example') {
          return _json('{"releases": []}');
        }
        return history(exchange);
      });
      final release = await client.checkForUpdate(
        channel: UpdateChannel.release,
        mirror: Uri.parse('https://mirror.example/update-manifest.json'),
      );
      expect(release?.tag, 'v0.3.0');
      expect(release?.source.id, 'github');
      expect(adapter.count('mirror.example'), 0);
    });

    test(
      'a mirror without opt-in is a fallback for the official sources',
      () async {
        client = Request(mirrorUrls: 'https://cdn.example');
        final adapter = serve(
          (exchange) => exchange.uri.host == 'mirror.example'
              ? _json('{"releases": []}')
              : _json('unavailable', status: 503),
        );
        expect(
          await client.checkForUpdate(
            channel: UpdateChannel.pre,
            mirror: Uri.parse('https://mirror.example/update-manifest.json'),
          ),
          isNull,
        );
        expect(adapter.requests.map((request) => request.uri.host), [
          'cdn.example',
          'api.github.com',
          'mirror.example',
        ]);
      },
    );

    test('updateSource resolves the mirror and GitHub, nothing else', () {
      expect(client.updateSource('mirror')?.id, 'mirror');
      expect(client.updateSource('github')?.id, 'github');
      expect(client.updateSource('unknown'), isNull);
    });

    test('the signed catalog offers updates without querying GitHub', () async {
      const mirror = 'https://cdn.example/update/';
      const tag = 'v0.2.0';
      const name = 'ReClash-0.2.0-android-arm64-v8a.apk';
      const notes = 'Release notes';
      final seed = List<int>.filled(32, 1);
      final digest = _updateDigest('package');
      final signature = await signUpdateManifestMessage(
        updateManifestMessage(
          tag: tag,
          prerelease: false,
          notes: notes,
          assets: [(name: name, size: 7, sha256: digest)],
        ),
        seed,
      );
      client = Request(mirrorUrls: mirror);
      client.updateSources[0] = OfficialUpdateSource(
        client.updateDio,
        Uri.parse(mirror),
        UpdateResponseCache(),
        keys: [await updateManifestPublicKey(seed)],
      );
      final adapter = serve((exchange) {
        expect(exchange.uri.toString(), '$mirror$updateManifestFileName');
        if (exchange.headers['if-none-match'] == 'abc') {
          return _json('', status: 304);
        }
        return _json(
          jsonEncode({
            'releases': [
              {
                'tag': tag,
                'prerelease': false,
                'notes': notes,
                'published_at': '2026-11-23T12:00:00Z',
                'assets': [
                  {
                    'name': name,
                    'size': 7,
                    'sha256': digest,
                    'url': 'https://arbitrary.example/package.apk',
                  },
                ],
                'signature': signature,
              },
            ],
          }),
          etag: 'abc',
        );
      });

      expect(client.updateCheckInterval, const Duration(minutes: 15));
      final release = await client.checkForUpdate(
        channel: UpdateChannel.release,
      );
      expect(release?.source.id, officialUpdateSourceId);
      expect(release?.tag, tag);
      expect(release?.data['published_at'], '2026-11-23T12:00:00Z');
      expect(
        release!.assets.single['browser_download_url'],
        'https://github.com/$repository/releases/download/$tag/$name',
      );
      expect(
        (await client.checkForUpdate(channel: UpdateChannel.release))?.tag,
        tag,
      );
      expect(adapter.requests.last.headers['if-none-match'], 'abc');
      expect(adapter.requests, hasLength(2));
    });

    test(
      'catalog failures keep trying mirrors and reuse the GitHub fallback',
      () async {
        client = Request(
          mirrorUrls: 'https://cdn.example, https://other.example',
        );
        final adapter = serve(
          (exchange) => switch (exchange.uri.host) {
            'cdn.example' => _json('unavailable', status: 503),
            'other.example' => _json('{"releases": []}'),
            _ => _json(_releaseJson('v0.1.0')),
          },
        );

        for (var attempt = 0; attempt < 2; attempt++) {
          expect(
            await client.checkForUpdate(channel: UpdateChannel.release),
            isNull,
          );
        }
        expect(adapter.count('cdn.example'), 2);
        expect(adapter.count('other.example'), 2);
        expect(adapter.count(_latestUrl), 1);
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

    for (final corrupt in [false, true]) {
      test(
        corrupt
            ? 'a corrupt partial from a mirror is recovered from scratch'
            : 'a faster mirror is tried first and GitHub resumes its failed download',
        () async {
          const complete = 'apk-bytes';
          final head = corrupt ? 'bad-' : 'apk-';
          final digest = _updateDigest(complete);
          final origin = Uri.parse(
            'https://github.com/$repository/releases/download/v1.0.0/app.apk',
          );
          final adapter = _UpdateAdapter((options) async {
            final range = options.headers[HttpHeaders.rangeHeader];
            final mirror = options.uri.host == 'cdn.example';
            if (range == 'bytes=0-8') {
              if (!mirror) {
                await Future<void>.delayed(const Duration(milliseconds: 30));
              }
              return _updateResponse(
                complete,
                status: 206,
                range: 'bytes 0-8/9',
              );
            }
            if (mirror) {
              expect(options.uri.path, '/releases/v1.0.0/$digest/app.apk');
              expect(range, isNull);
              return ResponseBody.fromString(
                head,
                200,
                headers: {
                  HttpHeaders.contentLengthHeader: ['9'],
                  HttpHeaders.etagHeader: ['"mirror-etag"'],
                },
              );
            }
            if (range == null) {
              expect(corrupt, isTrue);
              return _updateResponse(complete);
            }
            expect(range, 'bytes=4-');
            expect(options.headers[HttpHeaders.ifRangeHeader], isNull);
            return _updateResponse('bytes', status: 206, range: 'bytes 4-8/9');
          });
          final client = Request(mirrorUrls: 'https://cdn.example')
            ..updateDownloadAdapter = adapter;
          final target = '${directory.path}/update-v1.apk';

          final error = await client.downloadUpdateFile(
            origin,
            target,
            onProgress: (_, _) {},
            cancelToken: CancelToken(),
            resume: true,
            useMirrors: true,
            expectedSha256: digest,
            expectedSize: complete.length,
          );
          expect(error, isNull);
          expect(await File(target).readAsString(), complete);
          expect(adapter.requests.skip(2).map((request) => request.uri.host), [
            'cdn.example',
            'github.com',
            if (corrupt) 'github.com',
          ]);
        },
      );
    }

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

  group('GitHub release links', () {
    for (final tag in [
      'v1.2.3',
      'v1.2.3+build.7',
      'release/v1.2.3',
      'v1%test',
    ]) {
      test('encodes the release tag exactly once: $tag', () {
        final uri = GitHubUpdateSource(Dio()).releasePage(tag);

        expect(uri.scheme, 'https');
        expect(uri.host, 'github.com');
        expect(uri.pathSegments, [
          ...repository.split('/'),
          'releases',
          'tag',
          tag,
        ]);
      });
    }
  });

  group('GitHubUpdateSource.releasePage', () {
    for (final tag in [
      'v1.2.3',
      'v1.2.3+build.7',
      'release/v1.2.3',
      'v1.2.3%patched',
    ]) {
      test('encodes $tag once as one path segment', () {
        final uri = GitHubUpdateSource(Dio()).releasePage(tag);

        expect(uri.scheme, 'https');
        expect(uri.host, 'github.com');
        expect(uri.pathSegments, [
          ...repository.split('/'),
          'releases',
          'tag',
          tag,
        ]);
        expect(uri.hasQuery, isFalse);
        expect(uri.hasFragment, isFalse);
      });
    }
  });

  group('latestRelease', () {
    Request requestAnswering(Map<String, ResponseBody Function()> byHost) {
      return Request()..updateDio.httpClientAdapter = _HostAdapter(byHost);
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

    test('encodes an omitted password as an empty Basic password', () {
      for (final userInfo in ['alice', 'alice:']) {
        final target = downloadTarget(
          'https://$userInfo@dav.example.com/dav/a.yaml',
        );

        expect(target.uri.toString(), 'https://dav.example.com/dav/a.yaml');
        expect(
          target.headers[HttpHeaders.authorizationHeader],
          'Basic ${base64.encode(utf8.encode('alice:'))}',
        );
      }
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

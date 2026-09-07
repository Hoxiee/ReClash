import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reclash/common/request.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test(
    'checkIp tries sources sequentially and stops at first success',
    () async {
      final client = Request();
      final adapter = _SequentialIpAdapter();
      client.dio.httpClientAdapter = adapter;

      final result = await client.checkIp();

      expect(result.data?.ip, '2.2.2.2');
      expect(adapter.paths, ['', '']);
      expect(adapter.hosts, ['ipwho.is', 'api.myip.com']);
      expect(adapter.maxActive, 1);
    },
  );

  test('checkIp cancellation does not start the next source', () async {
    final client = Request();
    final adapter = _CancelIpAdapter();
    client.dio.httpClientAdapter = adapter;
    final token = CancelToken();

    final pending = client.checkIp(cancelToken: token);
    await adapter.started.future;
    token.cancel();
    final result = await pending;

    expect(result.data, isNull);
    expect(result.message, 'cancelled');
    expect(adapter.requestCount, 1);
  });
}

class _SequentialIpAdapter implements HttpClientAdapter {
  final List<String> paths = [];
  final List<String> hosts = [];
  int _active = 0;
  int maxActive = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.uri.path);
    hosts.add(options.uri.host);
    _active++;
    if (_active > maxActive) maxActive = _active;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (options.uri.host == 'ipwho.is') {
        return ResponseBody.fromString('unavailable', 503);
      }
      return ResponseBody.fromString(
        jsonEncode({'ip': '2.2.2.2', 'cc': 'US'}),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    } finally {
      _active--;
    }
  }

  @override
  void close({bool force = false}) {}
}

class _CancelIpAdapter implements HttpClientAdapter {
  final started = Completer<void>();
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    if (!started.isCompleted) started.complete();
    await cancelFuture;
    throw DioException(requestOptions: options, type: DioExceptionType.cancel);
  }

  @override
  void close({bool force = false}) {}
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reclash/common/net/request.dart';
import 'package:reclash/common/util/exception.dart';
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

  test('subscription client has bounded connection and response waits', () {
    final client = Request();

    expect(client.subscriptionTimeouts, (
      connect: subscriptionConnectTimeout,
      receive: subscriptionReceiveTimeout,
    ));
  });

  test(
    'subscription client follows safe redirects without leaking identity',
    () async {
      final client = Request();
      final adapter = _SubscriptionRedirectAdapter();
      client.subscriptionAdapter = adapter;

      final response = await client.getFileResponseForUrl(
        'https://primary.test/sub?token=secret',
        headers: {
          'User-Agent': 'INCY/3.3.1/Android',
          'x-client': 'INCY',
          'x-hwid': 'secret-hwid',
          'Accept-Language': 'ru-RU',
        },
      );

      expect(utf8.decode(response.data!), 'proxies: []');
      expect(response.realUri, Uri.parse('https://cdn.test/sub'));
      expect(
        adapter.requests[0].headers,
        containsPair('x-hwid', 'secret-hwid'),
      );
      expect(adapter.requests[1].headers, isNot(contains('x-hwid')));
      expect(adapter.requests[1].headers, isNot(contains('User-Agent')));
      expect(
        adapter.requests[1].headers,
        containsPair('Accept-Language', 'ru-RU'),
      );
    },
  );

  test('subscription client rejects HTTPS downgrade redirects', () async {
    final client = Request();
    client.subscriptionAdapter = _DowngradeRedirectAdapter();

    await expectLater(
      client.getFileResponseForUrl('https://primary.test/sub'),
      throwsA(
        isA<MessageException>().having(
          (error) => error.message,
          'message',
          'unsafe subscription redirect',
        ),
      ),
    );
  });

  test('subscription client rejects redirect without location', () async {
    final client = Request();
    client.subscriptionAdapter = _MissingLocationRedirectAdapter();

    await expectLater(
      client.getFileResponseForUrl('https://primary.test/sub'),
      throwsA(
        isA<MessageException>().having(
          (error) => error.message,
          'message',
          'subscription redirect has no location',
        ),
      ),
    );
  });

  test('subscription client rejects oversized response bodies', () async {
    final client = Request();
    final adapter = _LargeSubscriptionAdapter();
    client.subscriptionAdapter = adapter;

    await expectLater(
      client.getFileResponseForUrl('https://primary.test/sub'),
      throwsA(
        isA<MessageException>().having(
          (error) => error.message,
          'message',
          'subscription response is too large',
        ),
      ),
    );
  });

  test('subscription client cancels oversized declared bodies early', () async {
    final client = Request();
    final adapter = _DeclaredLargeSubscriptionAdapter();
    client.subscriptionAdapter = adapter;

    await expectLater(
      client.getFileResponseForUrl('https://primary.test/sub'),
      throwsA(isA<MessageException>()),
    );
    expect(adapter.cancelled, isTrue);
  });

  test('invalid content length falls back to bounded stream reading', () async {
    final client = Request();
    client.subscriptionAdapter = _InvalidLengthSubscriptionAdapter();

    final response = await client.getFileResponseForUrl(
      'https://primary.test/sub',
    );

    expect(utf8.decode(response.data!), 'proxies: []');
  });

  test('size rejection does not follow a later redirect', () async {
    final client = Request();
    final adapter = _OversizedThenRedirectAdapter();
    client.subscriptionAdapter = adapter;

    await expectLater(
      client.getFileResponseForUrl('https://primary.test/sub'),
      throwsA(isA<MessageException>()),
    );
    expect(adapter.requestCount, 1);
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

class _RecordedSubscriptionRequest {
  const _RecordedSubscriptionRequest(this.uri, this.headers);

  final Uri uri;
  final Map<String, dynamic> headers;
}

class _SubscriptionRedirectAdapter implements HttpClientAdapter {
  final requests = <_RecordedSubscriptionRequest>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      _RecordedSubscriptionRequest(
        options.uri,
        Map<String, dynamic>.from(options.headers),
      ),
    );
    if (options.uri.host == 'primary.test') {
      return ResponseBody.fromString(
        '',
        302,
        headers: {
          'location': ['https://cdn.test/sub'],
        },
      );
    }
    return ResponseBody.fromString('proxies: []', 200);
  }

  @override
  void close({bool force = false}) {}
}

class _DowngradeRedirectAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '',
      302,
      headers: {
        'location': ['http://primary.test/sub'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MissingLocationRedirectAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('', 302);
  }

  @override
  void close({bool force = false}) {}
}

class _LargeSubscriptionAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    const chunkSize = maxSubscriptionResponseBytes ~/ 2;
    late StreamController<Uint8List> controller;
    controller = StreamController<Uint8List>(
      onListen: () {
        controller
          ..add(Uint8List(chunkSize))
          ..add(Uint8List(chunkSize))
          ..add(Uint8List(1))
          ..add(Uint8List(1))
          ..close();
      },
    );
    return ResponseBody(controller.stream, 200);
  }

  @override
  void close({bool force = false}) {}
}

class _DeclaredLargeSubscriptionAdapter implements HttpClientAdapter {
  bool cancelled = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    unawaited(cancelFuture?.then((_) => cancelled = true));
    return ResponseBody(
      const Stream<Uint8List>.empty(),
      200,
      headers: {
        Headers.contentLengthHeader: ['${maxSubscriptionResponseBytes + 1}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _InvalidLengthSubscriptionAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      'proxies: []',
      200,
      headers: {
        Headers.contentLengthHeader: ['not-a-number'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _OversizedThenRedirectAdapter implements HttpClientAdapter {
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    if (requestCount == 1) {
      return ResponseBody.fromBytes(
        Uint8List(1),
        200,
        headers: {
          Headers.contentLengthHeader: ['${maxSubscriptionResponseBytes + 1}'],
          'location': ['https://cdn.test/sub'],
        },
      );
    }
    return ResponseBody.fromString('proxies: []', 200);
  }

  @override
  void close({bool force = false}) {}
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

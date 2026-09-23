import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/net/request.dart';
import 'package:reclash/common/subscription/subscription_retry.dart';
import 'package:reclash/core/method.dart';

DioException _failure(DioExceptionType type) => DioException(
  requestOptions: RequestOptions(path: 'https://subscription.test/sub'),
  type: type,
);

Response<Uint8List> _success() => Response(
  requestOptions: RequestOptions(path: 'https://subscription.test/sub'),
  statusCode: 200,
  data: Uint8List.fromList(utf8.encode('proxies: []')),
);

Map<String, dynamic> _hopResponse(
  int status, {
  Map<String, List<String>> headers = const {},
}) => {
  'status': status,
  'headers': headers,
  'body': base64Encode(utf8.encode('proxies: []')),
};

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? body,
    Future<void>? cancel,
  ) async => respond(options);

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final type in DioExceptionType.values) {
    test('only transport failures can offer a retry: $type', () async {
      var prompts = 0;
      var protected = 0;
      final retry = SubscriptionRetry(
        fetchNormally: (url, {headers}) async => throw _failure(type),
        fetchProtected: (url, {headers}) async {
          protected++;
          return _success();
        },
        allowed: () => true,
        confirm: () async {
          prompts++;
          return true;
        },
      );
      final eligible = const {
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      }.contains(type);
      if (eligible) {
        expect(
          (await retry.fetch('https://subscription.test/sub')).statusCode,
          200,
        );
      } else {
        await expectLater(
          retry.fetch('https://subscription.test/sub'),
          throwsA(isA<DioException>()),
        );
      }
      expect(prompts, eligible ? 1 : 0);
      expect(protected, eligible ? 1 : 0);
    });
  }

  test(
    'rejecting confirmation preserves the error and never asks again',
    () async {
      var prompts = 0;
      final retry = SubscriptionRetry(
        fetchNormally: (url, {headers}) async =>
            throw _failure(DioExceptionType.connectionError),
        fetchProtected: (url, {headers}) async => fail('unexpected bypass'),
        allowed: () => true,
        confirm: () async {
          prompts++;
          return false;
        },
      );
      for (var i = 0; i < 2; i++) {
        await expectLater(
          retry.fetch('https://subscription.test/sub'),
          throwsA(isA<DioException>()),
        );
      }
      expect(prompts, 1);
    },
  );

  test('policy blocks retry before and after confirmation', () async {
    for (final initiallyAllowed in [false, true]) {
      var allowed = initiallyAllowed;
      var prompts = 0;
      final retry = SubscriptionRetry(
        fetchNormally: (url, {headers}) async =>
            throw _failure(DioExceptionType.connectionError),
        fetchProtected: (url, {headers}) async => fail('unexpected bypass'),
        allowed: () => allowed,
        confirm: () async {
          prompts++;
          allowed = false;
          return true;
        },
      );
      await expectLater(
        retry.fetch('https://subscription.test/sub'),
        throwsA(isA<DioException>()),
      );
      expect(prompts, initiallyAllowed ? 1 : 0);
    }
  });

  test('an earlier panel response prevents bypass on later probes', () async {
    var calls = 0;
    final retry = SubscriptionRetry(
      fetchNormally: (url, {headers}) async {
        if (calls++ == 0) return _success();
        throw _failure(DioExceptionType.connectionError);
      },
      fetchProtected: (url, {headers}) async => fail('unexpected bypass'),
      allowed: () => true,
      confirm: () async => fail('must not prompt after a panel response'),
    );
    await retry.fetch('https://subscription.test/sub');
    await expectLater(
      retry.fetch('https://subscription.test/sub'),
      throwsA(isA<DioException>()),
    );
  });

  test(
    'protected failures never silently fall back to the ordinary route',
    () async {
      var normal = 0;
      var prompts = 0;
      final retry = SubscriptionRetry(
        fetchNormally: (url, {headers}) async {
          normal++;
          throw _failure(DioExceptionType.connectionError);
        },
        fetchProtected: (url, {headers}) async =>
            throw const CoreMethodException(
              code: 'subscription_protection',
              message: 'refused',
            ),
        allowed: () => true,
        confirm: () async {
          prompts++;
          return true;
        },
      );
      for (var i = 0; i < 2; i++) {
        await expectLater(
          retry.fetch('https://subscription.test/sub'),
          throwsA(isA<CoreMethodException>()),
        );
      }
      expect(normal, 1);
      expect(prompts, 1);
    },
  );

  test('redirect then transport failure cannot offer a bypass', () async {
    final client = Request();
    var calls = 0;
    client.subscriptionAdapter = _Adapter((options) {
      if (calls++ == 0) {
        return ResponseBody.fromString(
          '',
          302,
          headers: {
            'location': ['https://other.test/sub'],
          },
        );
      }
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    });
    try {
      await client.getFileResponseForUrl('https://subscription.test/sub');
      fail('expected failure');
    } catch (error) {
      expect(error, isA<DioException>());
      expect(isSubscriptionTransportFailure(error), isFalse);
    }
  });

  test('protected redirects reuse cross-origin header stripping', () async {
    final received = <Map<String, String>>[];
    final budgets = <int>[];
    final transport = ProtectedSubscriptionTransport(
      allowed: () => true,
      hop: ({required url, required headers, required timeoutMillis}) async {
        received.add(headers);
        budgets.add(timeoutMillis);
        if (received.length == 1) {
          return _hopResponse(
            302,
            headers: {
              'location': ['https://other.test/sub'],
            },
          );
        }
        return _hopResponse(200);
      },
    );
    final result = await transport.download(
      'https://subscription.test/sub',
      headers: {
        'X-Hwid': 'private-id',
        'Authorization': 'Bearer private-token',
        'User-Agent': 'test-client',
      },
    );
    expect(result.statusCode, 200);
    expect(received.first['X-Hwid'], 'private-id');
    expect(
      received.last.keys.map((key) => key.toLowerCase()),
      isNot(contains('x-hwid')),
    );
    expect(
      received.last.keys.map((key) => key.toLowerCase()),
      isNot(contains('authorization')),
    );
    expect(budgets.first, inInclusiveRange(1, 30000));
    expect(budgets.last, lessThanOrEqualTo(budgets.first));
  });

  test('protected transport preserves HTTP refusal and HWID headers', () async {
    final transport = ProtectedSubscriptionTransport(
      allowed: () => true,
      hop: ({required url, required headers, required timeoutMillis}) async =>
          _hopResponse(
            403,
            headers: {
              'x-hwid-not-supported': ['true'],
            },
          ),
    );
    await expectLater(
      transport.download('https://subscription.test/sub'),
      throwsA(
        isA<DioException>()
            .having((e) => e.type, 'type', DioExceptionType.badResponse)
            .having(
              (e) => e.response?.headers.value('x-hwid-not-supported'),
              'HWID signal',
              'true',
            ),
      ),
    );
  });

  test('protected request count is bounded across client probes', () async {
    var calls = 0;
    final transport = ProtectedSubscriptionTransport(
      allowed: () => true,
      hop: ({required url, required headers, required timeoutMillis}) async {
        calls++;
        return _hopResponse(200);
      },
    );
    for (var i = 0; i < subscriptionRedirectLimit + 1; i++) {
      await transport.download('https://subscription.test/sub');
    }
    await expectLater(
      transport.download('https://subscription.test/sub'),
      throwsA(isA<DioException>()),
    );
    expect(calls, subscriptionRedirectLimit + 1);
  });

  test('policy is checked again before each redirect hop', () async {
    var allowed = true;
    var calls = 0;
    final transport = ProtectedSubscriptionTransport(
      allowed: () => allowed,
      hop: ({required url, required headers, required timeoutMillis}) async {
        calls++;
        allowed = false;
        return _hopResponse(
          302,
          headers: {
            'location': ['https://other.test/sub'],
          },
        );
      },
    );
    await expectLater(
      transport.download('https://subscription.test/sub'),
      throwsA(isA<DioException>()),
    );
    expect(calls, 1);
  });
}

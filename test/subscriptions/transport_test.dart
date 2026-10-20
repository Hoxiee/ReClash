import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/protocol/registry.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

class _FailedClient extends Fake implements HttpClient {
  _FailedClient(this.error);
  final Exception error;

  @override
  bool autoUncompress = false;
  @override
  Duration? connectionTimeout;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => throw error;
  @override
  void close({bool force = false}) {}
}

Matcher _failure(SubscriptionFailure failure) => isA<SubscriptionException>()
    .having((error) => error.failure, 'failure', failure);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HttpOverrides? overrides;
  final servers = <HttpServer>[];

  setUp(() {
    overrides = HttpOverrides.current;
    HttpOverrides.global = null;
  });
  tearDown(() async {
    for (final server in servers) {
      await server.close(force: true);
    }
    servers.clear();
    HttpOverrides.global = overrides;
  });

  Future<Uri> serve(FutureOr<void> Function(HttpRequest) handle) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    servers.add(server);
    server.listen((request) async => handle(request));
    return Uri.parse('http://127.0.0.1:${server.port}/subscription');
  }

  Future<void> respond(
    HttpRequest request,
    List<int> bytes, {
    String? encoding,
  }) {
    if (encoding != null) {
      request.response.headers.set('content-encoding', encoding);
    }
    request.response.add(bytes);
    return request.response.close();
  }

  test('decodes gzip and deflate and honours explicit identity', () async {
    final plain = utf8.encode('proxies: []');
    for (final encoding in ['gzip', 'deflate', 'identity']) {
      final wire = encoding == 'gzip'
          ? gzip.encode(plain)
          : encoding == 'deflate'
          ? zlib.encode(plain)
          : gzip.encode(plain);
      final uri = await serve(
        (request) => respond(request, wire, encoding: encoding),
      );
      final result = await SubscriptionTransport().fetch(uri);
      expect(result.bytes, encoding == 'identity' ? wire : plain);
    }
  });

  test('rejects unsupported and malformed content encoding', () async {
    for (final encoding in ['br', 'gzip, deflate', 'gzip']) {
      final uri = await serve(
        (request) => respond(request, [1, 2, 3], encoding: encoding),
      );
      await expectLater(
        SubscriptionTransport().fetch(uri),
        throwsA(_failure(SubscriptionFailure.invalid)),
      );
    }
  });

  test('bounds wire bytes and decoded bytes', () async {
    final uri = await serve((request) async {
      request.response.contentLength = subscriptionWireLimit + 1;
      request.response.add([0]);
      await request.response.flush();
    });
    await expectLater(
      SubscriptionTransport().fetch(uri),
      throwsA(_failure(SubscriptionFailure.oversized)),
    );
    final bomb = Uint8List.fromList(
      gzip.encode(Uint8List(subscriptionPayloadLimit + 1)),
    );
    await expectLater(
      decompressSubscriptionPayload(bomb, encoding: 'gzip'),
      throwsA(_failure(SubscriptionFailure.oversized)),
    );
  });

  test('keeps same-origin credentials and strips them across ports', () async {
    Map<String, String>? sameHeaders;
    Map<String, String>? crossHeaders;
    final cross = await serve((request) {
      crossHeaders = {
        for (final key in [
          'authorization',
          'x-hwid',
          'x-custom-token',
          'user-agent',
        ])
          key: request.headers.value(key) ?? '',
      };
      return respond(request, utf8.encode('proxies: []'));
    });
    final uri = await serve((request) {
      if (request.uri.path == '/subscription') {
        request.response.statusCode = 302;
        request.response.headers.set('location', '/same');
      } else if (request.uri.path == '/same') {
        sameHeaders = {
          for (final key in ['authorization', 'x-hwid', 'x-custom-token'])
            key: request.headers.value(key) ?? '',
        };
        request.response.statusCode = 302;
        request.response.headers.set('location', cross.toString());
      }
      return request.response.close();
    });
    await SubscriptionTransport().fetch(
      uri,
      headers: {
        'authorization': 'fake',
        'x-hwid': 'a' * 32,
        'x-custom-token': 'fake',
        'user-agent': 'ReClash/test',
      },
    );
    expect(sameHeaders, {
      'authorization': 'fake',
      'x-hwid': 'a' * 32,
      'x-custom-token': 'fake',
    });
    expect(crossHeaders, {
      'authorization': '',
      'x-hwid': '',
      'x-custom-token': '',
      'user-agent': 'ReClash/test',
    });
  });

  test(
    'rejects redirect loops and empty payloads without protected retry',
    () async {
      var retries = 0;
      final transport = SubscriptionTransport(
        protectedFetcher: (_, _, _, _) async {
          retries++;
          throw StateError('unexpected fallback');
        },
      );
      final uri = await serve((request) {
        request.response.statusCode = 302;
        request.response.headers.set('location', '/subscription');
        return request.response.close();
      });
      await expectLater(
        transport.fetch(uri),
        throwsA(_failure(SubscriptionFailure.redirect)),
      );
      final empty = await serve((request) => request.response.close());
      await expectLater(
        transport.fetch(empty),
        throwsA(_failure(SubscriptionFailure.empty)),
      );
      expect(retries, 0);
    },
  );

  test('retains a verified provider support URL on device limits', () async {
    final uri = await serve((request) async {
      request.response.headers
        ..set('x-hwid-max-devices-reached', 'true')
        ..set('reclash-supporturl', 'https://provider.example/account');
      await request.response.close();
    });
    await expectLater(
      SubscriptionTransport().fetch(uri),
      throwsA(
        isA<SubscriptionException>()
            .having(
              (error) => error.failure,
              'failure',
              SubscriptionFailure.deviceLimit,
            )
            .having(
              (error) => error.supportUri,
              'supportUri',
              Uri.parse('https://provider.example/account'),
            ),
      ),
    );
  });

  test(
    'never retries authorization, rate limits or device rejection',
    () async {
      var retries = 0;
      final transport = SubscriptionTransport(
        protectedFetcher: (_, _, _, _) async {
          retries++;
          throw StateError('unexpected fallback');
        },
      );
      for (final (status, failure) in [
        (401, SubscriptionFailure.unauthorized),
        (403, SubscriptionFailure.unauthorized),
        (429, SubscriptionFailure.rateLimited),
        (500, SubscriptionFailure.http),
        (200, SubscriptionFailure.deviceLimit),
      ]) {
        final uri = await serve((request) {
          request.response.statusCode = status;
          if (status == 200) {
            request.response.headers.set('x-hwid-max-devices-reached', 'true');
          }
          return respond(request, utf8.encode('rejected'));
        });
        await expectLater(transport.fetch(uri), throwsA(_failure(failure)));
      }
      expect(retries, 0);
    },
  );

  test(
    'retries a pre-response socket error exactly once within budget',
    () async {
      var retries = 0;
      final uri = Uri.parse('https://subscription.example/test');
      final transport = SubscriptionTransport(
        createClient: () => _FailedClient(const SocketException('fake')),
        protectedFetcher: (source, headers, timeout, cancellation) async {
          retries++;
          expect(timeout, lessThanOrEqualTo(const Duration(seconds: 2)));
          return SubscriptionResponse(
            bytes: Uint8List.fromList(utf8.encode('proxies: []')),
            headers: const {},
            status: 200,
            uri: source,
            protected: true,
            bypassed: true,
          );
        },
      );
      final response = await transport.fetch(
        uri,
        timeout: const Duration(seconds: 2),
      );
      expect(response.protected, isTrue);
      expect(response.bypassed, isTrue);
      expect(retries, 1);
    },
  );

  test('retries a pre-response timeout within the remaining budget', () async {
    var retries = 0;
    final transport = SubscriptionTransport(
      createClient: () => _HangingClient(),
      protectedFetcher: (source, _, timeout, _) async {
        retries++;
        expect(timeout, greaterThan(Duration.zero));
        expect(timeout, lessThan(const Duration(milliseconds: 900)));
        return SubscriptionResponse(
          bytes: Uint8List.fromList(utf8.encode('proxies: []')),
          headers: const {},
          status: 200,
          uri: source,
          protected: true,
          bypassed: true,
        );
      },
    );
    final result = await transport.fetch(
      Uri.parse('https://subscription.example/test'),
      timeout: const Duration(milliseconds: 900),
    );
    expect(result.protected, isTrue);
    expect(retries, 1);
  });

  test('rechecks fallback permission before switching routes', () async {
    var retries = 0;
    final transport = SubscriptionTransport(
      createClient: () => _FailedClient(const SocketException('fake')),
      canUseProtected: () => false,
      protectedFetcher: (_, _, _, _) async {
        retries++;
        throw StateError('unexpected fallback');
      },
    );
    await expectLater(
      transport.fetch(Uri.parse('https://subscription.example/test')),
      throwsA(_failure(SubscriptionFailure.transport)),
    );
    expect(retries, 0);
  });

  test('never retries TLS errors or cancellation', () async {
    var retries = 0;
    final transport = SubscriptionTransport(
      createClient: () => _FailedClient(const HandshakeException('fake')),
      protectedFetcher: (_, _, _, _) async {
        retries++;
        throw StateError('unexpected fallback');
      },
    );
    final uri = Uri.parse('https://subscription.example/test');
    await expectLater(
      transport.fetch(uri),
      throwsA(_failure(SubscriptionFailure.tls)),
    );
    final cancellation = SubscriptionCancellation()..cancel();
    await expectLater(
      transport.fetch(uri, cancellation: cancellation),
      throwsA(_failure(SubscriptionFailure.cancelled)),
    );
    expect(retries, 0);
  });

  test('cancels or times out a server that never sends headers', () async {
    final received = Completer<void>();
    final uri = await serve((request) => received.complete());
    final cancellation = SubscriptionCancellation();
    final fetch = SubscriptionTransport().fetch(
      uri,
      cancellation: cancellation,
    );
    await received.future;
    cancellation.cancel();
    await expectLater(fetch, throwsA(_failure(SubscriptionFailure.cancelled)));
    final stalled = await serve((request) {});
    await expectLater(
      SubscriptionTransport().fetch(
        stalled,
        timeout: const Duration(milliseconds: 50),
      ),
      throwsA(_failure(SubscriptionFailure.timeout)),
    );
  });

  test('protected fallback also obeys wire limit and deadline', () async {
    final uri = Uri.parse('https://subscription.example/test');
    final stalled = SubscriptionTransport(
      createClient: () => _FailedClient(const SocketException('fake')),
      protectedFetcher: (_, _, _, _) =>
          Completer<SubscriptionResponse>().future,
    );
    await expectLater(
      stalled.fetch(uri, timeout: const Duration(milliseconds: 50)),
      throwsA(_failure(SubscriptionFailure.timeout)),
    );
    final oversized = SubscriptionTransport(
      createClient: () => _FailedClient(const SocketException('fake')),
      protectedFetcher: (source, _, _, _) async => SubscriptionResponse(
        bytes: Uint8List(subscriptionWireLimit + 1),
        headers: const {},
        status: 200,
        uri: source,
      ),
    );
    await expectLater(
      oversized.fetch(uri),
      throwsA(_failure(SubscriptionFailure.oversized)),
    );
  });
}

class _HangingClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = false;
  @override
  Duration? connectionTimeout;
  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      Completer<HttpClientRequest>().future;
  @override
  void close({bool force = false}) {}
}

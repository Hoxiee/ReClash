import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:reclash/features/lovense/client.dart';
import 'package:reclash/features/lovense/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _Transport implements LovenseTransport {
  final commands = <Map<String, Object>>[];
  Future<Map<String, dynamic>> Function(Map<String, Object>)? handler;
  bool closed = false;

  @override
  Future<Map<String, dynamic>> send(Map<String, Object> command) {
    commands.add(Map.of(command));
    return handler?.call(command) ?? Future.value({'code': 200});
  }

  @override
  void close() => closed = true;
}

class _InspectableHttpClient implements HttpClient {
  @override
  bool Function(X509Certificate, String, int)? badCertificateCallback =
      (_, _, _) => true;
  @override
  String Function(Uri)? findProxy = (_) => 'PROXY invalid.test:1';
  bool closed = false;

  @override
  void close({bool force = false}) => closed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _InheritedOverrides extends HttpOverrides {
  final client = _InspectableHttpClient();

  @override
  HttpClient createHttpClient(SecurityContext? context) => client;
}

class _RealHttpOverrides extends HttpOverrides {}

Future<void> _withServer(
  Future<void> Function(HttpRequest) handler,
  Future<void> Function(HttpServer server) check,
) async {
  await HttpOverrides.runWithHttpOverrides(() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final subscription = server.listen(
      (request) => unawaited(handler(request)),
    );
    try {
      await check(server);
    } finally {
      await subscription.cancel();
      await server.close(force: true);
    }
  }, _RealHttpOverrides());
}

LovenseHttpTransport _http(
  HttpServer server, {
  int? maxBytes,
  Duration? timeout,
}) => LovenseHttpTransport(
  LovenseEndpoint.parse('http://127.0.0.1:${server.port}'),
  maxResponseBytes: maxBytes ?? 256 * 1024,
  timeout: timeout ?? const Duration(seconds: 5),
);

void main() {
  late _Transport transport;
  late LovenseClient client;
  setUp(() {
    transport = _Transport();
    client = LovenseClient(
      LovenseEndpoint.parse('localhost'),
      transport: transport,
    );
  });
  tearDown(() => client.close());

  test(
    'GetToys sends only a read command and decodes the nested JSON',
    () async {
      transport.handler = (_) async => {
        'code': 200,
        'data': {
          'toys': jsonEncode({
            'toy1': {'status': '1', 'name': 'lush'},
          }),
        },
      };
      final toys = await client.getToys();
      expect(transport.commands, [
        {'command': 'GetToys'},
      ]);
      expect(toys.single.connected, isTrue);
    },
  );

  for (final function in LovenseFunction.values) {
    test(
      '${function.apiName} uses its documented maximum and finite duration',
      () async {
        await client.function(
          toyId: 'toy1',
          function: function,
          strength: function.maxStrength,
          duration: 10,
        );
        expect(transport.commands.single, {
          'command': 'Function',
          'action': '${function.apiName}:${function.maxStrength}',
          'timeSec': 10,
          'toy': 'toy1',
          'apiVer': 1,
          'stopPrevious': 1,
        });
      },
    );
  }

  test('invalid strength, duration and IDs never send a command', () {
    for (final values in [(-1, 10), (21, 10), (1, 0), (1, 1), (1, 61)]) {
      expect(
        () => client.function(
          toyId: 'toy1',
          function: LovenseFunction.vibrate,
          strength: values.$1,
          duration: values.$2,
        ),
        throwsA(isA<LovenseError>()),
      );
    }
    expect(
      () => client.function(
        toyId: 'a,b',
        function: LovenseFunction.vibrate,
        strength: 1,
        duration: 10,
      ),
      throwsA(isA<LovenseError>()),
    );
    expect(transport.commands, isEmpty);
  });

  test(
    'Stroke is coupled to Thrusting and enforces a range of at least 20',
    () async {
      await client.function(
        toyId: 'toy1',
        function: LovenseFunction.thrusting,
        strength: 3,
        duration: 2,
        stroke: const LovenseStroke(10, 30),
      );
      expect(transport.commands.single['action'], 'Stroke:10-30,Thrusting:3');
      for (final stroke in [
        const LovenseStroke(0, 19),
        const LovenseStroke(-1, 50),
        const LovenseStroke(90, 110),
      ]) {
        expect(
          () => client.function(
            toyId: 'toy1',
            function: LovenseFunction.thrusting,
            strength: 1,
            duration: 2,
            stroke: stroke,
          ),
          throwsA(isA<LovenseError>()),
        );
      }
      expect(
        () => client.function(
          toyId: 'toy1',
          function: LovenseFunction.vibrate,
          strength: 1,
          duration: 2,
          stroke: const LovenseStroke(0, 100),
        ),
        throwsA(isA<LovenseError>()),
      );
      expect(transport.commands, hasLength(1));
    },
  );

  test(
    'Stop targets one toy or all toys with the documented command',
    () async {
      await client.stop(toyId: 'toy1');
      await client.stop();
      expect(transport.commands, [
        {
          'command': 'Function',
          'action': 'Stop',
          'timeSec': 0,
          'toy': 'toy1',
          'apiVer': 1,
        },
        {'command': 'Function', 'action': 'Stop', 'timeSec': 0, 'apiVer': 1},
      ]);
    },
  );

  test(
    'Stop invalidates queued starts and follows an in-flight command',
    () async {
      final firstReply = Completer<Map<String, dynamic>>();
      transport.handler = (_) => transport.commands.length == 1
          ? firstReply.future
          : Future.value({'code': 200});
      final first = client.function(
        toyId: 'toy1',
        function: LovenseFunction.vibrate,
        strength: 1,
        duration: 10,
      );
      await Future<void>.delayed(Duration.zero);
      final queued = client.function(
        toyId: 'toy1',
        function: LovenseFunction.vibrate,
        strength: 2,
        duration: 10,
      );
      final cancelled = expectLater(
        queued,
        throwsA(
          isA<LovenseError>().having(
            (e) => e.kind,
            'kind',
            LovenseErrorKind.cancelled,
          ),
        ),
      );
      final stop = client.stop();
      expect(transport.commands, hasLength(1));
      firstReply.complete({'code': 200});
      await first;
      await cancelled;
      await stop;
      expect(transport.commands.map((c) => c['action']), ['Vibrate:1', 'Stop']);
    },
  );

  test('a remote failure does not poison the command queue', () async {
    transport.handler = (_) async => {
      'code': transport.commands.length == 1 ? 400 : 200,
    };
    await expectLater(
      client.function(
        toyId: 'toy1',
        function: LovenseFunction.vibrate,
        strength: 1,
        duration: 10,
      ),
      throwsA(isA<LovenseError>().having((e) => e.code, 'code', 400)),
    );
    await client.stop();
    expect(transport.commands.last['action'], 'Stop');
  });

  test(
    'missing response code is rejected instead of reporting success',
    () async {
      transport.handler = (_) async => {'type': 'OK'};
      await expectLater(
        client.stop(),
        throwsA(
          isA<LovenseError>().having(
            (e) => e.kind,
            'kind',
            LovenseErrorKind.invalidResponse,
          ),
        ),
      );
    },
  );

  test('a closed client cannot send more commands', () async {
    client.close();
    await expectLater(client.getToys(), throwsA(isA<LovenseError>()));
    expect(() => client.stop(), throwsA(isA<LovenseError>()));
    expect(transport.commands, isEmpty);
    expect(transport.closed, isTrue);
  });

  test('global proxy and disabled certificate checks never leak into LAN', () {
    final overrides = _InheritedOverrides();
    HttpOverrides.runWithHttpOverrides(() {
      final endpoint = LovenseEndpoint.parse(lovenseDefaultAddress);
      final http = LovenseHttpTransport(endpoint);
      expect(overrides.client.badCertificateCallback, isNull);
      expect(overrides.client.findProxy!(endpoint.uri), 'DIRECT');
      http.close();
      expect(overrides.client.closed, isTrue);
    }, overrides);
  });

  group('direct local HTTP transport', () {
    test('uses pinned LAN IP, /command, JSON and X-platform', () async {
      HttpRequest? received;
      Object? body;
      await _withServer(
        (request) async {
          received = request;
          body = jsonDecode(await utf8.decoder.bind(request).join());
          request.response.headers.contentType = ContentType.json;
          request.response.write('{"code":200,"data":{"toys":"{}"}}');
          await request.response.close();
        },
        (server) async {
          final http = _http(server);
          try {
            final response = await http.send({'command': 'GetToys'});
            expect(response['code'], 200);
            expect(received!.uri.path, '/command');
            expect(received!.headers.value('X-platform'), 'ReClash');
            expect(received!.headers.contentType!.mimeType, 'application/json');
            expect(body, {'command': 'GetToys'});
          } finally {
            http.close();
          }
        },
      );
    });

    test('never follows redirects out of the command endpoint', () async {
      var requests = 0;
      await _withServer(
        (request) async {
          requests++;
          request.response.statusCode = HttpStatus.found;
          request.response.headers.set(HttpHeaders.locationHeader, '/other');
          await request.response.close();
        },
        (server) async {
          final http = _http(server);
          try {
            await expectLater(
              http.send({'command': 'GetToys'}),
              throwsA(isA<LovenseError>().having((e) => e.code, 'code', 302)),
            );
            expect(requests, 1);
          } finally {
            http.close();
          }
        },
      );
    });

    for (final content in ['not JSON', '[1,2]', 'x' * 1000]) {
      test(
        'rejects malformed or oversized response ${content.length}',
        () async {
          await _withServer(
            (request) async {
              request.response.write(content);
              await request.response.close();
            },
            (server) async {
              final http = _http(server, maxBytes: 64);
              try {
                await expectLater(
                  http.send({'command': 'GetToys'}),
                  throwsA(
                    isA<LovenseError>().having(
                      (e) => e.kind,
                      'kind',
                      LovenseErrorKind.invalidResponse,
                    ),
                  ),
                );
              } finally {
                http.close();
              }
            },
          );
        },
      );
    }

    test('bounds the whole request with a timeout', () async {
      await _withServer((_) async {}, (server) async {
        final http = _http(server, timeout: const Duration(milliseconds: 100));
        try {
          await expectLater(
            http.send({'command': 'GetToys'}),
            throwsA(
              isA<LovenseError>().having(
                (e) => e.kind,
                'kind',
                LovenseErrorKind.timeout,
              ),
            ),
          );
        } finally {
          http.close();
        }
      });
    });
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUpAll(() => AppLocalizations.load(const Locale('en')));
  group('LanProfileImportServer', () {
    late LanProfileImportServer server;
    final servers = <LanProfileImportServer>[];

    tearDown(() async {
      for (final item in servers) {
        await item.close();
      }
    });

    Future<Uri> start({
      LanProfileImportCallback? onImport,
      LanProfileImportResolver? resolve,
      Duration timeout = const Duration(minutes: 1),
      Duration confirmationTimeout = const Duration(seconds: 20),
      Duration requestTimeout = const Duration(seconds: 10),
    }) async {
      server = LanProfileImportServer(
        onImport: onImport ?? (_) async => true,
        page: buildLanProfileImportPage(
          localizations: currentAppLocalizations,
          colors: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        confirmationTimeout: confirmationTimeout,
        requestTimeout: requestTimeout,
        resolve:
            resolve ??
            (input) async => SubscriptionImportTarget(
              url: input,
              client: SubscriptionClient.auto,
            ),
        timeout: timeout,
      );
      servers.add(server);
      return server.start(address: InternetAddress.loopbackIPv4);
    }

    Future<HttpClientResponse> send(
      Uri uri, {
      String method = 'POST',
      String contentType = 'application/json',
      Object? body,
      String? token,
      String? path,
    }) async {
      final client = HttpClient();
      final target = uri.replace(
        path: path ?? uri.path,
        queryParameters: {'token': token ?? uri.queryParameters['token']!},
      );
      try {
        final request = await client.openUrl(method, target);
        request.headers.contentType = ContentType.parse(contentType);
        if (body != null) {
          request.add(utf8.encode(body is String ? body : jsonEncode(body)));
        }
        final response = await request.close();
        await response.drain<void>();
        return response;
      } finally {
        client.close(force: true);
      }
    }

    Future<({int statusCode, String body, ContentType? contentType})> get(
      Uri uri, {
      String? token,
    }) async {
      final client = HttpClient();
      final target = uri.replace(
        queryParameters: {'token': token ?? uri.queryParameters['token']!},
      );
      final request = await client.getUrl(target);
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      final result = (
        statusCode: response.statusCode,
        body: body,
        contentType: response.headers.contentType,
      );
      client.close(force: true);
      return result;
    }

    test('serves a phone form without consuming the one-time link', () async {
      final uri = await start();

      final page = await get(uri);

      expect(page.statusCode, HttpStatus.ok);
      expect(page.contentType?.mimeType, ContentType.html.mimeType);
      expect(page.body, contains('<form id="form">'));
      expect(page.body, contains("method:'POST'"));
      expect(
        (await send(uri, body: {'url': 'https://example.com/sub'})).statusCode,
        HttpStatus.ok,
      );
    });

    test('rejects an invalid form token without consuming the link', () async {
      final uri = await start();

      expect((await get(uri, token: 'wrong')).statusCode, HttpStatus.forbidden);
      expect(
        (await send(uri, body: {'url': 'https://example.com/sub'})).statusCode,
        HttpStatus.ok,
      );
    });

    test('accepts one valid URL and calls back once', () async {
      final imported = <SubscriptionImportTarget>[];
      final uri = await start(
        onImport: (target) async {
          imported.add(target);
          return true;
        },
      );

      final response = await send(
        uri,
        body: {'url': 'https://example.com/sub'},
      );

      expect(response.statusCode, HttpStatus.ok);
      await server.close();
      expect(imported.single.url, 'https://example.com/sub');
    });

    test('accepts resolved local content', () async {
      final imported = <SubscriptionImportTarget>[];
      final uri = await start(
        resolve: (_) async => const SubscriptionImportTarget(
          url: '',
          client: SubscriptionClient.auto,
          localContent: 'proxies: []',
        ),
        onImport: (target) async {
          imported.add(target);
          return true;
        },
      );

      final response = await send(uri, body: {'url': 'reclash://payload'});

      expect(response.statusCode, HttpStatus.ok);
      await server.close();
      expect(imported.single.localContent, 'proxies: []');
    });

    test(
      'rejects method path content type and token without consuming',
      () async {
        final uri = await start();

        expect(
          (await send(uri, method: 'PUT')).statusCode,
          HttpStatus.methodNotAllowed,
        );
        expect(
          (await send(uri, path: '/other')).statusCode,
          HttpStatus.notFound,
        );
        expect(
          (await send(uri, contentType: 'text/plain', body: '{}')).statusCode,
          HttpStatus.unsupportedMediaType,
        );
        expect(
          (await send(
            uri,
            token: 'wrong',
            body: {'url': 'https://example.com'},
          )).statusCode,
          HttpStatus.forbidden,
        );
        final response = await send(uri, body: {'url': 'https://example.com'});
        expect(response.statusCode, HttpStatus.ok);
        await server.close();
      },
    );

    test('rejects malformed oversized and invalid URL bodies', () async {
      final uri = await start(
        resolve: (input) async => input.startsWith('https://')
            ? SubscriptionImportTarget(
                url: input,
                client: SubscriptionClient.auto,
              )
            : null,
      );

      expect((await send(uri, body: '{')).statusCode, HttpStatus.badRequest);
      expect(
        (await send(uri, body: {'url': 'not-a-url'})).statusCode,
        HttpStatus.unprocessableEntity,
      );
      expect(
        (await send(
          uri,
          body: 'x' * (lanProfileImportBodyLimit + 1),
        )).statusCode,
        HttpStatus.requestEntityTooLarge,
      );
      expect(
        (await send(uri, body: {'url': 'https://example.com'})).statusCode,
        HttpStatus.ok,
      );
    });

    test(
      'waits for commit and blocks parallel replay without closing',
      () async {
        final callbackStarted = Completer<void>();
        final release = Completer<bool>();
        var calls = 0;
        var responded = false;
        final uri = await start(
          onImport: (_) async {
            calls++;
            callbackStarted.complete();
            return release.future;
          },
        );
        final events = <LanProfileImportState>[];
        server.state.stream.listen(events.add);
        final first = send(uri, body: {'url': 'https://example.com/one'}).then((
          value,
        ) {
          responded = true;
          return value;
        });
        await callbackStarted.future;
        expect(responded, isFalse);
        expect((await get(uri)).statusCode, HttpStatus.ok);
        expect(
          (await send(
            uri,
            body: {'url': 'https://example.com/two'},
          )).statusCode,
          HttpStatus.conflict,
        );
        release.complete(true);
        expect((await first).statusCode, HttpStatus.ok);
        expect(events, isNot(contains(LanProfileImportState.imported)));
        expect(
          (await send(
            uri,
            body: {'url': 'https://example.com/one'},
          )).statusCode,
          HttpStatus.ok,
        );
        expect(
          (await send(uri, token: 'wrong', body: {'ack': true})).statusCode,
          HttpStatus.forbidden,
        );
        expect(calls, 1);
        expect(
          (await send(uri, body: {'ack': true})).statusCode,
          HttpStatus.ok,
        );
        await server.close();
        expect(
          events.where((state) => state == LanProfileImportState.imported),
          hasLength(1),
        );
      },
    );

    test('closing during import does not publish after stream close', () async {
      final callbackStarted = Completer<void>();
      final release = Completer<bool>();
      final uri = await start(
        onImport: (_) async {
          callbackStarted.complete();
          return release.future;
        },
      );
      final events = <LanProfileImportState>[];
      server.state.stream.listen(events.add);
      final request = send(uri, body: {'url': 'https://example.com/sub'});
      final disconnected = expectLater(request, throwsA(isA<HttpException>()));
      await callbackStarted.future;
      await server.close();
      release.complete(true);
      await disconnected;
      await Future<void>.delayed(Duration.zero);
      expect(events, isNot(contains(LanProfileImportState.imported)));
    });

    test('timeout and dispose close the listener', () async {
      final uri = await start(timeout: const Duration(milliseconds: 20));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await expectLater(
        send(uri, body: {'url': 'https://example.com'}),
        throwsA(isA<SocketException>()),
      );

      final disposedUri = await start();
      await server.close();
      await expectLater(
        send(disposedUri, body: {'url': 'https://example.com'}),
        throwsA(isA<SocketException>()),
      );
    });

    test('retries resolver and import failures in the same session', () async {
      var resolves = 0;
      var imports = 0;
      final uri = await start(
        resolve: (input) async {
          if (++resolves == 1) throw StateError('resolver failed');
          return SubscriptionImportTarget(
            url: input,
            client: SubscriptionClient.auto,
          );
        },
        onImport: (_) async {
          imports++;
          if (imports == 1) return false;
          if (imports == 2) throw StateError('import failed');
          return true;
        },
      );
      for (var i = 0; i < 3; i++) {
        expect(
          (await send(
            uri,
            body: {'url': 'https://example.com/sub'},
          )).statusCode,
          HttpStatus.unprocessableEntity,
        );
        expect((await get(uri)).statusCode, HttpStatus.ok);
      }
      expect(
        (await send(uri, body: {'url': 'https://example.com/sub'})).statusCode,
        HttpStatus.ok,
      );
      expect(imports, 3);
    });

    test('lost import response can be replayed without a duplicate', () async {
      final started = Completer<void>();
      final release = Completer<bool>();
      var imports = 0;
      final uri = await start(
        onImport: (_) async {
          imports++;
          started.complete();
          return release.future;
        },
      );
      final client = HttpClient();
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'url': 'https://example.com/sub'}));
      final response = request.close();
      final disconnected = expectLater(response, throwsA(isA<HttpException>()));
      await started.future;
      client.close(force: true);
      release.complete(true);
      await disconnected;
      await Future<void>.delayed(Duration.zero);
      expect(
        (await send(uri, body: {'url': 'https://example.com/sub'})).statusCode,
        HttpStatus.ok,
      );
      expect(imports, 1);
      expect((await send(uri, body: {'ack': true})).statusCode, HttpStatus.ok);
    });

    test('missing acknowledgement has bounded success grace', () async {
      final uri = await start(
        confirmationTimeout: const Duration(milliseconds: 80),
      );
      final events = <LanProfileImportState>[];
      final done = Completer<void>();
      server.state.stream.listen(events.add, onDone: done.complete);
      expect(
        (await send(uri, body: {'url': 'https://example.com/sub'})).statusCode,
        HttpStatus.ok,
      );
      await done.future;
      expect(
        events.where((value) => value == LanProfileImportState.imported),
        hasLength(1),
      );
      expect(events, isNot(contains(LanProfileImportState.timedOut)));
    });

    test(
      'session expires during resolution and never starts an import',
      () async {
        final started = Completer<void>();
        final release = Completer<SubscriptionImportTarget?>();
        var imports = 0;
        final uri = await start(
          timeout: const Duration(milliseconds: 80),
          resolve: (_) {
            started.complete();
            return release.future;
          },
          onImport: (_) async {
            imports++;
            return true;
          },
        );
        final request = send(uri, body: {'url': 'https://example.com/sub'});
        final disconnected = expectLater(
          request,
          throwsA(isA<HttpException>()),
        );
        await started.future;
        await disconnected;
        release.complete(
          const SubscriptionImportTarget(
            url: 'https://example.com/sub',
            client: SubscriptionClient.auto,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(imports, 0);
      },
    );

    test('bounds simultaneous slow requests and their idle lifetime', () async {
      final uri = await start(
        requestTimeout: const Duration(milliseconds: 150),
      );
      final sockets = <Socket>[];
      addTearDown(() {
        for (final socket in sockets) {
          socket.destroy();
        }
      });
      for (var i = 0; i < lanProfileImportMaxRequests; i++) {
        final socket = await Socket.connect(uri.host, uri.port);
        sockets.add(socket);
        socket.write(
          'POST ${uri.path}?${uri.query} HTTP/1.1\r\nHost: ${uri.host}\r\nContent-Type: application/json\r\nContent-Length: 100\r\n\r\n{',
        );
        await socket.flush();
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(
        (await send(uri, body: {'url': 'https://example.com/sub'})).statusCode,
        HttpStatus.serviceUnavailable,
      );
      await Future<void>.delayed(const Duration(milliseconds: 180));
      expect(
        (await send(uri, body: {'url': 'https://example.com/sub'})).statusCode,
        HttpStatus.ok,
      );
    });

    test('phone page uses theme colors and escapes localized markup', () {
      final localizations = _UnsafeLocalizations();
      for (final brightness in Brightness.values) {
        final colors = ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        );
        final page = buildLanProfileImportPage(
          localizations: localizations,
          colors: colors,
        );
        expect(page, contains('color-scheme:${brightness.name}'));
        expect(page, contains('&lt;unsafe&gt;'));
        final encoded = RegExp(
          "atob\\('([^']+)'\\)",
        ).firstMatch(page)!.group(1)!;
        final decoded = jsonDecode(utf8.decode(base64.decode(encoded)));
        expect(decoded['failed'], localizations.lanProfileImportPhoneFailed);
        expect('</script>'.allMatches(page), hasLength(1));
        expect(page, isNot(contains('src="http')));
        expect(page, contains('form.hidden=true'));
        expect(page, contains('requestAnimationFrame'));
      }
    });

    test('selects only private LAN IPv4 addresses', () {
      expect(isPrivateLanIPv4('10.0.0.1'), isTrue);
      expect(isPrivateLanIPv4('172.16.1.1'), isTrue);
      expect(isPrivateLanIPv4('172.31.255.254'), isTrue);
      expect(isPrivateLanIPv4('192.168.1.10'), isTrue);
      expect(isPrivateLanIPv4('127.0.0.1'), isFalse);
      expect(isPrivateLanIPv4('198.18.0.1'), isFalse);
      expect(isPrivateLanIPv4('8.8.8.8'), isFalse);
    });
  });
}

class _UnsafeLocalizations extends AppLocalizations {
  @override
  String get lanProfileImportTitle => '<unsafe>';

  @override
  String get lanProfileImportPhoneFailed => '</script><unsafe>';
}

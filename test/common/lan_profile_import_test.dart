import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';

void main() {
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
    }) async {
      server = LanProfileImportServer(
        onImport: onImport ?? (_) async {},
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
      final request = await client.openUrl(method, target);
      request.headers.contentType = ContentType.parse(contentType);
      if (body != null) {
        request.add(utf8.encode(body is String ? body : jsonEncode(body)));
      }
      final response = await request.close();
      await response.drain<void>();
      client.close(force: true);
      return response;
    }

    test('accepts one valid URL and calls back once', () async {
      final imported = <SubscriptionImportTarget>[];
      final uri = await start(onImport: (target) async => imported.add(target));

      final response = await send(
        uri,
        body: {'url': 'https://example.com/sub'},
      );

      expect(response.statusCode, HttpStatus.accepted);
      expect(imported.single.url, 'https://example.com/sub');
    });

    test(
      'rejects method path content type and token without consuming',
      () async {
        final uri = await start();

        expect(
          (await send(uri, method: 'GET')).statusCode,
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
        expect(
          (await send(uri, body: {'url': 'https://example.com'})).statusCode,
          HttpStatus.accepted,
        );
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
        HttpStatus.accepted,
      );
    });

    test('closes before callback so a parallel replay cannot win', () async {
      final callbackStarted = Completer<void>();
      final release = Completer<void>();
      var calls = 0;
      final uri = await start(
        onImport: (_) async {
          calls++;
          callbackStarted.complete();
          await release.future;
        },
      );

      final first = send(uri, body: {'url': 'https://example.com/one'});
      await callbackStarted.future;
      await expectLater(
        send(uri, body: {'url': 'https://example.com/two'}),
        throwsA(isA<SocketException>()),
      );
      release.complete();
      expect((await first).statusCode, HttpStatus.accepted);
      expect(calls, 1);
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

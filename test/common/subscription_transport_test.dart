import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A real forward proxy, so the subscription client is exercised through the
/// same `findProxy` -> `connectionFactory` path the app uses on a device.
class _ForwardProxy {
  _ForwardProxy();

  late final HttpServer _server;
  final List<Uri> requestedUris = [];
  final List<String?> proxyAuthorizations = [];
  String? requiredCredentials;
  String body = 'proxies: []';

  int get port => _server.port;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen(_handle);
  }

  Future<void> stop() => _server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    requestedUris.add(request.requestedUri);
    final authorization = request.headers.value(
      HttpHeaders.proxyAuthorizationHeader,
    );
    proxyAuthorizations.add(authorization);
    final expected = requiredCredentials;
    if (expected != null) {
      final encoded = base64.encode(utf8.encode(expected));
      if (authorization != 'Basic $encoded') {
        request.response.statusCode = HttpStatus.proxyAuthenticationRequired;
        request.response.headers.set(
          HttpHeaders.proxyAuthenticateHeader,
          'Basic realm="reclash"',
        );
        await request.response.close();
        return;
      }
    }
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.text;
    request.response.write(body);
    await request.response.close();
  }
}

ProviderContainer _container({
  required int mixedPort,
  bool authentication = false,
  String username = 'reclash',
  String password = 'secret',
  bool started = true,
  bool paused = false,
}) {
  final container = ProviderContainer(
    overrides: [
      ...buildConfigOverrides(
        Config(
          themeProps: defaultThemeProps,
          networkProps: defaultNetworkProps.copyWith(
            authentication: authentication
                ? AuthenticationProps(
                    enable: true,
                    username: username,
                    password: password,
                  )
                : defaultAuthenticationProps,
          ),
          patchClashConfig: defaultClashConfig.copyWith(mixedPort: mixedPort),
        ),
      ),
      isStartProvider.overrideWithValue(started),
      pausedProvider.overrideWithValue(paused),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ForwardProxy proxy;
  late HttpOverrides? previousOverrides;

  setUpAll(() {
    globalState.packageInfo = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: '1.2.3',
      buildNumber: '1',
    );
  });

  setUp(() async {
    previousOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    proxy = _ForwardProxy();
    await proxy.start();
  });

  tearDown(() async {
    await proxy.stop();
    HttpOverrides.global = previousOverrides;
  });

  test('the proxy entry is an address literal, never a name', () {
    final container = _container(mixedPort: proxy.port);

    final proxyString = ReClashHttpOverrides.findProxyForReader(
      container.read,
      Uri.parse('http://subscription.test/sub'),
    );

    expect(proxyString, 'PROXY $localhost:${proxy.port}');
  });

  test(
    'a running core routes the subscription through its mixed port',
    () async {
      final container = _container(mixedPort: proxy.port);
      final client = Request()..attach(container.read);

      final response = await client.getFileResponseForUrl(
        'http://subscription.test/sub',
      );

      expect(utf8.decode(response.data!), 'proxies: []');
      expect(proxy.requestedUris.single.host, 'subscription.test');
    },
  );

  test('an authenticated mixed port receives the proxy credentials', () async {
    proxy.requiredCredentials = 'reclash:secret';
    final container = _container(mixedPort: proxy.port, authentication: true);
    final client = Request()..attach(container.read);

    final response = await client.getFileResponseForUrl(
      'http://subscription.test/sub',
    );

    expect(utf8.decode(response.data!), 'proxies: []');
    expect(
      proxy.proxyAuthorizations.last,
      'Basic ${base64.encode(utf8.encode('reclash:secret'))}',
    );
  });

  test('credentials containing separators still reach the proxy', () async {
    proxy.requiredCredentials = 'user:p@ss:word';
    final container = _container(
      mixedPort: proxy.port,
      authentication: true,
      username: 'user',
      password: 'p@ss:word',
    );
    final client = Request()..attach(container.read);

    final response = await client.getFileResponseForUrl(
      'http://subscription.test/sub',
    );

    expect(utf8.decode(response.data!), 'proxies: []');
    expect(
      proxy.proxyAuthorizations.last,
      'Basic ${base64.encode(utf8.encode('user:p@ss:word'))}',
    );
  });

  test('a stopped core fetches without the proxy', () async {
    final container = _container(mixedPort: proxy.port, started: false);
    final client = Request()..attach(container.read);

    await expectLater(
      client.getFileResponseForUrl('http://127.0.0.1:1/sub'),
      throwsA(isA<DioException>()),
    );
    expect(proxy.requestedUris, isEmpty);
  });

  test('a paused core fetches without the proxy', () async {
    final container = _container(
      mixedPort: proxy.port,
      started: true,
      paused: true,
    );
    final client = Request()..attach(container.read);

    await expectLater(
      client.getFileResponseForUrl('http://127.0.0.1:1/sub'),
      throwsA(isA<DioException>()),
    );
    expect(proxy.requestedUris, isEmpty);
  });

  test(
    'an authenticated core rejects credentials the panel asks to drop',
    () async {
      proxy.requiredCredentials = 'reclash:secret';
      final container = _container(mixedPort: proxy.port);
      final client = Request()..attach(container.read);

      await expectLater(
        client.getFileResponseForUrl('http://subscription.test/sub'),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.badResponse,
          ),
        ),
      );
      expect(proxy.proxyAuthorizations.single, isNull);
    },
  );
}

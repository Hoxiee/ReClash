import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String redactUrlForLog(Uri url) => Uri(
  scheme: url.scheme,
  host: url.host,
  port: url.hasPort ? url.port : null,
).toString();

class ReClashHttpOverrides extends HttpOverrides {
  final ProviderContainer _container;

  ReClashHttpOverrides(this._container);

  static String findProxyFor(ProviderContainer container, Uri url) {
    return findProxyForReader(container.read, url);
  }

  static String findProxyForReader(ProviderReader read, Uri url) {
    if ([localhost].contains(url.host)) {
      return 'DIRECT';
    }
    final isStart = read(isStartProvider);
    final paused = read(pausedProvider);
    commonPrint.log('find ${redactUrlForLog(url)} proxy: $isStart');
    if (!isStart || paused) return 'DIRECT';
    final mixedPort = read(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    return 'PROXY $localhost:$mixedPort';
  }

  // Credentials never ride in the proxy string: a password containing '@' or
  // ':' would be mis-split by the parser.
  static void applyProxyAuthentication(HttpClient client, ProviderReader read) {
    final attempted = <(String, int, String?, String, String)>{};
    client.authenticateProxy = (host, port, scheme, realm) async {
      final authentication = read(networkSettingProvider).authentication;
      if (host != localhost ||
          port != read(patchClashConfigProvider).mixedPort ||
          !read(isStartProvider) ||
          read(pausedProvider) ||
          scheme.toLowerCase() != 'basic' ||
          authentication.credentials.isEmpty ||
          !attempted.add((
            host,
            port,
            realm,
            authentication.username,
            authentication.password,
          ))) {
        return false;
      }
      client.addProxyCredentials(
        host,
        port,
        realm ?? '',
        HttpClientBasicCredentials(
          authentication.username,
          authentication.password,
        ),
      );
      return true;
    };
  }

  static bool allowBadCertificate(
    ProviderContainer container,
    X509Certificate certificate,
    String host,
    int port,
  ) {
    return allowBadCertificateForReader(
      container.read,
      certificate,
      host,
      port,
    );
  }

  static bool allowBadCertificateForReader(
    ProviderReader read,
    X509Certificate certificate,
    String host,
    int port,
  ) {
    final checkCertificate = read(
      appSettingProvider.select((state) => state.checkCertificate),
    );
    commonPrint.log(
      'untrusted certificate for $host:$port issued by ${certificate.issuer}, '
      'check: $checkCertificate',
      logLevel: LogLevel.warning,
    );
    return !checkCertificate;
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (certificate, host, port) =>
        allowBadCertificate(_container, certificate, host, port);
    client.findProxy = (url) => findProxyFor(_container, url);
    applyProxyAuthentication(client, _container.read);
    return client;
  }
}

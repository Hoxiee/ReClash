import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    commonPrint.log('find $url proxy: $isStart');
    if (!isStart || paused) return 'DIRECT';
    final mixedPort = read(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    return 'PROXY localhost:$mixedPort';
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
    return client;
  }
}

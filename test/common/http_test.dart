import 'dart:io';
import 'dart:typed_data';

import 'package:reclash/common/util/constant.dart';
import 'package:reclash/common/net/http.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

class _FakeCertificate implements X509Certificate {
  @override
  String get issuer => 'CN=Untrusted';

  @override
  String get subject => 'CN=example.com';

  @override
  DateTime get startValidity => DateTime(2026);

  @override
  DateTime get endValidity => DateTime(2027);

  @override
  Uint8List get der => Uint8List(0);

  @override
  String get pem => '';

  @override
  Uint8List get sha1 => Uint8List(0);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer buildContainer({
    bool running = true,
    String? currentSsid,
    List<String> trustedNetworks = const [],
    int mixedPort = 7890,
    bool checkCertificate = true,
  }) {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(runTimeProvider.notifier).value = running ? 1 : null;
    container.read(currentSSIDProvider.notifier).value = currentSsid;
    if (trustedNetworks.isNotEmpty) {
      container
          .read(vpnSettingProvider.notifier)
          .update(
            (_) => const VpnProps().copyWith(
              smartPauseEnabled: true,
              smartPauseNetworks: trustedNetworks,
            ),
          );
    }
    container.read(patchClashConfigProvider.notifier).value =
        const PatchClashConfig().copyWith(mixedPort: mixedPort);
    container.read(appSettingProvider.notifier).value = const AppSettingProps()
        .copyWith(checkCertificate: checkCertificate);
    return container;
  }

  final remote = Uri.parse('https://example.com/path');

  test('redacts URL credentials, path tokens and query data from logs', () {
    final redacted = redactUrlForLog(
      Uri.parse(
        'https://user:pass@example.com/sub/path-secret?token=secret#private',
      ),
    );

    expect(redacted, 'https://example.com');
    expect(redacted, isNot(contains('user')));
    expect(redacted, isNot(contains('secret')));
  });

  test('loopback traffic always bypasses the proxy', () {
    final container = buildContainer();

    expect(
      ReClashHttpOverrides.findProxyFor(
        container,
        Uri.parse('http://$localhost:9090/ui'),
      ),
      'DIRECT',
    );
  });

  test('routes through the mixed port while the core is running', () {
    final container = buildContainer(mixedPort: 7891);

    expect(
      ReClashHttpOverrides.findProxyFor(container, remote),
      'PROXY $localhost:7891',
    );
  });

  test('holds credentials out of the proxy string', () {
    final container = buildContainer();
    container.read(networkSettingProvider.notifier).value = const NetworkProps()
        .copyWith(
          authentication: const AuthenticationProps(
            enable: true,
            username: 'user',
            password: 'pass',
          ),
        );

    expect(
      ReClashHttpOverrides.findProxyFor(container, remote),
      'PROXY $localhost:7890',
    );

    container.read(networkSettingProvider.notifier).value = const NetworkProps()
        .copyWith(
          authentication: const AuthenticationProps(
            enable: false,
            username: 'user',
          ),
        );
    expect(
      ReClashHttpOverrides.findProxyFor(container, remote),
      'PROXY $localhost:7890',
    );
  });

  test('bypasses the proxy when the core is not running', () {
    final container = buildContainer(running: false);

    expect(ReClashHttpOverrides.findProxyFor(container, remote), 'DIRECT');
  });

  test('bypasses the proxy on a trusted network', () {
    final container = buildContainer(
      currentSsid: 'Office Wi-Fi',
      trustedNetworks: const ['Office Wi-Fi'],
    );

    expect(ReClashHttpOverrides.findProxyFor(container, remote), 'DIRECT');
  });

  test('keeps proxying when the current network is not trusted', () {
    final container = buildContainer(
      currentSsid: 'Home Wi-Fi',
      trustedNetworks: const ['Office Wi-Fi'],
    );

    expect(
      ReClashHttpOverrides.findProxyFor(container, remote),
      'PROXY $localhost:7890',
    );
  });

  test('an untrusted loopback certificate is rejected by default', () {
    final container = buildContainer();

    expect(
      ReClashHttpOverrides.allowBadCertificate(
        container,
        _FakeCertificate(),
        localhost,
        443,
      ),
      isFalse,
    );
  });

  test('turning the check off accepts an untrusted loopback certificate', () {
    final container = buildContainer(checkCertificate: false);

    for (final host in [localhost, 'localhost', '::1']) {
      expect(
        ReClashHttpOverrides.allowBadCertificate(
          container,
          _FakeCertificate(),
          host,
          443,
        ),
        isTrue,
        reason: '$host should be treated as loopback',
      );
    }
  });

  test('an untrusted certificate is rejected for non-loopback hosts', () {
    final container = buildContainer(checkCertificate: false);

    for (final host in ['example.com', '1.1.1.1']) {
      expect(
        ReClashHttpOverrides.allowBadCertificate(
          container,
          _FakeCertificate(),
          host,
          443,
        ),
        isFalse,
        reason: '$host must never bypass certificate validation',
      );
    }
  });

  test('non-loopback certificates stay rejected with the check enabled', () {
    final container = buildContainer();

    expect(
      ReClashHttpOverrides.allowBadCertificate(
        container,
        _FakeCertificate(),
        'example.com',
        443,
      ),
      isFalse,
    );
  });
}

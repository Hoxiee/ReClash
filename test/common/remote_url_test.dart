import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/remote_url.dart';

void main() {
  test('blocks loopback, link-local, CGNAT and metadata targets', () {
    for (final url in [
      'http://127.0.0.1/',
      'http://127.1/',
      'http://2130706433/',
      'http://0x7f000001/',
      'http://0177.0.0.1/',
      'http://0.0.0.0/',
      'http://169.254.169.254/latest/meta-data',
      'http://100.100.100.200/',
      'http://168.63.129.16/',
      'http://localhost/',
      'http://localhost./',
      'http://panel.localhost/',
      'http://metadata.google.internal/',
      'http://instance-data/',
      'http://metadata.tencentyun.com/',
      'http://[::1]/',
      'http://[::ffff:127.0.0.1]/',
      'http://[fe80::1]/',
      'http://[fd00:ec2::254]/',
      'http://224.0.0.1/',
      'ftp://example.com/',
      'http://user:pass@example.com/',
    ]) {
      expect(isBlockedRemoteUrl(url), isTrue, reason: url);
    }
  });

  test('allows public and RFC 1918/ULA subscription hosts', () {
    for (final url in [
      'https://example.com/logo.png',
      'http://192.168.1.10:8080/sub',
      'http://10.0.0.2/sub',
      'http://172.16.0.1/sub',
      'http://nas.local/sub',
      'http://router/sub',
      'http://[fd00::1]/sub',
      'http://[fd12:3456::1]/sub',
      'https://example.com:8443/path',
    ]) {
      expect(isBlockedRemoteUrl(url), isFalse, reason: url);
    }
  });

  test('a provider URL keeps its credentials but not a local target', () {
    expect(
      isBlockedProviderUrl('https://user:pass@example.com/provider.yaml'),
      isFalse,
    );
    for (final url in [
      'http://127.0.0.1/provider.yaml',
      'http://[::1]/provider.yaml',
      'http://169.254.169.254/provider.yaml',
      'ftp://example.com/provider.yaml',
      'file:///etc/hosts',
    ]) {
      expect(isBlockedProviderUrl(url), isTrue, reason: url);
    }
  });

  test('a content URL never resolves a blocked literal', () async {
    expect(
      await resolvesToBlockedRemoteAddress(Uri.parse('http://127.1/')),
      isTrue,
    );
    expect(
      await resolvesToBlockedRemoteAddress(Uri.parse('http://192.168.1.10/')),
      isFalse,
    );
  });
}

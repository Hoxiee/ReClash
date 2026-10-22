import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/rcx_link.dart';

void main() {
  test('round trips text including non-ASCII', () {
    const yaml = 'rcx: 1\nprofiles:\n  - name: "Домашний маршрут ✓"\n';
    final link = encodeRcxLink(yaml);

    expect(link, startsWith('reclash://routing?p='));
    expect(link.split('p=').last, isNot(contains('=')));
    expect(decodeRcxPayload(Uri.parse(link).queryParameters['p']!), yaml);
  });

  test('rejects malformed payloads', () {
    for (final bad in [
      '',
      '***',
      'AAAA',
      base64Url.encode([1, 2, 3, 4]),
    ]) {
      expect(() => decodeRcxPayload(bad), throwsFormatException, reason: bad);
    }
    final invalidUtf8 = base64Url.encode(
      ZLibEncoder(raw: true).convert([0xff, 0xfe]),
    );
    expect(() => decodeRcxPayload(invalidUtf8), throwsFormatException);
  });

  test('rejects output above the size limit without inflating it', () {
    final bomb = ZLibEncoder(
      raw: true,
      level: 9,
    ).convert(List.filled(100 * 1024 * 1024, 0x61));
    expect(bomb.length, lessThan(256 * 1024));
    expect(
      () => decodeRcxPayload(base64Url.encode(bomb)),
      throwsFormatException,
    );
    final exact = 'a' * rcxLinkMaxBytes;
    expect(decodeRcxPayload(encodeRcxLink(exact).split('p=').last), exact);
  });
}

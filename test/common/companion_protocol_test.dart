import 'dart:convert';
import 'dart:io';

import 'package:reclash/common/companion/companion_protocol.dart';
import 'package:reclash/common/util/string.dart';
import 'package:reclash/models/companion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixtures =
      jsonDecode(
            File('test/fixtures/companion/qr_cases.json').readAsStringSync(),
          )
          as Map<String, dynamic>;

  group('companion pairing QR parser (shared fixtures)', () {
    test('S01 valid QR parses to the expected typed payload', () {
      final valid = fixtures['valid'] as Map<String, dynamic>;
      final result = parseCompanionPairingQr(valid['raw'] as String);

      expect(result, isA<CompanionQrPaired>());
      final payload = (result as CompanionQrPaired).payload;
      expect(payload.deviceId, valid['deviceId']);
      expect(payload.host, valid['host']);
      expect(payload.port, valid['port']);
      expect(payload.spkiPin, valid['spkiPin']);
      expect(payload.pairingSecret, valid['pairingSecret']);
      expect(payload.baseUrl, 'https://${valid['host']}:${valid['port']}');
    });

    test('S01 every malformed QR is rejected with its typed reason', () {
      for (final entry in (fixtures['rejected'] as List)) {
        final map = entry as Map<String, dynamic>;
        final result = parseCompanionPairingQr(map['raw'] as String);
        expect(
          result,
          isA<CompanionQrRejected>(),
          reason: 'expected rejection for ${map['reason']}',
        );
        expect(
          (result as CompanionQrRejected).reason.name,
          map['reason'],
          reason: map['raw'] as String,
        );
      }
    });

    test('S01 oversize input is rejected before any parsing', () {
      final huge = 'reclash://companion/pair?v=1&x=${'a' * 3000}';
      final result = parseCompanionPairingQr(huge);
      expect(result, isA<CompanionQrRejected>());
      expect(
        (result as CompanionQrRejected).reason,
        CompanionQrRejection.tooLarge,
      );
    });
  });

  group('S02 companion and subscription QR never cross over', () {
    test('a subscription URL is not a companion pairing link', () {
      const sub = 'https://sub.example.com/config.yaml';
      expect(isCompanionPairingLink(sub), isFalse);
      expect(sub.isProfileImportLink, isTrue);
    });

    test('a companion pairing link is not a profile import link', () {
      final valid = (fixtures['valid'] as Map<String, dynamic>)['raw'] as String;
      expect(isCompanionPairingLink(valid), isTrue);
      expect(valid.isProfileImportLink, isFalse);
    });

    test('legacy custom schemes stay profile imports, not companion', () {
      for (final legacy in ['incy://subscription', 'happ://add/x']) {
        expect(isCompanionPairingLink(legacy), isFalse);
        expect(legacy.isProfileImportLink, isTrue);
      }
    });
  });

  test('parsed payload never leaks the secret or pin in toString', () {
    final valid = (fixtures['valid'] as Map<String, dynamic>)['raw'] as String;
    final payload = (parseCompanionPairingQr(valid) as CompanionQrPaired).payload;
    final text = payload.toString();
    expect(text, contains('<redacted>'));
    expect(text, isNot(contains(payload.pairingSecret)));
    expect(text, isNot(contains(payload.spkiPin)));
  });
}

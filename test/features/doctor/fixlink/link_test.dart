import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/fixlink/link.dart';
import 'package:reclash/features/doctor/fixlink/verifier.dart';

import 'fixture.dart';

Matcher _rejected(FixLinkRejection reason) => throwsA(
  isA<FixLinkRejected>().having((error) => error.reason, 'reason', reason),
);

void main() {
  group('the reference vector', () {
    test('parses into its payload', () {
      final payload = parseFixLink(vectorLink).payload;
      expect(payload.keyId, vectorKeyId);
      expect(payload.reportId, vectorReport);
      expect(payload.expires, DateTime.utc(2026));
      expect(payload.nonce, 'AAECAwQFBgcICQoL');
      expect(payload.actions, const [
        FixAction('profile.update'),
        FixAction('proxy.select', group: 'Auto', node: 'NL-1'),
      ]);
    });

    test('derives its key id from the header key', () async {
      final key = parseSupportKey(vectorHeader)!;
      expect(key, await publicKey(await seededKeys()));
      expect(supportKeyId(key), vectorKeyId);
    });

    test('verifies against the signing profile', () async {
      final verifier = await fixtureVerifier();
      final verified = await verifier.verify(vectorLink);
      expect(verified.profileId, 1);
      expect(verified.payload.reportId, vectorReport);
    });
  });

  group('parsing', () {
    test('rejects a link over 2 KB before reading it', () {
      expect(
        () => parseFixLink('reclash://fix?p=${'A' * 2100}&s=A'),
        _rejected(FixLinkRejection.oversized),
      );
    });

    test('rejects any field or argument it does not know', () async {
      for (final payload in [
        {...fixturePayload(), 'extra': true},
        fixturePayload(
          fix: [
            {'id': 'profile.update', 'url': 'https://example.com'},
          ],
        ),
        fixturePayload(
          fix: [
            {'id': 'proxy.select', 'group': 'Auto'},
          ],
        ),
        {...fixturePayload(), 'v': 2},
        fixturePayload(rid: 'RC-1234'),
        fixturePayload(nonce: 'AAEC'),
        fixturePayload(fix: []),
      ]) {
        expect(
          () async => parseFixLink(await signLink(payload)),
          _rejected(FixLinkRejection.malformed),
          reason: jsonEncode(payload),
        );
      }
    });

    test('rejects a link of another shape', () {
      for (final link in [
        'reclash://doctor?p=e30&s=AA',
        '$vectorLink&x=1',
        '$vectorLink#f',
        vectorLink.replaceFirst('&s=', '&p='),
        vectorLink.replaceFirst('s=XEdY', 's=XEdY='),
      ]) {
        expect(
          () => parseFixLink(link),
          _rejected(FixLinkRejection.malformed),
          reason: link,
        );
      }
    });
  });

  group('verification', () {
    test('rejects a key no installed profile sent', () async {
      final other = await seededKeys(7);
      final verifier = await fixtureVerifier(
        keys: [TrustedKey(profileId: 1, key: await publicKey(other))],
      );
      expect(
        () => verifier.verify(vectorLink),
        _rejected(FixLinkRejection.unknownKey),
      );
    });

    test('rejects a tampered payload or a signature by another key', () async {
      final verifier = await fixtureVerifier();
      final signed = parseFixLink(vectorLink).signed;
      final tampered = utf8.encode(
        utf8.decode(signed).replaceFirst('NL-1', 'NL-2'),
      );
      final signature = vectorLink.split('&s=').last;
      expect(
        () => verifier.verify(
          'reclash://fix?p=${encodeBase64Url(tampered)}&s=$signature',
        ),
        _rejected(FixLinkRejection.badSignature),
      );
      expect(
        () async => verifier.verify(
          await signLink(fixturePayload(), keys: await seededKeys(7)),
        ),
        _rejected(FixLinkRejection.badSignature),
      );
    });

    test('rejects an expired link and one valid over 7 days', () async {
      final verifier = await fixtureVerifier();
      expect(
        () async => verifier.verify(
          await signLink(fixturePayload(expires: fixtureNow)),
        ),
        _rejected(FixLinkRejection.expired),
      );
      expect(
        () async => verifier.verify(
          await signLink(
            fixturePayload(
              expires: fixtureNow.add(const Duration(days: 7, seconds: 1)),
            ),
          ),
        ),
        _rejected(FixLinkRejection.tooFarAhead),
      );
    });

    test('rejects a nonce already spent', () async {
      final nonces = MemoryNonces()..used.add('AAECAwQFBgcICQoL');
      final verifier = await fixtureVerifier(nonces: nonces);
      expect(
        () => verifier.verify(vectorLink),
        _rejected(FixLinkRejection.replayed),
      );
    });

    test('rejects a report this device did not make in 30 days', () async {
      for (final reports in [
        [fixtureReport(id: 'RC-0000-0000')],
        [fixtureReport(age: const Duration(days: 31))],
      ]) {
        final verifier = await fixtureVerifier(reports: reports);
        expect(
          () => verifier.verify(vectorLink),
          _rejected(FixLinkRejection.unknownReport),
        );
      }
    });

    test('rejects a report made for another profile', () async {
      for (final profileId in [2, null]) {
        final verifier = await fixtureVerifier(
          reports: [fixtureReport(profileId: profileId)],
        );
        expect(
          () => verifier.verify(vectorLink),
          _rejected(FixLinkRejection.otherProfile),
          reason: '$profileId',
        );
      }
    });

    test('rejects the whole link for one action off the allowlist', () async {
      final verifier = await fixtureVerifier();
      for (final id in ['proxy.clear', 'made.up']) {
        expect(
          () async => verifier.verify(
            await signLink(
              fixturePayload(
                fix: [
                  {'id': 'config.ruleMode'},
                  {'id': id},
                ],
              ),
            ),
          ),
          _rejected(FixLinkRejection.unknownAction),
          reason: id,
        );
      }
    });

    test('accepts own-reach remedies and the fixed actions', () async {
      final verifier = await fixtureVerifier();
      final verified = await verifier.verify(
        await signLink(
          fixturePayload(
            fix: [
              for (final id in [
                'proxy.clearOwn',
                'profile.activate',
                'connections.reset',
                'core.restart',
                'overrides.reset',
              ])
                {'id': id},
            ],
          ),
        ),
      );
      expect(verified.payload.actions, hasLength(5));
    });

    test('rejects a group the profile does not have', () async {
      final verifier = await fixtureVerifier(groups: const {'Manual'});
      expect(
        () => verifier.verify(vectorLink),
        _rejected(FixLinkRejection.unknownGroup),
      );
    });
  });
}

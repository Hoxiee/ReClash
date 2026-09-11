import 'dart:convert';

import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCapabilityManifestHeader', () {
    test('parses versioned claims and selectors', () {
      final result = parseCapabilityManifestHeader({
        'X-ReClash-Capabilities': [
          _header({
            'v': 1,
            'claims': [
              {
                'cap': 'youtube-adfree',
                'selectors': [
                  {'name_contains': '⚡'},
                ],
              },
              {
                'cap': 'gemini-access',
                'selectors': [
                  {'provider': 'premium', 'name_contains': '⭐'},
                ],
              },
            ],
          }),
        ],
      });

      expect(result, isA<CapabilityManifestHeaderValid>());
      final claims = (result as CapabilityManifestHeaderValid).claims;
      expect(claims, hasLength(2));
      expect(claims.first.capabilityId, 'youtube-adfree');
      expect(claims.first.selectors.single.nameContains, '⚡');
      expect(claims.last.selectors.single.provider, 'premium');
    });

    test('distinguishes absent, empty, and malformed headers', () {
      expect(
        parseCapabilityManifestHeader(const {}),
        isA<CapabilityManifestHeaderAbsent>(),
      );
      final empty = parseCapabilityManifestHeader({
        capabilityManifestHeader: [
          _header({'v': 1, 'claims': []}),
        ],
      });
      expect((empty as CapabilityManifestHeaderValid).claims, isEmpty);
      for (final value in [
        'v2.payload',
        'v1.not+base64url',
        _header({'v': 2, 'claims': []}),
        _header({'v': 1, 'claims': [], 'rules': []}),
      ]) {
        expect(
          parseCapabilityManifestHeader({
            capabilityManifestHeader: [value],
          }),
          isA<CapabilityManifestHeaderInvalid>(),
          reason: value,
        );
      }
    });

    test(
      'ignores invalid claims and selectors without accepting new fields',
      () {
        final result = parseCapabilityManifestHeader({
          capabilityManifestHeader: [
            _header({
              'v': 1,
              'claims': [
                {
                  'cap': 'Bad ID',
                  'selectors': [
                    {'name_contains': 'ignored'},
                  ],
                },
                {
                  'cap': 'future-capability',
                  'selectors': [
                    {'name_contains': ''},
                    {'regex': '.*'},
                    {'provider': 'nested'},
                  ],
                },
              ],
            }),
          ],
        });

        final claims = (result as CapabilityManifestHeaderValid).claims;
        expect(claims, hasLength(1));
        expect(claims.single.capabilityId, 'future-capability');
        expect(claims.single.selectors, [
          const CapabilitySelector(provider: 'nested'),
        ]);
      },
    );

    test('rejects explicit null selector fields', () {
      final result = parseCapabilityManifestHeader({
        capabilityManifestHeader: [
          _header({
            'v': 1,
            'claims': [
              {
                'cap': 'gemini-access',
                'selectors': [
                  {'provider': null},
                  {'name_contains': null},
                  {'provider': 'premium', 'name_contains': null},
                ],
              },
            ],
          }),
        ],
      });

      expect((result as CapabilityManifestHeaderValid).claims, isEmpty);
    });

    test('rejects oversized manifests and selector totals', () {
      final tooManySelectors = List.generate(
        capabilityManifestMaxSelectors + 1,
        (_) => {'name_contains': 'x'},
      );
      final result = parseCapabilityManifestHeader({
        capabilityManifestHeader: [
          _header({
            'v': 1,
            'claims': [
              {'cap': 'gemini-access', 'selectors': tooManySelectors},
            ],
          }),
        ],
      });
      expect(result, isA<CapabilityManifestHeaderInvalid>());

      expect(
        parseCapabilityManifestHeader({
          capabilityManifestHeader: [
            'v1.${'a' * capabilityManifestMaxHeaderBytes}',
          ],
        }),
        isA<CapabilityManifestHeaderInvalid>(),
      );
    });
  });

  test('capability profile models round-trip through JSON', () {
    final manifest = ProviderCapabilityManifest(
      version: 1,
      claims: const [
        CapabilityClaim(
          capabilityId: 'youtube-adfree',
          selectors: [CapabilitySelector(nameContains: '⚡')],
        ),
      ],
      receivedAt: DateTime.utc(2026, 9, 9),
      sourceHost: 'provider.test',
    );
    final restored = ProviderCapabilityManifest.fromJson(
      jsonDecode(jsonEncode(manifest.toJson())) as Map<String, Object?>,
    );

    expect(restored, manifest);
    expect(
      ServiceRoutePolicy.fromJson(
        jsonDecode(
              jsonEncode(
                const ServiceRoutePolicy(
                  capabilityId: 'gemini-access',
                  enabled: true,
                  fallback: ServiceRouteFallback.reject,
                ).toJson(),
              ),
            )
            as Map<String, Object?>,
      ).fallback,
      ServiceRouteFallback.reject,
    );
  });
}

String _header(Map<String, Object?> value) =>
    'v1.${base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '')}';

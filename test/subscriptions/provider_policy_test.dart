import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_policy.dart';

const _profile = '''
reclash-policy:
  version: 1
  global: {allow: [safe]}
  apps:
    android:
      exclude: [com.example.bank]
proxies:
  - {name: display name, reclash-id: safe, type: socks5, server: example.test, port: 1080}
''';

SubscriptionImportResult _import(String value) =>
    convertSubscriptionImport(Uint8List.fromList(utf8.encode(value)));

void main() {
  test('native policy is validated before the subscription is saved', () {
    final result = _import(_profile);
    expect(result.summary.providerPolicy?.globalAllow, ['safe']);
    expect(result.summary.providerPolicy?.requiredExcludedApps, {
      'com.example.bank',
    });
    expect(utf8.decode(result.bytes), _profile);
  });

  test('an old subscription remains unrestricted', () {
    final result = _import('proxies: []\n');
    expect(result.summary.providerPolicy, isNull);
  });

  test('an empty allow list forbids every global node', () {
    final policy = _import(
      _profile.replaceFirst('[safe]', '[]'),
    ).summary.providerPolicy!;
    expect(policy.isGlobalRestricted, isTrue);
    expect(policy.globalAllow, isEmpty);
  });

  for (final entry in <String, String>{
    'unknown version': _profile.replaceFirst('version: 1', 'version: 2'),
    'unknown node': _profile.replaceFirst('allow: [safe]', 'allow: [missing]'),
    'duplicate permission': _profile.replaceFirst(
      'allow: [safe]',
      'allow: [safe, safe]',
    ),
    'unknown setting': _profile.replaceFirst(
      'global: {allow: [safe]}',
      'global: {allow: [safe], fallback: direct}',
    ),
    'null policy': 'reclash-policy: null\nproxies: []\n',
    'missing version': 'reclash-policy: {global: {allow: []}}\nproxies: []\n',
    'bad package': _profile.replaceFirst('com.example.bank', '*'),
    'unknown platform': _profile.replaceFirst('android:', 'linux:'),
    'duplicate node ID':
        '$_profile  - {name: other, reclash-id: safe, type: socks5, server: other.test, port: 1080}\n',
    'missing allow': 'reclash-policy: {version: 1, global: {}}\nproxies: []\n',
  }.entries) {
    test('rejects ${entry.key} rather than discarding the policy', () {
      expect(
        () => _import(entry.value),
        throwsA(isA<SubscriptionImportException>()),
      );
    });
  }

  test('conversion cannot silently strip a provider policy', () {
    final content = jsonEncode({
      'outbounds': [
        {'type': 'direct', 'tag': 'direct'},
      ],
      'reclash-policy': {
        'version': 1,
        'apps': {
          'android': {
            'exclude': ['com.example.bank'],
          },
        },
      },
    });
    expect(() => _import(content), throwsA(isA<SubscriptionImportException>()));
  });

  test('lists are bounded and strict', () {
    expect(
      () => ProviderPolicy.fromJson({
        'version': 1,
        'global': {
          'allow': List.generate(maxProviderPolicyNodes + 1, (i) => 'node-$i'),
        },
      }),
      throwsFormatException,
    );
    expect(
      () => ProviderPolicy.fromJson({
        'version': 1,
        'apps': {
          'android': {
            'exclude': ['com.example.bank', 1],
          },
        },
      }),
      throwsFormatException,
    );
  });

  test('the snapshot persists required policy independently of hints', () {
    final policy = _import(_profile).summary.providerPolicy!;
    final snapshot = SubscriptionSnapshot(
      metadata: const SubscriptionMetadata({
        'apps.exclude': ['com.example.optional'],
      }),
      receivedAt: DateTime.utc(2026),
      providerPolicy: policy,
    );
    final restored = SubscriptionSnapshot.fromJson(
      Map<String, Object?>.from(
        jsonDecode(jsonEncode(snapshot.toJson())) as Map,
      ),
    );
    expect(restored, snapshot);
    expect(restored.providerPolicy?.requiredExcludedApps, {'com.example.bank'});
    expect(restored.metadata.strings('apps.exclude'), ['com.example.optional']);
    expect(ProviderPolicy.fromJson(policy.toJson()), policy);
  });
}

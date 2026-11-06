import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_policy.dart';

import '../helpers/provider_presentation.dart';

const _proxies = '''
proxies:
  - {name: a, type: socks5, server: a.test, port: 1080}
  - {name: b, type: socks5, server: b.test, port: 1080}
  - {name: c, type: socks5, server: c.test, port: 1080}
''';

const _nested =
    '''
$_proxies
proxy-groups:
  - {name: GLOBAL, type: select, proxies: [pool, a]}
  - {name: pool, type: select, proxies: [b, pool, DIRECT]}
''';

SubscriptionImportResult _import(String value) =>
    convertSubscriptionImport(Uint8List.fromList(utf8.encode(value)));

ProviderPolicy? _derive(
  Map<String, Object?> policy,
  String body, {
  Map<String, Object?> sections = const {},
  int? globalNodes,
}) {
  final hints = ProviderHints(
    manifestMetadata({'policy': policy, ...sections}),
  );
  return ProviderPolicy.derive(
    restrictions: hints.restrictions.map((r) => r.name.toLowerCase()),
    globalNodes: globalNodes,
    excluded: _import(body).summary.excludedPackages,
  );
}

void main() {
  test('Dart cannot evaluate a group filter, so the Core has to', () {
    // ignore: valid_regexps
    expect(() => RegExp(r'(?i)\bLTE\b'), throwsFormatException);
    // regexp2 sees no word boundary inside this name; ASCII-only \b would.
    expect(RegExp(r'\bLTE\b').hasMatch('МегаLTE'), isTrue);
  });

  test('the Core wire form matches its Go encoding', () {
    final nodes = ProviderGlobalNodes.fromJson(
      jsonDecode('{"allowed":1,"inline":3}') as Map<String, Object?>,
    );
    expect((nodes.allowed, nodes.inline), (1, 3));
  });

  test('global listed follows the Core count for a filtered group', () {
    const filtered =
        '''
$_proxies
proxy-groups:
  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '(?i)^a\$'}
''';
    final policy = _derive({'global': 'listed'}, filtered, globalNodes: 1)!;
    expect(policy.lockGlobal, isTrue);
    expect(policy.isGlobalRestricted, isFalse);
    expect(
      _derive(
        {'global': 'listed'},
        filtered,
        globalNodes: 0,
      )?.isGlobalRestricted,
      isTrue,
    );
  });

  test('global listed restricts Global when the Core was not asked', () {
    expect(_derive({'global': 'listed'}, _nested)?.isGlobalRestricted, isTrue);
  });

  group('unrestricted lock warning', () {
    List<String> warnings(int allowed, int inline, {int remoteProviders = 0}) =>
        ProviderPolicy.warnings(
          ProviderGlobalNodes(allowed: allowed, inline: inline),
          remoteProviders: remoteProviders,
        );

    test('warns when GLOBAL reaches every inline route', () {
      expect(warnings(3, 3), [providerGlobalUnrestrictedWarning]);
    });

    test('stays quiet when the lock denies something', () {
      expect(warnings(2, 3), isEmpty);
      expect(warnings(3, 3, remoteProviders: 1), isEmpty);
    });

    test('stays quiet with nothing to narrow or nothing allowed', () {
      expect(warnings(1, 1), isEmpty);
      expect(warnings(0, 3), isEmpty);
      expect(warnings(0, 0), isEmpty);
      expect(ProviderPolicy.warnings(null, remoteProviders: 0), isEmpty);
    });
  });

  test('global off locks nothing in the policy and removes Global mode', () {
    final hints = ProviderHints(
      manifestMetadata({
        'policy': {'global': 'off'},
      }),
    );
    expect(hints.restrictions, {ProviderRestriction.noGlobal});
    expect(_derive({'global': 'off'}, _nested), isNull);
  });

  test('apps required picks up the body tun exclude-package', () {
    const body = '''
tun:
  exclude-package: [com.example.bank, not a package]
$_proxies''';
    expect(_import(body).summary.excludedPackages, ['com.example.bank']);
    final policy = _derive({'apps': 'required'}, body)!;
    expect(policy.lockApps, isTrue);
    expect(policy.requiredExcludedApps, {'com.example.bank'});
    expect(_derive({'apps': 'recommended'}, body), isNull);
  });

  test('an invalid value withdraws the whole policy section', () {
    expect(
      manifestMetadata({
        'policy': {'global': 'listed', 'apps': 'sometimes'},
      }).fields,
      isEmpty,
    );
    expect(_derive({'global': 'listed', 'apps': 'sometimes'}, _nested), isNull);
  });

  test('the policy values map to their restriction tokens', () {
    final metadata = manifestMetadata({
      'policy': {
        'global': 'listed',
        'apps': 'required',
        'local-ports': 'closed',
        'dashboard': 'locked',
      },
    });
    expect(metadata.strings('settings.restrictions'), [
      'lockglobal',
      'lockapps',
      'androidsecure',
      'denywidgets',
    ]);
  });

  test('an old subscription remains unrestricted', () {
    expect(
      ProviderPolicy.derive(
        restrictions: const [],
        globalNodes: 0,
        excluded: [],
      ),
      isNull,
    );
  });

  test('legacy policy keys in the body are ignored, not rejected', () {
    const body = '''
reclash-policy: {version: 9, nonsense: true}
rcx: 1
$_proxies''';
    final result = _import(body);
    expect(result.summary.nodes, 3);
    expect(utf8.decode(result.bytes), body);
  });

  test('the snapshot persists required policy independently of hints', () {
    final policy = _derive({
      'apps': 'required',
    }, 'tun:\n  exclude-package: [com.example.bank]\n$_proxies')!;
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

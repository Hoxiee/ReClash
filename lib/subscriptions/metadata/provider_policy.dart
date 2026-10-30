import 'package:collection/collection.dart';

import 'metadata.dart' show isAndroidPackageName;

const maxProviderPolicyNodes = 4096;
const maxProviderPolicyApps = 512;
final _nodeId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]{0,63}$');

class ProviderPolicyFormatException extends FormatException {
  const ProviderPolicyFormatException(super.message);
}

class ProviderPolicy {
  const ProviderPolicy({
    this.globalAllow,
    this.requiredExcludedApps = const {},
  });

  final List<String>? globalAllow;
  final Set<String> requiredExcludedApps;

  bool get isGlobalRestricted => globalAllow != null;

  factory ProviderPolicy.fromJson(Map<String, Object?> json) {
    _keys(json, const {'version', 'global', 'apps'});
    if (json['version'] != 1 || json['version'] is! int) {
      throw const ProviderPolicyFormatException(
        'Unsupported provider policy version',
      );
    }
    List<String>? allowed;
    if (json.containsKey('global')) {
      final global = _mapping(json['global']);
      _keys(global, const {'allow'});
      allowed = _strings(
        global['allow'],
        maxProviderPolicyNodes,
        _nodeId.hasMatch,
      );
    }
    var excluded = <String>{};
    if (json.containsKey('apps')) {
      final apps = _mapping(json['apps']);
      _keys(apps, const {'android'});
      if (apps.containsKey('android')) {
        final android = _mapping(apps['android']);
        _keys(android, const {'exclude'});
        excluded = _strings(
          android['exclude'],
          maxProviderPolicyApps,
          isAndroidPackageName,
        ).toSet();
      }
    }
    return ProviderPolicy(
      globalAllow: allowed == null ? null : List.unmodifiable(allowed),
      requiredExcludedApps: Set.unmodifiable(excluded),
    );
  }

  static ProviderPolicy? parseConfig(Map config) {
    if (!config.containsKey('reclash-policy')) return null;
    final policy = ProviderPolicy.fromJson(_mapping(config['reclash-policy']));
    final ids = <String>{};
    final proxies = config['proxies'];
    if (proxies is List) {
      for (final proxy in proxies) {
        if (proxy is! Map || !proxy.containsKey('reclash-id')) continue;
        final id = proxy['reclash-id'];
        if (id is! String || !_nodeId.hasMatch(id) || !ids.add(id)) {
          throw const ProviderPolicyFormatException(
            'Invalid or duplicate provider node ID',
          );
        }
      }
    }
    if (ids.length > maxProviderPolicyNodes ||
        !(policy.globalAllow ?? const <String>[]).every(ids.contains)) {
      throw const ProviderPolicyFormatException(
        'Provider policy references an unknown node ID',
      );
    }
    return policy;
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    if (globalAllow != null) 'global': {'allow': globalAllow},
    if (requiredExcludedApps.isNotEmpty)
      'apps': {
        'android': {'exclude': requiredExcludedApps.toList()..sort()},
      },
  };

  @override
  bool operator ==(Object other) =>
      other is ProviderPolicy &&
      const ListEquality<String>().equals(globalAllow, other.globalAllow) &&
      const SetEquality<String>().equals(
        requiredExcludedApps,
        other.requiredExcludedApps,
      );

  @override
  int get hashCode => Object.hash(
    const ListEquality<String>().hash(globalAllow),
    const SetEquality<String>().hash(requiredExcludedApps),
  );
}

Map<String, Object?> _mapping(Object? value) {
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw const ProviderPolicyFormatException(
      'Provider policy must contain mappings',
    );
  }
  return Map<String, Object?>.from(value);
}

void _keys(Map<String, Object?> value, Set<String> allowed) {
  if (value.keys.any((key) => !allowed.contains(key))) {
    throw const ProviderPolicyFormatException('Unknown provider policy field');
  }
}

List<String> _strings(Object? value, int limit, bool Function(String) valid) {
  if (value is! List ||
      value.length > limit ||
      value.any((entry) => entry is! String || !valid(entry))) {
    throw const ProviderPolicyFormatException('Invalid provider policy list');
  }
  final result = List<String>.from(value);
  if (result.toSet().length != result.length) {
    throw const ProviderPolicyFormatException(
      'Duplicate provider policy list entry',
    );
  }
  return result;
}

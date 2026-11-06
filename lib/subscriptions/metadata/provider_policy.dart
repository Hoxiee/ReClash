import 'package:collection/collection.dart';

/// The Core's answer about a profile body, counted in routes. Only the Core can
/// give it: group filters are regexp2 patterns, which Dart's RegExp cannot run
/// (it rejects `(?i)`, and its `\b` and `\w` are ASCII-only).
class ProviderGlobalNodes {
  const ProviderGlobalNodes({required this.allowed, required this.inline});

  factory ProviderGlobalNodes.fromJson(Map<String, Object?> json) =>
      ProviderGlobalNodes(
        allowed: json['allowed'] as int,
        inline: json['inline'] as int,
      );

  /// Inline routes reachable through `GLOBAL`; 0 when there is no such group.
  final int allowed;

  /// Every inline route of the body.
  final int inline;
}

typedef ResolveProviderGlobalNodes =
    Future<ProviderGlobalNodes> Function(List<int> body);

const providerGlobalUnrestrictedWarning =
    'policy.global is listed, but GLOBAL reaches every inline node of the body, '
    'so the lock restricts nothing';

/// What a provider locks, derived from the manifest's `policy` and the profile
/// body; the Core derives the allowlist itself from the same body.
class ProviderPolicy {
  const ProviderPolicy({
    this.lockGlobal = false,
    this.lockApps = false,
    this.globalEmpty = false,
    this.requiredExcludedApps = const {},
  });

  final bool lockGlobal;
  final bool lockApps;

  /// The body has no `GLOBAL` group or it reaches no inline node, so nothing is
  /// left to permit.
  final bool globalEmpty;

  /// The body's `tun.exclude-package`, mandatory under `apps: required`.
  final Set<String> requiredExcludedApps;

  bool get isGlobalRestricted => lockGlobal && globalEmpty;

  /// The lock can only narrow something when there is a second inline route to
  /// deny or a remote provider whose nodes it denies.
  static List<String> warnings(
    ProviderGlobalNodes? nodes, {
    required int remoteProviders,
  }) => [
    if (nodes != null &&
        remoteProviders == 0 &&
        nodes.inline > 1 &&
        nodes.allowed >= nodes.inline)
      providerGlobalUnrestrictedWarning,
  ];

  /// [globalNodes] is [ProviderGlobalNodes.allowed]; null when the Core was not
  /// asked. Null result: nothing is locked.
  static ProviderPolicy? derive({
    required Iterable<String> restrictions,
    required int? globalNodes,
    required Iterable<String> excluded,
  }) {
    final names = restrictions.toSet();
    final lockGlobal = names.contains('lockglobal');
    final lockApps = names.contains('lockapps');
    if (!lockGlobal && !lockApps) return null;
    return ProviderPolicy(
      lockGlobal: lockGlobal,
      lockApps: lockApps,
      globalEmpty: lockGlobal && (globalNodes ?? 0) == 0,
      requiredExcludedApps: lockApps
          ? Set.unmodifiable(excluded.toSet())
          : const {},
    );
  }

  factory ProviderPolicy.fromJson(Map<String, Object?> json) => ProviderPolicy(
    lockGlobal: json['lockGlobal'] == true,
    lockApps: json['lockApps'] == true,
    globalEmpty: json['globalEmpty'] == true,
    requiredExcludedApps: Set.unmodifiable([
      ...?(json['requiredExcludedApps'] as List?)?.whereType<String>(),
    ]),
  );

  Map<String, Object?> toJson() => {
    'lockGlobal': lockGlobal,
    'lockApps': lockApps,
    'globalEmpty': globalEmpty,
    'requiredExcludedApps': requiredExcludedApps.toList()..sort(),
  };

  @override
  bool operator ==(Object other) =>
      other is ProviderPolicy &&
      lockGlobal == other.lockGlobal &&
      lockApps == other.lockApps &&
      globalEmpty == other.globalEmpty &&
      const SetEquality<String>().equals(
        requiredExcludedApps,
        other.requiredExcludedApps,
      );

  @override
  int get hashCode => Object.hash(
    lockGlobal,
    lockApps,
    globalEmpty,
    const SetEquality<String>().hash(requiredExcludedApps),
  );
}

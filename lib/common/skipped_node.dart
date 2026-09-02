library;

import 'package:json_annotation/json_annotation.dart';

enum SkippedNodeReason {
  /// mihomo has no dialer for the protocol (ssr, amneziawg, naive…).
  protocol,

  /// The transport exists only for another protocol (xhttp on vmess/trojan).
  transport,

  bandwidth;

  String get wireName => name;

  static SkippedNodeReason parse(String value) =>
      SkippedNodeReason.values.where((r) => r.name == value).firstOrNull ??
      SkippedNodeReason.protocol;
}

class SkippedNode {
  const SkippedNode({
    required this.name,
    required this.kind,
    required this.reason,
  });

  factory SkippedNode.fromJson(Map<String, Object?> json) => SkippedNode(
    name: json['name']?.toString() ?? '',
    kind: json['kind']?.toString() ?? '',
    reason: SkippedNodeReason.parse(json['reason']?.toString() ?? ''),
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'kind': kind,
    'reason': reason.wireName,
  };

  final String name;

  final String kind;

  final SkippedNodeReason reason;

  @override
  bool operator ==(Object other) =>
      other is SkippedNode &&
      other.name == name &&
      other.kind == kind &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(name, kind, reason);

  @override
  String toString() => 'SkippedNode($kind: $name)';
}

/// Drops malformed entries rather than taking the whole profile down.
class SkippedNodesConverter
    implements JsonConverter<List<SkippedNode>, List<Object?>> {
  const SkippedNodesConverter();

  @override
  List<SkippedNode> fromJson(List<Object?> json) => [
    for (final entry in json)
      if (entry is Map<String, Object?>) SkippedNode.fromJson(entry),
  ];

  @override
  List<Object?> toJson(List<SkippedNode> nodes) =>
      [for (final node in nodes) node.toJson()];
}

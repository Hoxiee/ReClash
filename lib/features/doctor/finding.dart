import 'package:flutter/foundation.dart';

import 'cause.dart';

/// Declared in order of urgency, so the index sorts findings.
enum CheckSeverity { critical, warning, tip }

@immutable
final class Finding {
  const Finding({
    required this.id,
    required this.severity,
    required this.evidence,
    required this.titleKey,
    required this.detailKey,
    this.cause,
    this.args = const {},
    this.remedyIds = const [],
  });

  /// Stable: reports, snoozes and the deep link refer to it.
  final String id;
  final CheckSeverity severity;

  /// Null for a risk that has not failed anything yet, such as battery
  /// optimisation that may stop the VPN later.
  final FailureCause? cause;

  /// The ids of the facts the rule read.
  final List<String> evidence;
  final String titleKey;
  final String detailKey;
  final Map<String, Object> args;
  final List<String> remedyIds;

  @override
  bool operator ==(Object other) =>
      other is Finding &&
      other.id == id &&
      other.severity == severity &&
      other.cause == cause &&
      listEquals(other.evidence, evidence) &&
      other.titleKey == titleKey &&
      other.detailKey == detailKey &&
      mapEquals(other.args, args) &&
      listEquals(other.remedyIds, remedyIds);

  @override
  int get hashCode => Object.hash(
    id,
    severity,
    cause,
    Object.hashAll(evidence),
    titleKey,
    detailKey,
    Object.hashAll(args.entries.map((e) => Object.hash(e.key, e.value))),
    Object.hashAll(remedyIds),
  );

  @override
  String toString() => 'Finding($id, ${severity.name}, ${cause?.id})';
}

int compareFindings(Finding a, Finding b) {
  final bySeverity = a.severity.index.compareTo(b.severity.index);
  return bySeverity != 0 ? bySeverity : a.id.compareTo(b.id);
}

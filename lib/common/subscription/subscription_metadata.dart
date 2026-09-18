import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

/// Transport stays empty: the runtime adapter marshals only type and id.
Map<String, SubscriptionNodeLabel> subscriptionNodeLabelsOf(
  Map<String, dynamic> proxies,
) {
  final groupTypes = GroupTypeExtension.valueList;
  final memberships = <String, List<String>>{};
  final positions = <String, int>{};
  for (final entry in proxies.entries) {
    final raw = entry.value;
    if (raw is! Map) continue;
    if (!groupTypes.contains(raw['type'])) continue;
    final members = raw['all'];
    if (members is! List) continue;
    for (var i = 0; i < members.length; i++) {
      final member = members[i];
      if (member is! String) continue;
      memberships.putIfAbsent(member, () => []).add(entry.key);
      positions.putIfAbsent(member, () => i + 1);
    }
  }

  final labels = <String, SubscriptionNodeLabel>{};
  for (final entry in proxies.entries) {
    final raw = entry.value;
    if (raw is! Map) continue;
    final type = raw['type'];
    if (type is! String || groupTypes.contains(type)) continue;
    labels[entry.key] = SubscriptionNodeLabel(
      protocol: type,
      groups: memberships[entry.key] ?? const [],
      positionHint: positions[entry.key] ?? 0,
    );
  }
  return labels;
}

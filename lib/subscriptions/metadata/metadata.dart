import 'dart:convert';

import 'package:collection/collection.dart';

import '../protocol/registry.dart';

enum SubscriptionDeviceStatus { required, accepted, unsupported, limitReached }

enum SubscriptionDataSource { http, body }

class SubscriptionMetadata {
  const SubscriptionMetadata([this.fields = const {}]);

  final Map<String, Object?> fields;

  String? text(String path) =>
      fields[path] is String ? fields[path] as String : null;
  int? count(String path) => fields[path] is int ? fields[path] as int : null;
  bool? flag(String path) => fields[path] is bool ? fields[path] as bool : null;
  List<Object?> list(String path) => fields[path] is List
      ? List<Object?>.from(fields[path] as List)
      : const [];

  String? get name => text('provider.name');
  String? get accountTitle => text('account.title');
  bool get hideUrl => flag('presentation.hideUrl') ?? false;
  bool get unlimited => flag('subscription.unlimited') ?? false;
  bool get perpetual => flag('subscription.perpetual') ?? false;
  double? get usage {
    final total = count('subscription.total');
    if (unlimited || total == null || total <= 0) return null;
    return ((count('subscription.upload') ?? 0) +
            (count('subscription.download') ?? 0)) /
        total;
  }

  @override
  bool operator ==(Object other) =>
      other is SubscriptionMetadata &&
      const DeepCollectionEquality().equals(fields, other.fields);

  @override
  int get hashCode => const DeepCollectionEquality().hash(fields);

  Map<String, Object?> toJson() {
    final result = <String, Object?>{};
    for (final MapEntry(:key, :value) in fields.entries) {
      final parts = key.split('.');
      final section =
          result.putIfAbsent(parts.first, () => <String, Object?>{})
              as Map<String, Object?>;
      section[parts.last] = value;
    }
    return result;
  }

  factory SubscriptionMetadata.fromJson(Map<String, Object?> json) {
    final fields = <String, Object?>{};
    for (final descriptor in subscriptionFields) {
      final parts = descriptor.path.split('.');
      final section = json[parts.first];
      if (section is! Map || !section.containsKey(parts.last)) continue;
      final value = section[parts.last];
      if (validSubscriptionField(descriptor, value)) {
        fields[descriptor.path] = value;
      }
    }
    final usage = json['subscription'];
    if (usage is Map) {
      for (final key in ['upload', 'download', 'total', 'expire']) {
        final value = usage[key];
        final maximum = key == 'expire' ? 8640000000000 : 9007199254740991;
        if (value is int && value >= 0 && value <= maximum) {
          fields['subscription.$key'] = value;
        }
      }
      if (fields['subscription.total'] case final int total) {
        fields['subscription.unlimited'] = total == 0;
      }
      if (fields['subscription.expire'] case final int expire) {
        fields['subscription.perpetual'] = expire == 0;
      }
    }
    return SubscriptionMetadata(Map.unmodifiable(fields));
  }

  SubscriptionMetadata merge(SubscriptionMetadata incoming) =>
      SubscriptionMetadata(Map.unmodifiable({...fields, ...incoming.fields}));
}

bool validSubscriptionField(SubscriptionField field, Object? value) {
  if (value == null) return true;
  switch (field.type) {
    case SubscriptionFieldType.text:
      return value is String &&
          utf8.encode(value).length <= field.limit &&
          !value.runes.any((c) => c < 32 || c == 127);
    case SubscriptionFieldType.url:
      return value is String &&
          value.length <= field.limit &&
          safeSubscriptionLink(value) != null;
    case SubscriptionFieldType.integer:
      return value is int && value >= field.minimum && value <= field.maximum;
    case SubscriptionFieldType.boolean:
      return value is bool;
    case SubscriptionFieldType.hosts:
      return value is List &&
          value.length <= field.limit &&
          value.every((v) => v is String && subscriptionHost(v) != null);
  }
}

Uri? safeSubscriptionLink(String value, {bool httpsOnly = false}) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      (uri.scheme != 'https' && (httpsOnly || uri.scheme != 'http')) ||
      value.contains(RegExp(r'[\x00-\x20\x7f]'))) {
    return null;
  }
  return uri;
}

String? subscriptionHost(String value) {
  if (value.isEmpty ||
      value.length > 253 ||
      value.contains(RegExp(r'[\s/\\:@?#]'))) {
    return null;
  }
  final uri = Uri.tryParse('https://$value');
  if (uri == null || uri.host.isEmpty || uri.host != value.toLowerCase()) {
    return null;
  }
  return uri.host;
}

class SubscriptionSnapshot {
  const SubscriptionSnapshot({
    required this.metadata,
    required this.receivedAt,
    this.stale = false,
    this.staleFields = const [],
    this.source = SubscriptionDataSource.http,
    this.deviceStatus,
    this.warnings = const [],
  });
  final SubscriptionMetadata metadata;
  final DateTime receivedAt;
  final bool stale;
  final List<String> staleFields;
  final SubscriptionDataSource source;
  final SubscriptionDeviceStatus? deviceStatus;
  final List<String> warnings;

  bool get usageStale =>
      stale || staleFields.any((f) => f.startsWith('subscription.'));

  @override
  bool operator ==(Object other) =>
      other is SubscriptionSnapshot &&
      metadata == other.metadata &&
      receivedAt == other.receivedAt &&
      stale == other.stale &&
      const ListEquality<String>().equals(staleFields, other.staleFields) &&
      source == other.source &&
      deviceStatus == other.deviceStatus &&
      const ListEquality<String>().equals(warnings, other.warnings);

  @override
  int get hashCode => Object.hash(
    metadata,
    receivedAt,
    stale,
    const ListEquality<String>().hash(staleFields),
    source,
    deviceStatus,
    const ListEquality<String>().hash(warnings),
  );

  Map<String, Object?> toJson() => {
    'metadata': metadata.toJson(),
    'receivedAt': receivedAt.toUtc().toIso8601String(),
    'stale': stale,
    'staleFields': staleFields,
    'source': source.name,
    'deviceStatus': deviceStatus?.name,
    'warnings': warnings,
  };

  static SubscriptionSnapshot? safeFromJson(Object? value) {
    if (value is! Map) return null;
    try {
      final json = Map<String, Object?>.from(value);
      return SubscriptionSnapshot(
        metadata: SubscriptionMetadata.fromJson(
          Map<String, Object?>.from(json['metadata'] as Map? ?? const {}),
        ),
        receivedAt:
            DateTime.tryParse(json['receivedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        stale: json['stale'] as bool? ?? false,
        staleFields: (json['staleFields'] as List? ?? const [])
            .whereType<String>()
            .take(subscriptionFields.length)
            .toList(),
        source: SubscriptionDataSource.values.firstWhere(
          (s) => s.name == json['source'],
          orElse: () => SubscriptionDataSource.http,
        ),
        deviceStatus: SubscriptionDeviceStatus.values
            .where((s) => s.name == json['deviceStatus'])
            .firstOrNull,
        warnings: (json['warnings'] as List? ?? const [])
            .whereType<String>()
            .take(32)
            .toList(),
      );
    } on Object {
      return null;
    }
  }

  factory SubscriptionSnapshot.fromJson(Map<String, Object?> json) =>
      SubscriptionSnapshot.safeFromJson(json)!;
}

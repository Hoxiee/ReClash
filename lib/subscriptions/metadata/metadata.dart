import 'package:collection/collection.dart';

import '../../common/telegram_link.dart';
import '../protocol/registry.dart';
import 'provider_policy.dart';

enum SubscriptionDeviceStatus { required, accepted, unsupported, limitReached }

enum SubscriptionDataSource { http, body }

/// Unknown provider kinds omit the badge without rejecting the subscription.
enum SubscriptionKind {
  test('test'),
  promo('promo'),
  dev('dev');

  const SubscriptionKind(this.token);

  final String token;

  static SubscriptionKind? fromToken(String? value) {
    final token = value?.trim().toLowerCase();
    return values.where((kind) => kind.token == token).firstOrNull;
  }
}

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
  List<String> strings(String path) => list(path).whereType<String>().toList();
  List<int> numbers(String path) => list(path).whereType<int>().toList();

  String? get name => text('provider.name');
  String? get accountTitle => text('account.title');
  SubscriptionKind? get kind =>
      SubscriptionKind.fromToken(text('subscription.type'));
  String? get announce => text('provider.announce');
  String? get logo => text('provider.logo');

  String? logoFor({required bool dark}) =>
      dark ? text('provider.logoDark') ?? logo : logo;

  /// `ed25519:<key>` values that sign this provider's support fix links.
  List<String> get supportKeys => strings('support.keys');
  String? get supportUploadUrl => text('support.uploadUrl');
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
    Object? stored(String path) {
      final parts = path.split('.');
      final section = json[parts.first];
      return section is Map ? section[parts.last] : null;
    }

    for (final descriptor in subscriptionFields) {
      final value = normalizeSubscriptionValue(
        descriptor.type,
        stored(descriptor.path),
      );
      if (value != null && validSubscriptionField(descriptor, value)) {
        fields[descriptor.path] = value;
      }
      if (descriptor.suffix case final suffix?) {
        if (stored(suffix.path) case final int value
            when value >= suffix.minimum && value <= suffix.maximum) {
          fields[suffix.path] = value;
        }
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

final _token = RegExp(r'^[a-z0-9._:#-]{1,64}$');

/// The unpadded base64url of exactly 32 bytes: its last character carries
/// four zero bits.
final _supportKey = RegExp(r'^ed25519:[A-Za-z0-9_-]{42}[AEIMQUYcgkosw048]$');
final _package = RegExp(r'^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$');

/// Gives a decoded JSON value the element types the decoder produces.
Object? normalizeSubscriptionValue(SubscriptionFieldType type, Object? value) {
  return switch (type) {
    SubscriptionFieldType.hosts ||
    SubscriptionFieldType.tokens ||
    SubscriptionFieldType.policy ||
    SubscriptionFieldType.packages ||
    SubscriptionFieldType.keys when value is List =>
      value.every((v) => v is String) ? List<String>.from(value) : null,
    SubscriptionFieldType.numbers when value is List =>
      value.every((v) => v is int) ? List<int>.from(value) : null,
    SubscriptionFieldType.flags when value is Map =>
      value.keys.every((k) => k is String) &&
              value.values.every((v) => v is bool)
          ? Map<String, bool>.from(value)
          : null,
    _ => value,
  };
}

bool validSubscriptionField(SubscriptionField field, Object? value) {
  if (value == null) return true;
  switch (field.type) {
    case SubscriptionFieldType.text:
      return value is String &&
          value.runes.length <= field.limit &&
          !value.runes.any(
            (c) => (c < 32 && !(field.multiline && c == 10)) || c == 127,
          );
    case SubscriptionFieldType.url:
      return value is String &&
          value.length <= field.limit &&
          (field.path == 'provider.supportUrl'
              ? safeSubscriptionSupportLink(value) != null
              : safeSubscriptionLink(value, httpsOnly: field.secure) != null);
    case SubscriptionFieldType.integer:
      return value is int && value >= field.minimum && value <= field.maximum;
    case SubscriptionFieldType.boolean:
      return value is bool;
    case SubscriptionFieldType.hosts:
      return value is List &&
          value.length <= field.limit &&
          value.every((v) => v is String && subscriptionAuthority(v) == v);
    case SubscriptionFieldType.tokens:
    case SubscriptionFieldType.policy:
      return value is List &&
          value.length <= field.limit &&
          value.every((v) => v is String && _token.hasMatch(v));
    case SubscriptionFieldType.packages:
      return value is List &&
          value.length <= field.limit &&
          value.every(
            (v) => v is String && v.length <= 255 && _package.hasMatch(v),
          );
    case SubscriptionFieldType.numbers:
      return value is List &&
          value.length <= field.limit &&
          value.every(
            (v) => v is int && v >= field.minimum && v <= field.maximum,
          );
    case SubscriptionFieldType.keys:
      return value is List &&
          value.length <= field.limit &&
          value.every((v) => v is String && _supportKey.hasMatch(v));
    case SubscriptionFieldType.flags:
      return value is Map &&
          value.length <= field.limit &&
          value.entries.every(
            (e) => e.key is String && _token.hasMatch(e.key) && e.value is bool,
          );
  }
}

bool isAndroidPackageName(String value) =>
    value.length <= 255 && _package.hasMatch(value);

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

Uri? safeSubscriptionSupportLink(String value) =>
    safeSubscriptionLink(value) ?? TelegramLink.tryParse(value)?.uri;

/// `host` or `host:port`, lowercased; an `https://` prefix is dropped.
String? subscriptionAuthority(String value) {
  final bare = value.toLowerCase().startsWith('https://')
      ? value.substring(8)
      : value;
  final trimmed = bare.endsWith('/')
      ? bare.substring(0, bare.length - 1)
      : bare;
  if (trimmed.isEmpty ||
      trimmed.length > 259 ||
      trimmed.contains(RegExp(r'[\s/\\@?#\[\]]'))) {
    return null;
  }
  final uri = Uri.tryParse('https://$trimmed');
  if (uri == null || uri.host.isEmpty || uri.host.length > 253) return null;
  final colon = trimmed.indexOf(':');
  final host = colon == -1 ? trimmed : trimmed.substring(0, colon);
  if (uri.host != host.toLowerCase()) return null;
  // Uri drops the https default port, so `:443` has no port to read back.
  if (colon == -1 || trimmed.endsWith(':443')) return uri.host;
  if (!uri.hasPort || uri.port <= 0 || uri.port > 65535) return null;
  return '${uri.host}:${uri.port}';
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
    this.providerPolicy,
  });
  final SubscriptionMetadata metadata;
  final DateTime receivedAt;
  final bool stale;
  final List<String> staleFields;
  final SubscriptionDataSource source;
  final SubscriptionDeviceStatus? deviceStatus;
  final List<String> warnings;
  final ProviderPolicy? providerPolicy;

  bool get usageStale => staleFields.any((f) => f.startsWith('subscription.'));

  @override
  bool operator ==(Object other) =>
      other is SubscriptionSnapshot &&
      metadata == other.metadata &&
      receivedAt == other.receivedAt &&
      stale == other.stale &&
      const ListEquality<String>().equals(staleFields, other.staleFields) &&
      source == other.source &&
      deviceStatus == other.deviceStatus &&
      providerPolicy == other.providerPolicy &&
      const ListEquality<String>().equals(warnings, other.warnings);

  @override
  int get hashCode => Object.hash(
    metadata,
    receivedAt,
    stale,
    const ListEquality<String>().hash(staleFields),
    source,
    deviceStatus,
    providerPolicy,
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
    if (providerPolicy != null) 'providerPolicy': providerPolicy!.toJson(),
  };

  static SubscriptionSnapshot? safeFromJson(Object? value) {
    if (value is! Map) return null;
    try {
      final json = Map<String, Object?>.from(value);
      return SubscriptionSnapshot(
        providerPolicy: json['providerPolicy'] == null
            ? null
            : ProviderPolicy.fromJson(
                Map<String, Object?>.from(json['providerPolicy'] as Map),
              ),
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

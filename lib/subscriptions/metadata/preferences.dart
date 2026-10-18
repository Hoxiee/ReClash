import 'package:collection/collection.dart';

import '../compatibility/clients.dart';
import '../transport/header_policy.dart';

class SubscriptionPreferences {
  const SubscriptionPreferences({
    this.headers = const {},
    this.intervalOverride = true,
    this.trustedOrigins = const [],
    this.client = const SubscriptionClientSettings(),
  });

  final Map<String, String> headers;
  final bool intervalOverride;
  final List<String> trustedOrigins;
  final SubscriptionClientSettings client;

  SubscriptionPreferences copyWith({
    Map<String, String>? headers,
    bool? intervalOverride,
    List<String>? trustedOrigins,
    SubscriptionClientSettings? client,
  }) => SubscriptionPreferences(
    headers: headers ?? this.headers,
    intervalOverride: intervalOverride ?? this.intervalOverride,
    trustedOrigins: trustedOrigins ?? this.trustedOrigins,
    client: client ?? this.client,
  );

  Map<String, Object?> toJson() => {
    'headers': headers,
    'intervalOverride': intervalOverride,
    'trustedOrigins': trustedOrigins,
    'client': client.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is SubscriptionPreferences &&
      const MapEquality<String, String>().equals(headers, other.headers) &&
      intervalOverride == other.intervalOverride &&
      const ListEquality<String>().equals(
        trustedOrigins,
        other.trustedOrigins,
      ) &&
      client.preset == other.client.preset &&
      client.customUserAgent == other.client.customUserAgent &&
      const DeepCollectionEquality().equals(
        client.importPolicy.toJson(),
        other.client.importPolicy.toJson(),
      );

  @override
  int get hashCode => Object.hash(
    const MapEquality<String, String>().hash(headers),
    intervalOverride,
    const ListEquality<String>().hash(trustedOrigins),
    client.preset,
    client.customUserAgent,
    const DeepCollectionEquality().hash(client.importPolicy.toJson()),
  );

  factory SubscriptionPreferences.safeFromJson(Object? json) {
    if (json is! Map) return const SubscriptionPreferences();
    Map<String, String> headers;
    List<String> trustedOrigins;
    try {
      headers = validateSubscriptionHeaders(
        Map<String, String>.from(json['headers'] as Map? ?? const {}),
      );
    } on Object {
      headers = const {};
    }
    try {
      trustedOrigins = (json['trustedOrigins'] as List? ?? const [])
          .whereType<String>()
          .take(64)
          .toList(growable: false);
    } on Object {
      trustedOrigins = const [];
    }
    return SubscriptionPreferences(
      headers: headers,
      intervalOverride: json['intervalOverride'] as bool? ?? true,
      trustedOrigins: trustedOrigins,
      client: SubscriptionClientSettings.safeFromJson(json['client']),
    );
  }
}

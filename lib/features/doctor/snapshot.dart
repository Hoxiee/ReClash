import 'package:flutter/foundation.dart';
import 'package:reclash/enum/enum.dart';

/// Names one fact and the type of its value. Values cross into the rules
/// isolate, so they must be plain data: no closures, handles or providers.
@immutable
final class FactKey<T extends Object> {
  const FactKey(this.id);

  final String id;

  @override
  String toString() => id;
}

@immutable
final class Fact<T extends Object> {
  const Fact(this.value, {required this.at, this.ttl});

  final T value;
  final DateTime at;

  /// A measured fact goes stale; a sensed one stays true until its source
  /// changes it, and has no TTL.
  final Duration? ttl;

  bool isFreshAt(DateTime now) {
    final ttl = this.ttl;
    return ttl == null || now.difference(at) < ttl;
  }
}

@immutable
final class SubscriptionFact {
  const SubscriptionFact({
    required this.profileId,
    this.expiresAt,
    this.used = 0,
    this.total = 0,
  });

  final int profileId;
  final DateTime? expiresAt;
  final int used;
  final int total;

  @override
  bool operator ==(Object other) =>
      other is SubscriptionFact &&
      other.profileId == profileId &&
      other.expiresAt == expiresAt &&
      other.used == used &&
      other.total == total;

  @override
  int get hashCode => Object.hash(profileId, expiresAt, used, total);
}

abstract final class Facts {
  static const coreStatus = FactKey<CoreStatus>('core.status');
  static const mode = FactKey<Mode>('config.mode');
  static const batteryOptimizationIgnored = FactKey<bool>(
    'device.batteryOptimizationIgnored',
  );

  /// Device clock minus server clock: positive when the device runs ahead.
  static const clockSkew = FactKey<Duration>('device.clockSkew');
  static const subscription = FactKey<SubscriptionFact>('profile.subscription');
}

/// The immutable merge of every current fact. A missing fact means the kernel
/// cannot tell, which a rule reads as "no finding", never as a problem.
@immutable
final class DiagnosticSnapshot {
  DiagnosticSnapshot({
    required this.takenAt,
    Map<String, Fact<Object>> facts = const {},
  }) : _facts = Map.unmodifiable(facts);

  final DateTime takenAt;
  final Map<String, Fact<Object>> _facts;

  Iterable<String> get factIds => _facts.keys;

  Fact<T>? fact<T extends Object>(FactKey<T> key) {
    final fact = _facts[key.id];
    return fact is Fact<T> ? fact : null;
  }

  T? valueOf<T extends Object>(FactKey<T> key) {
    final fact = this.fact(key);
    return fact != null && fact.isFreshAt(takenAt) ? fact.value : null;
  }

  /// A rough size of the data the rules walk, which decides whether they run
  /// off the UI isolate.
  int get weight {
    var weight = 0;
    for (final fact in _facts.values) {
      weight += switch (fact.value) {
        final Iterable<Object?> items => items.length,
        final Map<Object?, Object?> entries => entries.length,
        _ => 1,
      };
    }
    return weight;
  }

  DiagnosticSnapshot withFact<T extends Object>(
    FactKey<T> key,
    Fact<T>? fact, {
    DateTime? at,
  }) {
    final facts = Map.of(_facts);
    if (fact == null) {
      facts.remove(key.id);
    } else {
      facts[key.id] = fact;
    }
    return DiagnosticSnapshot(takenAt: at ?? takenAt, facts: facts);
  }

  DiagnosticSnapshot at(DateTime takenAt) =>
      DiagnosticSnapshot(takenAt: takenAt, facts: _facts);
}

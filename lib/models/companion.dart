import 'package:material_ui/material_ui.dart' show immutable;

// Pairing payload and credentials carry a shared secret and a bearer token. These types are written
// by hand rather than with freezed on purpose: a generated toString would print the secret, and
// S14/S03 forbid a token or secret reaching any log, wire error or backup.

enum CompanionQrRejection {
  tooLarge,
  wrongScheme,
  wrongPath,
  hasUserInfo,
  hasFragment,
  unsupportedVersion,
  duplicateParam,
  missingParam,
  invalidDeviceId,
  invalidHost,
  invalidPort,
  invalidPin,
  invalidSecret,
}

@immutable
class CompanionPairingPayload {
  const CompanionPairingPayload({
    required this.deviceId,
    required this.host,
    required this.port,
    required this.spkiPin,
    required this.pairingSecret,
  });

  final String deviceId;
  final String host;
  final int port;
  final String spkiPin;
  final String pairingSecret;

  String get baseUrl => 'https://$host:$port';

  @override
  bool operator ==(Object other) =>
      other is CompanionPairingPayload &&
      other.deviceId == deviceId &&
      other.host == host &&
      other.port == port &&
      other.spkiPin == spkiPin &&
      other.pairingSecret == pairingSecret;

  @override
  int get hashCode => Object.hash(deviceId, host, port, spkiPin, pairingSecret);

  @override
  String toString() =>
      'CompanionPairingPayload(deviceId: $deviceId, host: $host, port: $port, spkiPin: <redacted>, pairingSecret: <redacted>)';
}

@immutable
sealed class CompanionQrResult {
  const CompanionQrResult();
}

class CompanionQrPaired extends CompanionQrResult {
  const CompanionQrPaired(this.payload);

  final CompanionPairingPayload payload;
}

class CompanionQrRejected extends CompanionQrResult {
  const CompanionQrRejected(this.reason);

  final CompanionQrRejection reason;
}

enum CompanionPairingPhase { pending, approved, rejected, expired, cancelled }

// A probe result, not a stored flag: a stale green must never outlive the truth (I20).
enum CompanionReachability {
  checking,
  reachable,
  unreachable,
  identityChanged,
  accessRevoked,
  incompatible,
}

CompanionReachability companionReachabilityFromCode(String? code) =>
    switch (code) {
      null => CompanionReachability.reachable,
      'identityChanged' => CompanionReachability.identityChanged,
      'unauthorized' ||
      'forbidden' ||
      'accessRevoked' => CompanionReachability.accessRevoked,
      'incompatible' => CompanionReachability.incompatible,
      _ => CompanionReachability.unreachable,
    };

@immutable
class CompanionPairingStatus {
  const CompanionPairingStatus({
    required this.pairingId,
    required this.phase,
    this.confirmationCode,
    this.expiresInMs,
  });

  final String pairingId;
  final CompanionPairingPhase phase;
  final String? confirmationCode;
  final int? expiresInMs;

  static CompanionPairingPhase phaseFromWire(String value) => switch (value) {
    'approved' => CompanionPairingPhase.approved,
    'rejected' => CompanionPairingPhase.rejected,
    'expired' => CompanionPairingPhase.expired,
    'cancelled' => CompanionPairingPhase.cancelled,
    _ => CompanionPairingPhase.pending,
  };
}

@immutable
class CompanionReceiverEndpoint {
  const CompanionReceiverEndpoint({
    required this.deviceId,
    required this.host,
    required this.port,
  });

  final String deviceId;
  final String host;
  final int port;
}

@immutable
class CompanionQrOffer {
  const CompanionQrOffer({
    required this.deviceId,
    required this.host,
    required this.port,
    required this.spkiPin,
    required this.pairingSecret,
    required this.expiresInMs,
  });

  final String deviceId;
  final String host;
  final int port;
  final String spkiPin;
  final String pairingSecret;
  final int expiresInMs;

  String get qr =>
      'reclash://companion/pair?v=1&d=$deviceId&h=$host&p=$port&k=$spkiPin&s=$pairingSecret';

  @override
  String toString() =>
      'CompanionQrOffer(deviceId: $deviceId, host: $host, port: $port, expiresInMs: $expiresInMs)';
}

@immutable
class CompanionPendingPhone {
  const CompanionPendingPhone({
    required this.clientId,
    required this.clientName,
    required this.confirmationCode,
  });

  final String clientId;
  final String clientName;
  final String confirmationCode;
}

@immutable
class CompanionTrustedPhone {
  const CompanionTrustedPhone({
    required this.clientId,
    required this.clientName,
    required this.createdAtMs,
    required this.lastSeenAtMs,
  });

  final String clientId;
  final String clientName;
  final int createdAtMs;
  final int lastSeenAtMs;
}

@immutable
class CompanionTargetSummary {
  const CompanionTargetSummary({
    required this.deviceId,
    required this.clientName,
    required this.host,
    required this.port,
    required this.active,
    this.lastSeenAtMs,
  });

  final String deviceId;
  final String clientName;
  final String host;
  final int port;
  final bool active;
  final int? lastSeenAtMs;
}

@immutable
class CompanionStateSnapshot {
  const CompanionStateSnapshot({
    required this.running,
    required this.profileLabel,
    required this.revision,
    this.groupName,
    this.nodeName,
    this.trafficUp = 0,
    this.trafficDown = 0,
    this.subscription,
    this.outboundMode,
  });

  final bool running;
  final String profileLabel;
  final int revision;
  final String? groupName;
  final String? nodeName;
  final int trafficUp;
  final int trafficDown;
  final CompanionSubscriptionInfo? subscription;
  final String? outboundMode;

  static CompanionStateSnapshot fromMap(Map<String, dynamic> map) {
    final sub = map['subscription'] as Map?;
    return CompanionStateSnapshot(
      running: map['running'] as bool? ?? false,
      profileLabel: map['profileLabel'] as String? ?? '',
      revision: (map['revision'] as num?)?.toInt() ?? 0,
      groupName: map['groupName'] as String?,
      nodeName: map['nodeName'] as String?,
      trafficUp: (map['trafficUp'] as num?)?.toInt() ?? 0,
      trafficDown: (map['trafficDown'] as num?)?.toInt() ?? 0,
      subscription: sub == null
          ? null
          : CompanionSubscriptionInfo(
              upload: (sub['upload'] as num?)?.toInt() ?? 0,
              download: (sub['download'] as num?)?.toInt() ?? 0,
              total: (sub['total'] as num?)?.toInt() ?? 0,
              expire: (sub['expire'] as num?)?.toInt() ?? 0,
            ),
      outboundMode: map['outboundMode'] as String?,
    );
  }
}

@immutable
class CompanionSubscriptionInfo {
  const CompanionSubscriptionInfo({
    required this.upload,
    required this.download,
    required this.total,
    required this.expire,
  });

  final int upload;
  final int download;
  final int total;
  final int expire;

  int get used => upload + download;
  bool get unlimited => total <= 0;
  bool get hasFacts => used > 0 || total > 0 || expire > 0;
}

@immutable
class CompanionGroupView {
  const CompanionGroupView({
    required this.name,
    required this.type,
    required this.options,
    this.selected,
  });

  final String name;
  final String type;
  final String? selected;
  final List<CompanionNodeView> options;

  static CompanionGroupView fromMap(Map<String, dynamic> map) {
    final options = (map['options'] as List?) ?? const [];
    return CompanionGroupView(
      name: map['name'] as String,
      type: map['type'] as String? ?? '',
      selected: map['selected'] as String?,
      options: options
          .cast<Map>()
          .map(
            (option) => CompanionNodeView(
              name: option['name'] as String,
              type: option['type'] as String? ?? '',
              delayMs: (option['delayMs'] as num?)?.toInt(),
            ),
          )
          .toList(),
    );
  }
}

@immutable
class CompanionNodeView {
  const CompanionNodeView({
    required this.name,
    required this.type,
    this.delayMs,
  });

  final String name;
  final String type;
  final int? delayMs;
}

@immutable
class CompanionProfileView {
  const CompanionProfileView({
    required this.id,
    required this.label,
    required this.active,
    this.lastUpdate,
  });

  final int id;
  final String label;
  final bool active;
  final int? lastUpdate;

  static CompanionProfileView fromMap(Map<String, dynamic> map) =>
      CompanionProfileView(
        id: (map['id'] as num?)?.toInt() ?? 0,
        label: map['label'] as String? ?? '',
        active: map['active'] as bool? ?? false,
        lastUpdate: (map['lastUpdate'] as num?)?.toInt(),
      );
}

@immutable
class CompanionCommandOutcome {
  const CompanionCommandOutcome({
    required this.ok,
    this.status,
    this.effectState,
    this.code,
  });

  final bool ok;
  final String? status;
  final String? effectState;
  final String? code;

  bool get succeeded => ok && status == 'succeeded';
  bool get unknown => code == 'outcomeUnknown' || status == 'outcomeUnknown';
  bool get pending => succeeded && effectState == 'pending';
  bool get restartRequired => effectState == 'restartRequired';
}

@immutable
class CompanionReadResult {
  const CompanionReadResult({this.snapshot, this.code});

  final CompanionStateSnapshot? snapshot;
  final String? code;

  bool get ok => snapshot != null;

  CompanionReachability get reachability => ok
      ? CompanionReachability.reachable
      : companionReachabilityFromCode(code);
}

@immutable
class CompanionPairOutcome {
  const CompanionPairOutcome({
    required this.ok,
    this.deviceId,
    this.pairingId,
    this.confirmationCode,
    this.code,
  });

  final bool ok;
  final String? deviceId;
  final String? pairingId;
  final String? confirmationCode;
  final String? code;
}

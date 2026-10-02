import 'dart:async';

import 'package:flutter/services.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/companion.dart';

// Typed facades over the two native method channels: the TV receiver (enable/pair/approve/revoke)
// and the phone client (scan/pair/poll/forget). No token or secret crosses these boundaries in a
// loggable shape; the phone gets only a confirmation code and status, the TV only opaque metadata.

class CompanionReceiver {
  CompanionReceiver._();

  static final CompanionReceiver instance = CompanionReceiver._();

  final MethodChannel _channel = const MethodChannel(
    '$packageName/companion_receiver',
  );

  Future<CompanionReceiverEndpoint> enable() async {
    final result = await _channel.invokeMapMethod<String, dynamic>('enable');
    return CompanionReceiverEndpoint(
      deviceId: result!['deviceId'] as String,
      host: result['host'] as String,
      port: result['port'] as int,
    );
  }

  Future<void> disable() => _channel.invokeMethod('disable');

  Future<bool> isRunning() async =>
      await _channel.invokeMethod<bool>('isRunning') ?? false;

  Future<CompanionQrOffer?> openPairingWindow() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'openPairingWindow',
    );
    if (result == null) return null;
    return CompanionQrOffer(
      deviceId: result['deviceId'] as String,
      host: result['host'] as String,
      port: result['port'] as int,
      spkiPin: result['spkiPin'] as String,
      pairingSecret: result['pairingSecret'] as String,
      expiresInMs: result['expiresInMs'] as int,
    );
  }

  Future<void> cancelPairingWindow() =>
      _channel.invokeMethod('cancelPairingWindow');

  Future<CompanionPendingPhone?> pendingPairing() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'pendingPairing',
    );
    if (result == null) return null;
    return CompanionPendingPhone(
      clientId: result['clientId'] as String,
      clientName: result['clientName'] as String,
      confirmationCode: result['confirmationCode'] as String,
    );
  }

  Future<bool> approvePending() async =>
      await _channel.invokeMethod<bool>('approvePending') ?? false;

  Future<void> rejectPending() => _channel.invokeMethod('rejectPending');

  Future<List<CompanionTrustedPhone>> trustedClients() async {
    final result = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
      'trustedClients',
    );
    return (result ?? [])
        .map(
          (e) => CompanionTrustedPhone(
            clientId: e['clientId'] as String,
            clientName: e['clientName'] as String,
            createdAtMs: e['createdAtMs'] as int,
            lastSeenAtMs: e['lastSeenAtMs'] as int,
          ),
        )
        .toList();
  }

  Future<bool> revokeClient(String clientId) async =>
      await _channel.invokeMethod<bool>('revokeClient', {
        'clientId': clientId,
      }) ??
      false;

  Future<void> resetIdentity() => _channel.invokeMethod('resetIdentity');
}

class CompanionClient {
  CompanionClient._();

  static final CompanionClient instance = CompanionClient._();

  final MethodChannel _channel = const MethodChannel(
    '$packageName/companion_client',
  );

  Future<CompanionPairOutcome> pair(String raw, {String? clientName}) async {
    final result = await _channel.invokeMapMethod<String, dynamic>('pair', {
      'raw': raw,
      'clientName': clientName,
    });
    return _outcome(result);
  }

  Future<String> pollPairing(String deviceId) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'pollPairing',
      {'deviceId': deviceId},
    );
    if (result?['ok'] == true) {
      return result!['phase'] as String? ?? 'pending';
    }
    return result?['code'] as String? ?? 'outcomeUnknown';
  }

  Future<void> forget(String deviceId) =>
      _channel.invokeMethod('forget', {'deviceId': deviceId});

  Future<CompanionStateSnapshot?> readState(String deviceId) async {
    final data = await _readData('readState', deviceId);
    return data == null ? null : CompanionStateSnapshot.fromMap(data);
  }

  // Keeps the failure code so the caller can classify reachability (I20).
  Future<CompanionReadResult> readStateResult(String deviceId) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'readState',
      {'deviceId': deviceId},
    );
    if (result?['ok'] != true) {
      return CompanionReadResult(code: result?['code'] as String?);
    }
    final data = (result!['data'] as Map?)?.cast<String, dynamic>();
    return CompanionReadResult(
      snapshot: data == null ? null : CompanionStateSnapshot.fromMap(data),
    );
  }

  Future<bool> rename(String deviceId, String name) async {
    try {
      return await _channel.invokeMethod<bool>('rename', {
            'deviceId': deviceId,
            'name': name,
          }) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<List<CompanionProfileView>?> readProfiles(String deviceId) async {
    final data = await _readData('readProfiles', deviceId);
    if (data == null) return null;
    return ((data['items'] as List?) ?? const [])
        .cast<Map>()
        .map((e) => CompanionProfileView.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  Future<List<CompanionGroupView>?> readGroups(String deviceId) async {
    final data = await _readData('readGroups', deviceId);
    if (data == null) return null;
    return ((data['items'] as List?) ?? const [])
        .cast<Map>()
        .map((e) => CompanionGroupView.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  Future<CompanionCommandOutcome> command(
    String deviceId,
    String kind, {
    Map<String, dynamic> arguments = const {},
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>('command', {
      'deviceId': deviceId,
      'kind': kind,
      'arguments': arguments,
    });
    if (result?['ok'] != true) {
      return CompanionCommandOutcome(
        ok: false,
        code: result?['code'] as String?,
      );
    }
    final data = (result!['data'] as Map?)?.cast<String, dynamic>();
    return CompanionCommandOutcome(
      ok: true,
      status: data?['status'] as String?,
      effectState: data?['effectState'] as String?,
      code: data?['error'] as String?,
    );
  }

  Future<Map<String, dynamic>?> _readData(
    String method,
    String deviceId,
  ) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(method, {
      'deviceId': deviceId,
    });
    if (result?['ok'] != true) return null;
    return (result!['data'] as Map?)?.cast<String, dynamic>();
  }

  Future<List<CompanionTargetSummary>> targets() async {
    final result = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
      'targets',
    );
    return (result ?? [])
        .map(
          (e) => CompanionTargetSummary(
            deviceId: e['deviceId'] as String,
            clientName: e['clientName'] as String,
            host: e['host'] as String,
            port: e['port'] as int,
            active: e['active'] as bool,
            lastSeenAtMs: (e['lastSeenAtMs'] as num?)?.toInt(),
          ),
        )
        .toList();
  }

  CompanionPairOutcome _outcome(Map<String, dynamic>? result) {
    if (result == null) {
      return const CompanionPairOutcome(ok: false, code: 'outcomeUnknown');
    }
    return CompanionPairOutcome(
      ok: result['ok'] as bool? ?? false,
      deviceId: result['deviceId'] as String?,
      pairingId: result['pairingId'] as String?,
      confirmationCode: result['confirmationCode'] as String?,
      code: result['code'] as String?,
    );
  }
}

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../remedies/remedy.dart';
import '../report/sources.dart';
import 'link.dart';
import 'nonces.dart';

/// A support key one installed profile's subscription sent.
@immutable
final class TrustedKey {
  const TrustedKey({required this.profileId, required this.key});

  final int profileId;

  /// The raw 32-byte Ed25519 public key.
  final List<int> key;

  String get id => supportKeyId(key);
}

/// A link that passed every check, bound to the profile whose key signed it
/// and for which the named report was made.
@immutable
final class VerifiedFixLink {
  const VerifiedFixLink({required this.profileId, required this.payload});

  final int profileId;
  final FixPayload payload;
}

/// Runs the checks of a support fix link in order; the first failing one
/// throws [FixLinkRejected] and nothing is applied.
class FixLinkVerifier {
  FixLinkVerifier({
    required this.keys,
    required this.nonces,
    required this.findReport,
    required this.remedyReach,
    required this.hasGroup,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final List<TrustedKey> Function() keys;
  final NonceStore nonces;
  final Future<ReportRecord?> Function(String id) findReport;

  /// The reach of a registered catalogue remedy, null when there is none.
  final RemedyReach? Function(String id) remedyReach;
  final bool Function(int profileId, String group) hasGroup;
  final DateTime Function() _clock;

  Future<VerifiedFixLink> verify(String link) async {
    final envelope = parseFixLink(link);
    final payload = envelope.payload;
    final candidates = [
      for (final key in keys())
        if (key.id == payload.keyId) key,
    ];
    if (candidates.isEmpty) {
      throw const FixLinkRejected(FixLinkRejection.unknownKey);
    }
    final signers = <int>{};
    for (final candidate in candidates) {
      if (await _verifies(envelope, candidate.key)) {
        signers.add(candidate.profileId);
      }
    }
    if (signers.isEmpty) {
      throw const FixLinkRejected(FixLinkRejection.badSignature);
    }
    final now = _clock();
    if (!payload.expires.isAfter(now)) {
      throw const FixLinkRejected(FixLinkRejection.expired);
    }
    if (payload.expires.isAfter(now.add(fixLinkMaxLifetime))) {
      throw const FixLinkRejected(FixLinkRejection.tooFarAhead);
    }
    if (await nonces.isUsed(payload.nonce)) {
      throw const FixLinkRejected(FixLinkRejection.replayed);
    }
    final report = await findReport(payload.reportId);
    if (report == null ||
        report.id != payload.reportId ||
        report.createdAt.isBefore(now.subtract(fixLinkReportAge))) {
      throw const FixLinkRejected(FixLinkRejection.unknownReport);
    }
    final profileId = report.profileId;
    if (profileId == null || !signers.contains(profileId)) {
      throw const FixLinkRejected(FixLinkRejection.otherProfile);
    }
    for (final action in payload.actions) {
      _checkAllowed(action, profileId);
    }
    return VerifiedFixLink(profileId: profileId, payload: payload);
  }

  void _checkAllowed(FixAction action, int profileId) {
    switch (action.kind) {
      case FixActionKind.remedy:
        final reach = remedyReach(action.id);
        if (reach != RemedyReach.app && reach != RemedyReach.own) {
          throw const FixLinkRejected(FixLinkRejection.unknownAction);
        }
      case FixActionKind.proxySelect:
        if (!hasGroup(profileId, action.group!)) {
          throw const FixLinkRejected(FixLinkRejection.unknownGroup);
        }
      case FixActionKind.overridesReset:
        if (remedyReach(action.id) != RemedyReach.app) {
          throw const FixLinkRejected(FixLinkRejection.unknownAction);
        }
      case FixActionKind.profileUpdate ||
          FixActionKind.profileActivate ||
          FixActionKind.connectionsReset ||
          FixActionKind.coreRestart:
        break;
    }
  }

  Future<bool> _verifies(FixLinkEnvelope envelope, List<int> key) async {
    try {
      return await Ed25519().verify(
        envelope.signed,
        signature: Signature(
          envelope.signature,
          publicKey: SimplePublicKey(key, type: KeyPairType.ed25519),
        ),
      );
    } on Object {
      return false;
    }
  }
}

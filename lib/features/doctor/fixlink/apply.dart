import 'package:flutter/foundation.dart';

import '../journal.dart';
import '../kernel.dart';
import '../remedies/remedy.dart';
import 'link.dart';
import 'verifier.dart';

/// The app actions a link may take, each bound to the signing profile by the
/// caller.
abstract interface class FixActions {
  Future<void> updateProfile(int profileId);

  Future<void> activateProfile(int profileId);

  Future<void> selectProxy(int profileId, String group, String node);

  Future<void> resetConnections();

  Future<void> restartCore();
}

@immutable
final class FixStep {
  const FixStep(this.action, {required this.ok, this.canUndo = false});

  final FixAction action;
  final bool ok;
  final bool canUndo;
}

@immutable
final class FixLinkResult {
  const FixLinkResult({
    required this.reportId,
    required this.profileId,
    required this.steps,
  });

  final String reportId;
  final int profileId;
  final List<FixStep> steps;

  bool get ok => steps.every((step) => step.ok);

  bool get canUndo => steps.any((step) => step.canUndo);

  /// The line the user sends back to support; it stays English so support
  /// tooling can read it whatever the app's language.
  String get summary => [
    reportId,
    ok ? 'fix applied' : 'fix failed',
    steps
        .map((step) => '${step.action.id} ${step.ok ? 'ok' : 'failed'}')
        .join(', '),
  ].join(' · ');
}

class FixLinkService {
  FixLinkService({
    required this.verifier,
    required DiagnosticKernel kernel,
    required FixActions actions,
    DateTime Function()? clock,
  }) : _kernel = kernel,
       _actions = actions,
       _clock = clock ?? DateTime.now;

  final FixLinkVerifier verifier;
  final DiagnosticKernel _kernel;
  final FixActions _actions;
  final DateTime Function() _clock;

  Future<VerifiedFixLink> verify(String link) => verifier.verify(link);

  /// Verifies [link] again, since the confirmation may have stayed open past
  /// its expiry, and spends its nonce before the first action runs.
  Future<FixLinkResult> apply(String link, {required String provider}) async {
    final verified = await verifier.verify(link);
    final payload = verified.payload;
    if (!await verifier.nonces.consume(payload.nonce, payload.expires)) {
      throw const FixLinkRejected(FixLinkRejection.replayed);
    }
    final steps = [
      for (final action in payload.actions)
        await _run(action, verified.profileId),
    ];
    final result = FixLinkResult(
      reportId: payload.reportId,
      profileId: verified.profileId,
      steps: List.unmodifiable(steps),
    );
    await _kernel.record(
      DiagnosticEvent(
        kind: DiagnosticEventKind.supportFix,
        at: _clock(),
        subject: payload.reportId,
        outcome: result.ok ? 'applied' : 'failed',
        detail: '$provider: ${payload.actions.join(', ')}',
      ),
    );
    return result;
  }

  Future<FixStep> _run(FixAction action, int profileId) async {
    try {
      switch (action.kind) {
        case FixActionKind.remedy || FixActionKind.overridesReset:
          final outcome = await _kernel.apply(action.id);
          return FixStep(
            action,
            ok: switch (outcome.status) {
              RemedyStatus.fixed ||
              RemedyStatus.notFixed ||
              RemedyStatus.applied => true,
              _ => false,
            },
            canUndo: outcome.canUndo,
          );
        case FixActionKind.profileUpdate:
          await _actions.updateProfile(profileId);
        case FixActionKind.profileActivate:
          await _actions.activateProfile(profileId);
        case FixActionKind.proxySelect:
          await _actions.selectProxy(profileId, action.group!, action.node!);
        case FixActionKind.connectionsReset:
          await _actions.resetConnections();
        case FixActionKind.coreRestart:
          await _actions.restartCore();
      }
      return FixStep(action, ok: true);
    } on Object {
      return FixStep(action, ok: false);
    }
  }

  /// Takes back the undoable steps, newest first; false when one could not
  /// be, as when the setting changed since.
  Future<bool> undo(FixLinkResult result) async {
    var undone = true;
    for (final step in result.steps.reversed) {
      if (!step.canUndo) continue;
      final outcome = await _kernel.undo(step.action.id);
      undone &= outcome.status == RemedyStatus.undone;
    }
    return undone;
  }
}

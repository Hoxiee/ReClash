import 'package:flutter/foundation.dart';
import 'package:reclash/features/doctor/account/standing.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/supervisor/health.dart';

/// The button's lifecycle look; [paused] is a run the on-demand rules hold.
enum PowerLink { off, connecting, on, paused }

enum PowerTone { normal, attention, problem, failure, quiet }

/// What the big button or the pill under the title does.
enum PowerAction {
  start,
  stop,
  resume,
  addProfile,
  accountSheet,
  causeSheet,
  renew,
  topUp,
  support,
  updateProfile,
  grantVpn,
  openVpnSettings,
  openDateSettings,
  openPortal,
  ruleMode,
  repair,
  switchServer,
}

enum PowerFaceState {
  noProfile,
  starting,
  accountLocked,
  trafficLocked,
  revoked,
  noServers,
  vpnTaken,
  vpnDenied,
  portal,
  offline,
  clock,
  expired,
  exhausted,
  ending,
  off,
  paused,
  verifying,
  recovering,
  brokenClock,
  brokenPortal,
  broken,
  waitingNetwork,
  direct,
  grace,
  on,
}

/// The plan ends soon: [daysLeft] when expiry comes first, else
/// [trafficLeft] bytes.
@immutable
final class AccountAttention {
  const AccountAttention.days(int this.daysLeft) : trafficLeft = null;

  const AccountAttention.traffic(int this.trafficLeft) : daysLeft = null;

  final int? daysLeft;
  final int? trafficLeft;

  bool get byTraffic => trafficLeft != null;

  @override
  bool operator ==(Object other) =>
      other is AccountAttention &&
      other.daysLeft == daysLeft &&
      other.trafficLeft == trafficLeft;

  @override
  int get hashCode => Object.hash(daysLeft, trafficLeft);
}

/// Which of the provider's safe links exist.
@immutable
final class AccountLinks {
  const AccountLinks({
    this.renew = false,
    this.topUp = false,
    this.support = false,
  });

  final bool renew;
  final bool topUp;
  final bool support;

  PowerAction get renewAction => renew
      ? PowerAction.renew
      : support
      ? PowerAction.support
      : PowerAction.updateProfile;

  PowerAction get topUpAction => topUp ? PowerAction.topUp : renewAction;

  PowerAction? accountAction({required bool byTraffic}) {
    if (byTraffic ? topUp || renew || support : renew || support) {
      return byTraffic ? topUpAction : renewAction;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is AccountLinks &&
      other.renew == renew &&
      other.topUp == topUp &&
      other.support == support;

  @override
  int get hashCode => Object.hash(renew, topUp, support);
}

@immutable
final class PowerInputs {
  const PowerInputs({
    required this.link,
    this.hasProfile = true,
    this.online,
    this.findings = const [],
    this.health = ConnectionHealth.idle,
    this.account = AccountStanding.clear,
    this.attention,
    this.links = const AccountLinks(),
    this.direct = false,
  });

  final PowerLink link;
  final bool hasProfile;

  /// Null while the network state is unknown.
  final bool? online;
  final List<Finding> findings;
  final ConnectionHealth health;
  final AccountStanding account;
  final AccountAttention? attention;
  final AccountLinks links;

  /// The outbound mode sends everything around the tunnel.
  final bool direct;

  PowerInputs withLink(PowerLink link) => PowerInputs(
    link: link,
    hasProfile: hasProfile,
    online: online,
    findings: findings,
    health: health,
    account: account,
    attention: attention,
    links: links,
    direct: direct,
  );
}

@immutable
final class PowerFace {
  const PowerFace({
    required this.state,
    required this.link,
    required this.tap,
    this.tone = PowerTone.normal,
    this.fix,
    this.secondFix,
    this.verified = false,
    this.cause,
    this.attention,
    this.step,
    this.stepDetail,
    this.checking = false,
  });

  /// The look of a bare [link], for surfaces without the kernel.
  factory PowerFace.plain(PowerLink link) => PowerFace(
    state: switch (link) {
      PowerLink.off => PowerFaceState.off,
      PowerLink.connecting => PowerFaceState.starting,
      PowerLink.on => PowerFaceState.on,
      PowerLink.paused => PowerFaceState.paused,
    },
    link: link,
    tap: switch (link) {
      PowerLink.off => PowerAction.start,
      PowerLink.paused => PowerAction.resume,
      _ => PowerAction.stop,
    },
  );

  final PowerFaceState state;
  final PowerLink link;
  final PowerTone tone;

  /// Null disables the button.
  final PowerAction? tap;

  /// The pill; null leaves the second row to text or the live line.
  final PowerAction? fix;

  /// A pill beside [fix] for a choice the app never makes on its own.
  final PowerAction? secondFix;

  /// The connection answered through the tunnel: the check badge.
  final bool verified;
  final FailureCause? cause;
  final AccountAttention? attention;
  final HealStep? step;
  final String? stepDetail;

  /// A stale expired or exhausted reading is being refreshed.
  final bool checking;

  bool get running => link == PowerLink.on || link == PowerLink.paused;

  @override
  bool operator ==(Object other) =>
      other is PowerFace &&
      other.state == state &&
      other.link == link &&
      other.tone == tone &&
      other.tap == tap &&
      other.fix == fix &&
      other.secondFix == secondFix &&
      other.verified == verified &&
      other.cause == cause &&
      other.attention == attention &&
      other.step == step &&
      other.stepDetail == stepDetail &&
      other.checking == checking;

  @override
  int get hashCode => Object.hash(
    state,
    link,
    tone,
    tap,
    fix,
    secondFix,
    verified,
    cause,
    attention,
    step,
    stepDetail,
    checking,
  );

  @override
  String toString() => 'PowerFace(${state.name}, ${link.name}, ${tone.name})';
}

const revokedFinding = 'profile.revoked';
const noServersFinding = 'profile.noServers';
const _subscriptionFinding = 'profile.subscription';
const _vpnPermissionFinding = 'tunnel.vpnPermission';
const _alwaysOnFinding = 'tunnel.alwaysOn';
const _portalFinding = 'network.captivePortal';
const _clockFinding = 'device.clockSkew';

Finding? _critical(List<Finding> findings, String id) => findings
    .where(
      (finding) =>
          finding.id == id &&
          finding.severity == CheckSeverity.critical &&
          finding.cause != null,
    )
    .firstOrNull;

Finding? _raised(List<Finding> findings, String id) =>
    findings.where((finding) => finding.id == id).firstOrNull;

/// The subscription cause the kernel raised, expired or exhausted.
FailureCause? _accountCause(List<Finding> findings) =>
    _critical(findings, _subscriptionFinding)?.cause;

PowerFace resolvePowerFace(PowerInputs inputs) {
  if (!inputs.hasProfile) {
    return const PowerFace(
      state: PowerFaceState.noProfile,
      link: PowerLink.off,
      tap: PowerAction.addProfile,
      fix: PowerAction.addProfile,
    );
  }
  return switch (inputs.link) {
    PowerLink.connecting => const PowerFace(
      state: PowerFaceState.starting,
      link: PowerLink.connecting,
      tap: PowerAction.stop,
    ),
    PowerLink.paused => const PowerFace(
      state: PowerFaceState.paused,
      link: PowerLink.paused,
      tap: PowerAction.resume,
    ),
    PowerLink.on => _running(inputs),
    PowerLink.off => _stopped(inputs),
  };
}

PowerFace _stopped(PowerInputs inputs) {
  final findings = inputs.findings;
  final links = inputs.links;
  PowerFace face(
    PowerFaceState state,
    PowerTone tone, {
    PowerAction? tap = PowerAction.start,
    PowerAction? fix,
    FailureCause? cause,
    AccountAttention? attention,
    bool checking = false,
  }) => PowerFace(
    state: state,
    link: PowerLink.off,
    tone: tone,
    tap: tap,
    fix: fix,
    cause: cause,
    attention: attention,
    checking: checking,
  );

  switch (inputs.account.lock) {
    case AccountLock.expired:
      return face(
        PowerFaceState.accountLocked,
        PowerTone.failure,
        tap: PowerAction.accountSheet,
        fix: links.renewAction,
        cause: FailureCause.subscriptionExpired,
      );
    case AccountLock.exhausted:
      return face(
        PowerFaceState.trafficLocked,
        PowerTone.failure,
        tap: PowerAction.accountSheet,
        fix: links.topUpAction,
        cause: FailureCause.trafficExhausted,
      );
    case AccountLock.none:
  }
  if (_critical(findings, revokedFinding) case final revoked?) {
    return face(
      PowerFaceState.revoked,
      PowerTone.failure,
      tap: PowerAction.accountSheet,
      fix: links.support ? PowerAction.support : PowerAction.updateProfile,
      cause: revoked.cause,
    );
  }
  if (_critical(findings, noServersFinding) case final noServers?) {
    return face(
      PowerFaceState.noServers,
      PowerTone.failure,
      tap: PowerAction.updateProfile,
      fix: PowerAction.updateProfile,
      cause: noServers.cause,
    );
  }
  if (_critical(findings, _alwaysOnFinding) case final taken?) {
    return face(
      PowerFaceState.vpnTaken,
      PowerTone.problem,
      tap: PowerAction.causeSheet,
      fix: PowerAction.openVpnSettings,
      cause: taken.cause,
    );
  }
  if (_critical(findings, _vpnPermissionFinding) case final denied?) {
    return face(
      PowerFaceState.vpnDenied,
      PowerTone.problem,
      tap: PowerAction.grantVpn,
      fix: PowerAction.grantVpn,
      cause: denied.cause,
    );
  }
  if (_raised(findings, _portalFinding) != null) {
    return face(
      PowerFaceState.portal,
      PowerTone.problem,
      tap: PowerAction.openPortal,
      fix: PowerAction.openPortal,
      cause: FailureCause.captivePortal,
    );
  }
  if (inputs.online == false) {
    return face(
      PowerFaceState.offline,
      PowerTone.quiet,
      cause: FailureCause.noNetwork,
    );
  }
  if (_critical(findings, _clockFinding) case final clock?) {
    return face(
      PowerFaceState.clock,
      PowerTone.problem,
      fix: PowerAction.openDateSettings,
      cause: clock.cause,
    );
  }
  switch (_accountCause(findings)) {
    case FailureCause.subscriptionExpired:
      return face(
        PowerFaceState.expired,
        PowerTone.problem,
        fix: links.renewAction,
        cause: FailureCause.subscriptionExpired,
        checking: inputs.account.checking,
      );
    case FailureCause.trafficExhausted:
      return face(
        PowerFaceState.exhausted,
        PowerTone.problem,
        fix: links.topUpAction,
        cause: FailureCause.trafficExhausted,
        checking: inputs.account.checking,
      );
    default:
  }
  if (inputs.attention case final attention?) {
    return face(
      PowerFaceState.ending,
      PowerTone.attention,
      fix: links.accountAction(byTraffic: attention.byTraffic),
      attention: attention,
    );
  }
  return face(PowerFaceState.off, PowerTone.normal);
}

PowerFace _running(PowerInputs inputs) {
  final health = inputs.health;
  final links = inputs.links;
  final accountCause = _accountCause(inputs.findings);
  PowerFace face(
    PowerFaceState state,
    PowerTone tone, {
    PowerLink link = PowerLink.on,
    PowerAction? fix,
    PowerAction? secondFix,
    FailureCause? cause,
    bool verified = false,
    AccountAttention? attention,
  }) => PowerFace(
    state: state,
    link: link,
    tone: tone,
    tap: PowerAction.stop,
    fix: fix,
    secondFix: secondFix,
    verified: verified,
    cause: cause,
    attention: attention,
    step: health.step,
    stepDetail: health.stepDetail,
  );

  if (inputs.online == false ||
      health.phase == ConnectionPhase.waitingNetwork) {
    return face(
      PowerFaceState.waitingNetwork,
      PowerTone.quiet,
      cause: FailureCause.noNetwork,
    );
  }
  switch (health.phase) {
    case ConnectionPhase.connecting:
      return face(
        PowerFaceState.verifying,
        PowerTone.normal,
        link: PowerLink.connecting,
      );
    case ConnectionPhase.recovering:
      return face(PowerFaceState.recovering, PowerTone.normal);
    case ConnectionPhase.broken:
      return switch (health.cause) {
        FailureCause.clockSkew => face(
          PowerFaceState.brokenClock,
          PowerTone.failure,
          fix: PowerAction.openDateSettings,
          cause: FailureCause.clockSkew,
        ),
        FailureCause.captivePortal => face(
          PowerFaceState.brokenPortal,
          PowerTone.failure,
          fix: PowerAction.openPortal,
          cause: FailureCause.captivePortal,
        ),
        _ when accountCause != null => face(
          PowerFaceState.broken,
          PowerTone.failure,
          fix: accountCause == FailureCause.trafficExhausted
              ? links.topUpAction
              : links.renewAction,
          cause: accountCause,
        ),
        final cause => face(
          PowerFaceState.broken,
          PowerTone.failure,
          fix: health.repairFailed
              ? PowerAction.causeSheet
              : PowerAction.repair,
          secondFix: PowerAction.switchServer,
          cause: cause,
        ),
      };
    case ConnectionPhase.idle ||
        ConnectionPhase.verified ||
        ConnectionPhase.unknown ||
        ConnectionPhase.waitingNetwork:
  }
  final verified = health.phase == ConnectionPhase.verified;
  if (inputs.direct) {
    return face(
      PowerFaceState.direct,
      PowerTone.attention,
      fix: PowerAction.ruleMode,
      verified: verified,
    );
  }
  if (accountCause != null) {
    return face(
      PowerFaceState.grace,
      PowerTone.attention,
      fix: accountCause == FailureCause.trafficExhausted
          ? links.topUpAction
          : links.renewAction,
      cause: accountCause,
      verified: verified,
    );
  }
  if (inputs.attention case final attention?) {
    return face(
      PowerFaceState.ending,
      PowerTone.attention,
      fix: links.accountAction(byTraffic: attention.byTraffic),
      attention: attention,
      verified: verified,
    );
  }
  return face(PowerFaceState.on, PowerTone.normal, verified: verified);
}

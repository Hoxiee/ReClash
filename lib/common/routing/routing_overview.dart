import 'package:reclash/models/models.dart';

enum NetworkFormat { unknown, open, restricted, portal, offline }

NetworkFormat networkFormatOf(String terrain) => switch (terrain) {
  'normal' => NetworkFormat.open,
  'whitelist' => NetworkFormat.restricted,
  'portal' => NetworkFormat.portal,
  'offline' => NetworkFormat.offline,
  _ => NetworkFormat.unknown,
};

extension RcxLinkReportFormat on RcxLinkReport {
  /// Reach outcomes carry `overloaded` for "never measured", so an unmeasured
  /// canary must not read as a failed one. `mismatch` is a TLS chain a gate
  /// forged: the address answered, the open internet did not.
  bool get foreignReached => foreign == 'ok';

  bool get domesticReached => domestic == 'ok';

  bool get foreignMeasured =>
      foreign == 'ok' || foreign == 'fail' || foreign == 'mismatch';

  bool get foreignForged => foreign == 'mismatch';

  bool get domesticMeasured => domestic == 'ok' || domestic == 'fail';
}

extension RcxCanaryReportView on RcxCanaryReport {
  bool get answered => outcome == 'ok';

  bool get measured =>
      outcome == 'ok' || outcome == 'fail' || outcome == 'mismatch';

  bool get forged => outcome == 'mismatch';

  /// The host is what a person recognises; the port is noise until it is not.
  String get label => addr;
}

extension RcxCandidateReportView on RcxCandidateReport {
  bool get eligible => block.isEmpty;

  bool get proven => verdict == 'preferred' || verdict == 'viable';

  /// The endpoint country names the front a relay-fronted node advertises, so a
  /// measured egress replaces it rather than joining it.
  String get region => exit.isNotEmpty ? exit : country;
}

class RoutingCounts {
  const RoutingCounts({
    required this.total,
    required this.eligible,
    required this.blocked,
    required this.unknown,
  });

  final int total;
  final int eligible;
  final int blocked;
  final int unknown;
}

RoutingCounts routingCountsOf(RcxReport report) {
  final rows = report.candidates;
  if (rows.isEmpty) {
    final total = report.status.candidates;
    final eligible = report.status.eligible;
    return RoutingCounts(
      total: total,
      eligible: eligible,
      blocked: total - eligible < 0 ? 0 : total - eligible,
      unknown: 0,
    );
  }
  var eligible = 0;
  var unknown = 0;
  for (final row in rows) {
    if (row.eligible) {
      eligible++;
      if (row.evidence == 'none') {
        unknown++;
      }
    }
  }
  return RoutingCounts(
    total: rows.length,
    eligible: eligible,
    blocked: rows.length - eligible,
    unknown: unknown,
  );
}

enum RoutingRung {
  admission,
  verdict,
  misfit,
  recurrence,
  degraded,
  homeRisk,
  latency,
  evidence,
  unproven,
  incumbent,
  tiebreak,
}

const _balancedLadder = [
  RoutingRung.admission,
  RoutingRung.verdict,
  RoutingRung.misfit,
  RoutingRung.recurrence,
  RoutingRung.degraded,
  RoutingRung.homeRisk,
  RoutingRung.latency,
  RoutingRung.evidence,
  RoutingRung.unproven,
  RoutingRung.incumbent,
  RoutingRung.tiebreak,
];

const _latencyLadder = [
  RoutingRung.admission,
  RoutingRung.verdict,
  RoutingRung.recurrence,
  RoutingRung.degraded,
  RoutingRung.homeRisk,
  RoutingRung.latency,
  RoutingRung.evidence,
  RoutingRung.unproven,
  RoutingRung.incumbent,
  RoutingRung.tiebreak,
];

List<RoutingRung> routingLadder(String strategy) => switch (strategy) {
  'lowest-latency' => _latencyLadder,
  _ => _balancedLadder,
};

/// Ranking, never filtering: only a whitelist network wants the specialist.
int _routingMisfit(String terrain, bool breaker) =>
    terrain == 'whitelist' ? (breaker ? 0 : 1) : (breaker ? 1 : 0);

int _routingVerdictRank(String verdict) => switch (verdict) {
  'preferred' => 0,
  'viable' => 1,
  'last-resort' => 2,
  _ => 3,
};

int _routingEvidenceRank(String evidence) => switch (evidence) {
  'live' || 'fresh' => 0,
  'stale' => 2,
  _ => 3,
};

int routingRungValue(
  RoutingRung rung,
  RcxCandidateReport candidate,
  String terrain,
) => switch (rung) {
  RoutingRung.admission => candidate.eligible ? 0 : 1,
  RoutingRung.verdict => _routingVerdictRank(candidate.verdict),
  RoutingRung.misfit => _routingMisfit(terrain, candidate.breaker),
  RoutingRung.evidence => _routingEvidenceRank(candidate.evidence),
  RoutingRung.recurrence => candidate.recurrence < 2 ? 0 : candidate.recurrence,
  RoutingRung.degraded => candidate.degraded ? 1 : 0,
  RoutingRung.homeRisk => candidate.homeRisk,
  RoutingRung.latency =>
    candidate.latencyMs > 0 ? candidate.latencyMs : 0x7fffffffffffffff,
  RoutingRung.unproven => candidate.unproven ? 1 : 0,
  RoutingRung.incumbent => candidate.current ? 0 : 1,
  RoutingRung.tiebreak => candidate.order,
};

typedef RoutingDuel = ({RoutingRung? rung, bool won});

/// The first rung [candidate] and [rival] differ on; a null rung means none does.
RoutingDuel routingDuel(
  RcxCandidateReport candidate,
  RcxCandidateReport rival, {
  required String terrain,
  required String strategy,
}) {
  for (final rung in routingLadder(strategy)) {
    final mine = routingRungValue(rung, candidate, terrain);
    final theirs = routingRungValue(rung, rival, terrain);
    if (mine != theirs) {
      return (rung: rung, won: mine < theirs);
    }
  }
  return (rung: null, won: false);
}

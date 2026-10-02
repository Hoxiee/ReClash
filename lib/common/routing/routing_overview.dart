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

// The shipped comparator order in wire tokens, mirroring the committed golden
// fixture core/rcx/testdata/default_ladder.json; admission is a Dart-only gate
// shown first, not a core rung.
const routingDefaultRungTokens = [
  'verdict',
  'misfit',
  'recurrence',
  'degraded',
  'homeRisk',
  'latency',
  'evidence',
  'unproven',
  'incumbent',
  'tiebreak',
];

List<RoutingRung> routingDefaultLadder() => [
  RoutingRung.admission,
  for (final token in routingDefaultRungTokens)
    RoutingRung.values.byName(token),
];

List<RoutingRung> routingLadder(String strategy) {
  final full = routingDefaultLadder();
  if (strategy == 'lowest-latency') {
    return [
      for (final rung in full)
        if (rung != RoutingRung.misfit) rung,
    ];
  }
  return full;
}

/// The ladder the core actually applied, echoed in [RcxReport.ladder]: admission
/// first, then every enabled rung in the edited order. Falls back to the shipped
/// order for an empty report (older core, or a hold before the first decision).
List<RoutingRung> routingLadderFromSpecs(
  List<RcxRungSpec> specs,
  String strategy,
) {
  if (specs.isEmpty) {
    return routingLadder(strategy);
  }
  final byName = RoutingRung.values.asNameMap();
  return [
    RoutingRung.admission,
    for (final spec in specs)
      if (spec.enabled) ?byName[spec.id],
  ];
}

/// Per-rung tunables the core echoes back; the duel view reads them so an edited
/// recurrence floor or latency tolerance changes the breakdown immediately.
typedef RoutingThresholds = ({int recurrenceFloor, int latencyToleranceMs});

/// The recurrence floor the core applies by default (core `rcxRecurrenceFloorDefault`
/// and the golden fixture's `rf`), below which a fresh node's failures do not yet
/// weigh against it. Kept in one place so the editor seeds the same number.
const routingRecurrenceFloorDefault = 2;

const _defaultThresholds = (
  recurrenceFloor: routingRecurrenceFloorDefault,
  latencyToleranceMs: 0,
);

/// The default ladder as editable specs: the shipped comparator order, every
/// rung enabled, with only recurrence carrying a non-zero threshold. The editor
/// materializes this when [SmartRoutingProps.ladder] is still empty (the wire
/// signal for "let the engine use its default").
List<RcxRungSpec> routingDefaultLadderSpecs() => [
  for (final token in routingDefaultRungTokens)
    RcxRungSpec(
      id: token,
      recurrenceFloor: token == RoutingRung.recurrence.name
          ? routingRecurrenceFloorDefault
          : 0,
    ),
];

RoutingThresholds _thresholdsFor(RoutingRung rung, List<RcxRungSpec> specs) {
  for (final spec in specs) {
    if (spec.id == rung.name) {
      return (
        recurrenceFloor: spec.recurrenceFloor,
        latencyToleranceMs: spec.latencyToleranceMs,
      );
    }
  }
  return _defaultThresholds;
}

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
  String terrain, [
  RoutingThresholds thresholds = _defaultThresholds,
]) => switch (rung) {
  RoutingRung.admission => candidate.eligible ? 0 : 1,
  RoutingRung.verdict => _routingVerdictRank(candidate.verdict),
  RoutingRung.misfit => _routingMisfit(terrain, candidate.breaker),
  RoutingRung.evidence => _routingEvidenceRank(candidate.evidence),
  RoutingRung.recurrence =>
    candidate.recurrence < thresholds.recurrenceFloor
        ? 0
        : candidate.recurrence,
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
/// [ladder] is the core's echoed ladder ([RcxReport.ladder]); empty falls back
/// to the strategy's shipped order with default thresholds.
RoutingDuel routingDuel(
  RcxCandidateReport candidate,
  RcxCandidateReport rival, {
  required String terrain,
  required String strategy,
  List<RcxRungSpec> ladder = const [],
}) {
  final rungs = routingLadderFromSpecs(ladder, strategy);
  for (final rung in rungs) {
    final thresholds = ladder.isEmpty
        ? _defaultThresholds
        : _thresholdsFor(rung, ladder);
    final mine = routingRungValue(rung, candidate, terrain, thresholds);
    final theirs = routingRungValue(rung, rival, terrain, thresholds);
    if (rung == RoutingRung.latency &&
        thresholds.latencyToleranceMs > 0 &&
        (mine - theirs).abs() <= thresholds.latencyToleranceMs) {
      continue;
    }
    if (mine != theirs) {
      return (rung: rung, won: mine < theirs);
    }
  }
  return (rung: null, won: false);
}

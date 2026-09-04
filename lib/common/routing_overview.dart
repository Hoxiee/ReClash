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
  /// canary must not read as a failed one.
  bool get foreignReached => foreign == 'ok';

  bool get domesticReached => domestic == 'ok';

  bool get foreignMeasured => foreign == 'ok' || foreign == 'fail';

  bool get domesticMeasured => domestic == 'ok' || domestic == 'fail';
}

extension RcxCanaryReportView on RcxCanaryReport {
  bool get answered => outcome == 'ok';

  bool get measured => outcome == 'ok' || outcome == 'fail';

  /// The host is what a person recognises; the port is noise until it is not.
  String get label => addr;
}

extension RcxCandidateReportView on RcxCandidateReport {
  bool get eligible => block.isEmpty;

  bool get proven => verdict == 'preferred' || verdict == 'viable';
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

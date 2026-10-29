import 'dart:isolate';

import '../finding.dart';
import '../snapshot.dart';

/// Pure and synchronous: a rule reads the snapshot and nothing else, so the
/// engine can move it to an isolate and tests need no device.
typedef Rule = Finding? Function(DiagnosticSnapshot snapshot);

List<Finding> evaluateRules(DiagnosticSnapshot snapshot, List<Rule> rules) {
  final findings = <String, Finding>{};
  for (final rule in rules) {
    final finding = rule(snapshot);
    if (finding != null) findings[finding.id] = finding;
  }
  return findings.values.toList()..sort(compareFindings);
}

class RuleEngine {
  const RuleEngine(this.rules, {this.isolateWeight = 2000});

  /// Top-level functions only: the list is sent to the isolate as it is.
  final List<Rule> rules;

  /// A snapshot at least this heavy is evaluated off the UI isolate.
  final int isolateWeight;

  Future<List<Finding>> evaluate(DiagnosticSnapshot snapshot) async {
    if (snapshot.weight < isolateWeight) {
      return evaluateRules(snapshot, rules);
    }
    final sent = rules;
    return Isolate.run(() => evaluateRules(snapshot, sent));
  }
}

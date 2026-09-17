import 'dart:io';

import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/dashboard/widgets/routing_overview.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const _decide = 'core/rcx_decide.go';

Set<String> _constants(String source, String type) => RegExp(
  'rcx$type'
  r'\w+\s+rcx'
  '$type'
  r'\s*=\s*"([^"]+)"',
).allMatches(source).map((match) => match.group(1)!).toSet();

Set<String> _returned(String source, String type) {
  final body = RegExp(
    'func \\(\\w+ rcx$type\\) String\\(\\) string \\{.*?\\n\\}',
    dotAll: true,
  ).firstMatch(source);
  expect(body, isNotNull, reason: 'rcx$type has no String() in $_decide');
  return RegExp(
    r'return "([^"]+)"',
  ).allMatches(body!.group(0)!).map((match) => match.group(1)!).toSet();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;
  late String source;

  setUpAll(() async {
    l10n = await AppLocalizations.load(const Locale('en'));
    source = [
      File(_decide).readAsStringSync(),
      File('core/rcx_selection.go').readAsStringSync(),
    ].join('\n');
  });

  // A label the UI never wrote falls through to a default that reads as a
  // different verdict, so a silent gap looks like a working screen.
  void expectDistinct(Set<String> vocabulary, String Function(String) label) {
    expect(vocabulary, isNotEmpty, reason: 'nothing was read from $_decide');
    final labels = {for (final word in vocabulary) word: label(word)};
    expect(
      labels.values.toSet(),
      hasLength(vocabulary.length),
      reason: 'two of these share a label or fall back to one: $labels',
    );
  }

  test('every reason the engine can decide on has its own line', () {
    final reasons = _constants(source, 'Reason');

    expectDistinct(reasons, (reason) => routingReasonLabel(l10n, reason));
    for (final reason in reasons) {
      expect(
        routingReasonLabel(l10n, reason),
        isNot(l10n.unknown),
        reason: '$reason has no label of its own',
      );
    }
  });

  test('every gate the engine can close has its own line', () {
    final blocks = _constants(source, 'Block');
    String label(String block) => routingBlockLabel(
      l10n,
      RcxCandidateReport(block: block, verdict: 'preferred', fails: 4),
    );

    expectDistinct(blocks, label);
    for (final block in blocks) {
      expect(
        label(block),
        isNot(routingVerdictLabel(l10n, 'preferred')),
        reason: '$block reads as the rank it was supposed to replace',
      );
    }
  });

  test('every rank the engine can report has its own line', () {
    expectDistinct(
      _returned(source, 'Verdict'),
      (verdict) => routingVerdictLabel(l10n, verdict),
    );
    expectDistinct(
      _returned(source, 'Evidence'),
      (evidence) => routingEvidenceLabel(l10n, evidence),
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview_parts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.load(const Locale('en'));
  });

  test('a blank rename is rejected', () {
    for (final vocab in routingVocabularies) {
      expect(
        validateRoutingVocabEdit(vocab: vocab, value: '   ', otherLabels: []),
        RoutingVocabEditError.empty,
        reason: '$vocab must reject a whitespace-only label',
      );
    }
  });

  test('a rename onto another token in the same vocabulary is rejected', () {
    expect(
      validateRoutingVocabEdit(
        vocab: routingVocabVerdict,
        value: 'Taken',
        otherLabels: const ['Taken', 'Other'],
      ),
      RoutingVocabEditError.duplicate,
    );
  });

  test('rung labels may repeat because they never reach the core', () {
    expect(
      validateRoutingVocabEdit(
        vocab: routingVocabRung,
        value: 'Same',
        otherLabels: const ['Same'],
      ),
      RoutingVocabEditError.none,
    );
  });

  test('a distinct label passes', () {
    expect(
      validateRoutingVocabEdit(
        vocab: routingVocabVerdict,
        value: 'Fresh',
        otherLabels: const ['Taken', 'Other'],
      ),
      RoutingVocabEditError.none,
    );
  });

  test('shipped defaults are one-to-one within every core-facing vocabulary', () {
    for (final vocab in routingVocabularies) {
      if (!routingVocabEnforcesUniqueness(vocab)) {
        continue;
      }
      final labels = [
        for (final token in routingVocabTokens(vocab))
          routingVocabDefaultLabel(l10n, vocab, token),
      ];
      expect(
        labels.toSet().length,
        labels.length,
        reason: '$vocab default labels must stay distinct',
      );
    }
  });
}

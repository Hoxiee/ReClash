import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/import_policy.dart';
import 'package:reclash/subscriptions/imports/import.dart';

void main() {
  const summary = SubscriptionImportSummary(
    nodes: 2,
    ignoredSections: ['dns', 'routing'],
    hasLosses: true,
  );
  final scope = subscriptionImportScope('https://example.test/sub', 'key');

  test('requires explicit acceptance for lossy imports by default', () {
    expect(
      const SubscriptionImportPolicy().allows(
        SubscriptionFormat.xray,
        summary,
        sourceScope: scope,
      ),
      false,
    );
  });

  test('accepted sections apply only to the same source and format', () {
    final policy = SubscriptionImportPolicy.accepted(
      scope: scope,
      format: SubscriptionFormat.xray,
      summary: summary,
    );
    expect(
      policy.allows(SubscriptionFormat.xray, summary, sourceScope: scope),
      true,
    );
    expect(
      policy.allows(SubscriptionFormat.singbox, summary, sourceScope: scope),
      false,
    );
    expect(
      policy.allows(
        SubscriptionFormat.xray,
        summary,
        sourceScope: subscriptionImportScope('https://other.test/sub', 'key'),
      ),
      false,
    );
    expect(
      policy.allows(
        SubscriptionFormat.xray,
        const SubscriptionImportSummary(
          nodes: 2,
          ignoredSections: ['dns', 'new-section'],
          hasLosses: true,
        ),
        sourceScope: scope,
      ),
      false,
    );
  });

  test('partial nodes and other losses require their own acceptance', () {
    final policy = SubscriptionImportPolicy.accepted(
      scope: scope,
      format: SubscriptionFormat.xray,
      summary: summary,
    );
    expect(
      policy.allows(
        SubscriptionFormat.xray,
        const SubscriptionImportSummary(
          nodes: 2,
          skipped: ['unsupported'],
          hasLosses: true,
        ),
        sourceScope: scope,
      ),
      false,
    );
    expect(
      policy.allows(
        SubscriptionFormat.xray,
        const SubscriptionImportSummary(
          nodes: 2,
          hasOtherLosses: true,
          hasLosses: true,
        ),
        sourceScope: scope,
      ),
      false,
    );
  });

  test(
    'round-trips consent with the client settings without input secrets',
    () {
      final settings = SubscriptionClientSettings(
        importPolicy: SubscriptionImportPolicy.accepted(
          scope: scope,
          format: SubscriptionFormat.xray,
          summary: summary,
        ),
      );
      final restored = SubscriptionClientSettings.safeFromJson(
        settings.toJson(),
      );
      expect(restored.importPolicy.toJson(), settings.importPolicy.toJson());
      expect(
        restored.toJson().toString(),
        isNot(contains('https://example.test')),
      );
    },
  );

  test('malformed consent fails closed without losing the selected client', () {
    final settings = SubscriptionClientSettings.safeFromJson({
      'preset': 'happ',
      'importPolicy': {'format': 'xray', 'scope': 'invalid'},
    });
    expect(settings.preset, SubscriptionClientPreset.happ);
    expect(settings.importPolicy.isEmpty, true);
  });
}

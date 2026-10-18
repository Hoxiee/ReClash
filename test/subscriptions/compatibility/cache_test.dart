import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/backup.dart';
import 'package:reclash/subscriptions/compatibility/cache.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/import_policy.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/metadata/preferences.dart';

void main() {
  late Directory directory;
  late SubscriptionClientCache cache;

  setUp(() {
    directory = Directory.systemTemp.createTempSync(
      'subscription_client_cache',
    );
    cache = SubscriptionClientCache(directory: directory);
  });

  tearDown(() => directory.deleteSync(recursive: true));

  String fingerprint({
    String url = 'https://example.test/sub?token=SECRET',
    String key = 'SECRET-AGE',
    String userAgent = 'ReClash/test',
    SubscriptionPreferences preferences = const SubscriptionPreferences(),
    String? locale,
  }) => subscriptionClientFingerprint(
    url: url,
    ageSecretKey: key,
    preferences: preferences.toJson(),
    defaultUserAgent: userAgent,
    locale: locale,
  );

  test('persists only a client and a digest, never input secrets', () async {
    final input = fingerprint();
    await cache.remember(42, input, SubscriptionClientPreset.happ);
    expect(await cache.read(42, input), SubscriptionClientPreset.happ);
    final file = File('${directory.path}/subscription_clients/42.json');
    final bytes = await file.readAsString();
    expect(bytes, isNot(contains('SECRET')));
    expect(bytes, isNot(contains('example.test')));
    expect(jsonDecode(bytes), {'v': 1, 'fingerprint': input, 'client': 'happ'});
  });

  test(
    'URL, key, effective UA, locale, headers and policy invalidate the cache',
    () async {
      final input = fingerprint();
      await cache.remember(42, input, SubscriptionClientPreset.happ);
      final policy = SubscriptionImportPolicy.accepted(
        scope: subscriptionImportScope('url', 'key'),
        format: SubscriptionFormat.xray,
        summary: const SubscriptionImportSummary(
          nodes: 1,
          ignoredSections: ['routing'],
          hasLosses: true,
        ),
      );
      for (final changed in [
        fingerprint(url: 'https://other.test/sub'),
        fingerprint(key: 'another key'),
        fingerprint(userAgent: 'ReClash/new'),
        fingerprint(locale: 'ru'),
        fingerprint(
          preferences: const SubscriptionPreferences(
            headers: {'x-token': 'new'},
          ),
        ),
        fingerprint(
          preferences: SubscriptionPreferences(
            client: SubscriptionClientSettings(importPolicy: policy),
          ),
        ),
      ]) {
        expect(changed, isNot(input));
        expect(await cache.read(42, changed), isNull);
      }
    },
  );

  test('header ordering does not invalidate identical requests', () {
    expect(
      fingerprint(
        preferences: const SubscriptionPreferences(
          headers: {'a': '1', 'b': '2'},
        ),
      ),
      fingerprint(
        preferences: const SubscriptionPreferences(
          headers: {'b': '2', 'a': '1'},
        ),
      ),
    );
  });

  test('can rekey an accepted candidate after remembering its policy', () {
    final preferences = const SubscriptionPreferences().toJson();
    final request = subscriptionClientRequestFingerprint(
      url: 'url',
      ageSecretKey: 'key',
      preferences: preferences,
      defaultUserAgent: 'ua',
    );
    expect(
      subscriptionClientCacheKey(
        request,
        (preferences['client'] as Map)['importPolicy'],
      ),
      subscriptionClientFingerprint(
        url: 'url',
        ageSecretKey: 'key',
        preferences: preferences,
        defaultUserAgent: 'ua',
      ),
    );
  });

  test('ignores malformed cache data and forgets deleted profiles', () async {
    final file = File('${directory.path}/subscription_clients/42.json');
    await file.parent.create(recursive: true);
    await file.writeAsString('not json');
    expect(await cache.read(42, fingerprint()), isNull);
    await cache.remember(42, fingerprint(), SubscriptionClientPreset.clash);
    await cache.forget(42);
    expect(await file.exists(), isFalse);
  });

  test('local negotiation state is not part of backup entries', () {
    expect(BackupEntries.of(profileIds: [42], scriptIds: [], providers: []), [
      'profiles/42.yaml',
    ]);
  });
}

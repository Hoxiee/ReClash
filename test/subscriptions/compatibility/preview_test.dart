import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/exception.dart';
import 'package:reclash/models/profile.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';
import 'package:reclash/subscriptions/compatibility/preview.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

PreparedSubscriptionUpdate _prepared(Profile profile) =>
    PreparedSubscriptionUpdate(
      profileId: profile.id,
      sourceUrl: profile.url,
      sourceAgeSecretKey: profile.ageSecretKey,
      sourcePreferences: profile.subscriptionPreferences,
      payload: SubscriptionImportResult(
        bytes: Uint8List(0),
        format: SubscriptionFormat.clash,
        summary: const SubscriptionImportSummary(nodes: 1),
      ),
      metadata: const SubscriptionMetadataResult(
        metadata: SubscriptionMetadata(),
        source: SubscriptionDataSource.http,
      ),
      subscriptionInfo: null,
      snapshot: SubscriptionSnapshot(
        metadata: const SubscriptionMetadata(),
        receivedAt: DateTime(2026),
      ),
      label: profile.label,
      client: SubscriptionClientPreset.clashMeta,
    );

void main() {
  test(
    'checks form values without committing or changing the source',
    () async {
      final source = Profile.normal(
        label: 'Example',
        url: 'https://old.test/sub',
      );
      final candidate = source.copyWith(url: 'https://new.test/sub');
      var calls = 0;
      final result = _prepared(candidate);
      final preview = SubscriptionClientPreview(
        prepare: (profile, _) async {
          calls++;
          expect(profile, candidate);
          return result;
        },
      );
      addTearDown(preview.dispose);
      expect(calls, 0);
      await preview.check(candidate, source: source);
      expect(calls, 1);
      expect(preview.matches(candidate), true);
      expect(preview.source, same(source));
      expect(preview.checking, false);
      expect(source.lastUpdateDate, null);
      expect(source.subscriptionSnapshot, null);
      expect(preview.prepared, same(result));
    },
  );

  test('invalidates a candidate when request inputs change', () async {
    final profile = Profile.normal(
      label: 'Example',
      url: 'https://example.test/sub',
    );
    final preview = SubscriptionClientPreview(
      prepare: (profile, _) async => _prepared(profile),
    );
    addTearDown(preview.dispose);
    await preview.check(profile, source: profile);
    expect(preview.matches(profile.copyWith(label: 'Renamed')), true);
    expect(
      preview.matches(profile.copyWith(url: 'https://other.test/sub')),
      false,
    );
    expect(preview.matches(profile.copyWith(ageSecretKey: 'new-key')), false);
    expect(
      preview.matches(
        profile.copyWith(
          subscriptionPreferences: profile.subscriptionPreferences.copyWith(
            client: const SubscriptionClientSettings(
              preset: SubscriptionClientPreset.happ,
            ),
          ),
        ),
      ),
      false,
    );
    preview.invalidate();
    expect(preview.prepared, null);
    expect(preview.source, null);
  });

  test('cancels an obsolete attempt and ignores its late result', () async {
    final profile = Profile.normal(
      label: 'Example',
      url: 'https://example.test/sub',
    );
    final first = Completer<PreparedSubscriptionUpdate>();
    final second = Completer<PreparedSubscriptionUpdate>();
    final tokens = <SubscriptionCancellation>[];
    final preview = SubscriptionClientPreview(
      prepare: (_, cancellation) {
        tokens.add(cancellation);
        return tokens.length == 1 ? first.future : second.future;
      },
    );
    addTearDown(preview.dispose);
    final run1 = preview.check(profile, source: profile);
    final changed = profile.copyWith(url: 'https://new.test/sub');
    final run2 = preview.check(changed, source: profile);
    expect(tokens.first.cancelled, true);
    second.complete(_prepared(changed));
    await run2;
    first.complete(_prepared(profile));
    await run1;
    expect(preview.prepared?.sourceUrl, changed.url);
    expect(preview.checking, false);
  });

  test(
    'cleans loading after failure and exposes only a typed reason',
    () async {
      final profile = Profile.normal(
        label: 'Example',
        url: 'https://example.test/sub',
      );
      final preview = SubscriptionClientPreview(
        prepare: (_, _) async {
          throw const SubscriptionUpdateRejected(
            SubscriptionRetryReason.forbidden,
          );
        },
      );
      addTearDown(preview.dispose);
      await preview.check(profile, source: profile);
      expect(preview.checking, false);
      expect(preview.failure, SubscriptionPreviewFailure.authorization);
      expect(preview.prepared, null);
    },
  );

  test(
    'shows the AGE key requirement without converting it into transport failure',
    () async {
      final profile = Profile.normal(
        label: 'Example',
        url: 'https://example.test/sub',
      );
      final preview = SubscriptionClientPreview(
        prepare: (_, _) async => throw const AgeSecretKeyRequiredException(),
      );
      addTearDown(preview.dispose);
      await preview.check(profile, source: profile);
      expect(preview.failure, SubscriptionPreviewFailure.ageKey);
    },
  );

  test('disposal cancels work without notifying after its result', () async {
    final profile = Profile.normal(
      label: 'Example',
      url: 'https://example.test/sub',
    );
    final result = Completer<PreparedSubscriptionUpdate>();
    late SubscriptionCancellation cancellation;
    final preview = SubscriptionClientPreview(
      prepare: (_, token) {
        cancellation = token;
        return result.future;
      },
    );
    var changes = 0;
    preview.addListener(() => changes++);
    final run = preview.check(profile, source: profile);
    preview.dispose();
    final before = changes;
    result.complete(_prepared(profile));
    await run;
    expect(cancellation.cancelled, true);
    expect(changes, before);
    expect(preview.prepared, null);
  });
}

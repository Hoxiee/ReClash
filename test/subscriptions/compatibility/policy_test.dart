import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';

void main() {
  group('remainingSubscriptionAttemptTimeout', () {
    test('spends one shared budget across attempts', () {
      expect(
        remainingSubscriptionAttemptTimeout(const Duration(seconds: 7)),
        const Duration(seconds: 13),
      );
      expect(
        remainingSubscriptionAttemptTimeout(const Duration(seconds: 20)),
        Duration.zero,
      );
      expect(
        remainingSubscriptionAttemptTimeout(const Duration(seconds: 21)),
        Duration.zero,
      );
    });
  });

  group('subscriptionClientAttempts', () {
    test('keeps a fixed preset to one request', () {
      expect(
        subscriptionClientAttempts(
          selected: SubscriptionClientPreset.happ,
          lastSuccessful: SubscriptionClientPreset.clashMeta,
          defaultUserAgent: 'ReClash/test',
        ),
        [SubscriptionClientPreset.happ],
      );
    });

    test('expands only Auto to the bounded preset sequence', () {
      expect(
        subscriptionClientAttempts(
          selected: SubscriptionClientPreset.auto,
          defaultUserAgent: 'ReClash/test',
        ),
        automaticSubscriptionAttempts(defaultUserAgent: 'ReClash/test'),
      );
    });
  });

  group('automaticSubscriptionAttempts', () {
    test('uses the last successful preset first and deduplicates it', () {
      expect(
        automaticSubscriptionAttempts(
          lastSuccessful: SubscriptionClientPreset.clashMeta,
          defaultUserAgent: 'ReClash/test',
        ).take(3),
        [
          SubscriptionClientPreset.clashMeta,
          SubscriptionClientPreset.reclash,
          SubscriptionClientPreset.flClashX,
        ],
      );
    });

    test('places FlClashX directly after ReClash', () {
      expect(subscriptionClientPresetOrder.take(3), [
        SubscriptionClientPreset.reclash,
        SubscriptionClientPreset.flClashX,
        SubscriptionClientPreset.clashMeta,
      ]);
    });

    test('caps the automatic request budget', () {
      expect(
        automaticSubscriptionAttempts(defaultUserAgent: 'ReClash/test').length,
        maxAutomaticSubscriptionAttempts,
      );
    });

    test('does not probe the custom preset automatically', () {
      final attempts = automaticSubscriptionAttempts(
        lastSuccessful: SubscriptionClientPreset.custom,
        defaultUserAgent: 'ReClash/test',
      );
      expect(attempts, isNot(contains(SubscriptionClientPreset.custom)));
      expect(attempts.first, SubscriptionClientPreset.reclash);
    });
  });

  group('negotiateSubscriptionClients', () {
    test('moves to the next client only after a retryable rejection', () async {
      final tried = <SubscriptionClientPreset>[];
      final result = await negotiateSubscriptionClients<String>(
        attempts: [
          SubscriptionClientPreset.reclash,
          SubscriptionClientPreset.clashMeta,
        ],
        runAttempt: (client, timeout, _) async {
          tried.add(client);
          if (client == SubscriptionClientPreset.reclash) {
            return const SubscriptionClientRejected(
              SubscriptionRetryReason.unsupportedMediaType,
            );
          }
          return const SubscriptionClientReady('prepared');
        },
      );
      expect(tried, [
        SubscriptionClientPreset.reclash,
        SubscriptionClientPreset.clashMeta,
      ]);
      expect(result, isA<SubscriptionNegotiationReady<String>>());
    });

    test('stops immediately on authorization failure', () async {
      final tried = <SubscriptionClientPreset>[];
      final result = await negotiateSubscriptionClients<String>(
        attempts: subscriptionClientPresetOrder,
        runAttempt: (client, timeout, _) async {
          tried.add(client);
          return const SubscriptionClientRejected(
            SubscriptionRetryReason.unauthorized,
          );
        },
      );
      expect(tried, [SubscriptionClientPreset.reclash]);
      expect(result, isA<SubscriptionNegotiationFailed<String>>());
    });

    test(
      'keeps a review candidate while checking the bounded sequence',
      () async {
        var tries = 0;
        final result = await negotiateSubscriptionClients<String>(
          attempts: subscriptionClientPresetOrder,
          runAttempt: (client, timeout, _) async {
            tries++;
            return const SubscriptionClientReady('nodes', requiresReview: true);
          },
        );
        expect(tries, subscriptionClientPresetOrder.length);
        expect(
          result,
          isA<SubscriptionNegotiationReady<String>>().having(
            (value) => value.requiresReview,
            'requiresReview',
            isTrue,
          ),
        );
      },
    );

    test('prefers a complete candidate after a lossy conversion', () async {
      final result = await negotiateSubscriptionClients<String>(
        attempts: [
          SubscriptionClientPreset.reclash,
          SubscriptionClientPreset.clashMeta,
        ],
        runAttempt: (client, _, _) async =>
            client == SubscriptionClientPreset.reclash
            ? const SubscriptionClientReady('nodes', requiresReview: true)
            : const SubscriptionClientReady('native'),
      );
      expect(
        result,
        isA<SubscriptionNegotiationReady<String>>()
            .having((result) => result.value, 'value', 'native')
            .having(
              (result) => result.client,
              'client',
              SubscriptionClientPreset.clashMeta,
            )
            .having((result) => result.requiresReview, 'review', false),
      );
    });

    test(
      'a later authorization refusal does not promote a lossy candidate',
      () async {
        final result = await negotiateSubscriptionClients<String>(
          attempts: [
            SubscriptionClientPreset.reclash,
            SubscriptionClientPreset.clashMeta,
          ],
          runAttempt: (client, _, _) async =>
              client == SubscriptionClientPreset.reclash
              ? const SubscriptionClientReady('nodes', requiresReview: true)
              : const SubscriptionClientRejected(
                  SubscriptionRetryReason.forbidden,
                ),
        );
        expect(
          result,
          isA<SubscriptionNegotiationFailed<String>>().having(
            (result) => result.reason,
            'reason',
            SubscriptionRetryReason.forbidden,
          ),
        );
      },
    );

    test(
      'passes remaining budget and rejects a result that exceeds it',
      () async {
        final timeouts = <Duration>[];
        var elapsed = Duration.zero;
        final result = await negotiateSubscriptionClients<String>(
          attempts: [
            SubscriptionClientPreset.reclash,
            SubscriptionClientPreset.clashMeta,
          ],
          budget: const Duration(milliseconds: 40),
          elapsedTime: () => elapsed,
          runAttempt: (client, timeout, _) async {
            timeouts.add(timeout);
            elapsed += const Duration(milliseconds: 25);
            return const SubscriptionClientRejected(
              SubscriptionRetryReason.incompatibleResponse,
            );
          },
        );
        expect(timeouts, hasLength(2));
        expect(timeouts.last, lessThan(timeouts.first));
        expect(
          result,
          isA<SubscriptionNegotiationFailed<String>>().having(
            (value) => value.reason,
            'reason',
            SubscriptionRetryReason.timeout,
          ),
        );
      },
    );

    test('cancels the in-flight attempt when its timeout expires', () async {
      final request = Completer<SubscriptionClientAttempt<String>>();
      SubscriptionClientCancellation? cancellation;
      final result = await negotiateSubscriptionClients<String>(
        attempts: [SubscriptionClientPreset.reclash],
        budget: const Duration(milliseconds: 20),
        runAttempt: (client, timeout, token) {
          cancellation = token;
          return request.future;
        },
      );
      expect(cancellation?.cancelled, isTrue);
      expect(
        result,
        isA<SubscriptionNegotiationFailed<String>>().having(
          (value) => value.reason,
          'reason',
          SubscriptionRetryReason.timeout,
        ),
      );
    });

    test('forwards an external cancellation to the active attempt', () async {
      final request = Completer<SubscriptionClientAttempt<String>>();
      final cancelSignal = Completer<void>();
      SubscriptionClientCancellation? cancellation;
      final negotiation = negotiateSubscriptionClients<String>(
        attempts: subscriptionClientPresetOrder,
        cancellationSignal: cancelSignal.future,
        runAttempt: (client, timeout, token) {
          cancellation = token;
          return request.future;
        },
      );
      cancelSignal.complete();
      final result = await negotiation;
      expect(cancellation?.cancelled, isTrue);
      expect(
        result,
        isA<SubscriptionNegotiationFailed<String>>().having(
          (value) => value.reason,
          'reason',
          SubscriptionRetryReason.cancelled,
        ),
      );
    });

    test('does not start when cancellation is already requested', () async {
      var tries = 0;
      final result = await negotiateSubscriptionClients<String>(
        attempts: subscriptionClientPresetOrder,
        isCancelled: () => true,
        runAttempt: (client, timeout, _) async {
          tries++;
          return const SubscriptionClientReady('prepared');
        },
      );
      expect(tries, 0);
      expect(
        result,
        isA<SubscriptionNegotiationFailed<String>>().having(
          (value) => value.reason,
          'reason',
          SubscriptionRetryReason.cancelled,
        ),
      );
    });
  });

  group('shouldRetrySubscriptionClient', () {
    test('continues only when another client may change the response', () {
      expect(
        shouldRetrySubscriptionClient(
          SubscriptionRetryReason.unsupportedMediaType,
        ),
        isTrue,
      );
      expect(
        shouldRetrySubscriptionClient(
          SubscriptionRetryReason.incompatibleResponse,
        ),
        isTrue,
      );
      expect(
        shouldRetrySubscriptionClient(SubscriptionRetryReason.invalidResponse),
        isFalse,
      );
    });

    test(
      'stops on network, consent, authorization and rate-limit failures',
      () {
        for (final reason in [
          SubscriptionRetryReason.transport,
          SubscriptionRetryReason.tls,
          SubscriptionRetryReason.timeout,
          SubscriptionRetryReason.cancelled,
          SubscriptionRetryReason.unauthorized,
          SubscriptionRetryReason.forbidden,
          SubscriptionRetryReason.rateLimited,
          SubscriptionRetryReason.deviceConsentRequired,
          SubscriptionRetryReason.deviceLimitReached,
        ]) {
          expect(
            shouldRetrySubscriptionClient(reason),
            isFalse,
            reason: reason.name,
          );
        }
      },
    );
  });
}

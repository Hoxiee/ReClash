import 'dart:async';

import 'clients.dart';

const maxAutomaticSubscriptionAttempts = 8;
const subscriptionNegotiationBudget = Duration(seconds: 20);

Duration remainingSubscriptionAttemptTimeout(
  Duration elapsed, {
  Duration budget = subscriptionNegotiationBudget,
}) {
  final remaining = budget - elapsed;
  return remaining.isNegative ? Duration.zero : remaining;
}

List<SubscriptionClientPreset> subscriptionClientAttempts({
  required SubscriptionClientPreset selected,
  SubscriptionClientPreset? lastSuccessful,
  required String defaultUserAgent,
  String? locale,
}) {
  if (selected != SubscriptionClientPreset.auto) return [selected];
  return automaticSubscriptionAttempts(
    lastSuccessful: lastSuccessful,
    defaultUserAgent: defaultUserAgent,
    locale: locale,
  );
}

enum SubscriptionRetryReason {
  unsupportedMediaType,
  incompatibleResponse,
  transport,
  tls,
  timeout,
  cancelled,
  unauthorized,
  forbidden,
  rateLimited,
  deviceConsentRequired,
  deviceLimitReached,
  invalidResponse,
}

bool shouldRetrySubscriptionClient(SubscriptionRetryReason reason) =>
    switch (reason) {
      SubscriptionRetryReason.unsupportedMediaType ||
      SubscriptionRetryReason.incompatibleResponse => true,
      SubscriptionRetryReason.invalidResponse ||
      SubscriptionRetryReason.transport ||
      SubscriptionRetryReason.tls ||
      SubscriptionRetryReason.timeout ||
      SubscriptionRetryReason.cancelled ||
      SubscriptionRetryReason.unauthorized ||
      SubscriptionRetryReason.forbidden ||
      SubscriptionRetryReason.rateLimited ||
      SubscriptionRetryReason.deviceConsentRequired ||
      SubscriptionRetryReason.deviceLimitReached => false,
    };

List<SubscriptionClientPreset> automaticSubscriptionAttempts({
  SubscriptionClientPreset? lastSuccessful,
  required String defaultUserAgent,
  String? locale,
}) {
  final ordered = <SubscriptionClientPreset>[
    if (lastSuccessful != null &&
        lastSuccessful != SubscriptionClientPreset.custom &&
        lastSuccessful != SubscriptionClientPreset.auto)
      lastSuccessful,
    ...subscriptionClientPresetOrder.where(
      (preset) =>
          preset != SubscriptionClientPreset.custom &&
          preset != SubscriptionClientPreset.auto,
    ),
  ];
  final seenHeaders = <String>{};
  final attempts = <SubscriptionClientPreset>[];
  for (final preset in ordered) {
    final headers = subscriptionClientRequestHeaders(
      preset,
      defaultUserAgent: defaultUserAgent,
      locale: locale,
    );
    final signature =
        headers.entries
            .map((entry) => '${entry.key.toLowerCase()}:${entry.value.trim()}')
            .toList()
          ..sort();
    if (!seenHeaders.add(signature.join('\n'))) continue;
    attempts.add(preset);
    if (attempts.length == maxAutomaticSubscriptionAttempts) break;
  }
  return List.unmodifiable(attempts);
}

class SubscriptionClientCancellation {
  final _cancelled = Completer<void>();

  bool get cancelled => _cancelled.isCompleted;
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }
}

sealed class SubscriptionClientAttempt<T> {
  const SubscriptionClientAttempt();
}

final class SubscriptionClientReady<T> extends SubscriptionClientAttempt<T> {
  const SubscriptionClientReady(this.value, {this.requiresReview = false});

  final T value;
  final bool requiresReview;
}

final class SubscriptionClientRejected<T> extends SubscriptionClientAttempt<T> {
  const SubscriptionClientRejected(this.reason);

  final SubscriptionRetryReason reason;
}

sealed class SubscriptionNegotiationResult<T> {
  const SubscriptionNegotiationResult();
}

final class SubscriptionNegotiationReady<T>
    extends SubscriptionNegotiationResult<T> {
  const SubscriptionNegotiationReady({
    required this.client,
    required this.value,
    this.requiresReview = false,
  });

  final SubscriptionClientPreset client;
  final T value;
  final bool requiresReview;
}

final class SubscriptionNegotiationFailed<T>
    extends SubscriptionNegotiationResult<T> {
  const SubscriptionNegotiationFailed(this.reason);

  final SubscriptionRetryReason reason;
}

Future<SubscriptionNegotiationResult<T>> negotiateSubscriptionClients<T>({
  required Iterable<SubscriptionClientPreset> attempts,
  required Future<SubscriptionClientAttempt<T>> Function(
    SubscriptionClientPreset client,
    Duration timeout,
    SubscriptionClientCancellation cancellation,
  )
  runAttempt,
  Duration budget = subscriptionNegotiationBudget,
  Future<void>? cancellationSignal,
  bool Function()? isCancelled,
  Duration Function()? elapsedTime,
}) async {
  final stopwatch = Stopwatch()..start();
  Duration elapsed() => elapsedTime?.call() ?? stopwatch.elapsed;
  var cancellationRequested = false;
  unawaited(
    cancellationSignal?.then((_) {
      cancellationRequested = true;
    }),
  );
  SubscriptionRetryReason? lastReason;
  SubscriptionNegotiationReady<T>? reviewCandidate;
  for (final client in attempts) {
    if (cancellationRequested || (isCancelled?.call() ?? false)) {
      return const SubscriptionNegotiationFailed(
        SubscriptionRetryReason.cancelled,
      );
    }
    final timeout = remainingSubscriptionAttemptTimeout(
      elapsed(),
      budget: budget,
    );
    if (timeout == Duration.zero) {
      return const SubscriptionNegotiationFailed(
        SubscriptionRetryReason.timeout,
      );
    }
    final attemptCancellation = SubscriptionClientCancellation();
    final request = runAttempt(
      client,
      timeout,
      attemptCancellation,
    ).then<SubscriptionClientAttempt<T>>((result) => result);
    final timedRequest = request.timeout(
      timeout,
      onTimeout: () {
        attemptCancellation.cancel();
        return SubscriptionClientRejected<T>(SubscriptionRetryReason.timeout);
      },
    );
    final result = cancellationSignal == null
        ? await timedRequest
        : await Future.any([
            timedRequest,
            cancellationSignal.then((_) {
              cancellationRequested = true;
              attemptCancellation.cancel();
              return SubscriptionClientRejected<T>(
                SubscriptionRetryReason.cancelled,
              );
            }),
          ]);
    if (cancellationRequested) {
      attemptCancellation.cancel();
      return const SubscriptionNegotiationFailed(
        SubscriptionRetryReason.cancelled,
      );
    }
    if (elapsed() >= budget) {
      attemptCancellation.cancel();
      return const SubscriptionNegotiationFailed(
        SubscriptionRetryReason.timeout,
      );
    }
    switch (result) {
      case SubscriptionClientReady(:final value, :final requiresReview):
        final candidate = SubscriptionNegotiationReady(
          client: client,
          value: value,
          requiresReview: requiresReview,
        );
        if (!requiresReview) return candidate;
        reviewCandidate ??= candidate;
      case SubscriptionClientRejected(:final reason):
        lastReason = reason;
        if (!shouldRetrySubscriptionClient(reason)) {
          return SubscriptionNegotiationFailed(reason);
        }
    }
  }
  return reviewCandidate ??
      SubscriptionNegotiationFailed(
        lastReason ?? SubscriptionRetryReason.invalidResponse,
      );
}

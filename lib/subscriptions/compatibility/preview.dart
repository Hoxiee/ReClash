import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:reclash/common/exception.dart';
import 'package:reclash/models/profile.dart';

import '../transport/transport.dart';
import 'policy.dart';

enum SubscriptionPreviewFailure {
  incompatible,
  timeout,
  authorization,
  rateLimited,
  transport,
  superseded,
  ageKey,
}

class SubscriptionClientPreview extends ChangeNotifier {
  SubscriptionClientPreview({required this.prepare});

  final Future<PreparedSubscriptionUpdate> Function(
    Profile candidate,
    SubscriptionCancellation cancellation,
  )
  prepare;

  PreparedSubscriptionUpdate? _prepared;
  Profile? _source;
  SubscriptionCancellation? _cancellation;
  SubscriptionPreviewFailure? _failure;
  var _revision = 0;
  var _disposed = false;

  PreparedSubscriptionUpdate? get prepared => _prepared;
  Profile? get source => _source;
  SubscriptionPreviewFailure? get failure => _failure;
  bool get checking => _cancellation != null;

  void invalidate() {
    _revision++;
    _cancellation?.cancel();
    _cancellation = null;
    _prepared = null;
    _source = null;
    _failure = null;
    if (!_disposed) notifyListeners();
  }

  bool matches(Profile candidate) {
    final prepared = _prepared;
    return prepared != null &&
        prepared.profileId == candidate.id &&
        prepared.sourceUrl == candidate.url &&
        prepared.sourceAgeSecretKey == candidate.ageSecretKey &&
        jsonEncode(prepared.sourcePreferences.toJson()) ==
            jsonEncode(candidate.subscriptionPreferences.toJson());
  }

  Future<void> check(Profile candidate, {required Profile source}) async {
    invalidate();
    final revision = _revision;
    final cancellation = SubscriptionCancellation();
    _cancellation = cancellation;
    _source = source;
    notifyListeners();
    bool isCurrent() =>
        !_disposed &&
        _revision == revision &&
        identical(_cancellation, cancellation) &&
        !cancellation.cancelled;
    try {
      final prepared = await prepare(candidate, cancellation);
      if (!isCurrent()) return;
      _prepared = prepared;
    } on Object catch (error) {
      if (!isCurrent()) return;
      _failure = _previewFailure(error);
    } finally {
      cancellation.cancel();
      if (identical(_cancellation, cancellation)) {
        _cancellation = null;
        if (!_disposed) notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    _cancellation?.cancel();
    _cancellation = null;
    _prepared = null;
    _source = null;
    super.dispose();
  }
}

SubscriptionPreviewFailure _previewFailure(Object error) => switch (error) {
  AgeSecretKeyRequiredException() => SubscriptionPreviewFailure.ageKey,
  SubscriptionUpdateSuperseded() => SubscriptionPreviewFailure.superseded,
  SubscriptionUpdateRejected(:final reason) => switch (reason) {
    SubscriptionRetryReason.timeout => SubscriptionPreviewFailure.timeout,
    SubscriptionRetryReason.unauthorized || SubscriptionRetryReason.forbidden =>
      SubscriptionPreviewFailure.authorization,
    SubscriptionRetryReason.rateLimited =>
      SubscriptionPreviewFailure.rateLimited,
    SubscriptionRetryReason.transport ||
    SubscriptionRetryReason.tls => SubscriptionPreviewFailure.transport,
    _ => SubscriptionPreviewFailure.incompatible,
  },
  SubscriptionException(:final failure) => switch (failure) {
    SubscriptionFailure.timeout => SubscriptionPreviewFailure.timeout,
    SubscriptionFailure.unauthorized =>
      SubscriptionPreviewFailure.authorization,
    SubscriptionFailure.rateLimited => SubscriptionPreviewFailure.rateLimited,
    SubscriptionFailure.transport ||
    SubscriptionFailure.tls => SubscriptionPreviewFailure.transport,
    SubscriptionFailure.superseded => SubscriptionPreviewFailure.superseded,
    _ => SubscriptionPreviewFailure.incompatible,
  },
  _ => SubscriptionPreviewFailure.incompatible,
};

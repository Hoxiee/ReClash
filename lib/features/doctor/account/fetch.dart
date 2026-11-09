import 'package:reclash/common/network_error.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:riverpod/riverpod.dart';

import '../snapshot.dart';

ProfileUpdateFact profileUpdateFailed(
  int profileId,
  Object error, {
  required DateTime at,
}) => switch (error) {
  SubscriptionException(:final failure, :final status) => ProfileUpdateFact(
    profileId: profileId,
    at: at,
    error: failure.name,
    status: switch (failure) {
      SubscriptionFailure.unauthorized || SubscriptionFailure.http => status,
      _ => null,
    },
  ),
  _ => ProfileUpdateFact(
    profileId: profileId,
    at: at,
    error: networkFailureCause(error)?.id ?? 'other',
  ),
};

/// The last subscription fetch per profile, as the update path recorded it.
final profileUpdateResultsProvider =
    NotifierProvider<ProfileUpdateResults, Map<int, ProfileUpdateFact>>(
      ProfileUpdateResults.new,
    );

class ProfileUpdateResults extends Notifier<Map<int, ProfileUpdateFact>> {
  @override
  Map<int, ProfileUpdateFact> build() => const {};

  void record(ProfileUpdateFact result) {
    state = {...state, result.profileId: result};
  }
}

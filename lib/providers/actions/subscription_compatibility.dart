part of '../action.dart';

typedef _SubscriptionRequestInputs = ({
  Map<String, String> managedHeaders,
  String defaultUserAgent,
  String locale,
});

extension _SubscriptionProfilePreparation on ProfilesAction {
  Future<_SubscriptionRequestInputs> _subscriptionRequestInputs(
    Profile candidate,
  ) async {
    final managedHeaders = await _subscriptionIdentityHeaders(candidate);
    return (
      managedHeaders: Map<String, String>.unmodifiable(managedHeaders),
      defaultUserAgent: globalState.ua,
      locale: Intl.getCurrentLocale(),
    );
  }

  String _subscriptionRequestFingerprint(
    Profile candidate,
    _SubscriptionRequestInputs request,
  ) => subscriptionClientRequestFingerprint(
    url: candidate.url,
    ageSecretKey: candidate.ageSecretKey,
    preferences: candidate.subscriptionPreferences.toJson(),
    defaultUserAgent: request.defaultUserAgent,
    managedHeaders: request.managedHeaders,
    locale: request.locale,
  );

  Future<SubscriptionClientPreset?> _lastSuccessfulProfileClient(
    Profile candidate,
  ) async {
    if (candidate.type != ProfileType.url) return null;
    final request = await _subscriptionRequestInputs(candidate);
    return const SubscriptionClientCache().read(
      candidate.id,
      subscriptionClientCacheKey(
        _subscriptionRequestFingerprint(candidate, request),
        candidate.subscriptionPreferences.client.importPolicy.toJson(),
      ),
    );
  }

  Future<PreparedSubscriptionUpdate> _prepareProfileCompatibility(
    Profile candidate, {
    SubscriptionCancellation? cancellation,
    _SubscriptionRequestInputs? request,
  }) async {
    if (cancellation?.cancelled ?? false) {
      throw const SubscriptionUpdateCancelled();
    }
    final inputs = request ?? await _subscriptionRequestInputs(candidate);
    if (cancellation?.cancelled ?? false) {
      throw const SubscriptionUpdateCancelled();
    }
    return candidate.prepareUpdate(
      defaultUserAgent: inputs.defaultUserAgent,
      transport: _subscriptionTransport(),
      cancellation: cancellation,
      identityHeaders: inputs.managedHeaders,
      decrypt: _core.decryptProfilePayload,
      validate: (path, _) => _core.validateConfig(path),
      locale: inputs.locale,
    );
  }

  void _ensurePreparedSubscriptionCurrent(
    Profile candidate,
    PreparedSubscriptionUpdate prepared,
    _SubscriptionRequestInputs request,
  ) {
    if (prepared.profileId != candidate.id ||
        prepared.sourceUrl != candidate.url ||
        prepared.sourceAgeSecretKey != candidate.ageSecretKey ||
        jsonEncode(prepared.sourcePreferences.toJson()) !=
            jsonEncode(candidate.subscriptionPreferences.toJson()) ||
        prepared.clientFingerprint.isNotEmpty &&
            prepared.clientFingerprint !=
                _subscriptionRequestFingerprint(candidate, request)) {
      throw const SubscriptionUpdateSuperseded();
    }
  }
}

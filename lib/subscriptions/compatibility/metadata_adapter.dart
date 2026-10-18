import 'clients.dart';

class SubscriptionCompatibilityAdapter {
  const SubscriptionCompatibilityAdapter({
    this.responseHeaderAliases = const {},
  });

  final Map<String, String> responseHeaderAliases;

  Map<String, List<String>> normalizeResponseHeaders(
    Map<String, List<String>> headers,
  ) {
    if (responseHeaderAliases.isEmpty) return headers;
    final normalized = Map<String, List<String>>.of(headers);
    for (final MapEntry(:key, :value) in responseHeaderAliases.entries) {
      final aliasValues = normalized.remove(key);
      if (aliasValues != null) normalized.putIfAbsent(value, () => aliasValues);
    }
    return normalized;
  }
}

const _flClashXAdapter = SubscriptionCompatibilityAdapter(
  responseHeaderAliases: {
    'flclashx-servicename': 'reclash-servicename',
    'flclashx-servicelogo': 'reclash-servicelogo',
    'flclashx-supporturl': 'reclash-supporturl',
    'flclashx-webpageurl': 'reclash-webpageurl',
    'flclashx-buyplan': 'reclash-buyplan',
    'flclashx-buytraffic': 'reclash-buytraffic',
    'flclashx-autoupdateinterval': 'reclash-autoupdateinterval',
    'flclashx-hideurl': 'reclash-hideurl',
  },
);

const subscriptionCompatibilityAdapters = {
  SubscriptionClientPreset.flClashX: _flClashXAdapter,
};

const _noSubscriptionCompatibilityAdapter = SubscriptionCompatibilityAdapter();

SubscriptionCompatibilityAdapter subscriptionCompatibilityAdapterFor(
  SubscriptionClientPreset preset,
) =>
    subscriptionCompatibilityAdapters[preset] ??
    _noSubscriptionCompatibilityAdapter;

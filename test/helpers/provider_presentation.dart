import 'dart:convert';

import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';

/// Hints whose presentation comes from a hosted config with these sections.
ProviderHints presentedHints(Map<String, Object?> sections) => ProviderHints(
  const SubscriptionMetadata(),
  config: parseProviderConfig(
    jsonEncode({'version': 1, ...sections}),
    'en',
  ).config,
);

/// The snapshot metadata a manifest with these sections yields.
SubscriptionMetadata manifestMetadata(Map<String, Object?> sections) =>
    SubscriptionMetadata(
      parseProviderConfig(
        jsonEncode({'version': 1, ...sections}),
        'en',
      ).config!.fields,
    );

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:reclash/common/path.dart';

import 'clients.dart';

String subscriptionClientFingerprint({
  required String url,
  required String ageSecretKey,
  required Map<String, Object?> preferences,
  required String defaultUserAgent,
  String? locale,
  Map<String, String> managedHeaders = const {},
}) => subscriptionClientCacheKey(
  subscriptionClientRequestFingerprint(
    url: url,
    ageSecretKey: ageSecretKey,
    preferences: preferences,
    defaultUserAgent: defaultUserAgent,
    locale: locale,
    managedHeaders: managedHeaders,
  ),
  preferences['client'] is Map
      ? (preferences['client'] as Map)['importPolicy']
      : null,
);

String subscriptionClientCacheKey(String requestFingerprint, Object? policy) =>
    _digest([requestFingerprint, policy]);

String subscriptionClientRequestFingerprint({
  required String url,
  required String ageSecretKey,
  required Map<String, Object?> preferences,
  required String defaultUserAgent,
  String? locale,
  Map<String, String> managedHeaders = const {},
}) {
  final client = preferences['client'];
  return _digest({
    'url': url,
    'key': ageSecretKey,
    'preferences': {
      ...preferences,
      if (client is Map<String, Object?>)
        'client': {...client}..remove('importPolicy'),
    },
    'managedHeaders': managedHeaders,
    'clients': {
      for (final preset in subscriptionClientPresetOrder)
        preset.name: subscriptionClientRequestHeaders(
          preset,
          defaultUserAgent: defaultUserAgent,
          locale: locale,
        ),
    },
  });
}

String _digest(Object? value) =>
    sha256.convert(utf8.encode(jsonEncode(_ordered(value)))).toString();

Object? _ordered(Object? value) {
  if (value is Map<String, Object?>) {
    final keys = value.keys.toList()..sort();
    return {for (final key in keys) key: _ordered(value[key])};
  }
  if (value is Iterable) return value.map(_ordered).toList();
  return value;
}

class SubscriptionClientCache {
  const SubscriptionClientCache({this.directory});

  final Directory? directory;

  Future<File> _file(int profileId) async {
    final root = directory ?? await appPath.cacheDir.future;
    return File(join(root.path, 'subscription_clients', '$profileId.json'));
  }

  Future<SubscriptionClientPreset?> read(
    int profileId,
    String fingerprint,
  ) async {
    try {
      final file = await _file(profileId);
      if (!await file.exists() || await file.length() > 2048) return null;
      final value = jsonDecode(await file.readAsString());
      if (value is! Map ||
          value['v'] != 1 ||
          value['fingerprint'] != fingerprint) {
        return null;
      }
      return SubscriptionClientPreset.values
          .where(
            (preset) =>
                preset != SubscriptionClientPreset.auto &&
                preset.name == value['client'],
          )
          .firstOrNull;
    } on Object {
      return null;
    }
  }

  Future<void> remember(
    int profileId,
    String fingerprint,
    SubscriptionClientPreset client,
  ) async {
    if (client == SubscriptionClientPreset.auto) return;
    File? staged;
    try {
      final file = await _file(profileId);
      await file.parent.create(recursive: true);
      staged = File(
        '${file.path}.${DateTime.now().microsecondsSinceEpoch}.staged',
      );
      await staged.writeAsString(
        jsonEncode({'v': 1, 'fingerprint': fingerprint, 'client': client.name}),
        flush: true,
      );
      await staged.rename(file.path);
    } on Object {
      // A local cache failure does not cancel the accepted configuration.
    } finally {
      try {
        if (staged != null && await staged.exists()) await staged.delete();
      } on Object {
        // Clearing the cache does not change the profile commit result.
      }
    }
  }

  Future<void> forget(int profileId) async {
    try {
      final file = await _file(profileId);
      if (await file.exists()) await file.delete();
    } on Object {
      // Without a cache, negotiation starts with the default client order.
    }
  }
}

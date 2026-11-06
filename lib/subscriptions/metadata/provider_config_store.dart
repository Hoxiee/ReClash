import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show compute;
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';

import '../transport/header_policy.dart';
import '../transport/transport.dart';
import 'provider_config.dart';

const providerConfigFetchBudget = Duration(seconds: 8);
const _minimumFetchBudget = Duration(seconds: 1);
const _etagLimit = 256;

class StoredProviderConfig {
  const StoredProviderConfig({
    required this.url,
    required this.source,
    this.etag,
  });

  /// An `ETag` only validates the URL that issued it.
  final String url;
  final String source;
  final String? etag;
}

Future<File> _storedFile(int profileId) async =>
    File(await appPath.getProfileProviderConfigPath(profileId.toString()));

Future<StoredProviderConfig?> readStoredProviderConfig(int profileId) async {
  try {
    final file = await _storedFile(profileId);
    if (!await file.exists()) return null;
    final decoded = jsonDecode(await file.readAsString());
    if (decoded case {'url': final String url, 'source': final String source}) {
      final etag = decoded['etag'];
      return StoredProviderConfig(
        url: url,
        source: source,
        etag: etag is String ? etag : null,
      );
    }
  } on Object catch (error) {
    commonPrint.log(
      'Could not read the provider config: $error',
      logLevel: LogLevel.warning,
    );
  }
  return null;
}

Future<void> deleteStoredProviderConfig(int profileId) async =>
    (await _storedFile(profileId)).safeDelete();

Future<ProviderConfigResult> parseProviderConfigOffThread(
  String source,
  String locale,
) => compute(_parse, (source, locale));

ProviderConfigResult _parse((String, String) input) =>
    parseProviderConfig(input.$1, input.$2);

/// What an update decided; it reaches the disk only when the profile commits.
class ProviderConfigDelivery {
  const ProviderConfigDelivery({
    this.replacement,
    this.withdrawn = false,
    this.warnings = const [],
    this.config,
  });

  final StoredProviderConfig? replacement;
  final bool withdrawn;
  final List<String> warnings;

  /// The manifest in force after this update: the fetched copy, else the
  /// stored one a failed fetch kept; null when there is none.
  final ProviderConfig? config;

  /// Never throws; the result undoes the change if the commit rolls back.
  /// The Core reads `routing` from the profile's routing file, which holds
  /// the whole manifest source while the manifest has that section.
  Future<Future<void> Function()> commit(int profileId) async {
    if (replacement == null && !withdrawn) return () async {};
    try {
      final file = await _storedFile(profileId);
      final routing = File(
        await appPath.getProfileRoutingPath(profileId.toString()),
      );
      final previous = await file.exists() ? await file.readAsString() : null;
      final previousRouting = await routing.exists()
          ? await routing.readAsString()
          : null;
      await _replace(file, _encode(replacement));
      await _replace(
        routing,
        config?.routing == null ? null : replacement?.source,
      );
      return () async {
        try {
          await _replace(file, previous);
          await _replace(routing, previousRouting);
        } on Object catch (error) {
          _logStoreFailure(error);
        }
      };
    } on Object catch (error) {
      _logStoreFailure(error);
      return () async {};
    }
  }

  static String? _encode(StoredProviderConfig? config) => config == null
      ? null
      : jsonEncode({
          'url': config.url,
          'source': config.source,
          'etag': ?config.etag,
        });

  static Future<void> _replace(File file, String? content) async {
    if (content == null) {
      await file.safeDelete();
    } else {
      await file.writeAsStringAtomically(content);
    }
  }

  static void _logStoreFailure(Object error) => commonPrint.log(
    'Could not store the provider config: $error',
    logLevel: LogLevel.warning,
  );
}

/// Never throws: every failure keeps the stored copy and becomes a warning.
/// Headers follow the subscription's own rule for another origin, so the
/// device ID never leaves it.
Future<ProviderConfigDelivery> fetchProviderConfig({
  required int profileId,
  required String? url,
  required SubscriptionTransport transport,
  required Duration budget,
  required SubscriptionCancellation cancellation,
  required String locale,
  required Uri subscription,
  Map<String, String> headers = const {},
}) async {
  if (url == null) return const ProviderConfigDelivery(withdrawn: true);
  final stored = await readStoredProviderConfig(profileId);
  final etag = stored?.url == url ? stored?.etag : null;
  final warnings = <String>[];
  void warn(String text) => warnings.add('Provider config: $text');
  try {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw const SubscriptionException(SubscriptionFailure.invalid);
    }
    if (budget < _minimumFetchBudget) {
      throw const SubscriptionException(SubscriptionFailure.timeout);
    }
    final response = await transport.fetchCapped(
      uri,
      limit: providerConfigSizeLimit,
      headers: {
        ...redirectSubscriptionHeaders(headers, subscription, uri),
        HttpHeaders.ifNoneMatchHeader: ?etag,
      },
      timeout: budget,
      cancellation: cancellation,
    );
    if (response.uri.scheme != 'https') {
      throw const SubscriptionException(SubscriptionFailure.redirect);
    }
    final source = utf8.decode(response.bytes);
    final parsed = await parseProviderConfigOffThread(source, locale);
    parsed.warnings.forEach(warn);
    if (parsed.config != null) {
      return ProviderConfigDelivery(
        replacement: StoredProviderConfig(
          url: url,
          source: source,
          etag: _usableEtag(response.headers['etag']?.singleOrNull),
        ),
        warnings: warnings,
        config: parsed.config,
      );
    }
  } on SubscriptionException catch (error) {
    // The transport reports a 304 as a non-2xx status.
    final notModified = error.status == 304 && etag != null;
    if (!notModified && !cancellation.cancelled) warn(error.failure.name);
  } on Object catch (_) {
    warn(SubscriptionFailure.invalid.name);
  }
  ProviderConfig? kept;
  if (stored != null) {
    final parsed = await parseProviderConfigOffThread(stored.source, locale);
    parsed.warnings.forEach(warn);
    kept = parsed.config;
  }
  return ProviderConfigDelivery(warnings: warnings, config: kept);
}

/// An unsendable validator would make every later request fail validation.
String? _usableEtag(String? etag) {
  if (etag == null || etag.length > _etagLimit) return null;
  return RegExp(r'^[\x21-\x7e]+( [\x21-\x7e]+)*$').hasMatch(etag) ? etag : null;
}

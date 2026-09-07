import 'package:reclash/common/incy_links.dart';
import 'package:reclash/common/subscription_url.dart';
import 'package:reclash/enum/enum.dart';

class SubscriptionImportTarget {
  const SubscriptionImportTarget({
    required this.url,
    required this.client,
    this.name,
    this.localContent,
  });

  final String url;
  final SubscriptionClient client;
  final String? name;
  final String? localContent;
}

Future<SubscriptionImportTarget?> resolveSubscriptionImport(
  String input,
) async {
  final trimmed = input.trim();
  final resolved = await resolveExternalLink(trimmed);
  if (resolved?.data case final data?) {
    return SubscriptionImportTarget(
      url: '',
      client: resolved!.preset,
      name: resolved.name,
      localContent: data,
    );
  }

  final normalized = normalizeSubscriptionUrl(resolved?.url ?? trimmed);
  final uri = Uri.tryParse(normalized);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return null;
  }
  return SubscriptionImportTarget(
    url: normalized,
    client: resolved?.preset ?? SubscriptionClient.auto,
    name: resolved?.name,
  );
}

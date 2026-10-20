class TelegramLink {
  const TelegramLink({
    required this.uri,
    required this.destination,
    this.webFallback,
  });

  final Uri uri;
  final Uri? webFallback;
  final String destination;

  static TelegramLink? tryParse(String value) {
    if (value.isEmpty ||
        value.length > 4096 ||
        value.contains(RegExp(r'[\x00-\x20\x7f]'))) {
      return null;
    }
    final uri = Uri.tryParse(value);
    if (uri == null || uri.userInfo.isNotEmpty || uri.hasFragment) return null;
    if (uri.scheme == 'https' &&
        const {'t.me', 'telegram.me'}.contains(uri.host) &&
        (!uri.hasPort || uri.port == 443)) {
      return TelegramLink(
        uri: uri,
        destination: _destination(uri),
        webFallback: uri,
      );
    }
    if (uri.scheme != 'tg' ||
        uri.port != 0 ||
        !const {
          'resolve',
          'join',
          'addstickers',
          'msg_url',
          'privatepost',
          'user',
          'openmessage',
        }.contains(uri.host) ||
        uri.host == 'resolve' &&
            (uri.queryParametersAll['domain']?.length != 1 ||
                !RegExp(
                  r'^[A-Za-z0-9_]{1,64}$',
                ).hasMatch(uri.queryParameters['domain'] ?? '')) ||
        uri.host == 'join' &&
            (uri.queryParametersAll['invite']?.length != 1 ||
                !RegExp(
                  r'^[A-Za-z0-9_-]{1,256}$',
                ).hasMatch(uri.queryParameters['invite'] ?? ''))) {
      return null;
    }
    return TelegramLink(
      uri: uri,
      destination: _destination(uri),
      webFallback: _webFallback(uri),
    );
  }
}

String _destination(Uri uri) {
  final domain = uri.queryParameters['domain'];
  if (domain != null && domain.isNotEmpty) return domain;
  final invite = uri.queryParameters['invite'];
  if (invite != null && invite.isNotEmpty) return 'Telegram invite';
  final segment = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
  return segment.isEmpty ? 'Telegram' : segment;
}

Uri? _webFallback(Uri uri) {
  if (uri.host == 'resolve') {
    final domain = uri.queryParameters['domain'];
    if (domain == null || !RegExp(r'^[A-Za-z0-9_]{1,64}$').hasMatch(domain)) {
      return null;
    }
    return Uri.https(
      't.me',
      '/$domain',
      _without(uri.queryParametersAll, 'domain'),
    );
  }
  if (uri.host == 'join') {
    final invite = uri.queryParameters['invite'];
    if (invite == null || !RegExp(r'^[A-Za-z0-9_-]{1,256}$').hasMatch(invite)) {
      return null;
    }
    final query = _without(uri.queryParametersAll, 'invite');
    return query.isEmpty
        ? Uri.https('t.me', '/+$invite')
        : Uri.https('t.me', '/+$invite', query);
  }
  return null;
}

Map<String, List<String>> _without(
  Map<String, List<String>> values,
  String key,
) => Map.fromEntries(values.entries.where((entry) => entry.key != key));

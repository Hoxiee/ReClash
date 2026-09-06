import 'dart:convert';

/// Panel identity from wire signals; feeds only the profile label.
enum PanelKind {
  remnawave,
  marzban,
  marzneshin,
  threeXui,
  sUi,
  subconverter,
  other;

  static const _hostHints = {
    'remnawave': remnawave,
    'marzban': marzban,
    'marzneshin': marzneshin,
    '3x-ui': threeXui,
    'x-ui': threeXui,
    'subconvert': subconverter,
  };

  static PanelKind detect(String? host, Map<String, List<String>> headers) {
    final lowerHost = host?.toLowerCase() ?? '';
    for (final entry in _hostHints.entries) {
      if (lowerHost.contains(entry.key)) return entry.value;
    }
    final raw = headers.map(
      (key, value) => MapEntry(key.toLowerCase(), value.join(',')),
    );
    if (raw.containsKey('x-hwid-active') ||
        raw.containsKey('x-remnawave-injected-short-uuid')) {
      return remnawave;
    }
    final announce = raw['announce'] ?? '';
    if (raw.containsKey('x-hwid-not-supported') &&
        (announce.startsWith('base64:') || announce.startsWith('base64,'))) {
      return threeXui;
    }
    return other;
  }

  String? get serviceName => switch (this) {
    remnawave => 'Remnawave',
    marzban => 'Marzban',
    marzneshin => 'Marzneshin',
    threeXui => '3x-ui',
    sUi => 's-ui',
    subconverter => 'Subconverter',
    other => null,
  };
}

const _genericTitles = {
  'remnawave',
  'subscription',
  'subscription.json',
  'subscription.yaml',
  'subscription.yml',
  'profile',
  'support',
};

final _accountUsername = RegExp(r'^\d{4,}[_-][0-9a-z]{4,}$', caseSensitive: false);

final _telegramHandle = RegExp(
  r'^(?:@|t\.me\/|https?://(?:t|telegram)\.me\/)\w{3,}$',
  caseSensitive: false,
);

bool isGenericPanelTitle(String? value) {
  final title = value?.trim().toLowerCase();
  if (title == null || title.isEmpty) return true;
  return _genericTitles.contains(title) || _telegramHandle.hasMatch(title);
}

bool isAccountUsername(String? value) {
  final name = value?.trim();
  if (name == null || name.isEmpty) return false;
  return _accountUsername.hasMatch(name);
}

/// Wire form is `base64:<payload>` or plain UTF-8; a broken payload falls
/// back to the raw text, as the v2ray.ang family of parsers does.
String decodePanelTitle(String value) {
  final trimmed = value.trim();
  final prefixed = trimmed.startsWith('base64:') || trimmed.startsWith('base64,');
  final payload = prefixed ? trimmed.substring(7).trim() : trimmed;
  if (payload.isEmpty) return trimmed;
  try {
    return utf8.decode(base64.decode(base64.normalize(payload)));
  } catch (_) {
    return trimmed;
  }
}

class ProfileNaming {
  const ProfileNaming._({
    required this.label,
    required this.serviceName,
    required this.username,
  });

  final String? label;

  final String? serviceName;

  final String? username;

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (isGenericPanelTitle(trimmed)) return null;
    return trimmed;
  }

  static ProfileNaming fromResponse({
    required Map<String, List<String>> headers,
    required String? host,
    String? profileTitle,
    String? dispositionFilename,
  }) {
    final kind = PanelKind.detect(host, headers);
    final title = _clean(decodePanelTitle(profileTitle ?? ''));
    final filename = _clean(dispositionFilename);

    String? username;
    if (filename != null && isAccountUsername(filename)) {
      username = filename;
    } else if (title != null && isAccountUsername(title)) {
      username = title;
    }
    final service = kind.serviceName;

    String? label;
    if (title != null && title != username) {
      label = title;
    } else if (username != null && service != null) {
      label = '$service ($username)';
    } else if (filename != null) {
      label = filename;
    } else if (title != null) {
      label = title;
    }

    return ProfileNaming._(
      label: label,
      serviceName: service,
      username: username,
    );
  }
}

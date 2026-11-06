const subscriptionStandardVersion = 1;
const subscriptionHeaderLimit = 8 * 1024;
const subscriptionHeadersLimit = 64 * 1024;
const subscriptionWireLimit = 16 * 1024 * 1024;
const subscriptionPayloadLimit = 32 * 1024 * 1024;

/// For [SubscriptionFieldType.tokens], [packages], [hosts], [numbers] and [keys] the field's `limit` counts entries, not characters.
enum SubscriptionFieldType {
  text,
  url,
  integer,
  boolean,
  hosts,
  tokens,
  packages,
  numbers,
  keys,
  flags,

  /// Stored as restriction tokens; the manifest writes a map of named values.
  policy,
}

enum SubscriptionTrust { display, hint, consent }

/// The count that accompanies a URL field in the manifest, stored as its own
/// integer field.
class SubscriptionSuffix {
  const SubscriptionSuffix(
    this.path,
    this.manifest, {
    this.minimum = 1,
    this.maximum = 100,
  });

  final String path;
  final String manifest;
  final int minimum;
  final int maximum;
}

/// A value the snapshot keeps under [path]. The manifest names it at
/// [manifest]; [header] is the standard response header that supplies it when
/// the manifest does not (or, with no [manifest], the only source).
class SubscriptionField {
  const SubscriptionField(
    this.path,
    this.type, {
    this.manifest,
    this.header,
    this.headerScale = 1,
    this.limit = 1024,
    this.minimum = 0,
    this.maximum = 9007199254740991,
    this.unit,
    this.trust = SubscriptionTrust.display,
    this.suffix,
    this.multiline = false,
    this.secure = false,
    required this.consumer,
  });

  final String path;
  final SubscriptionFieldType type;
  final String? manifest;
  final String? header;

  /// Multiplies an integer header value, as hours become minutes.
  final int headerScale;
  final int limit;
  final int minimum;
  final int maximum;
  final String? unit;
  final SubscriptionTrust trust;
  final SubscriptionSuffix? suffix;
  final bool multiline;

  /// An `https` URL only.
  final bool secure;
  final String consumer;

  Map<String, Object?> toJson() => {
    'path': manifest,
    'type': type.name,
    'encoding': switch (type) {
      SubscriptionFieldType.text => 'string-or-locale-map',
      SubscriptionFieldType.url => 'url',
      SubscriptionFieldType.integer => 'integer',
      SubscriptionFieldType.boolean => 'boolean',
      SubscriptionFieldType.hosts => 'list-of-authorities',
      SubscriptionFieldType.tokens => 'list-of-tokens',
      SubscriptionFieldType.packages => 'list-of-packages',
      SubscriptionFieldType.numbers => 'list-of-integers',
      SubscriptionFieldType.keys => 'list-of-ed25519-keys',
      SubscriptionFieldType.flags => 'map-of-booleans',
      SubscriptionFieldType.policy => 'map-of-named-values',
    },
    'limit': limit,
    if (type == SubscriptionFieldType.integer ||
        type == SubscriptionFieldType.numbers) ...{
      'minimum': minimum,
      'maximum': maximum,
    },
    if (unit != null) 'unit': unit,
    if (suffix case final suffix?)
      'suffix': {
        'path': suffix.manifest,
        'minimum': suffix.minimum,
        'maximum': suffix.maximum,
      },
    if (secure) 'https': true,
    if (header != null) 'fallbackHeader': header,
    'trust': trust.name,
    'introduced': 1,
    'absence': 'withdraw',
    'consumer': consumer,
    'available': true,
  };
}

const subscriptionFields = <SubscriptionField>[
  SubscriptionField(
    'provider.name',
    SubscriptionFieldType.text,
    manifest: 'provider.name',
    limit: 160,
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.logo',
    SubscriptionFieldType.url,
    manifest: 'provider.logo',
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.logoDark',
    SubscriptionFieldType.url,
    manifest: 'provider.logo-dark',
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.supportUrl',
    SubscriptionFieldType.url,
    manifest: 'provider.support-url',
    header: 'support-url',
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.webUrl',
    SubscriptionFieldType.url,
    manifest: 'provider.web-url',
    header: 'profile-web-page-url',
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.buyPlanUrl',
    SubscriptionFieldType.url,
    manifest: 'provider.renew.url',
    suffix: SubscriptionSuffix(
      'provider.buyPlanDays',
      'provider.renew.days',
      maximum: 3650,
    ),
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.buyTrafficUrl',
    SubscriptionFieldType.url,
    manifest: 'provider.top-up.url',
    suffix: SubscriptionSuffix(
      'provider.buyTrafficPercent',
      'provider.top-up.percent',
    ),
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.announce',
    SubscriptionFieldType.text,
    manifest: 'provider.announce.text',
    header: 'announce',
    multiline: true,
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.announceUrl',
    SubscriptionFieldType.url,
    manifest: 'provider.announce.url',
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.notice',
    SubscriptionFieldType.text,
    manifest: 'provider.notice.text',
    multiline: true,
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.noticeUrl',
    SubscriptionFieldType.url,
    manifest: 'provider.notice.url',
    consumer: 'panel',
  ),
  SubscriptionField(
    'subscription.type',
    SubscriptionFieldType.text,
    manifest: 'provider.type',
    limit: 32,
    consumer: 'panel',
  ),
  SubscriptionField(
    'account.title',
    SubscriptionFieldType.text,
    header: 'profile-title',
    limit: 160,
    consumer: 'panel',
  ),
  SubscriptionField(
    'update.intervalMinutes',
    SubscriptionFieldType.integer,
    header: 'profile-update-interval',
    headerScale: 60,
    minimum: 5,
    maximum: 43200,
    unit: 'minutes',
    trust: SubscriptionTrust.hint,
    consumer: 'scheduler',
  ),
  SubscriptionField(
    'presentation.hideUrl',
    SubscriptionFieldType.boolean,
    manifest: 'provider.hide-url',
    header: 'hide-url',
    consumer: 'panel',
  ),
  SubscriptionField(
    'presentation.serverGroup',
    SubscriptionFieldType.text,
    manifest: 'provider.server-group',
    limit: 256,
    consumer: 'panel',
  ),
  SubscriptionField(
    'presentation.config',
    SubscriptionFieldType.url,
    header: 'reclash-config',
    trust: SubscriptionTrust.hint,
    secure: true,
    consumer: 'manifest',
  ),
  SubscriptionField(
    'reminder.expireDays',
    SubscriptionFieldType.numbers,
    manifest: 'reminders.expire-days',
    limit: 8,
    maximum: 365,
    unit: 'days',
    trust: SubscriptionTrust.hint,
    consumer: 'reminder',
  ),
  SubscriptionField(
    'reminder.trafficPercent',
    SubscriptionFieldType.numbers,
    manifest: 'reminders.traffic-percent',
    limit: 8,
    minimum: 1,
    maximum: 100,
    unit: 'percent',
    trust: SubscriptionTrust.hint,
    consumer: 'reminder',
  ),
  SubscriptionField(
    'settings.flags',
    SubscriptionFieldType.flags,
    manifest: 'settings',
    limit: 16,
    trust: SubscriptionTrust.hint,
    consumer: 'settings',
  ),
  SubscriptionField(
    'settings.restrictions',
    SubscriptionFieldType.policy,
    manifest: 'policy',
    limit: 16,
    trust: SubscriptionTrust.hint,
    consumer: 'settings',
  ),
  SubscriptionField(
    'transport.fallbackHosts',
    SubscriptionFieldType.hosts,
    manifest: 'transport.fallback-hosts',
    limit: 5,
    trust: SubscriptionTrust.hint,
    consumer: 'transport',
  ),
  SubscriptionField(
    'transport.newDomain',
    SubscriptionFieldType.hosts,
    manifest: 'transport.new-domain',
    limit: 1,
    trust: SubscriptionTrust.hint,
    consumer: 'transport',
  ),
  SubscriptionField(
    'apps.exclude',
    SubscriptionFieldType.packages,
    manifest: 'apps.exclude',
    limit: 512,
    trust: SubscriptionTrust.hint,
    consumer: 'apps',
  ),
  SubscriptionField(
    'apps.include',
    SubscriptionFieldType.packages,
    manifest: 'apps.include',
    limit: 512,
    trust: SubscriptionTrust.hint,
    consumer: 'apps',
  ),
  SubscriptionField(
    'apps.routing',
    SubscriptionFieldType.tokens,
    manifest: 'apps.routing',
    limit: 1,
    trust: SubscriptionTrust.hint,
    consumer: 'apps',
  ),
  SubscriptionField(
    'support.keys',
    SubscriptionFieldType.keys,
    manifest: 'support.keys',
    limit: 2,
    trust: SubscriptionTrust.consent,
    consumer: 'support',
  ),
  SubscriptionField(
    'support.uploadUrl',
    SubscriptionFieldType.url,
    manifest: 'support.upload-url',
    trust: SubscriptionTrust.consent,
    secure: true,
    consumer: 'support',
  ),
];

/// Every standard header the decoder reads for [subscriptionFields].
Iterable<String> get subscriptionFieldHeaders => [
  for (final field in subscriptionFields) ?field.header,
];

class SubscriptionHeader {
  const SubscriptionHeader(
    this.name,
    this.direction,
    this.encoding, {
    this.sensitive = false,
    this.values = const [],
    this.context = const ['subscription'],
  });
  final String name;
  final String direction;
  final String encoding;
  final bool sensitive;
  final List<String> values;
  final List<String> context;

  Map<String, Object?> toJson() => {
    'name': name,
    'direction': direction,
    'encoding': encoding,
    'multiplicity': 'singleton',
    'limitBytes': subscriptionHeaderLimit,
    'sensitive': sensitive,
    'introduced': 1,
    if (values.isNotEmpty) 'values': values,
    'context': context,
    'available': true,
  };
}

const subscriptionHeaders = <SubscriptionHeader>[
  SubscriptionHeader('x-hwid', 'request', 'lowercase-hex-32', sensitive: true),
  SubscriptionHeader('x-device-os', 'request', 'ascii', sensitive: true),
  SubscriptionHeader('x-ver-os', 'request', 'ascii', sensitive: true),
  SubscriptionHeader('x-device-model', 'request', 'ascii', sensitive: true),
  SubscriptionHeader(
    'x-hwid-not-supported',
    'response',
    'boolean',
    context: ['http-response'],
  ),
  SubscriptionHeader(
    'x-hwid-max-devices-reached',
    'response',
    'boolean',
    context: ['http-response'],
  ),
  SubscriptionHeader(
    'Subscription-Userinfo',
    'response',
    'semicolon-counts',
    context: ['http-response'],
  ),
  SubscriptionHeader(
    'Content-Disposition',
    'response',
    'rfc6266',
    context: ['http-response'],
  ),
  SubscriptionHeader('User-Agent', 'request', 'ascii'),
  SubscriptionHeader('Accept-Language', 'request', 'ascii'),
  SubscriptionHeader('x-client', 'request', 'ascii'),
  SubscriptionHeader('x-app-version', 'request', 'ascii'),
  SubscriptionHeader('x-device-locale', 'request', 'ascii', sensitive: true),
];

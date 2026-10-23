const subscriptionStandardVersion = 1;
const subscriptionHeaderLimit = 8 * 1024;
const subscriptionHeadersLimit = 64 * 1024;
const subscriptionWireLimit = 16 * 1024 * 1024;
const subscriptionPayloadLimit = 32 * 1024 * 1024;

/// For [SubscriptionFieldType.tokens], [packages], [hosts], [numbers] and
/// [pairs] the field's `limit` counts entries, not bytes.
enum SubscriptionFieldType {
  text,
  url,
  integer,
  boolean,
  hosts,
  tokens,
  pairs,
  packages,
  numbers,
}

enum SubscriptionTrust { display, hint, consent }

/// A de-facto name other clients and panels already emit for a field.
class SubscriptionAlias {
  const SubscriptionAlias(this.header, {this.scale = 1});

  final String header;

  /// Multiplies an integer value, as hours become minutes.
  final int scale;
}

/// The optional `,<n>` that follows a URL, stored as its own integer field.
class SubscriptionSuffix {
  const SubscriptionSuffix(this.path, {this.minimum = 1, this.maximum = 100});

  final String path;
  final int minimum;
  final int maximum;
}

class SubscriptionField {
  const SubscriptionField(
    this.path,
    this.header,
    this.type, {
    this.limit = 1024,
    this.minimum = 0,
    this.maximum = 9007199254740991,
    this.unit,
    this.trust = SubscriptionTrust.display,
    this.aliases = const [],
    this.suffix,
    this.multiline = false,
    required this.consumer,
  });

  final String path;
  final String header;
  final SubscriptionFieldType type;
  final int limit;
  final int minimum;
  final int maximum;
  final String? unit;
  final SubscriptionTrust trust;
  final List<SubscriptionAlias> aliases;
  final SubscriptionSuffix? suffix;
  final bool multiline;
  final String consumer;

  Map<String, Object?> toJson() => {
    'path': path,
    'name': header,
    'type': type.name,
    'direction': 'response',
    'context': ['http-response', 'body-comment'],
    'encoding': switch (type) {
      SubscriptionFieldType.text => 'text-or-base64-prefixed',
      SubscriptionFieldType.url => suffix == null ? 'url' : 'url-with-suffix',
      SubscriptionFieldType.integer => 'decimal',
      SubscriptionFieldType.boolean => 'boolean',
      SubscriptionFieldType.hosts => 'comma-separated-authorities',
      SubscriptionFieldType.tokens => 'comma-separated-tokens',
      SubscriptionFieldType.pairs => 'semicolon-separated-pairs',
      SubscriptionFieldType.packages => 'comma-separated-packages',
      SubscriptionFieldType.numbers => 'comma-separated-decimals',
    },
    'multiplicity': 'singleton',
    'limit': limit,
    if (type == SubscriptionFieldType.integer ||
        type == SubscriptionFieldType.numbers) ...{
      'minimum': minimum,
      'maximum': maximum,
    },
    if (unit != null) 'unit': unit,
    if (suffix case final suffix?)
      'suffix': {
        'path': suffix.path,
        'minimum': suffix.minimum,
        'maximum': suffix.maximum,
      },
    if (aliases.isNotEmpty)
      'aliases': [
        for (final alias in aliases)
          {'name': alias.header, if (alias.scale != 1) 'scale': alias.scale},
      ],
    'trust': trust.name,
    'introduced': 1,
    'absence': 'retain-last-known-stale',
    'consumer': consumer,
    'available': true,
  };
}

const subscriptionFields = <SubscriptionField>[
  SubscriptionField(
    'provider.name',
    'reclash-servicename',
    SubscriptionFieldType.text,
    limit: 160,
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.logo',
    'reclash-servicelogo',
    SubscriptionFieldType.url,
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.supportUrl',
    'reclash-supporturl',
    SubscriptionFieldType.url,
    aliases: [SubscriptionAlias('support-url')],
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.webUrl',
    'reclash-webpageurl',
    SubscriptionFieldType.url,
    aliases: [SubscriptionAlias('profile-web-page-url')],
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.buyPlanUrl',
    'reclash-buyplan',
    SubscriptionFieldType.url,
    suffix: SubscriptionSuffix('provider.buyPlanDays', maximum: 3650),
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.buyTrafficUrl',
    'reclash-buytraffic',
    SubscriptionFieldType.url,
    suffix: SubscriptionSuffix('provider.buyTrafficPercent'),
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.announce',
    'reclash-announce',
    SubscriptionFieldType.text,
    aliases: [SubscriptionAlias('announce')],
    multiline: true,
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.announceUrl',
    'reclash-announceurl',
    SubscriptionFieldType.url,
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.notice',
    'reclash-notice',
    SubscriptionFieldType.text,
    multiline: true,
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.noticeUrl',
    'reclash-noticeurl',
    SubscriptionFieldType.url,
    consumer: 'panel',
  ),
  SubscriptionField(
    'account.title',
    'profile-title',
    SubscriptionFieldType.text,
    limit: 160,
    consumer: 'panel',
  ),
  SubscriptionField(
    'update.intervalMinutes',
    'reclash-autoupdateinterval',
    SubscriptionFieldType.integer,
    minimum: 5,
    maximum: 43200,
    unit: 'minutes',
    trust: SubscriptionTrust.hint,
    aliases: [SubscriptionAlias('profile-update-interval', scale: 60)],
    consumer: 'scheduler',
  ),
  SubscriptionField(
    'routing.bundleUrl',
    'reclash-routing',
    SubscriptionFieldType.url,
    trust: SubscriptionTrust.hint,
    consumer: 'routing',
  ),
  SubscriptionField(
    'presentation.hideUrl',
    'reclash-hideurl',
    SubscriptionFieldType.boolean,
    aliases: [SubscriptionAlias('hide-url')],
    consumer: 'panel',
  ),
  SubscriptionField(
    'presentation.serverGroup',
    'reclash-serverinfo',
    SubscriptionFieldType.text,
    limit: 256,
    consumer: 'panel',
  ),
  SubscriptionField(
    'presentation.widgets',
    'reclash-widgets',
    SubscriptionFieldType.tokens,
    limit: 32,
    trust: SubscriptionTrust.hint,
    consumer: 'appearance',
  ),
  SubscriptionField(
    'presentation.background',
    'reclash-background',
    SubscriptionFieldType.url,
    suffix: SubscriptionSuffix('presentation.backgroundOpacity'),
    trust: SubscriptionTrust.hint,
    consumer: 'appearance',
  ),
  SubscriptionField(
    'presentation.view',
    'reclash-view',
    SubscriptionFieldType.pairs,
    limit: 32,
    trust: SubscriptionTrust.hint,
    consumer: 'appearance',
  ),
  SubscriptionField(
    'reminder.expireDays',
    'reclash-expiredays',
    SubscriptionFieldType.numbers,
    limit: 8,
    maximum: 365,
    unit: 'days',
    trust: SubscriptionTrust.hint,
    consumer: 'reminder',
  ),
  SubscriptionField(
    'reminder.trafficPercent',
    'reclash-trafficpercent',
    SubscriptionFieldType.numbers,
    limit: 8,
    minimum: 1,
    maximum: 100,
    unit: 'percent',
    trust: SubscriptionTrust.hint,
    consumer: 'reminder',
  ),
  SubscriptionField(
    'settings.flags',
    'reclash-settings',
    SubscriptionFieldType.tokens,
    limit: 16,
    trust: SubscriptionTrust.hint,
    consumer: 'settings',
  ),
  SubscriptionField(
    'settings.restrictions',
    'reclash-restrictions',
    SubscriptionFieldType.tokens,
    limit: 16,
    trust: SubscriptionTrust.hint,
    consumer: 'settings',
  ),
  SubscriptionField(
    'transport.fallbackHosts',
    'reclash-fallbackhosts',
    SubscriptionFieldType.hosts,
    limit: 5,
    trust: SubscriptionTrust.hint,
    consumer: 'transport',
  ),
  SubscriptionField(
    'transport.newDomain',
    'reclash-newdomain',
    SubscriptionFieldType.hosts,
    limit: 1,
    trust: SubscriptionTrust.hint,
    consumer: 'transport',
  ),
  SubscriptionField(
    'apps.exclude',
    'reclash-excludeapps',
    SubscriptionFieldType.packages,
    limit: 512,
    trust: SubscriptionTrust.hint,
    consumer: 'apps',
  ),
  SubscriptionField(
    'apps.include',
    'reclash-includeapps',
    SubscriptionFieldType.packages,
    limit: 512,
    trust: SubscriptionTrust.hint,
    consumer: 'apps',
  ),
  SubscriptionField(
    'apps.routing',
    'reclash-approuting',
    SubscriptionFieldType.tokens,
    limit: 1,
    trust: SubscriptionTrust.hint,
    consumer: 'apps',
  ),
];

/// Every header name the decoder reads for [subscriptionFields], aliases
/// included.
Iterable<String> get subscriptionFieldHeaders => [
  for (final field in subscriptionFields) ...[
    field.header,
    for (final alias in field.aliases) alias.header,
  ],
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

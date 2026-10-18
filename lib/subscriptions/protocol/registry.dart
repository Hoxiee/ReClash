const subscriptionStandardVersion = 1;
const subscriptionHeaderLimit = 8 * 1024;
const subscriptionHeadersLimit = 64 * 1024;
const subscriptionWireLimit = 16 * 1024 * 1024;
const subscriptionPayloadLimit = 32 * 1024 * 1024;

enum SubscriptionFieldType { text, url, integer, boolean, hosts }

enum SubscriptionTrust { display, hint, consent }

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
  final String consumer;

  Map<String, Object?> toJson() => {
    'path': path,
    'name': header,
    'type': type.name,
    'direction': 'response',
    'context': ['http-response', 'body-comment'],
    'encoding': switch (type) {
      SubscriptionFieldType.text => 'text-or-base64-prefixed',
      SubscriptionFieldType.url => 'url',
      SubscriptionFieldType.integer => 'decimal',
      SubscriptionFieldType.boolean => 'boolean',
      SubscriptionFieldType.hosts => 'comma-separated-hosts',
    },
    'multiplicity': 'singleton',
    'limit': limit,
    if (type == SubscriptionFieldType.integer) ...{
      'minimum': minimum,
      'maximum': maximum,
    },
    if (unit != null) 'unit': unit,
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
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.webUrl',
    'reclash-webpageurl',
    SubscriptionFieldType.url,
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.buyPlanUrl',
    'reclash-buyplan',
    SubscriptionFieldType.url,
    consumer: 'panel',
  ),
  SubscriptionField(
    'provider.buyTrafficUrl',
    'reclash-buytraffic',
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
    consumer: 'scheduler',
  ),
  SubscriptionField(
    'presentation.hideUrl',
    'reclash-hideurl',
    SubscriptionFieldType.boolean,
    consumer: 'panel',
  ),
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

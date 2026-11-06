import 'dart:convert';
import 'dart:io';

import 'package:reclash/subscriptions/protocol/registry.dart';

const _jsonPath = 'provider_standard.g.json';
const _markdownPath = 'docs/en/providers/standard.md';

void main(List<String> arguments) {
  final json = const JsonEncoder.withIndent('  ').convert({
    'name': 'ReClash Subscription Provider Standard',
    'version': subscriptionStandardVersion,
    'limits': {
      'headerBytes': subscriptionHeaderLimit,
      'headersBytes': subscriptionHeadersLimit,
      'wireBytes': subscriptionWireLimit,
      'payloadBytes': subscriptionPayloadLimit,
    },
    'manifestFields': [
      for (final field in subscriptionFields)
        if (field.manifest != null) field.toJson(),
    ],
    'headers': [for (final header in _headers()) header.toJson()],
  });
  if (arguments.contains('--json-only')) {
    File(_jsonPath).writeAsStringSync('$json\n');
    return;
  }
  final markdown = _markdown();
  if (arguments.contains('--check')) {
    _check(_jsonPath, '$json\n');
    _check(_markdownPath, markdown);
    return;
  }
  File(_jsonPath).writeAsStringSync('$json\n');
  File(_markdownPath).writeAsStringSync(markdown);
}

/// The device headers, then every standard header that supplies a field.
List<SubscriptionHeader> _headers() => [
  ...subscriptionHeaders,
  for (final field in subscriptionFields)
    if (field.header case final header?)
      SubscriptionHeader(
        header,
        'response',
        switch (field.type) {
          SubscriptionFieldType.integer => 'decimal',
          SubscriptionFieldType.boolean => 'boolean',
          SubscriptionFieldType.url => 'url',
          _ => 'text-or-base64-prefixed',
        },
        context: [
          field.secure ? 'https-response' : 'http-response',
          if (field.manifest != null) 'fallback:${field.manifest}',
        ],
      ),
];

String _markdown() {
  final out = StringBuffer()
    ..writeln('# Standard registry')
    ..writeln()
    ..writeln(
      'Limits, manifest fields and HTTP headers of provider standard version '
      '$subscriptionStandardVersion, generated from the registry the app '
      'decodes with.',
    )
    ..writeln()
    ..writeln(
      'Machine-readable copy: '
      '[`provider_standard.g.json`](../../../provider_standard.g.json). '
      'Value formats and behavior: [Response headers](headers.md) and '
      '[Request headers](request.md).',
    )
    ..writeln()
    ..writeln('## Limits')
    ..writeln()
    ..writeln('| Limit | Bytes |')
    ..writeln('| --- | ---: |')
    ..writeln('| One header field | $subscriptionHeaderLimit |')
    ..writeln('| All response headers | $subscriptionHeadersLimit |')
    ..writeln('| Wire payload | $subscriptionWireLimit |')
    ..writeln('| Decoded payload | $subscriptionPayloadLimit |')
    ..writeln()
    ..writeln('## Manifest fields')
    ..writeln()
    ..writeln('| Path | Type | Limit | Trust | Consumer | Notes |')
    ..writeln('| --- | --- | ---: | --- | --- | --- |');
  for (final field in subscriptionFields) {
    final manifest = field.manifest;
    if (manifest == null) continue;
    final notes = [
      if (field.header case final header?) 'fallback header `$header`',
      if (field.suffix case final suffix?)
        '`${suffix.manifest}` ${suffix.minimum}-${suffix.maximum}',
      if (field.secure) 'https only',
    ];
    out.writeln(
      '| `$manifest` | ${field.type.name} | ${field.limit} | '
      '${field.trust.name} | ${field.consumer} | ${notes.join('; ')} |',
    );
  }
  out
    ..writeln()
    ..writeln('## HTTP headers')
    ..writeln()
    ..writeln('| Header | Direction | Encoding | Sensitive |')
    ..writeln('| --- | --- | --- | --- |');
  for (final header in _headers()) {
    out.writeln(
      '| `${header.name}` | ${header.direction} | ${header.encoding} | '
      '${header.sensitive ? 'yes' : 'no'} |',
    );
  }
  return out.toString();
}

void _check(String path, String expected) {
  final file = File(path);
  if (!file.existsSync() || file.readAsStringSync() != expected) {
    stderr.writeln(
      '$path is stale; run dart run tool/gen_provider_standard.dart',
    );
    exitCode = 1;
  }
}

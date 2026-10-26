import 'dart:convert';
import 'dart:io';

import 'package:reclash/subscriptions/protocol/registry.dart';

const _jsonPath = 'provider_standard.g.json';
const _markdownPath = 'docs/en/PROVIDER_HEADERS.md';

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
    'fields': [for (final field in subscriptionFields) field.toJson()],
    'headers': [for (final header in subscriptionHeaders) header.toJson()],
  });
  final markdown = _markdown();
  if (arguments.contains('--check')) {
    _check(_jsonPath, '$json\n');
    _check(_markdownPath, markdown);
    return;
  }
  File(_jsonPath).writeAsStringSync('$json\n');
  File(_markdownPath).writeAsStringSync(markdown);
}

String _markdown() {
  final out = StringBuffer()
    ..writeln('# ReClash Subscription Provider Standard')
    ..writeln()
    ..writeln('Version: $subscriptionStandardVersion')
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
    ..writeln('## Metadata fields')
    ..writeln()
    ..writeln('| Path | Header | Type | Trust | Consumer | Notes |')
    ..writeln('| --- | --- | --- | --- | --- | --- |');
  for (final field in subscriptionFields) {
    final notes = [
      for (final alias in field.aliases)
        'alias `${alias.header}`${alias.scale == 1 ? '' : ' x${alias.scale}'}',
      if (field.suffix case final suffix?)
        'suffix `${suffix.path}` ${suffix.minimum}-${suffix.maximum}',
    ];
    out.writeln(
      '| `${field.path}` | `${field.header}` | ${field.type.name} | '
      '${field.trust.name} | ${field.consumer} | ${notes.join('; ')} |',
    );
  }
  out
    ..writeln()
    ..writeln('## HTTP headers')
    ..writeln()
    ..writeln('| Header | Direction | Encoding | Sensitive |')
    ..writeln('| --- | --- | --- | --- |');
  for (final header in subscriptionHeaders) {
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

import 'dart:convert';
import 'dart:io';

import 'provider_standard_docs.dart';

/// Emits the provider standard from the three model files that already hold the
/// truth: the header converter, the appearance token maps and the dashboard
/// enum. Value/purpose/example prose comes from provider_standard_docs.dart;
/// the build fails when a derived header or widget has no entry there. Run it
/// after editing any of them; pass `--check` to fail when the committed
/// artefacts are stale instead of rewriting them.
///
/// The site vendors [_jsonOut] — now carrying the English descriptions — and
/// layers its own bilingual prose on top, so the wire contract lives here,
/// once, and the site can never invent a header.

const _headersPath = 'lib/models/panel_headers.dart';
const _appearancePath = 'lib/models/panel_appearance.dart';
const _enumPath = 'lib/enum/enum.dart';
const _jsonOut = 'provider_standard.g.json';
const _mdOut = 'PROVIDER_HEADERS.md';

// convertValue function -> a stable tag the site reads instead of Dart code.
const _transformTags = <String, String>{
  '_decodeBase64Header': 'base64',
  '_decodeTrimmedBase64Header': 'base64-trimmed',
  '_hoursToMinutes': 'hours-to-minutes',
};

// Honoured by the app but parsed outside the converter, so the reader never
// lists them while the site still documents them.
const _externalCommon = ['subscription-userinfo', 'content-disposition'];

List<String> _splitTop(String s) {
  final parts = <String>[];
  var depth = 0;
  final buf = StringBuffer();
  for (final ch in s.split('')) {
    if (ch == '(' || ch == '[' || ch == '{') depth++;
    if (ch == ')' || ch == ']' || ch == '}') depth--;
    if (ch == ',' && depth == 0) {
      parts.add(buf.toString());
      buf.clear();
    } else {
      buf.write(ch);
    }
  }
  if (buf.toString().trim().isNotEmpty) parts.add(buf.toString());
  return parts;
}

List<Map<String, Object?>> _parseHeaders(String src) {
  final block = RegExp(
    r'_panelHeaderConverters\s*=\s*<_PanelHeaderConverter>\[(.*?)\n\];',
    dotAll: true,
  ).firstMatch(src);
  if (block == null) throw StateError('converter list not found');
  final out = <Map<String, Object?>>[];
  for (final e in RegExp(
    r'_PanelHeaderConverter\((.*?)\)',
    dotAll: true,
  ).allMatches(block.group(1)!)) {
    final body = e.group(1)!;
    final keysM = RegExp(
      r'sourceKeys:\s*\[(.*?)\]',
      dotAll: true,
    ).firstMatch(body);
    final canonM = RegExp(r"canonicalKey:\s*'([^']+)'").firstMatch(body);
    if (keysM == null || canonM == null) {
      throw StateError('unparseable converter entry: $body');
    }
    final keys = RegExp(
      r"'([^']+)'",
    ).allMatches(keysM.group(1)!).map((m) => m.group(1)!).toList();
    final fn = RegExp(r'convertValue:\s*(_\w+)').firstMatch(body)?.group(1);
    final transform = fn == null
        ? 'none'
        : (_transformTags[fn] ?? (throw StateError('unknown transform $fn')));
    out.add({
      'canonical': canonM.group(1),
      'sourceKeys': keys,
      'transform': transform,
    });
  }
  return out;
}

List<String> _enumValues(String src, String name) {
  final m = RegExp(
    'enum\\s+$name\\s*\\{(.*?)(?:;|\\})',
    dotAll: true,
  ).firstMatch(src);
  if (m == null) throw StateError('enum $name not found');
  final out = <String>[];
  for (final part in _splitTop(m.group(1)!)) {
    final id = RegExp(r'^\s*([A-Za-z_]\w*)').firstMatch(part);
    if (id != null) out.add(id.group(1)!);
  }
  return out;
}

List<String> _constEnumList(String src, String name) {
  final m = RegExp(
    'const\\s+$name\\s*=\\s*\\[(.*?)\\]',
    dotAll: true,
  ).firstMatch(src);
  if (m == null) throw StateError('const $name not found');
  return RegExp(
    r'\.(\w+)',
  ).allMatches(m.group(1)!).map((x) => x.group(1)!).toList();
}

List<String> _mapKeys(String src, String name) {
  final m = RegExp(
    'const\\s+$name\\s*=\\s*<[^>]*>\\{(.*?)\\};',
    dotAll: true,
  ).firstMatch(src);
  if (m == null) throw StateError('map $name not found');
  return RegExp(
    r"'([^']+)'\s*:",
  ).allMatches(m.group(1)!).map((x) => x.group(1)!).toList();
}

int _intAfter(String src, String pattern) {
  final m = RegExp(pattern).firstMatch(src);
  if (m == null) throw StateError('pattern not found: $pattern');
  return int.parse(m.group(1)!);
}

List<Map<String, Object?>> _parseWidgets(String enums) {
  final allPlatforms = _enumValues(enums, 'SupportPlatform');
  final allModes = _enumValues(enums, 'DashboardMode');
  final desktop = _constEnumList(enums, 'desktopPlatforms');
  final vpnOnly = _constEnumList(enums, '_vpnOnly');
  final byedpiOnly = _constEnumList(enums, '_byedpiOnly');

  final block = RegExp(
    r'enum\s+DashboardWidget\s*\{(.*?);',
    dotAll: true,
  ).firstMatch(enums);
  if (block == null) throw StateError('DashboardWidget enum not found');

  final out = <Map<String, Object?>>[];
  for (final entry in _splitTop(block.group(1)!)) {
    final name = RegExp(r'^\s*([a-z][A-Za-z0-9]*)').firstMatch(entry);
    if (name == null) continue;

    var platforms = allPlatforms;
    final platM = RegExp(r'platforms:\s*(\[[^\]]*\]|\w+)').firstMatch(entry);
    if (platM != null) {
      final token = platM.group(1)!;
      platforms = token == 'desktopPlatforms'
          ? desktop
          : RegExp(
              r'\.(\w+)',
            ).allMatches(token).map((x) => x.group(1)!).toList();
    }

    var modes = allModes;
    final modeM = RegExp(r'modes:\s*(\w+)').firstMatch(entry);
    if (modeM != null) {
      final token = modeM.group(1)!;
      modes = token == '_vpnOnly'
          ? vpnOnly
          : (token == '_byedpiOnly' ? byedpiOnly : allModes);
    }

    out.add({'id': name.group(1), 'platforms': platforms, 'modes': modes});
  }
  return out;
}

void _requireCoverage(
  String kind,
  Set<String> derived,
  Set<String> documented,
) {
  final missing = derived.difference(documented);
  final stale = documented.difference(derived);
  if (missing.isNotEmpty || stale.isNotEmpty) {
    throw StateError(
      '$kind docs in provider_standard_docs.dart out of sync — '
      'missing: ${missing.join(', ')}; stale: ${stale.join(', ')}',
    );
  }
}

Map<String, Object?> buildStandard({
  required String headers,
  required String appearance,
  required String enums,
}) {
  final parsedHeaders = _parseHeaders(headers);
  final widgets = _parseWidgets(enums);
  _requireCoverage('header', {
    for (final h in parsedHeaders) h['canonical'] as String,
  }, headerDocs.keys.toSet());
  _requireCoverage('widget', {
    for (final w in widgets) w['id'] as String,
  }, widgetDocs.keys.toSet());
  _requireCoverage(
    'external',
    _externalCommon.toSet(),
    externalDocs.keys.toSet(),
  );

  final enrichedHeaders = [
    for (final h in parsedHeaders)
      <String, Object?>{
        ...h,
        'value': headerDocs[h['canonical']]!['value'],
        'purpose': headerDocs[h['canonical']]!['purpose'],
      },
  ];
  final enrichedWidgets = [
    for (final w in widgets)
      <String, Object?>{...w, 'purpose': widgetDocs[w['id']]!},
  ];

  final view = {
    'type': _mapKeys(appearance, '_proxiesTypes'),
    'sort': _mapKeys(appearance, '_sortTypes'),
    'layout': _mapKeys(appearance, '_layouts'),
    'icon': _mapKeys(appearance, '_iconStyles'),
    'card': _mapKeys(appearance, '_cardTypes'),
  };
  final themeFlag = RegExp(r"token\s*==\s*'([a-z]+)'").firstMatch(appearance);
  return {
    r'$generated': 'tool/gen_provider_standard.dart — do not edit by hand',
    'headers': enrichedHeaders,
    'externalCommon': _externalCommon,
    'widgets': enrichedWidgets,
    'tokens': {
      'view': view,
      'themeVariants': _mapKeys(appearance, '_schemeVariants'),
      'themeFlags': [if (themeFlag != null) themeFlag.group(1)],
      'heroEffect': _mapKeys(appearance, '_heroEffects'),
      'constraints': {
        'heroRingColours': _intAfter(
          appearance,
          r'tokens\.length\s*!=\s*(\d+)',
        ),
        'backgroundOpacityMin': _intAfter(appearance, r'\.clamp\((\d+),'),
        'backgroundOpacityMax': _intAfter(
          appearance,
          r'\.clamp\(\d+,\s*(\d+)\)',
        ),
        'hexDigits': [
          _intAfter(appearance, r'hex\.length\s*!=\s*(\d+)'),
          _intAfter(
            appearance,
            r'hex\.length\s*!=\s*\d+\s*&&\s*hex\.length\s*!=\s*(\d+)',
          ),
        ],
      },
    },
  };
}

String renderJson(Map<String, Object?> std) =>
    '${const JsonEncoder.withIndent('  ').convert(std)}\n';

String _row(List<String> cells) => '| ${cells.join(' | ')} |';

// Angle brackets in a table cell would be eaten as HTML, so wrap format
// literals like `upload=<bytes>` in code spans.
String _cell(String v) => v.contains('<') ? '`$v`' : v;

String renderMarkdown(Map<String, Object?> std) {
  final headers = (std['headers'] as List).cast<Map<String, Object?>>();
  final widgets = (std['widgets'] as List).cast<Map<String, Object?>>();
  final tokens = std['tokens'] as Map<String, Object?>;
  final view = tokens['view'] as Map<String, Object?>;
  final c = tokens['constraints'] as Map<String, Object?>;
  final variants = (tokens['themeVariants'] as List)
      .map((t) => '`$t`')
      .join(', ');
  final flags = (tokens['themeFlags'] as List).map((t) => '`$t`').join(', ');
  final effects = (tokens['heroEffect'] as List).map((t) => '`$t`').join(', ');

  final b = StringBuffer()
    ..writeln('# $docTitle')
    ..writeln()
    ..writeln(
      '<!-- Generated by tool/gen_provider_standard.dart from the model files '
      'and provider_standard_docs.dart. Do not edit by hand: run '
      '`dart run tool/gen_provider_standard.dart`. -->',
    )
    ..writeln()
    ..writeln(docIntro)
    ..writeln()
    ..writeln('## Response example')
    ..writeln()
    ..writeln('```http')
    ..writeln(responsePreamble);
  final seen = <String>{};
  for (final h in headers) {
    final canonical = h['canonical'] as String;
    if (!seen.add(canonical)) continue;
    final example = headerDocs[canonical]!['example'];
    if (example != null) b.writeln(example);
  }
  b
    ..writeln('```')
    ..writeln()
    ..writeln(responseExampleNote)
    ..writeln()
    ..writeln('## Headers')
    ..writeln()
    ..writeln(
      _row([
        'Canonical key',
        'Wire keys (priority order)',
        'Transform',
        'Value',
        'Purpose',
      ]),
    )
    ..writeln(_row(['---', '---', '---', '---', '---']));
  for (final h in headers) {
    b.writeln(
      _row([
        '`${h['canonical']}`',
        (h['sourceKeys'] as List).map((k) => '`$k`').join(', '),
        h['transform'] == 'none' ? '—' : '`${h['transform']}`',
        _cell(h['value'] as String),
        h['purpose'] as String,
      ]),
    );
  }
  b
    ..writeln()
    ..writeln('Parsed outside the converter, documented for completeness:')
    ..writeln()
    ..writeln(_row(['Header', 'Value', 'Purpose']))
    ..writeln(_row(['---', '---', '---']));
  for (final k in _externalCommon) {
    b.writeln(
      _row([
        '`$k`',
        _cell(externalDocs[k]!['value']!),
        externalDocs[k]!['purpose']!,
      ]),
    );
  }
  b
    ..writeln()
    ..writeln('## Text and Base64')
    ..writeln()
    ..writeln(textBase64Prose)
    ..writeln()
    ..writeln('## Appearance')
    ..writeln()
    ..writeln('### Provider logo')
    ..writeln()
    ..writeln(logoProse)
    ..writeln()
    ..writeln('### Theme')
    ..writeln()
    ..writeln(themeProse)
    ..writeln()
    ..writeln(
      'Supported variants are $variants'
      '${flags.isEmpty ? '' : '; the optional flag is $flags'}. '
      'Hex colours use ${(c['hexDigits'] as List).join(' or ')} digits. '
      '$themeVariantsNote',
    )
    ..writeln()
    ..writeln('### Background')
    ..writeln()
    ..writeln(backgroundProse)
    ..writeln()
    ..writeln(
      'Opacity ranges from ${c['backgroundOpacityMin']} to '
      '${c['backgroundOpacityMax']}.',
    )
    ..writeln()
    ..writeln('### Hero ring')
    ..writeln()
    ..writeln(heroRingProse)
    ..writeln()
    ..writeln('Exactly ${c['heroRingColours']} colours are required.')
    ..writeln()
    ..writeln('### Hero effect')
    ..writeln()
    ..writeln(heroEffectProse)
    ..writeln()
    ..writeln('The supported effect is $effects; anything else disables it.')
    ..writeln()
    ..writeln('### Proxy page')
    ..writeln()
    ..writeln(viewProse)
    ..writeln()
    ..writeln(_row(['Key', 'Values']))
    ..writeln(_row(['---', '---']));
  view.forEach((k, v) {
    b.writeln(_row(['`$k`', (v as List).map((t) => '`$t`').join(', ')]));
  });
  b
    ..writeln()
    ..writeln(viewOnelineNote)
    ..writeln()
    ..writeln('## Dashboard widgets')
    ..writeln()
    ..writeln(widgetsIntro)
    ..writeln()
    ..writeln(_row(['Widget', 'Platforms', 'Modes', 'Purpose']))
    ..writeln(_row(['---', '---', '---', '---']));
  for (final w in widgets) {
    b.writeln(
      _row([
        '`${w['id']}`',
        (w['platforms'] as List).join(', '),
        (w['modes'] as List).join(', '),
        w['purpose'] as String,
      ]),
    );
  }
  b
    ..writeln()
    ..writeln(widgetsMergeNote)
    ..writeln()
    ..writeln('## Initial application settings')
    ..writeln()
    ..writeln(settingsIntro)
    ..writeln()
    ..writeln(_row(['Token', 'Initial value enabled']))
    ..writeln(_row(['---', '---']));
  settingsTokens.forEach((k, v) {
    b.writeln(_row(['`$k`', v]));
  });
  b
    ..writeln()
    ..writeln('## Domain migration and fallback hosts')
    ..writeln()
    ..writeln(domainProse)
    ..writeln()
    ..writeln('## Device identity and provider verdicts')
    ..writeln()
    ..writeln(hwidIntro)
    ..writeln()
    ..writeln(_row(['Request header', 'Value']))
    ..writeln(_row(['---', '---']));
  hwidRequestHeaders.forEach((k, v) {
    b.writeln(_row(['`$k`', v]));
  });
  b
    ..writeln()
    ..writeln(
      'The two response verdicts `x-hwid-max-devices-reached` and '
      '`x-hwid-not-supported` are listed in the Headers table above.',
    )
    ..writeln()
    ..writeln('## Compatibility aliases')
    ..writeln()
    ..writeln(aliasesProse)
    ..writeln()
    ..writeln('## Security and privacy')
    ..writeln()
    ..writeln(securityProse);
  return b.toString();
}

String _dirname(String path) => path.substring(0, path.lastIndexOf('/'));

void main(List<String> args) {
  final check = args.contains('--check');
  final root = _dirname(_dirname(Platform.script.toFilePath()));
  String read(String rel) => File('$root/$rel').readAsStringSync();

  final std = buildStandard(
    headers: read(_headersPath),
    appearance: read(_appearancePath),
    enums: read(_enumPath),
  );
  final json = renderJson(std);
  final md = renderMarkdown(std);

  final jsonFile = File('$root/$_jsonOut');
  final mdFile = File('$root/$_mdOut');

  if (check) {
    final stale = <String>[];
    if (!jsonFile.existsSync() || jsonFile.readAsStringSync() != json) {
      stale.add(_jsonOut);
    }
    if (!mdFile.existsSync() || mdFile.readAsStringSync() != md) {
      stale.add(_mdOut);
    }
    if (stale.isNotEmpty) {
      stderr.writeln(
        'stale: ${stale.join(', ')} — run `dart run tool/gen_provider_standard.dart`',
      );
      exit(1);
    }
    stdout.writeln('provider standard: up to date');
    return;
  }

  jsonFile.writeAsStringSync(json);
  mdFile.writeAsStringSync(md);
  stdout.writeln('wrote $_jsonOut and $_mdOut');
}

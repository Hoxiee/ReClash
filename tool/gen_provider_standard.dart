import 'dart:convert';
import 'dart:io';

/// Emits the provider standard from the three model files that already hold the
/// truth: the header converter, the appearance token maps and the dashboard
/// enum. Run it after editing any of them; pass `--check` to fail when the
/// committed artefacts are stale instead of rewriting them.
///
/// The site vendors [_jsonOut] and layers its own bilingual prose on top, so
/// the wire contract lives here, once, and the site can never invent a header.

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

Map<String, Object?> buildStandard({
  required String headers,
  required String appearance,
  required String enums,
}) {
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
    'headers': _parseHeaders(headers),
    'externalCommon': _externalCommon,
    'widgets': _parseWidgets(enums),
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

String renderMarkdown(Map<String, Object?> std) {
  final b = StringBuffer()
    ..writeln('# Provider header standard')
    ..writeln()
    ..writeln(
      '<!-- Generated by tool/gen_provider_standard.dart. Do not edit by '
      'hand: run `dart run tool/gen_provider_standard.dart`. Human-readable, '
      'bilingual explanations live on the ReClash site. -->',
    )
    ..writeln()
    ..writeln(
      'This is the wire contract the app honours. Within one canonical key the '
      'wire keys are tried in the listed order and the first non-empty value '
      'wins, so the `reclash-*` name outranks its compatibility aliases.',
    )
    ..writeln()
    ..writeln('## Headers')
    ..writeln()
    ..writeln(
      _row(['Canonical key', 'Wire keys (priority order)', 'Transform']),
    )
    ..writeln(_row(['---', '---', '---']));
  for (final h in (std['headers'] as List).cast<Map<String, Object?>>()) {
    final keys = (h['sourceKeys'] as List).map((k) => '`$k`').join(', ');
    b.writeln(
      _row([
        '`${h['canonical']}`',
        keys,
        h['transform'] == 'none' ? '—' : '`${h['transform']}`',
      ]),
    );
  }
  b
    ..writeln()
    ..writeln(
      'Parsed outside the converter, documented for completeness: '
      '${_externalCommon.map((k) => '`$k`').join(', ')}.',
    )
    ..writeln()
    ..writeln('## Appearance tokens')
    ..writeln();
  final tokens = std['tokens'] as Map<String, Object?>;
  final view = tokens['view'] as Map<String, Object?>;
  b
    ..writeln('`reclash-view` sub-tokens (`key:value`, `;`-separated):')
    ..writeln();
  view.forEach((k, v) {
    b.writeln('- `$k`: ${(v as List).map((t) => '`$t`').join(', ')}');
  });
  b
    ..writeln()
    ..writeln(
      '`reclash-hex` variants: '
      '${(tokens['themeVariants'] as List).map((t) => '`$t`').join(', ')}'
      '${(tokens['themeFlags'] as List).isEmpty ? '' : ' (flags: '
                '${(tokens['themeFlags'] as List).map((t) => '`$t`').join(', ')})'}.',
    )
    ..writeln()
    ..writeln(
      '`reclash-heroeffect` values: '
      '${(tokens['heroEffect'] as List).map((t) => '`$t`').join(', ')} '
      '(anything else disables it).',
    )
    ..writeln();
  final c = tokens['constraints'] as Map<String, Object?>;
  b
    ..writeln('Constraints:')
    ..writeln()
    ..writeln('- `reclash-heroring`: exactly ${c['heroRingColours']} colours')
    ..writeln(
      '- `reclash-background` opacity: ${c['backgroundOpacityMin']}–'
      '${c['backgroundOpacityMax']}',
    )
    ..writeln(
      '- hex colour digits: '
      '${(c['hexDigits'] as List).join(' or ')}',
    )
    ..writeln()
    ..writeln('## Dashboard widgets')
    ..writeln()
    ..writeln(_row(['Widget', 'Platforms', 'Modes']))
    ..writeln(_row(['---', '---', '---']));
  for (final w in (std['widgets'] as List).cast<Map<String, Object?>>()) {
    b.writeln(
      _row([
        '`${w['id']}`',
        (w['platforms'] as List).join(', '),
        (w['modes'] as List).join(', '),
      ]),
    );
  }
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

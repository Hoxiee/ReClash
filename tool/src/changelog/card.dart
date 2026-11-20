import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' show join;
import 'package:reclash/common/update_summary.dart';

const _width = 1280;
const _height = 720;
const _margin = 72;
const _widthsPath = 'tool/assets/release_card/widths.json';

const _bg = '#F3F1EC';
const _ink = '#15152A';
const _sub = '#4A4A62';
const _muted = '#7A7A8C';

const _logo =
    '<line x1="88" y1="225" x2="165" y2="435" stroke="url(#gp)" stroke-width="100" stroke-linecap="round"/>'
    '<line x1="205" y1="65" x2="358" y2="485" stroke="url(#gb)" stroke-width="100" stroke-linecap="round"/>'
    '<line x1="410" y1="148" x2="462" y2="288" stroke="url(#gc)" stroke-width="100" stroke-linecap="round"/>'
    '<line x1="113.28" y1="224.24" x2="145.18" y2="311.23" stroke="#fff" stroke-width="20" stroke-linecap="round" opacity="0.55"/>'
    '<line x1="230.28" y1="64.30" x2="268.62" y2="169.53" stroke="#fff" stroke-width="20" stroke-linecap="round" opacity="0.55"/>'
    '<line x1="435.28" y1="147.14" x2="455.89" y2="202.64" stroke="#fff" stroke-width="20" stroke-linecap="round" opacity="0.55"/>'
    '<g stroke="#7FD9FF" stroke-width="10" stroke-linecap="round" fill="none">'
    '<path d="M480 92 Q502 104 508 128"/><path d="M502 60 Q536 78 544 114"/></g>';

const _gradients =
    '<linearGradient id="gp" gradientUnits="userSpaceOnUse" x1="88" y1="225" x2="165" y2="435">'
    '<stop offset="0" stop-color="#A38BFF"/><stop offset="1" stop-color="#7B5CF5"/></linearGradient>'
    '<linearGradient id="gb" gradientUnits="userSpaceOnUse" x1="205" y1="65" x2="358" y2="485">'
    '<stop offset="0" stop-color="#5AA0FF"/><stop offset="1" stop-color="#2F6FF0"/></linearGradient>'
    '<linearGradient id="gc" gradientUnits="userSpaceOnUse" x1="410" y1="148" x2="462" y2="288">'
    '<stop offset="0" stop-color="#55D0FF"/><stop offset="1" stop-color="#2EB8F0"/></linearGradient>';

enum _Face {
  display('unbounded', 'font-family="Unbounded ExtraBold" font-weight="800"'),
  text('manrope', 'font-family="Manrope" font-weight="700"');

  const _Face(this.key, this.attributes);
  final String key;
  final String attributes;
}

/// Renders the release card as SVG. Text is laid out with the per-glyph
/// advances in [_widthsPath] because the rasterizer does not wrap lines.
String renderReleaseCard(ReleaseSummary summary, {String root = '.'}) {
  final content = summary.locales['en']!;
  final version = summary.tag.startsWith('v')
      ? summary.tag.substring(1)
      : summary.tag;
  final prerelease = summary.tag.contains('-pre.');
  final accent = prerelease ? '#C2541A' : '#0E7A5E';
  final label = prerelease ? 'PRE-RELEASE' : 'STABLE';
  final layout = _Layout(_loadWidths(root));

  final headline = layout.headline(content.headline);
  final description = layout.wrap(
    content.spotlight.description,
    _Face.text,
    31,
    820,
    lines: 2,
  );
  const top = 148.0;
  const bottom = _height - 200.0;
  final blockHeight =
      headline.lines.length * headline.size * 1.25 +
      28 +
      44 +
      description.length * 41;
  var y =
      top +
      ((bottom - top - blockHeight) / 2).clamp(0, double.infinity) +
      headline.size;

  final body = StringBuffer()
    ..write('<rect width="$_width" height="$_height" fill="$_bg"/>')
    ..write(_logoAt(1088, 345, 0.46))
    ..write(_logoAt(_margin + 26, 92, 0.11))
    ..write(layout.text('ReClash', _margin + 66, 106, 36, _ink, _Face.display))
    ..write(
      '<text x="${_n(_margin + 84 + layout.measure('ReClash', _Face.display, 36))}" '
      'y="105" font-family="JetBrains Mono" font-size="28" fill="$_muted">'
      '${_escape(version)}</text>',
    );

  final badgeWidth = layout.measure(label, _Face.text, 20, spacing: 3) + 40;
  body
    ..write(
      '<rect x="${_n(_width - _margin - badgeWidth)}" y="70" '
      'width="${_n(badgeWidth)}" height="44" fill="$accent"/>',
    )
    ..write(
      layout.text(
        label,
        _width - _margin - badgeWidth / 2,
        99,
        20,
        _bg,
        _Face.text,
        spacing: 3,
        anchor: 'middle',
      ),
    )
    ..write(
      '<rect x="$_margin" y="146" width="${_width - 2 * _margin}" '
      'height="3" fill="$_ink"/>',
    );

  for (final line in headline.lines) {
    body.write(
      layout.text(line, _margin, y, headline.size, _ink, _Face.display),
    );
    y += headline.size * 1.25;
  }
  y += 10;
  body
    ..write(
      '<rect x="$_margin" y="${_n(y - 26)}" width="5" '
      'height="${40 + description.length * 41}" fill="$accent"/>',
    )
    ..write(
      layout.text(
        content.spotlight.title.toUpperCase(),
        _margin + 26,
        y,
        25,
        accent,
        _Face.text,
        spacing: 3,
      ),
    );
  y += 44;
  for (final line in description) {
    body.write(layout.text(line, _margin + 26, y, 31, _sub, _Face.text));
    y += 41;
  }
  body.write(
    _chips(layout, [for (final item in content.highlights) item.title]),
  );

  return '<svg xmlns="http://www.w3.org/2000/svg" width="$_width" '
      'height="$_height" viewBox="0 0 $_width $_height">'
      '<defs>$_gradients</defs>$body</svg>';
}

String _chips(_Layout layout, List<String> titles) {
  const size = 26.0;
  const height = 54.0;
  final out = StringBuffer();
  var x = _margin.toDouble();
  var y = _height - 192.0;
  var row = 0;
  for (var i = 0; i < titles.length; i++) {
    final width = layout.measure(titles[i], _Face.text, size) + 40;
    if (x + width > _width - _margin - 140) {
      if (row == 1) {
        final more = '+${titles.length - i}';
        out
          ..write(
            '<rect x="${_n(x)}" y="${_n(y)}" '
            'width="${_n(layout.measure(more, _Face.text, size) + 40)}" '
            'height="$height" fill="$_ink"/>',
          )
          ..write(layout.text(more, x + 20, y + 36, size, _bg, _Face.text));
        break;
      }
      row++;
      x = _margin.toDouble();
      y += height + 12;
    }
    out
      ..write(
        '<rect x="${_n(x + 1)}" y="${_n(y + 1)}" width="${_n(width - 2)}" '
        'height="${height - 2}" fill="none" stroke="$_ink" stroke-width="2"/>',
      )
      ..write(layout.text(titles[i], x + 20, y + 36, size, _ink, _Face.text));
    x += width + 12;
  }
  return out.toString();
}

String _logoAt(num x, num y, num scale) =>
    '<g transform="translate($x $y) scale($scale) translate(-294 -275)">'
    '$_logo</g>';

Map<String, Map<String, double>> _loadWidths(String root) {
  final json =
      jsonDecode(File(join(root, _widthsPath)).readAsStringSync())
          as Map<String, dynamic>;
  return {
    for (final entry in json.entries)
      entry.key: {
        for (final glyph in (entry.value as Map<String, dynamic>).entries)
          glyph.key: (glyph.value as num).toDouble(),
      },
  };
}

class _Layout {
  _Layout(this._widths);

  final Map<String, Map<String, double>> _widths;

  double measure(String text, _Face face, double size, {double spacing = 0}) {
    final table = _widths[face.key]!;
    var total = 0.0;
    for (final rune in text.runes) {
      total += (table[String.fromCharCode(rune)] ?? 0.6) * size + spacing;
    }
    return total;
  }

  List<String> wrap(
    String text,
    _Face face,
    double size,
    double maxWidth, {
    int? lines,
  }) {
    final out = <String>[];
    var current = '';
    for (final word in text.split(' ')) {
      final next = current.isEmpty ? word : '$current $word';
      if (measure(next, face, size) > maxWidth && current.isNotEmpty) {
        out.add(current);
        current = word;
      } else {
        current = next;
      }
    }
    if (current.isNotEmpty) out.add(current);
    if (lines != null && out.length > lines) {
      out.length = lines;
      out[lines - 1] += '…';
    }
    return out;
  }

  ({List<String> lines, double size}) headline(String text) {
    for (var size = 60.0; size >= 46; size -= 2) {
      final lines = wrap(text, _Face.display, size, 800);
      if (lines.length <= 2) return (lines: lines, size: size);
    }
    final lines = wrap(text, _Face.display, 50, 800);
    if (lines.length > 3) {
      throw const FormatException('Release headline needs more than 3 lines');
    }
    return (lines: lines, size: 50);
  }

  String text(
    String value,
    num x,
    num y,
    num size,
    String fill,
    _Face face, {
    num spacing = 0,
    String? anchor,
  }) =>
      '<text x="${_n(x)}" y="${_n(y)}" ${face.attributes} '
      'font-size="${_n(size)}" fill="$fill"'
      '${spacing == 0 ? '' : ' letter-spacing="$spacing"'}'
      '${anchor == null ? '' : ' text-anchor="$anchor"'}>'
      '${_escape(value)}</text>';
}

String _n(num value) =>
    value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

String _escape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

const _base = 36;
const _tMin = 1;
const _tMax = 26;
const _skew = 38;
const _damp = 700;
const _initialBias = 72;
const _initialN = 128;
const _maxCodePoint = 0x10FFFF;
const _maxLabelLength = 63;

final _acePrefix = RegExp(r'(^|\.)xn--', caseSensitive: false);
final _encodedLabel = RegExp(r'^[a-z0-9-]+$', caseSensitive: false);
final _displayLabel = RegExp(
  r'^[\p{L}\p{N}][\p{L}\p{N}\p{M}-]*$',
  unicode: true,
);
final _invisible = RegExp(r'\p{Default_Ignorable_Code_Point}', unicode: true);

/// Display only: callers retain the ASCII host for copying and diagnostics.
String decodeIdnHost(String host) {
  if (host.length > 254 || !_acePrefix.hasMatch(host)) return host;
  return host.split('.').map(_decodeLabel).join('.');
}

String _decodeLabel(String label) {
  if (label.length <= 4 ||
      label.length > _maxLabelLength ||
      !label.toLowerCase().startsWith('xn--') ||
      !_encodedLabel.hasMatch(label)) {
    return label;
  }
  final decoded = _decodePunycode(label.substring(4));
  if (decoded == null ||
      decoded.endsWith('-') ||
      !_displayLabel.hasMatch(decoded) ||
      _invisible.hasMatch(decoded)) {
    return label;
  }
  return decoded;
}

String? _decodePunycode(String input) {
  final delimiter = input.lastIndexOf('-');
  final output = <int>[
    for (var index = 0; index < delimiter; index++) input.codeUnitAt(index),
  ];
  var n = _initialN;
  var bias = _initialBias;
  var i = 0;
  var position = delimiter >= 0 ? delimiter + 1 : 0;
  while (position < input.length) {
    final oldI = i;
    final limit = _maxCodePoint * (output.length + 1);
    var weight = 1;
    for (var k = _base; ; k += _base) {
      if (position >= input.length) return null;
      final digit = _digitOf(input.codeUnitAt(position++));
      if (digit == null || digit > (limit - i) ~/ weight) return null;
      i += digit * weight;
      final t = k <= bias
          ? _tMin
          : k >= bias + _tMax
          ? _tMax
          : k - bias;
      if (digit < t) break;
      if (weight > limit ~/ (_base - t)) return null;
      weight *= _base - t;
    }
    final length = output.length + 1;
    bias = _adapt(i - oldI, length, first: oldI == 0);
    n += i ~/ length;
    i %= length;
    if (n > _maxCodePoint || (n >= 0xD800 && n <= 0xDFFF)) return null;
    output.insert(i++, n);
  }
  if (output.every((code) => code < 0x80)) return null;
  return String.fromCharCodes(output);
}

int _adapt(int delta, int points, {required bool first}) {
  var scaled = first ? delta ~/ _damp : delta ~/ 2;
  scaled += scaled ~/ points;
  var k = 0;
  while (scaled > (_base - _tMin) * _tMax ~/ 2) {
    scaled ~/= _base - _tMin;
    k += _base;
  }
  return k + (_base - _tMin + 1) * scaled ~/ (scaled + _skew);
}

int? _digitOf(int unit) => switch (unit) {
  >= 0x30 && <= 0x39 => unit - 0x30 + 26,
  >= 0x41 && <= 0x5A => unit - 0x41,
  >= 0x61 && <= 0x7A => unit - 0x61,
  _ => null,
};

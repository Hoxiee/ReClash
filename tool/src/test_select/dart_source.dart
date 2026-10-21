import 'dart:typed_data';

/// One Dart file reduced to what the dependency graph needs.
class DartSource {
  DartSource._(
    this.imports,
    this.exports,
    this.parts,
    this.declarations,
    this.used,
  );

  final List<String> imports;
  final List<ExportDirective> exports;
  final List<String> parts;
  final List<Declaration> declarations;

  /// Every identifier in code, string interpolations included.
  final Set<String> used;

  /// Public top-level names, plus the public members of its extensions.
  Set<String> get declared => publicNames(declarations);

  factory DartSource.parse(String source) {
    final scanner = _Scanner(source)..run();
    final code = scanner.code;
    final imports = <String>[];
    final exports = <ExportDirective>[];
    final parts = <String>[];
    final declarations = <Declaration>[];
    for (final (start, end) in statements(code, 0, code.length)) {
      final text = code.substring(start, end).trim();
      final keyword = _directive.firstMatch(text)?.group(1);
      if (keyword == null) {
        _declare(code, start, end, scanner.usedIn, declarations);
        continue;
      }
      final uris = [
        for (final match in _quoted.allMatches(source.substring(start, end)))
          match.group(1) ?? match.group(2)!,
      ];
      switch (keyword) {
        case 'import':
          imports.addAll(uris);
        case 'export':
          final (show, hide) = _combinators(text);
          exports.addAll([
            for (final uri in uris) ExportDirective(uri, show, hide),
          ]);
        case 'part' when !text.startsWith(_partOf):
          parts.addAll(uris);
      }
    }
    return DartSource._(
      imports,
      exports,
      parts,
      declarations,
      scanner.identifiers,
    );
  }
}

/// A top-level declaration, or one member of an extension, which goes by the
/// extension's name as well as its own.
class Declaration {
  const Declaration(this.names, this.used);

  /// Private names included; empty when nothing names it, as for an operator,
  /// so that whatever reaches it reaches every name of its library.
  final Set<String> names;
  final Set<String> used;
}

Set<String> publicNames(Iterable<Declaration> declarations) => {
  for (final declaration in declarations)
    for (final name in declaration.names)
      if (!name.startsWith('_')) name,
};

class ExportDirective {
  const ExportDirective(this.uri, this.show, this.hide);

  final String uri;
  final Set<String>? show;
  final Set<String> hide;

  Set<String> filter(Set<String> names) => {
    for (final name in names)
      if ((show == null || show!.contains(name)) && !hide.contains(name)) name,
  };
}

final _directive = RegExp(r'^(import|export|part|library)\b');
final _partOf = RegExp(r'part\s+of\b');
final _quoted = RegExp(r'''(?:'([^']*)'|"([^"]*)")''');
final _combinator = RegExp(r'\b(show|hide)\s+([\w$\s,]+)');
final _identifier = RegExp(r'[A-Za-z_$][\w$]*');
final _annotation = RegExp(r'^@[\w$.]+\s*');
final _modifiers = RegExp(
  r'^(?:(?:external|static|late|augment|covariant)\s+)+',
);
final _class = RegExp(
  r'^(?:(?:abstract|sealed|base|final|interface|mixin)\s+)*class\s+([\w$]+)',
);
final _mixin = RegExp(r'^(?:base\s+)?mixin\s+([\w$]+)');
final _enum = RegExp(r'^enum\s+([\w$]+)');
final _typedef = RegExp(r'^typedef\s+([\w$]+)\s*[<=]');
final _oldTypedef = RegExp(r'^typedef\b[^(]*?([\w$]+)\s*(?:<[^(]*>)?\s*\(');
final _extensionType = RegExp(r'^extension\s+type\s+(?:const\s+)?([\w$]+)');
final _extension = RegExp(r'^extension\s+(?:([\w$]+)\s*(?:<[^{]*?>)?\s+)?on\b');
final _accessor = RegExp(r'^[^(=]*\b[gs]et\s+([\w$]+)');
final _operator = RegExp(r'^[^(=]*\boperator\b');

const _keywords = {
  'final',
  'const',
  'var',
  'late',
  'static',
  'external',
  'Function',
  'void',
  'dynamic',
  'get',
  'set',
  'operator',
  'required',
  'covariant',
};

(Set<String>?, Set<String>) _combinators(String text) {
  Set<String>? show;
  final hide = <String>{};
  for (final match in _combinator.allMatches(text)) {
    final names = _identifier.allMatches(match.group(2)!).map((m) => m[0]!);
    if (match.group(1) == 'show') {
      (show ??= {}).addAll(names);
    } else {
      hide.addAll(names);
    }
  }
  return (show, hide);
}

void _declare(
  String code,
  int start,
  int end,
  Set<String> Function(int start, int end) usedIn,
  List<Declaration> into, {
  String? owner,
  Set<String> header = const {},
}) {
  var offset = start;
  String rest() => code.substring(offset, end);
  void skipSpace() => offset += rest().length - rest().trimLeft().length;
  skipSpace();
  while (code.startsWith('@', offset)) {
    offset += _annotation.firstMatch(rest())![0]!.length;
    if (code.startsWith('(', offset)) offset = _closing(code, offset) + 1;
    skipSpace();
  }
  offset += _modifiers.firstMatch(rest())?.end ?? 0;
  final text = rest().trimRight();
  if (text.isEmpty || text == ';') return;

  final extension = _extension.firstMatch(text);
  final open = text.indexOf('{');
  final close = text.lastIndexOf('}');
  if (extension != null && open >= 0 && close > open) {
    final header = usedIn(start, offset + open);
    for (final (s, e) in statements(code, offset + open + 1, offset + close)) {
      _declare(
        code,
        s,
        e,
        usedIn,
        into,
        owner: extension.group(1) ?? '',
        header: header,
      );
    }
    return;
  }
  final name = _nameOf(text);
  final names = {
    ?name,
    if (name != null && owner != null && owner.isNotEmpty) owner,
  };
  into.add(
    Declaration(names, {...header, ...usedIn(start, end)}..removeAll(names)),
  );
}

String? _nameOf(String text) {
  for (final pattern in [
    _class,
    _mixin,
    _enum,
    _typedef,
    _oldTypedef,
    _extensionType,
  ]) {
    final match = pattern.firstMatch(text);
    if (match != null) return match.group(1);
  }
  if (_operator.hasMatch(text)) return null;
  final name = _accessor.firstMatch(text)?.group(1) ?? _memberName(text);
  return name == null || _keywords.contains(name) ? null : name;
}

/// The name of a top-level function or variable: whatever stands before the
/// first top-level `=`, or before the first parameter list that does not
/// belong to a `Function` type.
String? _memberName(String text) {
  var depth = 0;
  for (var i = 0; i < text.length; i++) {
    final char = text[i];
    if (char == '(') {
      if (depth == 0) {
        final name = _nameBefore(text, i);
        if (name != null && !_keywords.contains(name)) return name;
      }
      depth++;
    } else if (char == ')') {
      depth--;
    } else if (char == '=' && depth == 0) {
      final next = i + 1 < text.length ? text[i + 1] : '';
      final previous = i > 0 ? text[i - 1] : '';
      if (next == '=' || next == '>' || '<>!'.contains(previous)) continue;
      return _nameBefore(text, i);
    }
  }
  final names = _identifier.allMatches(text).map((m) => m[0]!).toList();
  return names.length > 1 ? names.last : null;
}

String? _nameBefore(String text, int index) {
  var i = index - 1;
  while (i >= 0 && text[i].trim().isEmpty) {
    i--;
  }
  if (i >= 0 && text[i] == '>') {
    var depth = 0;
    for (; i >= 0; i--) {
      if (text[i] == '>') depth++;
      if (text[i] == '<' && --depth == 0) break;
    }
    i--;
    while (i >= 0 && text[i].trim().isEmpty) {
      i--;
    }
  }
  final end = i + 1;
  while (i >= 0 && _isIdentifierUnit(text.codeUnitAt(i))) {
    i--;
  }
  return end > i + 1 ? text.substring(i + 1, end) : null;
}

int _closing(String text, int open) {
  var depth = 0;
  for (var i = open; i < text.length; i++) {
    if (text[i] == '(') depth++;
    if (text[i] == ')' && --depth == 0) return i;
  }
  return text.length - 1;
}

/// Splits [code], whose comments and string text are already blanked, into
/// the declarations between [from] and [to] at the outermost brace level. A
/// brace block ends one unless it follows an `=` or `=>`, as a literal or a
/// switch expression does.
List<(int, int)> statements(String code, int from, int to) {
  final result = <(int, int)>[];
  var start = from;
  var braces = 0;
  var parens = 0;
  var assigns = false;
  void close(int end) {
    if (code.substring(start, end).trim().isNotEmpty) result.add((start, end));
    start = end;
    assigns = false;
  }

  for (var i = from; i < to; i++) {
    switch (code.codeUnitAt(i)) {
      case 0x28 || 0x5B:
        parens++;
      case 0x29 || 0x5D:
        if (parens > 0) parens--;
      case 0x7B:
        braces++;
      case 0x7D:
        if (braces > 0) braces--;
        if (braces == 0 && parens == 0 && !assigns) close(i + 1);
      case 0x3B when braces == 0 && parens == 0:
        close(i + 1);
      case 0x3D when braces == 0 && parens == 0:
        assigns = true;
    }
  }
  close(to);
  return result;
}

bool _isIdentifierUnit(int unit) =>
    (unit >= 0x61 && unit <= 0x7A) ||
    (unit >= 0x41 && unit <= 0x5A) ||
    (unit >= 0x30 && unit <= 0x39) ||
    unit == 0x5F ||
    unit == 0x24;

bool _isDigit(int unit) => unit >= 0x30 && unit <= 0x39;

/// Blanks comments and literal string text in place, keeping offsets, line
/// breaks and the code inside interpolations, and collects identifiers.
class _Scanner {
  _Scanner(this.source) : _out = Uint16List.fromList(source.codeUnits);

  final String source;
  final Uint16List _out;
  final identifiers = <String>{};
  final _starts = <int>[];
  final _names = <String>[];

  Set<String> usedIn(int start, int end) {
    var low = 0;
    var high = _starts.length;
    while (low < high) {
      final middle = (low + high) >> 1;
      if (_starts[middle] < start) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return {
      for (var i = low; i < _starts.length && _starts[i] < end; i++) _names[i],
    };
  }

  void _identifier(int start, int end) {
    final name = source.substring(start, end);
    identifiers.add(name);
    _starts.add(start);
    _names.add(name);
  }

  String get code => String.fromCharCodes(_out);

  void run() => _code(0, nested: false);

  void _blank(int i) {
    final unit = _out[i];
    if (unit != 0x0A && unit != 0x0D) _out[i] = 0x20;
  }

  int _unit(int i) => i < source.length ? source.codeUnitAt(i) : 0;

  int _code(int i, {required bool nested}) {
    var depth = 0;
    while (i < source.length) {
      final unit = source.codeUnitAt(i);
      if (unit == 0x2F && _unit(i + 1) == 0x2F) {
        while (i < source.length && source.codeUnitAt(i) != 0x0A) {
          _blank(i++);
        }
      } else if (unit == 0x2F && _unit(i + 1) == 0x2A) {
        i = _blockComment(i);
      } else if (unit == 0x27 || unit == 0x22) {
        i = _string(i, raw: false);
      } else if (_isIdentifierUnit(unit) && !_isDigit(unit)) {
        final start = i;
        while (i < source.length && _isIdentifierUnit(source.codeUnitAt(i))) {
          i++;
        }
        final next = _unit(i);
        if (i - start == 1 && unit == 0x72 && (next == 0x27 || next == 0x22)) {
          i = _string(i, raw: true);
        } else {
          _identifier(start, i);
        }
      } else if (_isDigit(unit)) {
        while (i < source.length && _isIdentifierUnit(source.codeUnitAt(i))) {
          i++;
        }
      } else {
        if (nested && unit == 0x7B) depth++;
        if (nested && unit == 0x7D && depth-- == 0) return i;
        i++;
      }
    }
    return i;
  }

  int _blockComment(int i) {
    var depth = 0;
    while (i < source.length) {
      if (source.startsWith('/*', i)) {
        depth++;
        _blank(i++);
        _blank(i++);
      } else if (source.startsWith('*/', i)) {
        _blank(i++);
        _blank(i++);
        if (--depth == 0) return i;
      } else {
        _blank(i++);
      }
    }
    return i;
  }

  int _string(int i, {required bool raw}) {
    final quote = source[i];
    final delimiter = source.startsWith(quote * 3, i) ? quote * 3 : quote;
    i += delimiter.length;
    while (i < source.length) {
      final unit = source.codeUnitAt(i);
      if (source.startsWith(delimiter, i)) return i + delimiter.length;
      if (delimiter.length == 1 && unit == 0x0A) return i;
      if (!raw && unit == 0x5C) {
        _blank(i++);
        if (i < source.length) _blank(i++);
      } else if (!raw && unit == 0x24 && _unit(i + 1) == 0x7B) {
        _blank(i++);
        _blank(i++);
        i = _code(i, nested: true);
        if (i < source.length) _blank(i++);
      } else if (!raw && unit == 0x24) {
        _blank(i++);
        final start = i;
        while (i < source.length &&
            _isIdentifierUnit(source.codeUnitAt(i)) &&
            source.codeUnitAt(i) != 0x24) {
          i++;
        }
        if (i > start) _identifier(start, i);
      } else {
        _blank(i++);
      }
    }
    return i;
  }
}

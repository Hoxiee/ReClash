/// Splits a strategy line into argv tokens, shell-style; an unterminated quote
/// throws [FormatException] for the editor to show.
List<String> desyncArgsFromText(String text) {
  final args = <String>[];
  final current = StringBuffer();
  var quote = '';
  for (var i = 0; i < text.length; i++) {
    final char = text[i];
    if (quote.isNotEmpty) {
      if (char == quote) {
        quote = '';
      } else {
        current.write(char);
      }
      continue;
    }
    if (char == "'" || char == '"') {
      quote = char;
      continue;
    }
    if (char == ' ' || char == '\t' || char == '\n' || char == '\r') {
      if (current.isNotEmpty) {
        args.add(current.toString());
        current.clear();
      }
      continue;
    }
    current.write(char);
  }
  if (quote.isNotEmpty) {
    throw const FormatException('unterminated quote');
  }
  if (current.isNotEmpty) {
    args.add(current.toString());
  }
  return args;
}

/// Joins tokens back into a line; a token with both quote kinds is left raw.
String desyncArgsToText(List<String> args) {
  return args.map((arg) {
    final needsQuoting = arg.contains(RegExp(r'\s'));
    if (!needsQuoting) {
      return arg;
    }
    if (!arg.contains("'")) {
      return "'$arg'";
    }
    if (!arg.contains('"')) {
      return '"$arg"';
    }
    return arg;
  }).join(' ');
}

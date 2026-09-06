/// Splits a strategy line into argv tokens, shell-style; an unterminated quote
/// throws [FormatException] for the editor to show.
List<String> desyncArgsFromText(String text) {
  final args = <String>[];
  final current = StringBuffer();
  var started = false;
  var quote = '';
  for (var i = 0; i < text.length; i++) {
    final char = text[i];
    if (quote == "'") {
      if (char == "'") {
        quote = '';
      } else {
        current.write(char);
      }
      continue;
    }
    if (quote == '"') {
      if (char == '"') {
        quote = '';
      } else if (char == r'\' && i + 1 < text.length) {
        current.write(text[++i]);
      } else {
        current.write(char);
      }
      continue;
    }
    if (char == "'" || char == '"') {
      quote = char;
      started = true;
      continue;
    }
    if (char == r'\' && i + 1 < text.length) {
      current.write(text[++i]);
      started = true;
      continue;
    }
    if (char == ' ' || char == '\t' || char == '\n' || char == '\r') {
      if (started) {
        args.add(current.toString());
        current.clear();
        started = false;
      }
      continue;
    }
    started = true;
    current.write(char);
  }
  if (quote.isNotEmpty) {
    throw const FormatException('unterminated quote');
  }
  if (started) {
    args.add(current.toString());
  }
  return args;
}

/// Joins tokens back into a line; a token with both quote kinds is left raw.
String desyncArgsToText(List<String> args) {
  return args.map((arg) {
    if (arg.isEmpty) {
      return '""';
    }
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

enum DesyncArgsIssueKind { unknownFlag, appOwnedFlag, missingValue, positional }

class DesyncArgsIssue {
  const DesyncArgsIssue(this.kind, this.token);

  final DesyncArgsIssueKind kind;

  final String token;
}

// The vendored v0.17.3 option table as it lands on Android: __linux__ defines
// E/S/Y/P, FAKE_SUPPORT f/n, TIMEOUT_SUPPORT T; DAEMON stays off.
const _desyncFlagOptions = {
  'N', 'X', 'U', 'h', 'v', 'E', 'F', 'S', 'Y', 'Z',
};

const _desyncValueOptions = {
  'i', 'p', 'I', 'b', 'x', 'A', 'L', 'u', 'T', 'B', 'y', 'K', 'H', 'V', 'R',
  's', 'd', 'o', 'q', 'f', 'n', 't', 'l', 'O', 'Q', 'e', 'M', 'r', 'm', 'a',
  'g', 'W', 'P', 'j', 'C', '#', '/',
};

const _desyncLongOptions = {
  'no-domain': false,
  'no-ipv6': false,
  'no-udp': false,
  'help': false,
  'version': false,
  'transparent': false,
  'tfo': false,
  'md5sig': false,
  'drop-sack': false,
  'wait-send': false,
  'ip': true,
  'port': true,
  'conn-ip': true,
  'buf-size': true,
  'max-conn': true,
  'debug': true,
  'auto': true,
  'auto-mode': true,
  'cache-ttl': true,
  'timeout': true,
  'copy': true,
  'cache-file': true,
  'proto': true,
  'hosts': true,
  'pf': true,
  'round': true,
  'split': true,
  'disorder': true,
  'oob': true,
  'disoob': true,
  'fake': true,
  'fake-sni': true,
  'ttl': true,
  'fake-data': true,
  'fake-offset': true,
  'fake-tls-mod': true,
  'oob-data': true,
  'mod-http': true,
  'tlsrec': true,
  'tlsminor': true,
  'udp-fake': true,
  'def-ttl': true,
  'await-int': true,
  'protect-path': true,
  'ipset': true,
  'connect-to': true,
  'comment': true,
  'cache-merge': true,
};

// The app pins these before the user's tokens, and ciadpi's getopt is
// last-wins, so a strategy carrying one would silently retune the engine.
const _desyncAppOwnedShort = {'i', 'p', 'y', 'P'};

const _desyncAppOwnedLong = {'ip', 'port', 'cache-file', 'protect-path'};

/// Previews what the engine's parser would reject or the module would strip,
/// so the editor can show it before the strategy is ever applied.
List<DesyncArgsIssue> desyncValidateArgs(List<String> args) {
  final issues = <DesyncArgsIssue>[];
  for (var i = 0; i < args.length; i++) {
    final token = args[i];
    if (token == '--') {
      for (final rest in args.skip(i + 1)) {
        issues.add(DesyncArgsIssue(DesyncArgsIssueKind.positional, rest));
      }
      return issues;
    }
    if (token.startsWith('--')) {
      final name = token.substring(2).split('=').first;
      if (_desyncAppOwnedLong.contains(name)) {
        issues.add(
          DesyncArgsIssue(DesyncArgsIssueKind.appOwnedFlag, token),
        );
      } else if (!_desyncLongOptions.containsKey(name)) {
        issues.add(DesyncArgsIssue(DesyncArgsIssueKind.unknownFlag, token));
      } else if (_desyncLongOptions[name]! && !token.contains('=')) {
        if (++i >= args.length) {
          issues.add(
            DesyncArgsIssue(DesyncArgsIssueKind.missingValue, token),
          );
        }
      }
      continue;
    }
    if (token.startsWith('-') && token.length > 1) {
      for (var c = 1; c < token.length; c++) {
        final flag = token[c];
        // A rejected flag still owns its value: otherwise the value would
        // pile on as a second, noisier positional complaint.
        if (_desyncAppOwnedShort.contains(flag)) {
          issues.add(
            DesyncArgsIssue(DesyncArgsIssueKind.appOwnedFlag, token),
          );
          if (c + 1 >= token.length && i + 1 < args.length) i++;
          break;
        }
        if (!_desyncFlagOptions.contains(flag) &&
            !_desyncValueOptions.contains(flag)) {
          issues.add(DesyncArgsIssue(DesyncArgsIssueKind.unknownFlag, token));
          if (c + 1 >= token.length && i + 1 < args.length) i++;
          break;
        }
        if (_desyncValueOptions.contains(flag)) {
          if (c + 1 >= token.length && ++i >= args.length) {
            issues.add(
              DesyncArgsIssue(DesyncArgsIssueKind.missingValue, token),
            );
          }
          break;
        }
      }
      continue;
    }
    issues.add(DesyncArgsIssue(DesyncArgsIssueKind.positional, token));
  }
  return issues;
}

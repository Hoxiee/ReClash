import 'dart:convert';
import 'dart:io';

import 'apply.dart';
import 'audit.dart';
import 'workspace.dart';

/// Regenerates `lib/l10n/` and returns the generator's output on failure, or
/// null on success.
typedef L10nGenerator = Future<String?> Function(Directory root);

const l10nUsage = '''
Usage: dart run tool/l10n.dart <command>
  apply <spec.json|-> [--dry-run] [--no-generate]
      spec: {"fragment": "<feature>",
             "set": {"<key>": {"<locale>": "<text>", ...every locale, "@": {"placeholders": {...}}}},
             "remove": ["<key>"], "remove_upstream": ["<key>"]}
      "@" is optional and replaces the en metadata; omit it to keep the current one.
  get <key>...                  owner and value per locale
  find <text> [--locale <l>]    search assembled values (default en)
  audit [--fragment <feature>]  locale gaps, placeholders, Han text; undeclared, same-as-en warn''';

const _findLimit = 30;

class L10nCli {
  L10nCli({
    required this.root,
    required this.out,
    required this.err,
    required this.generate,
    Future<String> Function()? readStdin,
  }) : readStdin = readStdin ?? _readStdin;

  final Directory root;
  final StringSink out;
  final StringSink err;
  final L10nGenerator generate;
  final Future<String> Function() readStdin;

  Future<int> run(List<String> args) async {
    if (args.isEmpty) return _usage();
    final command = args.first;
    final rest = args.skip(1).toList();
    try {
      return switch (command) {
        'apply' => await _apply(rest),
        'get' => _get(rest),
        'find' => _find(rest),
        'audit' => _audit(rest),
        _ => _usage(),
      };
    } on L10nException catch (error) {
      error.messages.forEach(err.writeln);
      return 1;
    } on FormatException catch (error) {
      err.writeln('error: ${error.message}');
      return 1;
    }
  }

  Future<int> _apply(List<String> args) async {
    final dryRun = args.remove('--dry-run');
    final noGenerate = args.remove('--no-generate');
    if (args.length != 1 ||
        (args.single.startsWith('--') && args.single != '-')) {
      return _usage();
    }
    final String source;
    if (args.single == '-') {
      source = await readStdin();
    } else {
      final file = File(args.single);
      if (!file.existsSync()) {
        throw L10nException(['spec: ${args.single} not found']);
      }
      source = file.readAsStringSync();
    }
    final spec = L10nSpec.parse(source);
    final workspace = L10nWorkspace.load(root);
    final plan = planApply(workspace, spec);
    if (plan.isEmpty) {
      out.writeln('${spec.fragment}: no changes');
      return 0;
    }
    checkAssembly(root, plan);
    if (dryRun) {
      plan.lines.forEach(out.writeln);
      out.writeln('${plan.summary}; dry run, ${plan.texts.length} files');
      return 0;
    }
    writePlan(root, plan);
    if (noGenerate) {
      out.writeln('${plan.summary}; assembled');
      return 0;
    }
    final failure = await generate(root);
    if (failure != null) {
      err.writeln(failure.trimRight());
      err.writeln('${plan.summary}; assembled; generate failed');
      return 1;
    }
    out.writeln('${plan.summary}; assembled; generated');
    return 0;
  }

  int _get(List<String> keys) {
    if (keys.isEmpty) return _usage();
    final workspace = L10nWorkspace.load(root);
    final assembled = workspace.assembled();
    var status = 0;
    for (final key in keys) {
      if (assembled['en']?.containsKey(key) != true) {
        err.writeln('$key: not found');
        status = 1;
        continue;
      }
      if (assembled['en']!['@$key'] case final metadata?) {
        out.writeln('$key\t@\t${jsonEncode(metadata)}');
      }
      for (final locale in workspace.locales) {
        out.writeln(
          '$key\t$locale\t${workspace.ownerOf(key, locale)}\t'
          '${oneLine(assembled[locale]?[key])}',
        );
      }
    }
    return status;
  }

  int _find(List<String> args) {
    final locale = _option(args, '--locale') ?? 'en';
    if (args.length != 1) return _usage();
    final needle = args.single.toLowerCase();
    final values = L10nWorkspace.load(root).assembled()[locale];
    if (values == null) throw L10nException(['$locale: unknown locale']);
    final matches = [
      for (final MapEntry(:key, :value) in values.entries)
        if (isMessageKey(key) &&
            value is String &&
            value.toLowerCase().contains(needle))
          (key, value),
    ]..sort((a, b) => a.$2.length.compareTo(b.$2.length));
    if (matches.isEmpty) {
      out.writeln('no matches');
      return 0;
    }
    for (final (key, value) in matches.take(_findLimit)) {
      out.writeln('$key\t${oneLine(value)}');
    }
    if (matches.length > _findLimit) {
      out.writeln('+${matches.length - _findLimit} more');
    }
    return 0;
  }

  int _audit(List<String> args) {
    final fragment = _option(args, '--fragment');
    if (args.isNotEmpty) return _usage();
    final workspace = L10nWorkspace.load(root);
    if (fragment != null && !workspace.fragments.containsKey(fragment)) {
      throw L10nException(['$fragment: unknown fragment']);
    }
    final findings = audit(workspace, fragment: fragment);
    findings.forEach(out.writeln);
    final errors = findings.where((finding) => finding.error).length;
    final warnings = findings.length - errors;
    out.writeln(
      findings.isEmpty
          ? 'audit: clean'
          : 'audit: $errors errors, $warnings warnings',
    );
    return errors == 0 ? 0 : 1;
  }

  String? _option(List<String> args, String name) {
    final index = args.indexOf(name);
    if (index < 0) return null;
    if (index + 1 >= args.length) {
      throw L10nException(['$name needs a value']);
    }
    final value = args[index + 1];
    args.removeRange(index, index + 2);
    return value;
  }

  int _usage() {
    err.writeln(l10nUsage);
    return 64;
  }

  static Future<String> _readStdin() => stdin.transform(utf8.decoder).join();
}

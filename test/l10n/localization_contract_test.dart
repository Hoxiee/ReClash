import 'dart:convert';
import 'dart:io';

import 'package:reclash/l10n/intl/messages_en.dart' as messages_en;
import 'package:reclash/l10n/intl/messages_es.dart' as messages_es;
import 'package:reclash/l10n/intl/messages_fr.dart' as messages_fr;
import 'package:reclash/l10n/intl/messages_ja.dart' as messages_ja;
import 'package:reclash/l10n/intl/messages_ko.dart' as messages_ko;
import 'package:reclash/l10n/intl/messages_ru.dart' as messages_ru;
import 'package:reclash/l10n/intl/messages_zh_CN.dart' as messages_zh_cn;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:yaml/yaml.dart';

void main() {
  final lookups = <String, MessageLookupByLibrary>{
    'en': messages_en.messages,
    'es': messages_es.messages,
    'fr': messages_fr.messages,
    'ja': messages_ja.messages,
    'ko': messages_ko.messages,
    'ru': messages_ru.messages,
    'zh_CN': messages_zh_cn.messages,
  };

  test('vendor locale provenance stays outside application analysis', () {
    final options =
        loadYaml(File('analysis_options.yaml').readAsStringSync()) as YamlMap;
    final analyzer = options['analyzer'] as YamlMap;
    final excluded = analyzer['exclude'] as YamlList;
    expect(excluded, contains('upstream_l10n/**'));
    expect(excluded, isNot(contains('lib/**')));
  });

  test('application directives never reference vendor locale provenance', () {
    final directive = RegExp(
      r'''^\s*(?:import|export|part)\s+[^;]+;''',
      multiLine: true,
    );
    final literal = RegExp(r'''[\'"]([^\'"]+)[\'"]''');
    final offenders = <String>[];
    for (final root in ['lib', 'test']) {
      for (final file in Directory(root).listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        for (final statement in directive.allMatches(file.readAsStringSync())) {
          for (final match in literal.allMatches(statement[0]!)) {
            final uri = match[1]!;
            if (Uri.parse(uri).pathSegments.contains('upstream_l10n')) {
              offenders.add('${file.path}: $uri');
            }
          }
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('every generated locale exposes and evaluates every source message', () {
    final arbByLocale = <String, Map<String, dynamic>>{
      for (final locale in lookups.keys)
        locale:
            jsonDecode(File('arb/intl_$locale.arb').readAsStringSync())
                as Map<String, dynamic>,
    };
    final expectedKeys = arbByLocale['en']!.keys
        .where((key) => !key.startsWith('@'))
        .toSet();

    for (final entry in lookups.entries) {
      final locale = entry.key;
      final lookup = entry.value;
      final messages = lookup.messages;
      expect(
        messages.keys.toSet(),
        expectedKeys,
        reason: '$locale generated messages must match the English contract',
      );

      for (final key in expectedKeys) {
        final template = arbByLocale['en']![key] as String;
        final placeholderNames = RegExp(
          r'\{([A-Za-z_][A-Za-z0-9_]*)\s*[,}]',
        ).allMatches(template).map((match) => match.group(1)).toSet();
        final argumentCount = placeholderNames.length;
        final arguments = List<dynamic>.filled(argumentCount, 2);
        late final dynamic translated;
        try {
          translated = Function.apply(messages[key]! as Function, arguments);
        } on NoSuchMethodError catch (error) {
          fail('$locale.$key has mismatched placeholder metadata: $error');
        }

        expect(
          translated,
          isA<String>(),
          reason: '$locale.$key must evaluate to text',
        );
        expect(
          translated as String,
          isNotEmpty,
          reason: '$locale.$key must not be empty',
        );
      }
    }
  });
}

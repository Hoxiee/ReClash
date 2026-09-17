import 'dart:convert';
import 'dart:io';

import 'package:reclash/l10n/intl/messages_en.dart' as messages_en;
import 'package:reclash/l10n/intl/messages_ja.dart' as messages_ja;
import 'package:reclash/l10n/intl/messages_kk.dart' as messages_kk;
import 'package:reclash/l10n/intl/messages_ko.dart' as messages_ko;
import 'package:reclash/l10n/intl/messages_tk.dart' as messages_tk;
import 'package:reclash/l10n/intl/messages_uz.dart' as messages_uz;
import 'package:reclash/l10n/intl/messages_ru.dart' as messages_ru;
import 'package:reclash/l10n/intl/messages_zh_CN.dart' as messages_zh_cn;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/message_lookup_by_library.dart';

void main() {
  final lookups = <String, MessageLookupByLibrary>{
    'en': messages_en.messages,
    'ja': messages_ja.messages,
    'kk': messages_kk.messages,
    'ko': messages_ko.messages,
    'tk': messages_tk.messages,
    'uz': messages_uz.messages,
    'ru': messages_ru.messages,
    'zh_CN': messages_zh_cn.messages,
  };

  test('client compatibility copy avoids misleading terminology', () {
    final forbidden = RegExp(
      'эмуляци|emulation|emulýasiýa|emulyatsiya|エミュレーション|에뮬레이션|模拟',
      caseSensitive: false,
    );
    for (final locale in lookups.keys) {
      final source =
          jsonDecode(File('arb/intl_$locale.arb').readAsStringSync())
              as Map<String, dynamic>;
      for (final entry in source.entries) {
        if (entry.value is! String) continue;
        expect(
          forbidden.hasMatch(entry.value as String),
          isFalse,
          reason: '$locale.${entry.key}',
        );
      }
    }
    final russian =
        jsonDecode(File('arb/intl_ru.arb').readAsStringSync())
            as Map<String, dynamic>;
    expect(russian['roleAuthor'], 'Автор и мейнтейнер');
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
        // A name is a placeholder only where ICU ends it: a plural branch such
        // as `other{Your subscription…}` opens with a word, not an argument.
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

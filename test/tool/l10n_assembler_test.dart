import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../tool/assemble_l10n.dart';

void main() {
  late Directory root;
  late Directory arb;
  late LocalizationAssembler assembler;

  setUp(() {
    root = Directory.systemTemp.createTempSync('l10n-assembler-');
    arb = Directory('${root.path}/arb')..createSync();
    assembler = LocalizationAssembler(root);
  });

  tearDown(() => root.deleteSync(recursive: true));

  void writeArb(String path, String source) {
    final file = File('${arb.path}/$path');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
  }

  void writeUpstream(String localeFile, String source) {
    final file = File('${root.path}/arb_upstream/$localeFile');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
  }

  test(
    'write creates flat ARBs from upstream before feature fragments exist',
    () {
      arb.deleteSync();
      writeUpstream('intl_en.arb', '{"hello":"Hello"}');

      assembler.write();

      expect(
        File('${arb.path}/intl_en.arb').readAsStringSync(),
        '{\n  "hello": "Hello"\n}\n',
      );
    },
  );

  test('merges feature-owned messages and explicit base overrides', () {
    writeUpstream(
      'intl_en.arb',
      '{"hello":"Hello","shared":"Upstream","removed":"Old","@shared":{"description":"base"}}',
    );
    writeUpstream(
      'intl_es.arb',
      '{"hello":"Hola","shared":"Origen","removed":"Antiguo","@shared":{"description":"base"}}',
    );
    writeArb(
      'fragments/identity.branding/intl_en.arb',
      '{"shared":"ReClash","@shared":{"description":"brand"},"removed":null}',
    );
    writeArb(
      'fragments/identity.branding/intl_es.arb',
      '{"shared":"ReClash","@shared":{"description":"marca"},"removed":null}',
    );
    writeArb('fragments/tools.catalog/intl_en.arb', '{"tool":"Tool"}');
    writeArb('fragments/tools.catalog/intl_es.arb', '{"tool":"Herramienta"}');

    final output = assembler.assemble();
    final en = jsonDecode(output['intl_en.arb']!) as Map<String, dynamic>;
    expect(en['hello'], 'Hello');
    expect(en['shared'], 'ReClash');
    expect(en['@shared'], {'description': 'brand'});
    expect(en.containsKey('removed'), isFalse);
    expect(en['tool'], 'Tool');
    expect(output, assembler.assemble());
  });

  test('uses a locale baseline when upstream has no matching locale', () {
    writeUpstream('intl_en.arb', '{"hello":"Hello"}');
    writeArb('locales/intl_kk.arb', '{"hello":"Сәлем"}');
    writeArb('fragments/locale.support/intl_en.arb', '{"kazakh":"Kazakh"}');
    writeArb('fragments/locale.support/intl_kk.arb', '{"kazakh":"Қазақша"}');

    final output = assembler.assemble();
    expect(jsonDecode(output['intl_kk.arb']!) as Map<String, dynamic>, {
      'hello': 'Сәлем',
      'kazakh': 'Қазақша',
    });
  });

  test('a fragment-only locale falls back to English and honors removals', () {
    writeUpstream('intl_en.arb', '{"hello":"Hello","removed":"Old"}');
    writeArb('fragments/identity.branding/intl_zh_CN.arb', '{"removed":null}');

    final output = assembler.assemble();
    expect(jsonDecode(output['intl_zh_CN.arb']!) as Map<String, dynamic>, {
      'hello': 'Hello',
    });
  });

  test('rejects a key owned by more than one feature', () {
    writeUpstream('intl_en.arb', '{"hello":"Hello"}');
    writeArb('fragments/feature-a/intl_en.arb', '{"one":"One"}');
    writeArb('fragments/feature-b/intl_en.arb', '{"one":"Uno"}');

    expect(
      () => assembler.assemble(),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Duplicate fragment key one'),
        ),
      ),
    );
  });

  test('rejects a duplicate key in one fragment file', () {
    writeUpstream('intl_en.arb', '{"hello":"Hello"}');
    writeArb(
      'fragments/feature-a/intl_en.arb',
      '{"one":"One","one":"Duplicate"}',
    );

    expect(() => assembler.assemble(), throwsA(isA<YamlException>()));
  });

  test('fills missing locale messages from English', () {
    writeUpstream('intl_en.arb', '{"hello":"Hello","world":"World"}');
    writeUpstream('intl_es.arb', '{"hello":"Hola"}');

    final output = assembler.assemble();
    expect(jsonDecode(output['intl_es.arb']!) as Map<String, dynamic>, {
      'hello': 'Hola',
      'world': 'World',
    });
  });

  test('a locale removal suppresses the English fallback', () {
    writeUpstream('intl_en.arb', '{"hello":"Hello","bye":"Bye"}');
    writeUpstream('intl_es.arb', '{"hello":"Hola"}');
    writeArb('fragments/retired/intl_es.arb', '{"bye":null}');

    final output = assembler.assemble();
    expect(jsonDecode(output['intl_es.arb']!) as Map<String, dynamic>, {
      'hello': 'Hola',
    });
  });

  test('rejects locale keys that English does not have', () {
    writeUpstream('intl_en.arb', '{"hello":"Hello"}');
    writeUpstream('intl_es.arb', '{"hello":"Hola","extra":"Extra"}');

    expect(
      () => assembler.assemble(),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('missing from English'),
        ),
      ),
    );
  });

  test('check mode reports a stale assembled file', () {
    writeUpstream('intl_en.arb', '{"hello":"Hello"}');
    writeArb('intl_en.arb', '{"hello":"Stale"}\n');

    expect(
      assembler.check,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('intl_en.arb is stale'),
        ),
      ),
    );
  });
}

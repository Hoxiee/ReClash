import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('desyncArgsFromText', () {
    test('splits on whitespace', () {
      expect(
        desyncArgsFromText('-A torst,conn -L s,o --split 1'),
        ['-A', 'torst,conn', '-L', 's,o', '--split', '1'],
      );
    });

    test('a quoted value with spaces stays one token', () {
      expect(
        desyncArgsFromText("-l '/storage/emulated/0/Download/g.bin' -t 8"),
        ['-l', '/storage/emulated/0/Download/g.bin', '-t', '8'],
      );
    });

    test('an unterminated quote throws', () {
      expect(() => desyncArgsFromText("-l 'g.bin"), throwsFormatException);
    });

    test('an empty line yields no tokens', () {
      expect(desyncArgsFromText('   \n  '), isEmpty);
    });
  });

  group('desyncArgsToText', () {
    test('quotes only what whitespace would split', () {
      expect(
        desyncArgsToText(['--split', '1', '/path with spaces/g.bin']),
        "--split 1 '/path with spaces/g.bin'",
      );
    });

    test('round trips every token of the default strategy', () {
      expect(
        desyncArgsFromText(desyncArgsToText(desyncDefaultStrategy)),
        desyncDefaultStrategy,
      );
    });
  });

  group('desyncDefaultStrategy', () {
    // The ByeByeDPI tester's top preset on a live network: fake- and oob-free,
    // since those families trip the TSPU's fake-packet detectors.
    test('is a split/disorder ladder without fake or oob', () {
      expect(desyncDefaultStrategy.where((t) => t.startsWith('-d')), isNotEmpty);
      expect(desyncDefaultStrategy.where((t) => t.startsWith('-s')), isNotEmpty);
      expect(
        desyncDefaultStrategy.where(
          (t) => t.startsWith('-f') || t.startsWith('-o') || t.startsWith('-q'),
        ),
        isEmpty,
      );
    });
  });
}

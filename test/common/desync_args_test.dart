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
    test('no method runs before the first trigger group', () {
      expect(desyncDefaultStrategy.first, '-A');
    });

    test('every rung carries its own trigger group and auto mode', () {
      expect(desyncDefaultStrategy.where((t) => t == '-A').length, 5);
      expect(desyncDefaultStrategy.where((t) => t == '-L').length, 5);
    });
  });
}

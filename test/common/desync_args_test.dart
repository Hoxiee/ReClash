import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('desyncArgsFromText', () {
    test('splits on whitespace', () {
      expect(desyncArgsFromText('-A torst,conn -L s,o --split 1'), [
        '-A',
        'torst,conn',
        '-L',
        's,o',
        '--split',
        '1',
      ]);
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

    test('empty quotes carry an empty token', () {
      expect(desyncArgsFromText('-l "" -t 8'), ['-l', '', '-t', '8']);
    });

    test('a backslash escapes a space', () {
      expect(desyncArgsFromText(r'-l /a\ b.bin'), ['-l', '/a b.bin']);
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

  group('desyncValidateArgs', () {
    test('accepts the default strategy and every preset', () {
      expect(desyncValidateArgs(desyncDefaultStrategy), isEmpty);
      for (final preset in desyncTestPresets) {
        expect(
          desyncValidateArgs(desyncTestArgs(preset)),
          isEmpty,
          reason: preset,
        );
      }
    });

    test('flags app-owned options', () {
      final issues = desyncValidateArgs(['-d1', '-p', '9050']);
      expect(issues, hasLength(1));
      expect(issues.single.kind, DesyncArgsIssueKind.appOwnedFlag);
      expect(issues.single.token, '-p');
    });

    test('rejects an unknown flag', () {
      final issues = desyncValidateArgs(['-J', '1']);
      expect(issues.single.kind, DesyncArgsIssueKind.unknownFlag);
    });

    test('rejects a value flag without a value', () {
      final issues = desyncValidateArgs(['-d1', '--split']);
      expect(issues.single.kind, DesyncArgsIssueKind.missingValue);
    });

    test('rejects a positional token', () {
      final issues = desyncValidateArgs(['torst,conn']);
      expect(issues.single.kind, DesyncArgsIssueKind.positional);
    });
  });

  group('desyncDefaultStrategy', () {
    // The ByeByeDPI tester's top preset on a live network: fake- and oob-free,
    // since those families trip the TSPU's fake-packet detectors.
    test('is a split/disorder ladder without fake or oob', () {
      expect(
        desyncDefaultStrategy.where((t) => t.startsWith('-d')),
        isNotEmpty,
      );
      expect(
        desyncDefaultStrategy.where((t) => t.startsWith('-s')),
        isNotEmpty,
      );
      expect(
        desyncDefaultStrategy.where(
          (t) => t.startsWith('-f') || t.startsWith('-o') || t.startsWith('-q'),
        ),
        isEmpty,
      );
    });
  });
}

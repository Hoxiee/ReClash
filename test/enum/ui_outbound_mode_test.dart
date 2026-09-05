import 'package:reclash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UiOutboundModeExt', () {
    test('auto reads as rule to the core, the rest map one to one', () {
      expect(UiOutboundMode.auto.coreMode, Mode.rule);
      expect(UiOutboundMode.rule.coreMode, Mode.rule);
      expect(UiOutboundMode.global.coreMode, Mode.global);
      expect(UiOutboundMode.direct.coreMode, Mode.direct);
    });

    test('only auto carries the engine flag', () {
      expect(UiOutboundMode.auto.smartRouting, isTrue);
      expect(UiOutboundMode.rule.smartRouting, isFalse);
      expect(UiOutboundMode.global.smartRouting, isFalse);
      expect(UiOutboundMode.direct.smartRouting, isFalse);
    });
  });

  group('ModeUiExt', () {
    test('rule with the engine on is the only way to read as auto', () {
      expect(Mode.rule.uiMode(smartRouting: true), UiOutboundMode.auto);
      expect(Mode.rule.uiMode(smartRouting: false), UiOutboundMode.rule);
      expect(Mode.global.uiMode(smartRouting: true), UiOutboundMode.global);
      expect(Mode.direct.uiMode(smartRouting: true), UiOutboundMode.direct);
    });

    test('every core mode round-trips through the ui vocabulary', () {
      for (final mode in Mode.values) {
        final ui = mode.uiMode(smartRouting: false);
        expect(ui.coreMode, mode);
      }
    });

    test('a ui pick carries exactly what the core needs', () {
      for (final ui in UiOutboundMode.values) {
        expect(ui.coreMode.uiMode(smartRouting: ui.smartRouting), ui);
      }
    });
  });
}

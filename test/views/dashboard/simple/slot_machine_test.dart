import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/views/dashboard/simple/slot_machine.dart';

import '../../../helpers/test_app.dart';

class _FixedDraw extends SlotDraw {
  _FixedDraw(this.spins);

  final List<List<int>> spins;

  @override
  List<int> next() => spins.removeAt(0);
}

Widget _machine({
  required SlotDraw draw,
  required VoidCallback onPressed,
  PowerLink link = PowerLink.off,
  bool spinToStart = true,
}) => TestApp(
  locale: const Locale('en'),
  child: Scaffold(
    body: Center(
      child: SlotMachine(
        link: link,
        size: 240,
        label: 'Spin',
        spinToStart: spinToStart,
        onPressed: onPressed,
        draw: draw,
      ),
    ),
  ),
);

void main() {
  group('SlotDraw', () {
    test('pays out by the pity spin at the latest', () {
      for (var seed = 0; seed < 50; seed++) {
        final draw = SlotDraw(math.Random(seed));
        var spins = 0;
        while (!isJackpot(draw.next())) {
          spins++;
        }
        expect(spins, lessThan(SlotDraw.pity), reason: 'seed $seed');
      }
    });

    test('a losing draw never shows 777', () {
      final draw = SlotDraw(math.Random(1));
      for (var i = 0; i < 500; i++) {
        expect(isJackpot(draw.losing()), isFalse);
      }
    });
  });

  group('SlotMachine', () {
    testWidgets('starts only once the reels land on 777', (tester) async {
      var starts = 0;
      await tester.pumpWidget(
        _machine(
          draw: _FixedDraw([
            [0, 0, 3],
            [0, 0, 0],
          ]),
          onPressed: () => starts++,
        ),
      );
      await tester.tap(find.byType(SlotMachine));
      await tester.pumpAndSettle();
      expect(starts, 0);
      expect(find.text('SO CLOSE!'), findsOneWidget);

      await tester.tap(find.byType(SlotMachine));
      await tester.pumpAndSettle();
      expect(starts, 1);
      expect(find.text('JACKPOT!'), findsOneWidget);
    });

    testWidgets('a won start that did not run is retried without a spin', (
      tester,
    ) async {
      var starts = 0;
      final draw = _FixedDraw([
        [0, 0, 0],
      ]);
      await tester.pumpWidget(_machine(draw: draw, onPressed: () => starts++));
      await tester.tap(find.byType(SlotMachine));
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        _machine(
          draw: draw,
          link: PowerLink.connecting,
          onPressed: () => starts++,
        ),
      );
      await tester.pumpWidget(_machine(draw: draw, onPressed: () => starts++));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SlotMachine));
      await tester.pumpAndSettle();
      expect(starts, 2);
    });

    testWidgets('any other action runs on a plain tap', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _machine(
          draw: _FixedDraw([]),
          link: PowerLink.on,
          spinToStart: false,
          onPressed: () => presses++,
        ),
      );
      await tester.tap(find.byType(SlotMachine));
      await tester.pump();
      expect(presses, 1);
    });
  });
}

import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/widgets/nav/nav_slots.dart';

class _ManualVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

void main() {
  final spring = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 300),
  );

  NavSlots<String> make() => NavSlots<String>(
    vsync: _ManualVSync(),
    spring: spring,
    reduceMotion: true,
  );

  List<String> keysOf(NavSlots<String> slots) =>
      slots.slots.map((slot) => slot.key).toList();

  test('a key that returns before it sweeps is not duplicated', () {
    final slots = make();
    slots.seed(['a', 'b', 'c']);

    slots.sync(['a', 'c']);
    slots.sync(['a', 'b', 'c']);

    expect(keysOf(slots), ['a', 'b', 'c']);
    expect(keysOf(slots).toSet().length, keysOf(slots).length);
  });

  test('a head key that returns before it sweeps is not duplicated', () {
    final slots = make();
    slots.seed(['a', 'b', 'c']);

    slots.sync(['b', 'c']);
    slots.sync(['a', 'b', 'c']);

    expect(keysOf(slots), ['a', 'b', 'c']);
    expect(keysOf(slots).toSet().length, keysOf(slots).length);
  });

  test('repeated toggling never accumulates slots', () async {
    final slots = make();
    slots.seed(['a', 'b', 'c']);

    for (var i = 0; i < 5; i++) {
      slots.sync(['a', 'c']);
      await Future<void>.delayed(Duration.zero);
      slots.sync(['a', 'b', 'c']);
      await Future<void>.delayed(Duration.zero);
    }

    expect(keysOf(slots), ['a', 'b', 'c']);
  });

  test('a removed key collapses out after its weight settles', () async {
    final slots = make();
    slots.seed(['a', 'b', 'c']);

    slots.sync(['a', 'c']);
    await Future<void>.delayed(Duration.zero);

    expect(keysOf(slots), ['a', 'c']);
  });
}

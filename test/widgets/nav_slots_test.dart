import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/ui/nav_slots.dart';

class _SlotsHost extends StatefulWidget {
  const _SlotsHost({required this.onReady});

  final ValueChanged<NavSlots<String>> onReady;

  @override
  State<_SlotsHost> createState() => _SlotsHostState();
}

class _SlotsHostState extends State<_SlotsHost> with TickerProviderStateMixin {
  late final NavSlots<String> slots = NavSlots<String>(
    vsync: this,
    spring: const SpringDescription(mass: 1, stiffness: 300, damping: 30),
  );

  @override
  void initState() {
    super.initState();
    widget.onReady(slots);
  }

  @override
  void dispose() {
    slots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  late NavSlots<String> slots;

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(_SlotsHost(onReady: (value) => slots = value));
  }

  testWidgets('revives a leaving slot without duplicating it', (tester) async {
    await mount(tester);
    slots.seed(['a', 'b', 'c']);
    final b = slots.slots[1];

    slots.sync(['a', 'c']);
    expect(b.leaving, isTrue);
    slots.sync(['a', 'b', 'b', 'c']);

    expect(slots.slots.where((slot) => slot.key == 'b'), hasLength(1));
    expect(slots.slots[1], same(b));
    expect(b.leaving, isFalse);
    expect(b.weight.target, 1);
  });

  testWidgets('keeps orphan slots when their anchor is removed', (
    tester,
  ) async {
    await mount(tester);
    slots.seed(['a', 'b', 'c', 'd']);

    slots.sync(['a', 'c', 'd']);
    slots.sync(['c', 'd']);

    expect(slots.slots.map((slot) => slot.key).toSet(), {'a', 'b', 'c', 'd'});
    expect(slots.slots.where((slot) => slot.leaving), hasLength(2));
  });

  testWidgets('keeps a leaving slot between its anchor and successor', (
    tester,
  ) async {
    await mount(tester);
    slots.seed(['a', 'b', 'c']);

    slots.sync(['a', 'c']);
    slots.sync(['a', 'c']);

    expect(slots.slots.map((slot) => slot.key), ['a', 'b', 'c']);
    expect(slots.slots[1].leaving, isTrue);
  });

  testWidgets('does not notify for an unchanged live set', (tester) async {
    await mount(tester);
    slots.seed(['a', 'b']);
    var notifications = 0;
    slots.addListener(() => notifications++);

    slots.sync(['a', 'b']);

    expect(notifications, 0);
  });

  testWidgets('reorders live keys without duplicate slots', (tester) async {
    await mount(tester);
    slots.seed(['a', 'b', 'c']);

    slots.sync(['c', 'b', 'a']);

    expect(slots.slots.map((slot) => slot.key), ['c', 'b', 'a']);
    expect(slots.slots.map((slot) => slot.key).toSet(), hasLength(3));
  });

  testWidgets('reduced motion settles in-flight transitions', (tester) async {
    await mount(tester);
    slots.seed(['a', 'b']);
    slots.sync(['b', 'c']);
    slots.reduceMotion = true;

    expect(slots.slots.first.weight.value, 0);
    expect(slots.slots.last.weight.value, 1);
    await tester.pump();
    expect(slots.slots.map((slot) => slot.key), ['b', 'c']);
  });

  testWidgets('disposing active transitions leaves no ticker work', (
    tester,
  ) async {
    await mount(tester);
    slots.seed(['a', 'b']);
    slots.reduceMotion = true;
    slots.sync(['b', 'c']);
    await tester.pump(const Duration(milliseconds: 16));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });
}

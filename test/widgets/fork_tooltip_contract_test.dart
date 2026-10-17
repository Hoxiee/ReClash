import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/ui/tooltip.dart';

void main() {
  testWidgets('hover reveals the hint only after the shared delay', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTooltip(
            message: 'Contract hint',
            child: SizedBox(key: Key('target'), width: 48, height: 48),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('target'))));
    await tester.pump();
    await tester.pump(AppTooltipTiming.wait - const Duration(milliseconds: 1));
    expect(find.text('Contract hint'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(AppTooltipTiming.enterAnimation);
    expect(find.text('Contract hint'), findsOneWidget);
  });

  testWidgets('disposing a pending tooltip cancels its presentation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTooltip(
            message: 'Contract hint',
            child: SizedBox(key: Key('target'), width: 48, height: 48),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('target'))));
    await tester.pump();
    await tester.pump(AppTooltipTiming.adjacent ~/ 2);
    expect(find.text('Contract hint'), findsNothing);
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(AppTooltipTiming.wait);
    expect(find.text('Contract hint'), findsNothing);
  });
}

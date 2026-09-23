import 'dart:ui' as ui;

import 'package:reclash/widgets/theme/profile_patina.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('dust leaves from the touch and disappears after 600 ms', (
    tester,
  ) async {
    final level = ValueNotifier<double>(3);
    addTearDown(level.dispose);
    const key = ValueKey('patina-raster');
    await tester.pumpWidget(
      TestApp(
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: ValueListenableBuilder<double>(
              valueListenable: level,
              builder: (_, value, _) => ProfilePatina(
                level: value,
                reduceMotion: false,
                child: const SizedBox(width: 320, height: 120),
              ),
            ),
          ),
        ),
      ),
    );
    Future<List<int>> pixels() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(key),
      );
      return (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        image.dispose();
        return bytes!.buffer.asUint8List().toList();
      }))!;
    }

    await tester.pump();
    final initial = await pixels();
    final rect = tester.getRect(find.byKey(key));
    await tester.tapAt(rect.topLeft + const Offset(10, 60));
    level.value = 0;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final left = await pixels();
    expect(left, isNot(initial));
    await tester.pump(const Duration(milliseconds: 300));
    final clean = await pixels();
    level.value = 3;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tapAt(rect.topLeft + const Offset(310, 60));
    level.value = 0;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(await pixels(), isNot(left));
    await tester.pump(const Duration(milliseconds: 300));
    expect(await pixels(), clean);
  });

  testWidgets('reduced motion removes dust without a ticker', (tester) async {
    Future<void> show(double level) => tester.pumpWidget(
      TestApp(
        child: ProfilePatina(
          level: level,
          reduceMotion: true,
          child: const SizedBox(width: 320, height: 120),
        ),
      ),
    );
    await show(3);
    await show(0);
    expect(tester.hasRunningAnimations, isFalse);
  });
}

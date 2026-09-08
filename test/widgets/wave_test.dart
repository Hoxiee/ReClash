import 'dart:ui' show PictureRecorder;

import 'package:reclash/widgets/wave.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

WavePainter _painter({
  double animationValue = 0.0,
  double waveAmplitude = 50.0,
  double waveFrequency = 1.5,
  Color waveColor = const Color(0xFF112233),
}) {
  return WavePainter(
    animationValue: animationValue,
    waveAmplitude: waveAmplitude,
    waveFrequency: waveFrequency,
    waveColor: waveColor,
  );
}

void main() {
  group('WavePainter.shouldRepaint', () {
    test('is false for an identical configuration', () {
      expect(_painter().shouldRepaint(_painter()), isFalse);
    });

    test('is true when any input changes', () {
      final base = _painter();
      expect(base.shouldRepaint(_painter(animationValue: 0.5)), isTrue);
      expect(base.shouldRepaint(_painter(waveAmplitude: 10)), isTrue);
      expect(base.shouldRepaint(_painter(waveFrequency: 3)), isTrue);
      expect(
        base.shouldRepaint(_painter(waveColor: const Color(0xFFAABBCC))),
        isTrue,
      );
    });
  });

  group('WavePainter.paint', () {
    test('fills a closed path down to the bottom of the canvas', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(200, 120);

      _painter(animationValue: 0.25).paint(canvas, size);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
      picture.dispose();
    });

    test('repainting reuses the painter without accumulating path state', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = _painter();

      painter.paint(canvas, const Size(200, 120));
      painter.paint(canvas, const Size(200, 120));

      recorder.endRecording().dispose();
    });
  });

  group('WaveView', () {
    testWidgets('paints and keeps animating while mounted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: WaveView(waveColor: Color(0xFF00FF00)),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);

      final before = tester
          .widget<CustomPaint>(
            find
                .descendant(
                  of: find.byType(WaveView),
                  matching: find.byType(CustomPaint),
                )
                .first,
          )
          .painter;

      await tester.pump(const Duration(milliseconds: 500));

      final after = tester
          .widget<CustomPaint>(
            find
                .descendant(
                  of: find.byType(WaveView),
                  matching: find.byType(CustomPaint),
                )
                .first,
          )
          .painter;

      expect(
        (before! as WavePainter).animationValue,
        isNot((after! as WavePainter).animationValue),
      );
    });

    testWidgets('applies a changed duration immediately while animating', (
      tester,
    ) async {
      Widget buildApp(Duration duration) {
        return MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: WaveView(
                waveColor: const Color(0xFF00FF00),
                duration: duration,
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildApp(const Duration(seconds: 2)));
      await tester.pump(const Duration(milliseconds: 500));

      double animationValue() {
        return (tester
                    .widget<CustomPaint>(
                      find
                          .descendant(
                            of: find.byType(WaveView),
                            matching: find.byType(CustomPaint),
                          )
                          .first,
                    )
                    .painter!
                as WavePainter)
            .animationValue;
      }

      expect(animationValue(), closeTo(0.25, 0.001));

      await tester.pumpWidget(buildApp(const Duration(seconds: 4)));
      await tester.pump(const Duration(seconds: 1));

      // With the 4s period applied immediately, phase 0.25 advances by 1s/4s.
      expect(animationValue(), closeTo(0.5, 0.001));
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes its controller without leaking a ticker', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: WaveView(waveColor: Color(0xFF00FF00)),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      expect(find.byType(WaveView), findsNothing);
      expect(tester.takeException(), null);
    });

    testWidgets('does not animate when animations are disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            );
          },
          home: const Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: WaveView(waveColor: Color(0xFF00FF00)),
            ),
          ),
        ),
      );

      expect(tester.hasRunningAnimations, isFalse);

      final before = tester
          .widget<CustomPaint>(
            find
                .descendant(
                  of: find.byType(WaveView),
                  matching: find.byType(CustomPaint),
                )
                .first,
          )
          .painter;

      await tester.pump(const Duration(milliseconds: 500));

      final after = tester
          .widget<CustomPaint>(
            find
                .descendant(
                  of: find.byType(WaveView),
                  matching: find.byType(CustomPaint),
                )
                .first,
          )
          .painter;

      expect(
        (before! as WavePainter).animationValue,
        (after! as WavePainter).animationValue,
      );
    });

    testWidgets('stops and resumes under TickerMode changes', (tester) async {
      Widget buildApp({required bool enabled}) {
        return MaterialApp(
          home: Scaffold(
            body: TickerMode(
              enabled: enabled,
              child: const SizedBox(
                width: 300,
                height: 200,
                child: WaveView(waveColor: Color(0xFF00FF00)),
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildApp(enabled: true));
      await tester.pump(const Duration(milliseconds: 500));
      final before = tester
          .widget<CustomPaint>(
            find
                .descendant(
                  of: find.byType(WaveView),
                  matching: find.byType(CustomPaint),
                )
                .first,
          )
          .painter;

      await tester.pumpWidget(buildApp(enabled: false));
      await tester.pump(const Duration(milliseconds: 500));

      final muted = tester
          .widget<CustomPaint>(
            find
                .descendant(
                  of: find.byType(WaveView),
                  matching: find.byType(CustomPaint),
                )
                .first,
          )
          .painter;

      expect(
        (muted! as WavePainter).animationValue,
        (before! as WavePainter).animationValue,
      );

      await tester.pumpWidget(buildApp(enabled: true));
      await tester.pump(const Duration(milliseconds: 500));

      final resumed = tester
          .widget<CustomPaint>(
            find
                .descendant(
                  of: find.byType(WaveView),
                  matching: find.byType(CustomPaint),
                )
                .first,
          )
          .painter;

      expect(
        (resumed as WavePainter).animationValue,
        isNot((before as WavePainter).animationValue),
      );
    });
  });
}

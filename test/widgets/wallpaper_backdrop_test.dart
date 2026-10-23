import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/widgets/wallpaper.dart';

final _pixel = MemoryImage(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
  ),
);

Future<void> _precache(WidgetTester tester, ImageProvider image) async {
  await tester.runAsync(() async {
    final ready = Completer<void>();
    final stream = image.resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener(
      (info, _) {
        info.dispose();
        ready.complete();
      },
      onError: (Object error, StackTrace? stack) =>
          ready.completeError(error, stack),
    );
    stream.addListener(listener);
    try {
      await ready.future;
    } finally {
      stream.removeListener(listener);
    }
  });
}

void main() {
  testWidgets('wallpaper fade keeps the content element mounted', (
    tester,
  ) async {
    await _precache(tester, _pixel);
    await tester.pumpWidget(
      MaterialApp(
        home: WallpaperBackdrop(
          image: _pixel,
          settings: const WallpaperProps(enabled: true),
          baseColor: Colors.white,
          builder: (_, _) =>
              const Text('stable content', key: ValueKey('content')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final element = tester.element(find.byKey(const ValueKey('content')));
    await tester.pumpWidget(
      MaterialApp(
        home: WallpaperBackdrop(
          image: _pixel,
          settings: const WallpaperProps(enabled: false),
          baseColor: Colors.white,
          builder: (_, _) =>
              const Text('stable content', key: ValueKey('content')),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      tester.element(find.byKey(const ValueKey('content'))),
      same(element),
    );
    await tester.pumpAndSettle();
    expect(find.text('stable content'), findsOneWidget);
  });

  testWidgets('image replacement and no-image state retain the page', (
    tester,
  ) async {
    final replacement = MemoryImage(Uint8List.fromList(_pixel.bytes));
    await _precache(tester, _pixel);
    await _precache(tester, replacement);
    await tester.pumpWidget(
      MaterialApp(
        home: WallpaperBackdrop(
          image: _pixel,
          settings: const WallpaperProps(enabled: true),
          baseColor: Colors.white,
          builder: (_, _) => const Text('page remains'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(
      MaterialApp(
        home: WallpaperBackdrop(
          image: replacement,
          settings: const WallpaperProps(enabled: true),
          baseColor: Colors.white,
          builder: (_, _) => const Text('page remains'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('page remains'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: WallpaperBackdrop(
          image: null,
          settings: const WallpaperProps(enabled: false),
          baseColor: Colors.white,
          builder: (_, _) => const Text('page remains'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('page remains'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion completes wallpaper transition immediately', (
    tester,
  ) async {
    await _precache(tester, _pixel);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: WallpaperBackdrop(
            image: _pixel,
            settings: const WallpaperProps(enabled: true),
            baseColor: Colors.white,
            builder: (_, active) => Text('active:$active'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('active:true'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

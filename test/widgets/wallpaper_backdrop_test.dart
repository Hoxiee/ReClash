import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reclash/ui/wallpaper_image.dart';
import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/widgets/wallpaper.dart';

final _pixel = MemoryImage(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
  ),
);

const _svgMarkup =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1080 1920">'
    '<rect width="1080" height="1920" fill="#ff6b1a"/>'
    '</svg>';

class _PendingSvgLoader extends BytesLoader {
  final ready = Completer<ByteData>();

  @override
  Future<ByteData> loadBytes(BuildContext? context) => ready.future;
}

Future<void> _pumpSource(
  WidgetTester tester,
  WallpaperSource? image, {
  bool enabled = true,
}) => tester.pumpWidget(
  MaterialApp(
    home: WallpaperBackdrop(
      image: image,
      settings: WallpaperProps(enabled: enabled),
      baseColor: Colors.white,
      builder: (_, active) =>
          Text('active:$active', key: const ValueKey('page')),
    ),
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
  testWidgets('SVG отображается векторно и сохраняет страницу при смене фона', (
    tester,
  ) async {
    const image = SvgWallpaperSource(SvgStringLoader(_svgMarkup));
    await tester.runAsync(() => image.loader.loadBytes(null));
    await _pumpSource(tester, image);
    await tester.pump();
    await tester.runAsync(vg.waitForPendingDecodes);
    await tester.pumpAndSettle();
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.text('active:true'), findsOneWidget);
    final page = tester.element(find.byKey(const ValueKey('page')));

    await _pumpSource(tester, image, enabled: false);
    await tester.pumpAndSettle();
    expect(find.text('active:false'), findsOneWidget);
    expect(tester.element(find.byKey(const ValueKey('page'))), same(page));

    await _precache(tester, _pixel);
    await _pumpSource(tester, RasterWallpaperSource(_pixel));
    await tester.pumpAndSettle();
    expect(find.byType(SvgPicture), findsNothing);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);
    expect(tester.element(find.byKey(const ValueKey('page'))), same(page));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ошибка SVG оставляет обычный непрозрачный фон', (tester) async {
    final loader = _PendingSvgLoader();
    await _pumpSource(tester, SvgWallpaperSource(loader));
    expect(find.text('active:false'), findsOneWidget);
    loader.ready.completeError(const FormatException('Invalid SVG'));
    await tester.pumpAndSettle();
    expect(find.text('active:false'), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
    expect(tester.takeException(), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('устаревшая загрузка SVG не заменяет новый фон', (tester) async {
    final data = await tester.runAsync(
      () => const SvgStringLoader(_svgMarkup).loadBytes(null),
    );
    final loader = _PendingSvgLoader();
    await _pumpSource(tester, SvgWallpaperSource(loader));
    await _precache(tester, _pixel);
    await _pumpSource(tester, RasterWallpaperSource(_pixel));
    await tester.pumpAndSettle();
    loader.ready.complete(data!);
    await tester.pumpAndSettle();
    expect(find.byType(SvgPicture), findsNothing);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('завершение загрузки SVG после dispose не обновляет виджет', (
    tester,
  ) async {
    final loader = _PendingSvgLoader();
    await _pumpSource(tester, SvgWallpaperSource(loader));
    await tester.pumpWidget(const SizedBox.shrink());
    loader.ready.completeError(const FormatException('Invalid SVG'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('wallpaper fade keeps the content element mounted', (
    tester,
  ) async {
    await _precache(tester, _pixel);
    await tester.pumpWidget(
      MaterialApp(
        home: WallpaperBackdrop(
          image: RasterWallpaperSource(_pixel),
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
          image: RasterWallpaperSource(_pixel),
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
          image: RasterWallpaperSource(_pixel),
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
          image: RasterWallpaperSource(replacement),
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
            image: RasterWallpaperSource(_pixel),
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

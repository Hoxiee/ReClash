import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/manager/theme_manager.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';

import '../../test/helpers/app_paths.dart';
import '../../test/helpers/preferences.dart';
import '../../test/helpers/test_app.dart';

class _Cell {
  _Cell.fromJson(Map<String, dynamic> json)
    : size = Size(
        (json['width'] as num).toDouble(),
        (json['height'] as num).toDouble(),
      ),
      dark = json['theme'] == 'dark',
      locale = json['locale'] as String,
      fallback = (json['fallback'] as List).cast<String>(),
      path = json['path'] as String;

  final Size size;
  final bool dark;
  final String locale;
  final List<String> fallback;
  final String path;
}

/// Entry point of the harness `tool/preview.dart` generates for a scenario.
void runPreviews(
  String configPath, {
  required Widget Function() preview,
  List<Override> Function()? overrides,
  Future<void> Function()? prepare,
  Future<void> Function(WidgetTester tester)? act,
}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  final config =
      jsonDecode(File(configPath).readAsStringSync()) as Map<String, dynamic>;
  final pixelRatio = (config['pixelRatio'] as num).toDouble();
  final textScale = (config['textScale'] as num).toDouble();
  final fonts = (config['fonts'] as Map<String, dynamic>).map(
    (family, paths) => MapEntry(family, (paths as List).cast<String>()),
  );
  late Directory sandbox;

  setUpAll(() async {
    sandbox = await Directory.systemTemp.createTemp('reclash_preview_');
    await useAppPaths(sandbox);
    await mockPreferences();
    await _loadFonts(fonts);
  });
  tearDownAll(() => sandbox.delete(recursive: true));
  if (prepare != null) setUp(prepare);

  for (final json in config['cells'] as List) {
    final cell = _Cell.fromJson(json as Map<String, dynamic>);
    testWidgets(cell.path, (tester) async {
      debugDisableShadows = false;
      WidgetsApp.debugAllowBannerOverride = false;
      try {
        await _capture(
          tester,
          cell,
          pixelRatio: pixelRatio,
          textScale: textScale,
          preview: preview,
          overrides: overrides?.call() ?? const [],
          act: act,
        );
      } finally {
        debugDisableShadows = true;
        WidgetsApp.debugAllowBannerOverride = true;
      }
    });
  }
}

Future<void> _loadFonts(Map<String, List<String>> files) async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  final families = <String, List<Future<ByteData>>>{
    for (final entry in manifest.cast<Map<String, dynamic>>())
      entry['family'] as String: [
        for (final font
            in (entry['fonts'] as List).cast<Map<String, dynamic>>())
          rootBundle.load(font['asset'] as String),
      ],
  };
  for (final MapEntry(key: family, value: paths) in files.entries) {
    families.putIfAbsent(family, () => []).addAll([
      for (final path in paths)
        File(path).readAsBytes().then(ByteData.sublistView),
    ]);
  }
  await Future.wait([
    for (final MapEntry(key: family, value: data) in families.entries)
      data
          .fold(FontLoader(family), (loader, font) => loader..addFont(font))
          .load(),
  ]);
}

Locale _parseLocale(String value) {
  final parts = value.split(RegExp('[-_]'));
  return switch (parts.length) {
    1 => Locale(parts[0]),
    2 when parts[1].length == 4 => Locale.fromSubtags(
      languageCode: parts[0],
      scriptCode: parts[1],
    ),
    _ => Locale(parts[0], parts.last),
  };
}

ThemeData _withFallback(ThemeData theme, List<String> fallback) {
  final families = [
    ...?theme.textTheme.bodyMedium?.fontFamilyFallback,
    ...fallback,
  ];
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamilyFallback: families),
    primaryTextTheme: theme.primaryTextTheme.apply(
      fontFamilyFallback: families,
    ),
  );
}

Future<void> _capture(
  WidgetTester tester,
  _Cell cell, {
  required double pixelRatio,
  required double textScale,
  required Widget Function() preview,
  required List<Override> overrides,
  required Future<void> Function(WidgetTester tester)? act,
}) async {
  final dispatcher = tester.platformDispatcher;
  tester.view
    ..physicalSize = cell.size * pixelRatio
    ..devicePixelRatio = pixelRatio;
  dispatcher
    ..platformBrightnessTestValue = cell.dark
        ? Brightness.dark
        : Brightness.light
    ..textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(dispatcher.clearAllTestValues);

  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  globalState.container = container;
  container
    ..listen(appSettingProvider, (_, _) {})
    ..listen(themeSettingProvider, (_, _) {});
  container.read(viewSizeProvider.notifier).value = cell.size;
  container
      .read(themeSettingProvider.notifier)
      .update(
        (state) => state.copyWith(
          themeMode: cell.dark ? ThemeMode.dark : ThemeMode.light,
        ),
      );
  container
      .read(appSettingProvider.notifier)
      .update((state) => state.copyWith(locale: cell.locale));

  final boundary = GlobalKey();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(
        key: boundary,
        child: Consumer(
          builder: (context, ref, _) => TestApp(
            locale: _parseLocale(cell.locale),
            theme: _withFallback(
              watchAppTheme(ref, Brightness.light),
              cell.fallback,
            ),
            darkTheme: _withFallback(
              watchAppTheme(ref, Brightness.dark),
              cell.fallback,
            ),
            themeMode: cell.dark ? ThemeMode.dark : ThemeMode.light,
            homeBuilder: (child) => Builder(
              builder: (context) {
                final measure = Measure.of(context, textScale);
                globalState.measure = measure;
                return MeasureScope(measure: measure, child: child);
              },
            ),
            child: preview(),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
  if (act != null) {
    await act(tester);
    await _settle(tester);
  }

  final render =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await render.toImage(pixelRatio: pixelRatio);
    try {
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(cell.path).writeAsBytes(png!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

/// Caps frames per round, so an endless animation cannot hang the capture.
Future<void> _settle(WidgetTester tester) async {
  final requested = <ImageProvider>{};
  for (var round = 0; round < 3; round++) {
    await tester.pump();
    for (var i = 0; i < 50 && tester.binding.hasScheduledFrame; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    if (!await _precacheImages(tester, requested)) return;
  }
}

/// Image decoding only completes outside the fake-async zone.
Future<bool> _precacheImages(
  WidgetTester tester,
  Set<ImageProvider> requested,
) async {
  final pending = <(ImageProvider, BuildContext)>[];
  void collect(Element element) {
    final ImageProvider? provider = switch (element.widget) {
      Image(:final image) => image,
      DecoratedBox(decoration: BoxDecoration(image: final image?)) =>
        image.image,
      DecoratedBox(decoration: ShapeDecoration(image: final image?)) =>
        image.image,
      _ => null,
    };
    if (provider != null && requested.add(provider)) {
      pending.add((provider, element));
    }
    element.visitChildren(collect);
  }

  tester.binding.rootElement?.visitChildren(collect);
  if (pending.isEmpty) return false;
  await tester.runAsync(
    () => Future.wait([
      for (final (provider, context) in pending)
        precacheImage(provider, context, onError: (_, _) {}),
    ]),
  );
  return true;
}

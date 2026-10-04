import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/widgets/theme/wallpaper.dart';

// 1x1 PNGs, red and blue, so the backdrop has a decodable image to crossfade.
final _redPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
);
final _bluePng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGNgYPj/HwADAgH/5ncLrgAAAABJRU5ErkJggg==',
);

class _InitProbe extends StatefulWidget {
  const _InitProbe({required this.onInit});

  final VoidCallback onInit;

  @override
  State<_InitProbe> createState() => _InitProbeState();
}

class _InitProbeState extends State<_InitProbe> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  final imageA = MemoryImage(_redPng);
  final imageB = MemoryImage(_bluePng);
  const settings = WallpaperProps();

  Widget host(ValueNotifier<ImageProvider?> notifier, Widget child) {
    return MaterialApp(
      home: ValueListenableBuilder<ImageProvider?>(
        valueListenable: notifier,
        builder: (context, image, _) => WallpaperBackdrop(
          image: image,
          settings: settings,
          baseColor: const Color(0xFF101010),
          builder: (context, active) => child,
        ),
      ),
    );
  }

  testWidgets('keeps content mounted when a wallpaper appears and clears', (
    tester,
  ) async {
    var inits = 0;
    final notifier = ValueNotifier<ImageProvider?>(null);
    addTearDown(notifier.dispose);
    await tester.pumpWidget(host(notifier, _InitProbe(onInit: () => inits++)));
    expect(inits, 1);

    notifier.value = imageA;
    await tester.pumpAndSettle();
    expect(inits, 1, reason: 'content must not be reparented on fade-in');

    notifier.value = null;
    await tester.pumpAndSettle();
    expect(inits, 1, reason: 'content must not be reparented on fade-out');
  });

  testWidgets('active lingers until the fade-out finishes', (tester) async {
    final actives = <bool>[];
    final notifier = ValueNotifier<ImageProvider?>(imageA);
    addTearDown(notifier.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<ImageProvider?>(
          valueListenable: notifier,
          builder: (context, image, _) => WallpaperBackdrop(
            image: image,
            settings: settings,
            baseColor: const Color(0xFF101010),
            builder: (context, active) {
              actives.add(active);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(actives.last, isTrue);

    notifier.value = null;
    await tester.pump();
    expect(actives.last, isTrue, reason: 'stays active while fading out');

    await tester.pump(const Duration(milliseconds: 500));
    expect(actives.last, isFalse, reason: 'drops once the fade-out completes');
  });

  testWidgets('crossfades between two wallpapers without a gap', (
    tester,
  ) async {
    final notifier = ValueNotifier<ImageProvider?>(imageA);
    addTearDown(notifier.dispose);
    await tester.pumpWidget(host(notifier, const SizedBox()));
    await tester.pumpAndSettle();
    expect(find.byType(WallpaperLayer), findsOneWidget);

    notifier.value = imageB;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    // Mid-swap the outgoing and incoming layers overlap.
    expect(find.byType(WallpaperLayer), findsNWidgets(2));

    await tester.pumpAndSettle();
    expect(find.byType(WallpaperLayer), findsOneWidget);
  });
}

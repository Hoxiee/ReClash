import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';

import 'app_preview.dart' as app;

/// Records a walk through the app shell over the snapshot mock as numbered
/// PNG frames in `TOUR_FRAMES`, for ffmpeg to join into a GIF. The layout
/// comes from the same variables as app_preview.dart, the part from
/// `TOUR_PART`.
const _step = Duration(milliseconds: 40);
const _pace = 0.72;
final _dir = Directory(
  Platform.environment['TOUR_FRAMES'] ?? '.dart_tool/tour',
);
final _phone = Platform.environment['SNAPSHOT_PLATFORM'] == 'android';

/// `plain` walks the features on an unbranded subscription and switches to
/// Ember Line; `ember` and `halo` start on the profiles page with that one
/// current, as if just switched to it, and the first ends switching to Halo.
final _part = Platform.environment['TOUR_PART'] ?? 'plain';

Widget preview() => app.preview();

List<Override> previewOverrides() => app.previewOverrides();

Future<void> previewSetUp() => app.previewSetUp();

Future<void> previewAct(WidgetTester tester) async {
  await app.previewAct(tester);
  _dir.createSync(recursive: true);
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary).first,
  );
  final ratio = tester.view.devicePixelRatio;
  var index = 0;
  Future<void> frame() async {
    await tester.pump(_step);
    final path = '${_dir.path}/${(index++).toString().padLeft(5, '0')}.png';
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: ratio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      await File(path).writeAsBytes(png!.buffer.asUint8List());
    });
  }

  Future<void> hold(int ms) async {
    for (var t = 0; t < ms * _pace; t += _step.inMilliseconds) {
      await frame();
    }
  }

  Future<void> go(PageLabel page, int ms) async {
    globalState.container.read(currentPageLabelProvider.notifier).toPage(page);
    await hold(ms);
  }

  Future<void> scroll(Offset at, double dy, {int steps = 39}) async {
    final gesture = await tester.startGesture(at);
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(Offset(0, dy / steps));
      await frame();
    }
    await gesture.up();
    await hold(700);
  }

  Future<void> drag(Offset at, Offset by, {int steps = 10}) async {
    final gesture = await tester.startGesture(at);
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(by / steps.toDouble());
      await frame();
    }
    await gesture.up();
  }

  Future<void> tapText(String text, int ms) async {
    final found = find.text(text);
    final visible = found.hitTestable();
    await tester.tap(
      visible.evaluate().isEmpty ? found.last : visible.first,
      warnIfMissed: false,
    );
    await hold(ms);
  }

  Future<void> accent(int? color, int ms) async {
    globalState.container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(primaryColor: color));
    await hold(ms);
  }

  final l10n = tester.element(find.byType(Scaffold).first).appLocalizations;
  final size = tester.view.physicalSize / ratio;
  final content = _phone
      ? Offset(size.width / 2, size.height * 0.6)
      : const Offset(560, 560);

  if (_part != 'plain') {
    await hold(1400);
    await go(PageLabel.proxies, 2000);
    await go(PageLabel.dashboard, 2400);
    if (_phone) await tapText(l10n.simpleDashboardWidgets, 2400);
    if (_part == 'halo') {
      if (_phone) await tapText(l10n.simpleDashboardHome, 1600);
      return;
    }
    await go(PageLabel.profiles, 1200);
    await tapText('Halo', 1400);
    return;
  }
  await hold(2400);
  await go(PageLabel.proxies, 1800);
  await tapText(l10n.chainsAll, 2400);
  await _pop(tester);
  await hold(800);
  if (_phone) {
    await go(PageLabel.tools, 1000);
    await tapText(l10n.connections, 2200);
    await _pop(tester);
    await hold(700);
    await scroll(content, -420);
  } else {
    await go(PageLabel.connections, 2000);
    await go(PageLabel.tools, 1000);
  }
  await tapText(l10n.theme, 1400);
  await accent(defaultPrimaryColors[2], 1200);
  await accent(defaultPrimaryColors[6], 1400);
  final pane = _phone ? content : const Offset(960, 500);
  final swipe = _phone ? 300.0 : 520.0;
  for (final dx in [-swipe, -swipe, swipe, swipe]) {
    await drag(pane, Offset(dx, 0));
    await hold(1400);
  }
  if (_phone) {
    await _pop(tester);
    await hold(400);
  }
  await go(PageLabel.profiles, 2000);
  await tapText('Ember Line', 1400);
}

Future<void> _pop(WidgetTester tester) =>
    Navigator.of(tester.element(find.byType(Scaffold).last)).maybePop();

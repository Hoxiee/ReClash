import 'dart:io';

import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/window_manager.dart';
import 'package:reclash/pages/home.dart';
import 'package:reclash/providers/providers.dart';

import 'mock.dart' as mock;

/// The whole app shell over [mock] data. `SNAPSHOT_PAGE` names the page,
/// `SNAPSHOT_PLATFORM` the layout (`android`, `macos` or `linux`) and
/// `SNAPSHOT_DASHBOARD` the dashboard style; `tool/snapshots/render.sh` sets them.
final _env = Platform.environment;
final _page = PageLabel.values.byName(_env['SNAPSHOT_PAGE'] ?? 'dashboard');
final _platform = _env['SNAPSHOT_PLATFORM'] ?? 'linux';
final _dashboard = DashboardStyle.values.byName(
  _env['SNAPSHOT_DASHBOARD'] ?? 'detailed',
);

/// macOS draws its own window buttons over the sidebar, so the shell has no
/// header there; compose.py paints them.
Widget preview() => switch (_platform) {
  'android' => Builder(
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(platform: TargetPlatform.android),
      child: const HomePage(),
    ),
  ),
  'macos' => Builder(
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(platform: TargetPlatform.macOS),
      child: const HomePage(),
    ),
  ),
  _ => WindowHeaderLayout(
    height: kHeaderHeight,
    header: WindowHeaderBar(
      height: kHeaderHeight,
      onDragStart: () {},
      onDoubleTap: () {},
      leading: const WindowStatusIndicator(),
      actions: WindowHeaderActions(
        state: ValueNotifier(const WindowCaptionState()),
        onPin: () {},
        onMinimize: () {},
        onMaximize: () {},
        onClose: () {},
      ),
    ),
    child: const HomePage(),
  ),
};

List<Override> previewOverrides() => [
  ...mock.overrides(dashboard: _dashboard),
  currentPageLabelProvider.overrideWithBuild((_, _) => _page),
];

Future<void> previewSetUp() async {
  // ignore: invalid_use_of_visible_for_testing_member
  system.debugOperatingSystem = _platform;
  await mock.setUp();
}

/// A phone draws under its status and gesture bars.
Future<void> previewAct(WidgetTester tester) async {
  if (_platform != 'android') return;
  final ratio = tester.view.devicePixelRatio;
  tester.view.padding = FakeViewPadding(top: 36 * ratio, bottom: 16 * ratio);
  addTearDown(tester.view.resetPadding);
  await tester.pump();
}

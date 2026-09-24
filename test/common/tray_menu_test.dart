import 'dart:io';

import 'package:reclash/common/app/app_localizations.dart';
import 'package:reclash/common/app/app_ports.dart';
import 'package:reclash/common/util/constant.dart';
import 'package:reclash/common/desktop/tray.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/state.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tray/tray.dart';

const _channel = MethodChannel('tray');

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

TrayState _trayState({
  bool isStart = false,
  bool tunEnable = false,
  bool systemProxy = false,
  bool autoLaunch = false,
  bool showTrayTitle = false,
  Mode mode = Mode.rule,
  List<Group> groups = const [],
  Map<HotAction, HotKeyAction> hotKeys = const {},
}) {
  return TrayState(
    mode: mode,
    port: 7890,
    autoLaunch: autoLaunch,
    systemProxy: systemProxy,
    tunEnable: tunEnable,
    isStart: isStart,
    paused: false,
    groups: groups,
    selectedMap: const {},
    showTrayTitle: showTrayTitle,
    hotKeys: hotKeys,
  );
}

Map<Object?, Object?>? _itemByLabel(MethodCall? call, String label) {
  for (final item in _items(call)) {
    if (item['label'] == label) {
      return item;
    }
  }
  return null;
}

List<Map<Object?, Object?>> _items(MethodCall? call) {
  final menu = (call?.arguments as Map?)?['menu'] as List?;
  return menu?.cast<Map<Object?, Object?>>() ?? const [];
}

List<String> _labels(MethodCall? call) {
  return _items(call).map((item) => item['label']).whereType<String>().toList();
}

class _RecordingCommonAction extends CommonAction {
  static final calls = <String>[];

  @override
  void toggleRunning() => calls.add('running');

  @override
  void togglePaused() => calls.add('paused');
}

class _RecordingSystemAction extends SystemAction {
  static final calls = <String>[];

  @override
  Future<void> handleExit([bool needSave = true]) async {
    calls.add('exit');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> calls;
  late ProviderContainer container;
  late AppTray tray;

  late Directory root;

  setUpAll(() async {
    root = Directory.systemTemp.createTempSync('tray_menu_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
    await AppLocalizations.load(const Locale('en'));
  });

  tearDownAll(() {
    // The shared system temp dir is not exclusively ours; another suite running
    // alongside this one can take the tree out from under the teardown, either
    // before the check or between the check and the delete.
    try {
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    } on FileSystemException {
      return;
    }
  });

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    calls = [];
    tray = AppTray.forPlatform(isMacOS: true, isWindows: false);
    _RecordingCommonAction.calls.clear();
    _RecordingSystemAction.calls.clear();
    container = ProviderContainer(
      overrides: [
        commonActionProvider.overrideWith(_RecordingCommonAction.new),
        systemActionProvider.overrideWith(_RecordingSystemAction.new),
      ],
    );
    Tray.instance.resetForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    container.dispose();
    debugDefaultTargetPlatformOverride = null;
  });

  MethodCall? showCall() {
    for (final call in calls.reversed) {
      if (call.method == 'show') {
        return call;
      }
    }
    return null;
  }

  Future<void> select(String label) async {
    final item = _items(
      showCall(),
    ).firstWhere((item) => item['label'] == label);
    const codec = StandardMethodCodec();
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          _channel.name,
          codec.encodeMethodCall(
            MethodCall('onMenuItemSelected', {'id': item['id']}),
          ),
          null,
        );
  }

  Future<void> update(TrayState trayState, {AppTray? on}) {
    return (on ?? tray).update(
      trayState: trayState,
      traffic: const Traffic(),
      read: container.read,
    );
  }

  test(
    'SystemAction.updateTray builds the menu without reading itself',
    () async {
      globalState.container = container;
      trayPort = tray;
      addTearDown(() => trayPort = null);

      await container.read(systemActionProvider.notifier).updateTray();

      expect(showCall(), isNotNull);
      expect(_labels(showCall()), contains(currentAppLocalizations.exit));
    },
  );

  test('builds the stopped menu without the running-only toggles', () async {
    await update(_trayState());

    final labels = _labels(showCall());
    final l10n = currentAppLocalizations;
    expect(labels, contains(l10n.show));
    expect(labels, contains(l10n.start));
    expect(labels, contains(l10n.autoLaunch));
    expect(labels, contains(l10n.copyEnvVar));
    expect(labels, contains(l10n.exit));
    expect(labels, isNot(contains(l10n.tun)));
    expect(labels, isNot(contains(l10n.systemProxy)));
  });

  test('adds TUN and system proxy toggles once the core is running', () async {
    await update(_trayState(isStart: true));

    final labels = _labels(showCall());
    final l10n = currentAppLocalizations;
    expect(labels, contains(l10n.stop), reason: 'start flips to stop');
    expect(labels, contains(l10n.tun));
    expect(labels, contains(l10n.systemProxy));
  });

  test('offers every outbound mode as a menu entry', () async {
    await update(_trayState(mode: Mode.global));

    final checkedModes = _items(showCall())
        .where((item) => item['checked'] == true)
        .map((item) => item['label'])
        .toList();
    expect(checkedModes, contains(Intl.message(Mode.global.name)));
  });

  test('a bound hotkey surfaces as the menu item detail', () async {
    final binding = HotKeyAction(
      action: HotAction.copyEnv,
      key: PhysicalKeyboardKey.keyE.usbHidUsage,
      modifiers: const {KeyboardModifier.control},
    );
    await update(_trayState(hotKeys: {HotAction.copyEnv: binding}));

    final item = _itemByLabel(showCall(), currentAppLocalizations.copyEnvVar);
    expect(item, isNotNull);
    expect(item!['detail'], 'CTRL+E');
  });

  test('an unbound action leaves the menu item without a detail', () async {
    await update(_trayState());

    final item = _itemByLabel(showCall(), currentAppLocalizations.copyEnvVar);
    expect(item, isNotNull);
    expect(item!.containsKey('detail'), isFalse);
  });

  test('sends icon, tooltip and menu in a single show call', () async {
    await update(_trayState(isStart: true, tunEnable: true));

    final showCalls = calls.where((call) => call.method == 'show').toList();
    expect(showCalls, hasLength(1));

    final arguments = showCalls.single.arguments as Map;
    expect(arguments['toolTip'], appName);
    expect(arguments['menu'], isNotEmpty);
    final reps = ((arguments['icon'] as Map)['reps'] as List).cast<Map>();
    expect(reps.map((rep) => rep['scale']), containsAll([1.0, 2.0, 3.0, 4.0]));
    expect(reps.map((rep) => rep['bytes']), everyElement(isNotEmpty));
    expect((arguments['icon'] as Map)['isTemplate'], isTrue);
  });

  test('skips the platform call when the tray state is unchanged', () async {
    await update(_trayState(isStart: true));
    await update(_trayState(isStart: true));

    expect(calls.where((call) => call.method == 'show'), hasLength(1));
  });

  test('skips unchanged macOS tray titles', () async {
    final titles = <String>[];
    final titleTray = AppTray.forPlatform(
      isMacOS: true,
      isWindows: false,
      setTitle: (title) async => titles.add(title),
    );
    const traffic = Traffic(up: 1024, down: 2048);

    await titleTray.updateTitle(showTrayTitle: true, traffic: traffic);
    await titleTray.updateTitle(showTrayTitle: true, traffic: traffic);

    expect(titles, hasLength(1));
  });

  test('retries a macOS tray title after a platform failure', () async {
    var failures = 1;
    final titles = <String>[];
    final titleTray = AppTray.forPlatform(
      isMacOS: true,
      isWindows: false,
      setTitle: (title) async {
        titles.add(title);
        if (failures-- > 0) {
          throw PlatformException(code: 'set-title-failed');
        }
      },
    );
    const traffic = Traffic(up: 1024, down: 2048);

    await expectLater(
      titleTray.updateTitle(showTrayTitle: true, traffic: traffic),
      throwsA(isA<PlatformException>()),
    );
    await titleTray.updateTitle(showTrayTitle: true, traffic: traffic);

    expect(titles, hasLength(2));
  });

  test('menu item ids are stable across identical rebuilds', () async {
    await update(_trayState());
    final first = _items(showCall()).map((item) => item['id']).toList();

    Tray.instance.resetForTesting();
    calls.clear();

    await update(_trayState());
    final second = _items(showCall()).map((item) => item['id']).toList();

    expect(second, first);
    expect(first.first, 1024);
  });

  test('group submenus carry their proxies as nested items', () async {
    await update(
      _trayState(
        groups: [
          const Group(
            name: 'Proxy',
            type: GroupType.Selector,
            all: [Proxy(name: 'A', type: 'Direct')],
          ),
        ],
      ),
    );

    final submenu = _items(
      showCall(),
    ).firstWhere((item) => item['type'] == 'submenu');
    expect(submenu['label'], 'Proxy');
    final children = (submenu['items'] as List).cast<Map<Object?, Object?>>();
    expect(children.map((item) => item['label']), contains('A'));
  });

  test('dispatches start stop pause resume and exit actions', () async {
    final l10n = currentAppLocalizations;

    await update(_trayState());
    await select(l10n.start);
    await select(l10n.exit);

    Tray.instance.resetForTesting();
    calls.clear();
    await update(_trayState(isStart: true, tunEnable: true));
    await select(l10n.stop);
    await select(l10n.pause);

    Tray.instance.resetForTesting();
    calls.clear();
    await update(
      const TrayState(
        mode: Mode.rule,
        port: 7890,
        autoLaunch: false,
        systemProxy: false,
        tunEnable: true,
        isStart: true,
        paused: true,
        groups: [],
        selectedMap: {},
        showTrayTitle: false,
      ),
    );
    await select(l10n.resume);

    expect(_RecordingCommonAction.calls, [
      'running',
      'running',
      'paused',
      'paused',
    ]);
    expect(_RecordingSystemAction.calls, ['exit']);
  });

  group('a platform that is not macOS', () {
    late AppTray windows;

    setUp(() {
      windows = AppTray.forPlatform(isMacOS: false, isWindows: true);
    });

    test('gets a plain icon, no group submenus and no speed toggle', () async {
      await update(
        _trayState(
          isStart: true,
          groups: [
            const Group(
              name: 'Proxy',
              type: GroupType.Selector,
              all: [Proxy(name: 'A', type: 'Direct')],
            ),
          ],
        ),
        on: windows,
      );

      final arguments = showCall()!.arguments as Map;
      expect((arguments['icon'] as Map)['isTemplate'], isFalse);
      expect(
        _items(showCall()).where((item) => item['type'] == 'submenu'),
        isEmpty,
      );
      expect(
        _labels(showCall()),
        isNot(contains(currentAppLocalizations.speedStatistics)),
      );
    });

    test('never pushes a tray title', () async {
      await windows.updateTitle(showTrayTitle: true, traffic: const Traffic());

      expect(calls.where((call) => call.method == 'setTitle'), isEmpty);
    });
  });
}

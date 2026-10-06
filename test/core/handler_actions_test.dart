import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

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

/// A concrete handler exposing overridable primitives so the real
/// [CoreHandlerActions] composition runs against canned core answers.
class _FakeHandler extends CoreHandlerInterface {
  Future<String> Function(SetupParams params)? onSetupConfig;
  Future<Map<String, dynamic>> Function(String path)? onGetConfig;
  Future<String> Function(String path)? onValidateConfig;
  Future<ProxiesData> Function()? onGetProxies;

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async => null;

  @override
  Future<CoreLifecycleResult> start() => throw UnimplementedError();

  @override
  Future<CoreLifecycleResult> restart() => throw UnimplementedError();

  @override
  Future<CoreLifecycleResult> stop() => throw UnimplementedError();

  @override
  Future<CoreLifecycleResult> close() => throw UnimplementedError();

  @override
  Future<String> setupConfig(SetupParams params) => onSetupConfig!(params);

  @override
  Future<Map<String, dynamic>> getConfig(String path) => onGetConfig!(path);

  @override
  Future<String> validateConfig(String path) => onValidateConfig!(path);

  @override
  Future<ProxiesData> getProxies() => onGetProxies!();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Completer<Directory> originalDataDir;
  late _FakeHandler handler;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('handler-actions-test-');
    PathProviderPlatform.instance = _FakePathProvider(directory.path);
    originalDataDir = appPath.dataDir;
    appPath.dataDir = Completer<Directory>()..complete(directory);
    handler = _FakeHandler();
  });

  tearDown(() {
    appPath.dataDir = originalDataDir;
    directory.deleteSync(recursive: true);
  });

  group('setupConfigWithPreload', () {
    const params = SetupParams(selectedMap: {}, testUrl: 'http://x.com');

    test('waits for an asynchronous preload', () async {
      final preloadGate = Completer<void>();
      final events = <String>[];
      handler.onSetupConfig = (_) {
        events.add('setup');
        return Future.value('');
      };

      final operation = handler.setupConfigWithPreload(
        params: params,
        preloadInvoke: () async {
          events.add('preload');
          await preloadGate.future;
        },
      );
      var completed = false;
      unawaited(operation.then((_) => completed = true));
      await Future<void>.delayed(Duration.zero);

      expect(events, ['setup', 'preload']);
      expect(completed, isFalse);

      preloadGate.complete();
      expect(await operation, '');
    });

    test('without a preload it forwards the message', () async {
      handler.onSetupConfig = (_) async => 'invalid';
      expect(await handler.setupConfigWithPreload(params: params), 'invalid');
    });

    test('Linux applies configuration before starting listeners', () async {
      final configured = Completer<String>();
      var starts = 0;
      handler.onSetupConfig = (_) => configured.future;
      final operation = handler.setupConfigWithPreload(
        params: params,
        preloadInvoke: () async => starts++,
      );
      await Future<void>.delayed(Duration.zero);
      expect(starts, 0);
      configured.complete('');
      expect(await operation, '');
      expect(starts, 1);
    }, skip: !Platform.isLinux);

    test('Linux skips listener startup when configuration fails', () async {
      var starts = 0;
      handler.onSetupConfig = (_) async => 'invalid';
      expect(
        await handler.setupConfigWithPreload(
          params: params,
          preloadInvoke: () async => starts++,
        ),
        'invalid',
      );
      expect(starts, 0);
    }, skip: !Platform.isLinux);
  });

  test('getAppliedConfig renames the core rule key to rules', () async {
    handler.onGetConfig = (_) async => {
      'rule': ['MATCH,DIRECT'],
      'mode': 'rule',
    };
    final config = await handler.getAppliedConfig();
    expect(config['rules'], ['MATCH,DIRECT']);
    expect(config.containsKey('rule'), isFalse);
    expect(config['mode'], 'rule');
  });

  test('validateConfigWithData validates a temp file then clears it', () async {
    String? seenPath;
    String? seenData;
    handler.onValidateConfig = (path) async {
      seenPath = path;
      seenData = await File(path).readAsString();
      return 'ok';
    };

    expect(await handler.validateConfigWithData('mode: rule'), 'ok');
    expect(seenData, 'mode: rule');
    expect(seenPath, isNotNull);
    expect(File(seenPath!).existsSync(), isFalse);
  });

  test('getProxiesGroups computes from the fetched proxies', () async {
    var fetched = false;
    handler.onGetProxies = () async {
      fetched = true;
      return const ProxiesData(proxies: {}, all: []);
    };
    final groups = await handler.getProxiesGroups(
      sortType: ProxiesSortType.none,
      delayMap: const {},
      selectedMap: const {},
      defaultTestUrl: 'http://x.com',
    );
    expect(fetched, isTrue);
    expect(groups, isEmpty);
  });
}

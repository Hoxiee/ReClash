import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/tool_commands.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CoreActions extends CoreAction {
  int closes = 0;
  Future<void> Function()? close;

  @override
  void build() {}

  @override
  Future<void> closeConnections() async {
    closes++;
    await close?.call();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await preferences.rebind();
  });

  test('one path owns root selection, push, reveal and back', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final tools = container.read(toolsSessionProvider.notifier);
    tools.open(const ToolRoute(ToolPage.general));
    tools.open(const ToolRoute(ToolPage.userAgents), push: true);
    final nonce = container.read(toolsSessionProvider).focusNonce;
    tools.open(
      const ToolRoute(ToolPage.userAgents, settingId: 'userAgents.default'),
      push: true,
    );
    final state = container.read(toolsSessionProvider);
    expect(state.path.map((r) => r.page), [
      ToolPage.general,
      ToolPage.userAgents,
    ]);
    expect(state.focusNonce, greaterThan(nonce));
    tools.pop();
    expect(container.read(toolsSessionProvider).path, [
      const ToolRoute(ToolPage.general),
    ]);
    tools.open(const ToolRoute(ToolPage.application));
    expect(container.read(toolsSessionProvider).path, [
      const ToolRoute(ToolPage.application),
    ]);
  });

  test(
    'only pins persist, navigation and queries stay in the session',
    () async {
      final container = ProviderContainer();
      final tools = container.read(toolsSessionProvider.notifier);
      for (var i = 0; i < 45; i++) {
        tools.open(ToolRoute(ToolPage.general, settingId: 'general.$i'));
      }
      tools.open(const ToolRoute(ToolPage.general, settingId: 'general.44'));
      tools.togglePin('page.general');
      tools.search('secret query');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final store = await SharedPreferences.getInstance();
      expect(await preferences.getPinnedTools(), ['page.general']);
      expect(store.getKeys(), {'tools.pinned'});
      container.dispose();
      final reopened = ProviderContainer();
      addTearDown(reopened.dispose);
      reopened.read(toolsSessionProvider);
      await Future<void>.delayed(Duration.zero);
      expect(reopened.read(toolsSessionProvider).pinned, ['page.general']);
      expect(reopened.read(toolsSessionProvider).path, isEmpty);
    },
  );

  ProviderContainer commandsContainer() {
    final container = ProviderContainer(
      overrides: [
        coreActionProvider.overrideWith(_CoreActions.new),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('cancelled confirmation never reaches Core', () async {
    final container = commandsContainer();
    final result = await container
        .read(toolCommandsProvider.notifier)
        .execute(ToolCommand.closeConnections, confirm: () async => false);
    expect(result, isFalse);
    expect(
      (container.read(coreActionProvider.notifier) as _CoreActions).closes,
      0,
    );
    expect(container.read(toolCommandsProvider), isEmpty);
  });

  test('confirmation and work both reject repeated invocation', () async {
    final container = commandsContainer();
    final confirmed = Completer<bool>();
    final work = Completer<void>();
    final owner = container.read(coreActionProvider.notifier) as _CoreActions;
    owner.close = () => work.future;
    final commands = container.read(toolCommandsProvider.notifier);
    final first = commands.execute(
      ToolCommand.closeConnections,
      confirm: () => confirmed.future,
    );
    expect(
      await commands.execute(
        ToolCommand.closeConnections,
        confirm: () async => true,
      ),
      isFalse,
    );
    confirmed.complete(true);
    await Future<void>.delayed(Duration.zero);
    expect(owner.closes, 1);
    expect(
      await commands.execute(
        ToolCommand.closeConnections,
        confirm: () async => true,
      ),
      isFalse,
    );
    work.complete();
    expect(await first, isTrue);
    expect(container.read(toolCommandsProvider), isEmpty);
  });

  test('availability is checked again after confirmation', () async {
    final container = commandsContainer();
    final confirmed = Completer<bool>();
    final operation = container
        .read(toolCommandsProvider.notifier)
        .execute(ToolCommand.closeConnections, confirm: () => confirmed.future);
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    confirmed.complete(true);
    expect(await operation, isFalse);
    expect(
      (container.read(coreActionProvider.notifier) as _CoreActions).closes,
      0,
    );
  });

  test('disposing during confirmation never starts the owner', () async {
    final container = ProviderContainer(
      overrides: [
        coreActionProvider.overrideWith(_CoreActions.new),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
      ],
    );
    final owner = container.read(coreActionProvider.notifier) as _CoreActions;
    final answer = Completer<bool>();
    final pending = container
        .read(toolCommandsProvider.notifier)
        .execute(ToolCommand.closeConnections, confirm: () => answer.future);
    container.dispose();
    answer.complete(true);
    expect(await pending, isFalse);
    expect(owner.closes, 0);
  });

  test('owner failure clears the busy state', () async {
    final container = commandsContainer();
    final owner = container.read(coreActionProvider.notifier) as _CoreActions;
    owner.close = () async => throw StateError('test failure');
    await expectLater(
      container
          .read(toolCommandsProvider.notifier)
          .execute(ToolCommand.closeConnections, confirm: () async => true),
      throwsStateError,
    );
    expect(container.read(toolCommandsProvider), isEmpty);
  });
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:riverpod/riverpod.dart';

import '../../helpers/test_profiles.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _FixedReports extends ChainReports {
  _FixedReports(this.reports);

  final Map<int, ChainReport> reports;

  @override
  Map<int, ChainReport>? build() => reports;
}

class _RecordingSetupAction extends SetupAction {
  static var applies = 0;

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool suppressErrors = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    applies++;
    return true;
  }
}

class _RecordingDelayAction extends ProxiesAction {
  static final List<({List<String> names, String testUrl})> calls = [];

  @override
  Future<void> delayTestAt(List<Proxy> proxies, String testUrl) async {
    calls.add((
      names: [for (final proxy in proxies) proxy.name],
      testUrl: testUrl,
    ));
  }
}

const _proxy = Group(
  type: GroupType.Selector,
  name: 'Proxy',
  now: 'A',
  all: [
    Proxy(name: 'A', type: 'vless'),
    Proxy(name: 'B', type: 'ss'),
    Proxy(name: 'A → B', type: 'Selector'),
  ],
);

const _chainUrl = 'https://chain.test/204';

const _chainGroup = Group(
  type: GroupType.Selector,
  name: 'A → B',
  testUrl: _chainUrl,
);

void main() {
  late Database testDatabase;
  late _MockCore core;

  ProviderContainer buildContainer({
    Profile? profile,
    Map<int, ChainReport>? reports,
    List<Group> groups = const [_proxy],
    DelayMap? delays,
  }) {
    final container = ProviderContainer(
      overrides: [
        if (reports != null)
          chainReportsProvider.overrideWith(() => _FixedReports(reports)),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
        profilesProvider.overrideWith(
          () => TestProfiles([
            profile ??
                const Profile(
                  id: 1,
                  label: 'P',
                  autoUpdateDuration: Duration.zero,
                ),
          ]),
        ),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
        proxiesActionProvider.overrideWith(_RecordingDelayAction.new),
        groupsProvider.overrideWithBuild((_, _) => groups),
        if (delays != null)
          delayDataSourceProvider.overrideWithBuild((_, _) => delays),
        providerHintsProvider.overrideWithValue(null),
      ],
    );
    globalState.container = container;
    addTearDown(container.dispose);
    return container;
  }

  setUp(() async {
    _RecordingSetupAction.applies = 0;
    _RecordingDelayAction.calls.clear();
    testDatabase = Database(NativeDatabase.memory());
    database = testDatabase;
    await testDatabase.profilesDao.putAll([
      const Profile(
        id: 1,
        label: 'P',
        autoUpdateDuration: Duration.zero,
      ).toCompanion(),
    ]);
    core = _MockCore();
    when(() => core.getProxyDefinition('A')).thenAnswer(
      (_) async => {
        'name': 'A',
        'type': 'vless',
        'server': 'a.test',
        'port': 443,
      },
    );
    when(() => core.getProxyDefinition('B')).thenAnswer(
      (_) async => {
        'name': 'B',
        'type': 'ss',
        'server': 'b.test',
        'port': '8388',
      },
    );
  });

  tearDown(() => testDatabase.close());

  test(
    'a new chain is auto-named, fingerprinted and pins the main group',
    () async {
      final container = buildContainer();
      final actions = container.read(proxyChainsActionProvider.notifier);

      final chain = await actions.create(profileId: 1, hops: ['A', 'B']);

      expect(chain.name, 'A → B 2', reason: 'the running config has A → B');
      expect(chain.nameAuto, isTrue);
      expect(chain.fingerprints, const [
        HopFingerprint(type: 'vless', server: 'a.test', port: 443),
        HopFingerprint(type: 'ss', server: 'b.test', port: 8388),
      ]);
      expect(await testDatabase.proxyChainsDao.query(1).get(), [chain]);
      expect(container.read(selectedMapProvider), {'Proxy': 'A'});
      expect(_RecordingSetupAction.applies, 1);
    },
  );

  test('a hop gone from the config keeps its saved fingerprint', () async {
    final container = buildContainer();
    final actions = container.read(proxyChainsActionProvider.notifier);
    final chain = await actions.create(profileId: 1, hops: ['A', 'B']);
    when(() => core.getProxyDefinition('A')).thenAnswer((_) async => null);

    final disabled = await actions.setEnabled(chain, false);

    expect(disabled.fingerprints, chain.fingerprints);
    expect(disabled.name, chain.name);
  });

  test(
    'a rename rewrites added rules, MATCH and the pick naming the chain',
    () async {
      final container = buildContainer(
        profile: const Profile(
          id: 1,
          label: 'P',
          autoUpdateDuration: Duration.zero,
          matchTarget: 'Mine',
          selectedMap: {'Proxy': 'Mine'},
        ),
      );
      final actions = container.read(proxyChainsActionProvider.notifier);
      final chain = await actions.create(
        profileId: 1,
        hops: ['A', 'B'],
        name: 'Mine',
      );
      await testDatabase.rulesDao.putRule(
        const Rule(id: 4, content: 'example.com', ruleTarget: 'Mine'),
        profileId: 1,
      );

      final renamed = await actions.rename(chain, 'Fast');

      expect(renamed.nameAuto, isFalse);
      final rule =
          (await testDatabase.rulesDao.queryAddedRules(1).get()).single;
      expect(rule.ruleTarget, 'Fast');
      final profile = container.read(currentProfileProvider)!;
      expect(profile.matchTarget, 'Fast');
      expect(profile.selectedMap, {'Proxy': 'Fast'});
    },
  );

  test('a broken chain the target group selects is reported', () async {
    const report = ChainReport(
      id: 9,
      group: 'A → B',
      status: ChainStatus.broken,
      target: 'Proxy',
    );
    await testDatabase.proxyChainsDao.put(
      const ProxyChain(id: 9, profileId: 1, name: 'A → B', hops: ['A', 'B']),
    );
    final container = buildContainer(
      profile: const Profile(
        id: 1,
        label: 'P',
        autoUpdateDuration: Duration.zero,
        selectedMap: {'Proxy': 'A → B'},
      ),
      reports: {9: report},
    );
    container.listen(selectedBrokenChainProvider, (_, _) {});
    await container.read(profileChainsProvider(1).future);

    expect(container.read(selectedBrokenChainProvider), report);
  });

  for (final (label, leave)
      in <(String, Future<void> Function(ProxyChainsAction, ProxyChain))>[
        ('disabled', (actions, chain) => actions.setEnabled(chain, false)),
        ('deleted', (actions, chain) => actions.delete(chain)),
      ]) {
    test('a selected chain $label hands back the pick it displaced', () async {
      const chain = ProxyChain(
        id: 9,
        profileId: 1,
        name: 'A → B',
        hops: ['A', 'B'],
        restorePick: 'B',
      );
      await testDatabase.proxyChainsDao.put(chain);
      final container = buildContainer(
        profile: const Profile(
          id: 1,
          label: 'P',
          autoUpdateDuration: Duration.zero,
          selectedMap: {'Proxy': 'A → B'},
        ),
        reports: {
          9: const ChainReport(
            id: 9,
            group: 'A → B',
            status: ChainStatus.ok,
            target: 'Proxy',
          ),
        },
      );
      await leave(container.read(proxyChainsActionProvider.notifier), chain);

      expect(container.read(selectedMapProvider), {'Proxy': 'B'});
    });
  }

  group('testDelay', () {
    const chain = ProxyChain(
      id: 9,
      profileId: 1,
      name: 'Fast',
      hops: ['A', 'B'],
    );
    const report = ChainReport(
      id: 9,
      group: 'A → B',
      status: ChainStatus.ok,
      target: 'Proxy',
    );

    test(
      'a chain tests its group and entry together under the group test URL',
      () async {
        final container = buildContainer(
          groups: const [_proxy, _chainGroup],
          reports: {9: report},
        );

        await container
            .read(proxyChainsActionProvider.notifier)
            .testDelay(chain);

        final call = _RecordingDelayAction.calls.single;
        expect(call.names, ['A → B', 'A']);
        expect(call.testUrl, _chainUrl);
      },
    );

    test('a chain of another profile is not tested', () async {
      final container = buildContainer(
        groups: const [_proxy, _chainGroup],
        reports: {9: report},
      );
      const other = ProxyChain(
        id: 9,
        profileId: 2,
        name: 'Fast',
        hops: ['A', 'B'],
      );

      final delays = await container
          .read(proxyChainsActionProvider.notifier)
          .testDelay(other);

      expect(delays, (entry: null, chain: null));
      expect(_RecordingDelayAction.calls, isEmpty);
    });

    test(
      'the delays are read for the group and entry under the test URL',
      () async {
        final container = buildContainer(
          groups: const [_proxy, _chainGroup],
          reports: {9: report},
          delays: {
            _chainUrl: {'A → B': 250, 'A': 80},
            'https://other.test/204': {'A → B': 999, 'A': 999},
          },
        );

        final delays = await container
            .read(proxyChainsActionProvider.notifier)
            .testDelay(chain);

        expect(delays, (entry: 80, chain: 250));
      },
    );
  });
}

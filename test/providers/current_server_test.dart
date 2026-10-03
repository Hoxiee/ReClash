import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';

const _groups = [
  Group(name: 'Proxy', type: GroupType.Selector, now: 'A', hidden: false),
  Group(name: 'RCX-NODE', type: GroupType.Selector, now: 'B', hidden: false),
  Group(name: 'GLOBAL', type: GroupType.Selector, now: 'C', hidden: false),
];

void main() {
  test('automatic RCX selection precedes the profile hint and group order', () {
    for (final profileGroup in [null, 'Proxy']) {
      expect(
        selectCurrentServerGroupHint(
          mode: Mode.rule,
          groups: _groups,
          smartRoutingEnabled: true,
          profileGroup: profileGroup,
        ),
        'RCX-NODE',
      );
    }
  });

  test('automatic Global selection precedes every profile hint', () {
    for (final profileGroup in [null, 'Proxy', 'RCX-NODE']) {
      expect(
        selectCurrentServerGroupHint(
          mode: Mode.global,
          groups: _groups,
          smartRoutingEnabled: true,
          profileGroup: profileGroup,
        ),
        'GLOBAL',
      );
    }
  });

  test(
    'an explicit valid notification group remains an intentional override',
    () {
      for (final mode in [Mode.rule, Mode.global]) {
        expect(
          selectCurrentServerGroupHint(
            mode: mode,
            groups: _groups,
            smartRoutingEnabled: true,
            componentGroup: '  Proxy  ',
          ),
          'Proxy',
        );
      }
    },
  );

  test('direct mode never resolves a server from a saved override', () {
    expect(
      selectCurrentServerGroupHint(
        mode: Mode.direct,
        groups: _groups,
        smartRoutingEnabled: true,
        componentGroup: 'Proxy',
        profileGroup: 'RCX-NODE',
      ),
      isNull,
    );
  });

  test('missing groups do not resurrect stale notification overrides', () {
    expect(
      selectCurrentServerGroupHint(
        mode: Mode.rule,
        groups: _groups,
        componentGroup: 'Gone',
        profileGroup: ' Proxy ',
      ),
      'Proxy',
    );
    expect(
      selectCurrentServerGroupHint(
        mode: Mode.global,
        groups: _groups.take(2).toList(),
        profileGroup: 'Proxy',
      ),
      isNull,
    );
    expect(
      selectCurrentServerGroupHint(mode: Mode.rule, groups: const []),
      isNull,
    );
  });

  test(
    'an unavailable RCX skeleton falls back without selecting a missing group',
    () {
      expect(
        selectCurrentServerGroupHint(
          mode: Mode.rule,
          groups: [_groups.first],
          smartRoutingEnabled: true,
          profileGroup: 'Proxy',
        ),
        'Proxy',
      );
    },
  );

  group('provider integration', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          currentProfileProvider.overrideWithValue(
            Profile.normal().copyWith(
              panelMeta: const PanelMeta(serverInfoGroup: 'Proxy'),
            ),
          ),
        ],
      );
      container.listen(activeServerGroupProvider, (_, _) {});
      container.listen(activeServerProvider, (_, _) {});
      container.read(groupsProvider.notifier).value = _groups;
      container.read(smartRoutingStatusProvider.notifier).value =
          const RcxStatus(enabled: true, node: 'B');
      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(mode: Mode.rule));
    });

    tearDown(() => container.dispose());

    test(
      'notification and hero follow Smart Route being enabled and disabled',
      () {
        expect(container.read(activeServerGroupProvider), 'Proxy');
        expect(container.read(activeServerProvider).name, 'A');

        container
            .read(smartRoutingSettingProvider.notifier)
            .update((state) => state.copyWith(enabled: true));
        expect(container.read(activeServerGroupProvider), 'RCX-NODE');
        expect(container.read(activeServerProvider).name, 'B');

        container
            .read(smartRoutingSettingProvider.notifier)
            .update((state) => state.copyWith(enabled: false));
        expect(container.read(activeServerGroupProvider), 'Proxy');
        expect(container.read(activeServerProvider).name, 'A');
      },
    );

    test('Global and direct do not keep the profile or RCX server', () {
      container
          .read(smartRoutingSettingProvider.notifier)
          .update((state) => state.copyWith(enabled: true));
      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(mode: Mode.global));
      expect(container.read(activeServerGroupProvider), 'GLOBAL');
      expect(container.read(activeServerProvider).name, 'C');

      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(mode: Mode.direct));
      expect(container.read(activeServerGroupProvider), isNull);
      expect(container.read(activeServerProvider).name, isEmpty);
    });

    test('a notification-only override does not change the hero server', () {
      container
          .read(smartRoutingSettingProvider.notifier)
          .update((state) => state.copyWith(enabled: true));
      container
          .read(appSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              notificationSettings: state.notificationSettings.copyWith(
                components: const [
                  NotificationComponent(
                    type: NotificationComponentType.currentServer,
                    group: 'Proxy',
                  ),
                ],
              ),
            ),
          );
      expect(container.read(activeServerGroupProvider), 'Proxy');
      expect(container.read(activeServerProvider).name, 'B');
    });
  });
}

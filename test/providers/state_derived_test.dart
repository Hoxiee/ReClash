import 'package:reclash/common/app_ports.dart';
import 'package:reclash/common/constant.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/views/navigation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    navigationPort = navigation;
    addTearDown(() => navigationPort = null);
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('group derivation sanitizes runtime state and respects clash mode', () {
    final groups = [
      const Group(
        name: 'Visible',
        type: GroupType.Selector,
        now: 'Selected',
        hidden: false,
        all: [Proxy(name: 'Selected', type: 'Direct', now: 'runtime')],
      ),
      const Group(name: 'Hidden', type: GroupType.Selector, hidden: true),
      Group(name: GroupName.GLOBAL.name, type: GroupType.Selector),
    ];
    container.read(groupsProvider.notifier).update((_) => groups);
    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: Mode.rule));

    final ruleGroups = container.read(currentGroupsStateProvider).value;
    expect(ruleGroups.map((group) => group.name), ['Visible']);
    expect(ruleGroups.single.now, isEmpty);
    expect(ruleGroups.single.all.single.now, isEmpty);

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: Mode.global));
    expect(container.read(currentGroupsStateProvider).value, hasLength(3));

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: Mode.direct));
    expect(container.read(currentGroupsStateProvider).value, isEmpty);
  });

  test('navigation providers select items for width and current page', () {
    container
        .read(viewSizeProvider.notifier)
        .update((_) => Size(maxMobileWidth.toDouble(), 800));
    final mobile = container.read(currentNavigationItemsStateProvider).value;
    expect(
      mobile.map((item) => item.label),
      containsAll([PageLabel.dashboard, PageLabel.profiles, PageLabel.tools]),
    );
    expect(
      mobile.map((item) => item.label),
      isNot(contains(PageLabel.connections)),
    );

    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 800));
    container
        .read(currentPageLabelProvider.notifier)
        .toPage(PageLabel.connections);
    final desktop = container.read(navigationStateProvider);
    expect(desktop.viewMode, ViewMode.desktop);
    expect(desktop.currentIndex, greaterThan(0));
    expect(
      desktop.navigationItems[desktop.currentIndex].label,
      PageLabel.connections,
    );

    container
        .read(currentPageLabelProvider.notifier)
        .toPage(PageLabel.resources);
    expect(container.read(navigationStateProvider).currentIndex, 0);
  });

  test('layout and page state providers compose their dependencies', () {
    final profile = Profile.normal(label: 'Primary');
    _profiles(container).replace([profile]);
    container.read(currentProfileIdProvider.notifier).update((_) => profile.id);
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 800));
    container.read(sideWidthProvider.notifier).update((_) => 200);

    final profiles = container.read(profilesStateProvider);
    expect(profiles.profiles.single.label, 'Primary');
    expect(profiles.currentProfileId, profile.id);

    final dashboard = container.read(dashboardStateProvider);
    expect(dashboard.dashboardWidgets, isNotEmpty);

    final actions = container.read(proxiesActionsStateProvider);
    expect(actions.pageLabel, PageLabel.dashboard);
    expect(actions.hasProviders, isFalse);
    expect(actions.type, ProxiesType.tab);
  });

  test(
    'proxy list and tab providers filter groups and preserve selections',
    () {
      final profile = Profile.normal().copyWith(
        currentGroupName: 'Group B',
        unfoldSet: {'Group A'},
      );
      final groups = [
        const Group(
          name: 'Group A',
          type: GroupType.Selector,
          hidden: false,
          all: [
            Proxy(name: 'Alpha', type: 'Direct'),
            Proxy(name: 'Beta', type: 'Direct'),
          ],
        ),
        const Group(
          name: 'Group B',
          type: GroupType.URLTest,
          hidden: false,
          testUrl: 'https://group.test',
          all: [Proxy(name: 'Gamma', type: 'Direct')],
        ),
      ];
      _profiles(container).replace([profile]);
      container
          .read(currentProfileIdProvider.notifier)
          .update((_) => profile.id);
      container.read(groupsProvider.notifier).update((_) => groups);
      container
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(mode: Mode.rule));
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(900, 800));

      expect(container.read(filterGroupsStateProvider('')).value, hasLength(2));
      final filtered = container.read(filterGroupsStateProvider('ALP')).value;
      expect(filtered, hasLength(1));
      expect(filtered.single.all.single.name, 'Alpha');

      container
          .read(queryProvider(QueryTag.proxies).notifier)
          .update((_) => 'ga');
      final list = container.read(proxiesListStateProvider);
      expect(list.groups.single.name, 'Group B');
      expect(list.currentUnfoldSet, {'Group A'});

      final tab = container.read(proxiesTabStateProvider);
      expect(tab.currentGroupName, 'Group B');
      expect(tab.groups.single.all.single.name, 'Gamma');
      final controller = container.read(proxiesTabControllerStateProvider);
      expect(controller.groupNames, ['Group B']);
      expect(controller.currentGroupName, 'Group B');

      final selector = container.read(
        proxyGroupSelectorStateProvider('Group A', 'be'),
      );
      expect(selector.proxies.single.name, 'Beta');
      expect(selector.groupType, GroupType.Selector);

      final missing = container.read(
        proxyGroupSelectorStateProvider('Missing', ''),
      );
      expect(missing.proxies, isEmpty);
      expect(missing.groupType, GroupType.Selector);
    },
  );

  test('runtime, VPN, tray, and DNS states follow live state', () {
    container
        .read(runTimeProvider.notifier)
        .update((_) => DateTime(2026).millisecondsSinceEpoch);
    container
        .read(networkSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            systemProxy: false,
            bypassDomain: const ['localhost'],
            autoSetSystemDns: true,
          ),
        );
    container
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            mixedPort: 8899,
            mode: Mode.global,
            tun: state.tun.copyWith(enable: true),
          ),
        );
    expect(container.read(shouldPatchSystemDnsProvider), isFalse);

    container
        .read(authorizedTunEnableProvider.notifier)
        .update((_) => TunAuthorizationState.authorized);

    final proxy = container.read(proxyStateProvider);
    expect(proxy.isStart, isTrue);
    expect(proxy.systemProxy, isFalse);
    expect(proxy.bassDomain, ['localhost']);
    expect(proxy.port, 8899);
    expect(container.read(isStartProvider), isTrue);

    final tray = container.read(trayStateProvider);
    expect(tray.mode, Mode.global);
    expect(tray.port, 8899);
    expect(tray.tunEnable, isTrue);
    expect(tray.isStart, isTrue);

    final vpn = container.read(vpnStateProvider);
    expect(vpn.stack, container.read(patchClashConfigProvider).tun.stack);
    expect(vpn.vpnProps, container.read(vpnSettingProvider));

    expect(container.read(shouldPatchSystemDnsProvider), isTrue);

    container
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(autoSetSystemDns: false));
    expect(container.read(shouldPatchSystemDnsProvider), isFalse);
    container
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(autoSetSystemDns: true));

    container
        .read(authorizedTunEnableProvider.notifier)
        .update((_) => TunAuthorizationState.unauthorized);
    expect(container.read(shouldPatchSystemDnsProvider), isFalse);

    container
        .read(vpnSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            smartPauseEnabled: true,
            smartPauseNetworks: ['Office'],
          ),
        );
    container.read(currentSSIDProvider.notifier).update((_) => 'Office');
    expect(container.read(pausedProvider), isTrue);
    expect(container.read(proxyStateProvider).isStart, isFalse);
  });

  test('selection and delay providers resolve groups and profile state', () {
    final profile = Profile.normal().copyWith(
      selectedMap: {'Selector': 'Leaf'},
      unfoldSet: {'Selector'},
    );
    const groups = [
      Group(
        name: 'Selector',
        type: GroupType.Selector,
        all: [Proxy(name: 'Leaf', type: 'Direct')],
      ),
    ];
    _profiles(container).replace([profile]);
    container.read(currentProfileIdProvider.notifier).update((_) => profile.id);
    container.read(groupsProvider.notifier).update((_) => groups);
    container
        .read(delayDataSourceProvider.notifier)
        .setDelay(
          const Delay(
            name: 'Leaf',
            url: 'https://www.gstatic.com/generate_204',
            value: 42,
          ),
        );

    expect(container.read(selectedMapProvider), {'Selector': 'Leaf'});
    expect(container.read(unfoldSetProvider), {'Selector'});
    expect(container.read(proxyNameProvider('Selector')), 'Leaf');
    expect(container.read(selectedProxyNameProvider('Selector')), 'Leaf');
    expect(
      container.read(realSelectedProxyStateProvider('Selector')).proxyName,
      'Leaf',
    );
    expect(container.read(delayProvider(proxyName: 'Selector')), 42);
    expect(
      container.read(
        proxyDescProvider(const Proxy(name: 'Selector', type: 'Selector')),
      ),
      'Selector(Leaf)',
    );
    expect(
      container.read(
        proxyDescProvider(const Proxy(name: 'Leaf', type: 'Direct')),
      ),
      'Direct',
    );
  });

  test('theme and simple derived providers cover fallback branches', () {
    expect(container.read(currentBrightnessProvider), Brightness.dark);
    container
        .read(systemBrightnessProvider.notifier)
        .update((_) => Brightness.light);
    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(themeMode: ThemeMode.system));
    expect(container.read(currentBrightnessProvider), Brightness.light);

    final fallback = container.read(
      genColorSchemeProvider(Brightness.light, ignoreConfig: true),
    );
    expect(fallback.brightness, Brightness.light);
    final explicit = container.read(
      genColorSchemeProvider(Brightness.dark, color: Colors.purple),
    );
    expect(explicit.brightness, Brightness.dark);

    expect(
      container.read(realTestUrlProvider('https://custom.test')),
      'https://custom.test',
    );
    expect(container.read(isCurrentPageProvider(PageLabel.dashboard)), isTrue);
    expect(
      container.read(
        isCurrentPageProvider(
          PageLabel.logs,
          handler: (_, viewMode) => viewMode == ViewMode.mobile,
        ),
      ),
      isTrue,
    );
  });

  test('package, hotkey, profile, and overwrite providers expose defaults', () {
    const package = Package(
      packageName: 'app.example',
      label: 'Example',
      system: false,
      internet: true,
      lastUpdateTime: 1,
    );
    container.read(packagesProvider.notifier).update((_) => [package]);
    final packageList = container.read(packageListSelectorStateProvider);
    expect(packageList.packages, [package]);
    expect(
      packageList.accessControlProps,
      container.read(vpnSettingProvider).accessControlProps,
    );

    const action = HotKeyAction(
      action: HotAction.start,
      key: 1,
      modifiers: {KeyboardModifier.control},
    );
    container.read(hotKeyActionsProvider.notifier).update((_) => [action]);
    expect(container.read(getHotKeyActionProvider(HotAction.start)), action);
    expect(
      container.read(getHotKeyActionProvider(HotAction.tun)).action,
      HotAction.tun,
    );

    final profile = Profile.normal().copyWith(
      overwriteType: OverwriteType.custom,
    );
    _profiles(container).replace([profile]);
    expect(container.read(profileProvider(profile.id)), profile);
    expect(
      container.read(overwriteTypeProvider(profile.id)),
      OverwriteType.custom,
    );
    expect(container.read(overwriteTypeProvider(-1)), OverwriteType.standard);

    expect(
      container.read(accessControlStateProvider),
      const AccessControlProps(),
    );
  });

  test('shared state hands the VPN service the resolved route list', () async {
    await AppLocalizations.load(const Locale('en'));
    container.listen(sharedStateProvider, (_, _) {});
    container
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            tun: state.tun.copyWith(routeAddress: const ['10.0.0.0/8']),
          ),
        );
    container
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(routeMode: RouteMode.config));
    expect(container.read(sharedStateProvider).vpnOptions?.routeAddress, [
      '10.0.0.0/8',
    ]);

    container
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(routeMode: RouteMode.bypassPrivate));
    expect(
      container.read(sharedStateProvider).vpnOptions?.routeAddress,
      defaultBypassPrivateRouteAddress,
    );
  });

  // VpnService.setHttpProxy cannot carry credentials.
  test('local authentication withholds the VPN system proxy', () async {
    await AppLocalizations.load(const Locale('en'));
    container.listen(sharedStateProvider, (_, _) {});
    expect(container.read(sharedStateProvider).vpnOptions?.systemProxy, true);

    container
        .read(networkSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            authentication: const AuthenticationProps(
              enable: true,
              username: 'user',
              password: 'pass',
            ),
          ),
        );
    expect(container.read(sharedStateProvider).vpnOptions?.systemProxy, false);
    expect(container.read(updateParamsProvider).authentication, ['user:pass']);

    container
        .read(networkSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            authentication: const AuthenticationProps(enable: false),
          ),
        );
    expect(container.read(sharedStateProvider).vpnOptions?.systemProxy, true);
    expect(container.read(updateParamsProvider).authentication, isEmpty);
  });

  test('shared state carries the notification stop action switch', () async {
    await AppLocalizations.load(const Locale('en'));
    container.listen(sharedStateProvider, (_, _) {});
    expect(container.read(sharedStateProvider).showStopAction, true);

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showNotificationStopAction: false));
    expect(container.read(sharedStateProvider).showStopAction, false);
  });

  test('shared state follows the locale whose messages are loaded', () async {
    container.listen(sharedStateProvider, (_, _) {});
    await AppLocalizations.load(const Locale('en'));
    container.read(loadedLocaleProvider.notifier).value = const Locale('en');
    final en = container.read(sharedStateProvider);

    await AppLocalizations.load(const Locale('zh', 'CN'));
    addTearDown(() => AppLocalizations.load(const Locale('en')));
    expect(container.read(sharedStateProvider).stopText, en.stopText);

    container.read(loadedLocaleProvider.notifier).value = const Locale(
      'zh',
      'CN',
    );
    final zh = container.read(sharedStateProvider);
    expect(zh.stopText, isNot(en.stopText));
    expect(zh.stopTip, isNot(en.stopTip));
    expect(zh.startTip, isNot(en.startTip));
  });

  group('theme schedule', () {
    int currentMinutes() {
      final now = DateTime.now();
      return now.hour * 60 + now.minute;
    }

    int wrap(int minutes) => (minutes % 1440 + 1440) % 1440;

    String hhmm(int minutes) {
      final hh = (minutes ~/ 60).toString().padLeft(2, '0');
      final mm = (minutes % 60).toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    void schedule({String? darkAt, String? lightAt}) {
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              scheduledTheme: true,
              darkAt: darkAt,
              lightAt: lightAt,
            ),
          );
    }

    ThemeMode effectiveThemeMode() =>
        container.read(themeSettingProvider).effectiveThemeMode;

    test('falls back to the stored mode without a full schedule', () {
      container
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(themeMode: ThemeMode.system));
      expect(effectiveThemeMode(), ThemeMode.system);

      schedule(darkAt: '20:00');
      expect(effectiveThemeMode(), ThemeMode.system);
    });

    test('invalid times fall back to the stored mode', () {
      container
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(themeMode: ThemeMode.system));
      schedule(darkAt: '24:00', lightAt: '06:30');
      expect(effectiveThemeMode(), ThemeMode.system);

      schedule(darkAt: '20:00', lightAt: '12:60');
      expect(effectiveThemeMode(), ThemeMode.system);

      schedule(darkAt: 'evening', lightAt: '06:30');
      expect(effectiveThemeMode(), ThemeMode.system);
    });

    test('picks dark inside the window and light outside it', () {
      final minutes = currentMinutes();
      schedule(
        darkAt: hhmm(wrap(minutes - 2)),
        lightAt: hhmm(wrap(minutes + 2)),
      );
      expect(effectiveThemeMode(), ThemeMode.dark);

      schedule(
        darkAt: hhmm(wrap(minutes + 2)),
        lightAt: hhmm(wrap(minutes - 2)),
      );
      expect(effectiveThemeMode(), ThemeMode.light);
    });

    test('the window includes its start and excludes its end', () {
      final minutes = currentMinutes();
      schedule(darkAt: hhmm(minutes), lightAt: hhmm(wrap(minutes + 1)));
      expect(effectiveThemeMode(), ThemeMode.dark);

      schedule(darkAt: hhmm(wrap(minutes - 1)), lightAt: hhmm(minutes));
      expect(effectiveThemeMode(), ThemeMode.light);
    });

    test('effectiveThemeMode reflects the schedule', () {
      final minutes = currentMinutes();
      container
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(themeMode: ThemeMode.light));
      expect(container.read(effectiveThemeModeProvider), ThemeMode.light);

      schedule(
        darkAt: hhmm(wrap(minutes - 2)),
        lightAt: hhmm(wrap(minutes + 2)),
      );
      expect(container.read(effectiveThemeModeProvider), ThemeMode.dark);
    });

    test('currentBrightness follows the schedule over the system mode', () {
      final minutes = currentMinutes();
      container
          .read(systemBrightnessProvider.notifier)
          .update((_) => Brightness.light);
      schedule(
        darkAt: hhmm(wrap(minutes - 2)),
        lightAt: hhmm(wrap(minutes + 2)),
      );
      expect(container.read(currentBrightnessProvider), Brightness.dark);

      schedule(
        darkAt: hhmm(wrap(minutes + 2)),
        lightAt: hhmm(wrap(minutes - 2)),
      );
      expect(container.read(currentBrightnessProvider), Brightness.light);
    });
  });

  test('genColorScheme raises on-surface contrast with contrastLevel', () {
    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(contrastLevel: 1));
    final elevated = container.read(
      genColorSchemeProvider(Brightness.dark, ignoreConfig: true),
    );

    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(contrastLevel: 0));
    final normal = container.read(
      genColorSchemeProvider(Brightness.dark, ignoreConfig: true),
    );

    double contrast(ColorScheme scheme) =>
        (scheme.onSurface.computeLuminance() + 0.05) /
        (scheme.surface.computeLuminance() + 0.05);

    expect(contrast(elevated), greaterThan(contrast(normal)));
  });

  group('pausedProvider', () {
    void trust({
      String? ssid,
      List<String> networks = const ['Office Wi-Fi', '192.168.1.0/24'],
    }) {
      container
          .read(vpnSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              smartPauseEnabled: true,
              smartPauseNetworks: networks,
            ),
          );
      container.read(currentSSIDProvider.notifier).value = ssid;
      container.read(runTimeProvider.notifier).update((_) => 1);
    }

    test('stays off while the core is stopped', () {
      trust(ssid: 'Office Wi-Fi');
      container.read(runTimeProvider.notifier).update((_) => null);

      expect(container.read(pausedProvider), isFalse);
    });

    test('stays off while smart pause is disabled', () {
      trust(ssid: 'Office Wi-Fi');
      container
          .read(vpnSettingProvider.notifier)
          .update((state) => state.copyWith(smartPauseEnabled: false));

      expect(container.read(pausedProvider), isFalse);
    });

    test('stays off with no trusted networks', () {
      trust(ssid: 'Cafe', networks: const []);

      expect(container.read(pausedProvider), isFalse);
    });

    test('engages on a trusted SSID', () {
      trust(ssid: 'office wi-fi');

      expect(container.read(pausedProvider), isTrue);
    });

    test('engages on a trusted subnet', () {
      trust(ssid: null);
      container.read(currentIPv4sProvider.notifier).value = ['192.168.1.20'];

      expect(container.read(pausedProvider), isTrue);
    });

    test('a manual pause holds on an untrusted network', () {
      trust(ssid: 'Cafe');
      container.read(manualPauseProvider.notifier).pause(['Cafe']);

      expect(container.read(pausedProvider), isTrue);
    });

    test('a manual resume holds while the anchor network stays', () {
      trust(ssid: 'Office Wi-Fi');
      final anchor = container.read(networkAnchorProvider);
      final manual = container.read(manualPauseProvider.notifier);
      manual.pause(anchor);
      manual.resume(anchor);

      expect(container.read(pausedProvider), isFalse);

      container.read(manualPauseProvider.notifier).clear();
      expect(container.read(pausedProvider), isTrue);
    });

    test('networkAnchor prefers the SSID and falls back to /24 subnets', () {
      expect(container.read(networkAnchorProvider), isEmpty);

      container.read(currentIPv4sProvider.notifier).value = [
        '192.168.1.20',
        '10.0.0.5',
      ];
      expect(container.read(networkAnchorProvider), [
        '10.0.0.0/24',
        '192.168.1.0/24',
      ]);

      container.read(currentSSIDProvider.notifier).value = 'Cafe';
      expect(container.read(networkAnchorProvider), ['Cafe']);
    });
  });
}

TestProfiles _profiles(ProviderContainer container) {
  return container.read(profilesProvider.notifier) as TestProfiles;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/subscriptions/provider_settings.dart';

final _base = Config.realFromJson(null);

ProviderHints _hints(Map<String, List<String>> headers) =>
    ProviderHints(readSubscriptionMetadata(headers).metadata);

ProviderSettingsInput _input(Map<String, List<String>> headers) =>
    ProviderSettingsInput(_hints(headers));

void main() {
  group('header decoding', () {
    test('aliases, scales and suffixes', () {
      final metadata = readSubscriptionMetadata({
        'profile-update-interval': ['12'],
        'support-url': ['https://support.example.test'],
        'reclash-buyplan': ['https://buy.example.test/plan,7'],
        'reclash-buytraffic': ['https://buy.example.test/gb,80'],
        'reclash-background': ['https://img.example.test/bg.png,15'],
      }).metadata;
      expect(metadata.count('update.intervalMinutes'), 720);
      expect(metadata.text('provider.supportUrl'), isNotNull);
      expect(
        metadata.text('provider.buyPlanUrl'),
        'https://buy.example.test/plan',
      );
      expect(metadata.count('provider.buyPlanDays'), 7);
      expect(metadata.count('provider.buyTrafficPercent'), 80);
      expect(metadata.count('presentation.backgroundOpacity'), 15);
    });

    test('an out-of-range suffix is dropped with the value kept', () {
      final result = readSubscriptionMetadata({
        'reclash-buytraffic': ['https://buy.example.test/gb,500'],
      });
      expect(result.metadata.text('provider.buyTrafficUrl'), isNotNull);
      expect(result.metadata.count('provider.buyTrafficPercent'), isNull);
      expect(result.warnings, isNotEmpty);
    });

    test('one malformed package drops only itself', () {
      final result = readSubscriptionMetadata({
        'reclash-excludeapps': ['com.bank.app, not a package ,ru.gov.app'],
      });
      expect(result.metadata.strings('apps.exclude'), [
        'com.bank.app',
        'ru.gov.app',
      ]);
      expect(
        result.warnings,
        contains('Invalid package in reclash-excludeapps'),
      );
    });

    test('FlClashX names reach the same fields only under its preset', () {
      final headers = {
        'flclashx-widgets': ['profiles'],
        'flclashx-special': ['noglobal'],
      };
      expect(readSubscriptionMetadata(headers).metadata.fields, isEmpty);
      final hints = ProviderHints(
        readSubscriptionMetadata(
          headers,
          clientPreset: SubscriptionClientPreset.flClashX,
        ).metadata,
      );
      expect(hints.widgets, [DashboardWidget.profiles]);
      expect(hints.restrictions, {ProviderRestriction.noGlobal});
    });

    test('config package lists join the header lists', () {
      final merged = withConfigPackages(
        readSubscriptionMetadata({
          'reclash-excludeapps': ['com.one.app'],
        }),
        excluded: ['com.two.app', 'com.one.app'],
        included: const [],
      );
      expect(merged.metadata.strings('apps.exclude'), [
        'com.one.app',
        'com.two.app',
      ]);
    });
  });

  group('hints', () {
    test('view pairs ignore unknown keys and values', () {
      final view = _hints({
        'reclash-view': [
          'proxies.type:list;proxies.sort:bogus;app.navbar:floating;unknown:x;app.color:#ff8800',
        ],
      }).view;
      expect(view.proxiesType, ProxiesType.list);
      expect(view.proxiesSort, isNull);
      expect(view.floatingNavigationBar, isTrue);
      expect(view.primaryColor, 0xffff8800);
      expect(view.primaryColorDark, isNull);
    });

    test('power button pairs fall back to the default per key', () {
      expect(_hints({}).powerButton, defaultProviderPowerButtonHint);
      final flower = _hints({
        'reclash-powerbutton': ['shape:flower;type:outline'],
      }).powerButton;
      expect(flower.shapes, [ProviderPowerShape.flower]);
      expect(flower.type, ProviderPowerType.outline);
      final unknown = _hints({
        'reclash-powerbutton': ['shape:bogus;type:tonal;unknown:x'],
      }).powerButton;
      expect(unknown.shapes, [ProviderPowerShape.cookie]);
      expect(unknown.type, ProviderPowerType.tonal);
    });

    test('all power button shapes accept case-insensitive header names', () {
      expect(ProviderPowerShape.values, hasLength(21));
      for (final shape in ProviderPowerShape.values) {
        final hint = _hints({
          'reclash-powerbutton': [
            'shape:${shape.name.toUpperCase()};type:bogus',
          ],
        }).powerButton;
        expect(hint.shapes, [shape]);
        expect(hint.type, ProviderPowerType.solid);
      }
    });

    test('random offers every concrete power button shape', () {
      final hint = _hints({
        'reclash-powerbutton': [' SHAPE : RaNdOm ; TYPE : OUTLINE '],
      }).powerButton;
      expect(hint.shapes, ProviderPowerShape.values);
      expect(hint.type, ProviderPowerType.outline);
      expect(() => hint.shapes.clear(), throwsUnsupportedError);
    });

    test('power button lists ignore unknown names and duplicate weights', () {
      final hint = _hints({
        'reclash-powerbutton': [
          'shape:PuffyDiamond, cookie, unknown, COOKIE, ,clover8Leaf;type:tonal',
        ],
      }).powerButton;
      expect(hint.shapes, [
        ProviderPowerShape.cookie,
        ProviderPowerShape.puffyDiamond,
        ProviderPowerShape.clover8Leaf,
      ]);
      expect(hint.type, ProviderPowerType.tonal);
      expect(() => hint.shapes.clear(), throwsUnsupportedError);
    });

    test('an empty or unknown power button list keeps the default shape', () {
      for (final value in ['', ', ,', 'bogus,unknown', 'random,bogus']) {
        final hint = _hints({
          'reclash-powerbutton': ['shape:$value;type:outline'],
        }).powerButton;
        expect(hint.shapes, [ProviderPowerShape.cookie]);
        expect(hint.type, ProviderPowerType.outline);
      }
    });

    test('power button pools retain only the listed concrete shapes', () {
      final hint = _hints({
        'reclash-powerbutton': ['shape:random,puffy,puffy'],
      }).powerButton;
      expect(hint.shapes, [ProviderPowerShape.puffy]);
    });

    test('power button lists survive metadata storage', () {
      final metadata = readSubscriptionMetadata({
        'reclash-powerbutton': [
          'shape:pixelCircle,sharpBurst,softBoom;type:outline',
        ],
      }).metadata;
      final stored = SubscriptionMetadata.fromJson(metadata.toJson());
      final hint = ProviderHints(stored).powerButton;
      expect(hint.shapes, [
        ProviderPowerShape.pixelCircle,
        ProviderPowerShape.softBoom,
        ProviderPowerShape.sharpBurst,
      ]);
      expect(hint.type, ProviderPowerType.outline);
    });

    test('shape lists do not relax other pair values', () {
      for (final headers in [
        {
          'reclash-view': ['proxies.type:list,tab'],
        },
        {
          'reclash-powerbutton': ['shape:cookie;type:solid,tonal'],
        },
        {
          'reclash-powerbutton': ['shape:cookie;unknown:one,two'],
        },
      ]) {
        final result = readSubscriptionMetadata(headers);
        expect(result.metadata.fields, isEmpty);
        expect(result.warnings, isNotEmpty);
      }
    });

    test('stored shape lists reject controls and retain token size limits', () {
      for (final value in [
        'cookie,flower\n',
        'cookie,flower\r',
        'cookie,flower\t',
        'cookie,/flower',
        List.filled(65, 'a').join(),
        List.filled(1500, 'cookie').join(','),
      ]) {
        final metadata = SubscriptionMetadata({
          'presentation.powerButton': {'shape': value, 'type': 'tonal'},
        });
        final stored = SubscriptionMetadata.fromJson(metadata.toJson());
        expect(stored.pairs('presentation.powerButton'), isEmpty);
      }
    });

    test('an explicit pool may include every supported shape', () {
      final names = ProviderPowerShape.values.map((shape) => shape.name);
      final hint = _hints({
        'reclash-powerbutton': ['shape:${names.join(',')};type:tonal'],
      }).powerButton;
      expect(hint.shapes, ProviderPowerShape.values);
      expect(hint.type, ProviderPowerType.tonal);
    });

    test('domestic routing names the region optionally', () {
      expect(
        _hints({
          'reclash-approuting': ['domestic'],
        }).domesticApps,
        (enabled: true, region: null),
      );
      expect(
        _hints({
          'reclash-approuting': ['domestic:ru'],
        }).domesticApps,
        (enabled: true, region: 'RU'),
      );
      expect(_hints({}).domesticApps.enabled, isFalse);
    });

    test('settings are null when the header is absent', () {
      expect(_hints({}).settings, isNull);
      final settings = _hints({
        'reclash-settings': ['autorun,minimize'],
      }).settings!;
      expect(settings[ProviderSettingFlag.autorun], isTrue);
      expect(settings[ProviderSettingFlag.openlogs], isFalse);
    });

    test('an announcement needs text and keeps only a safe link', () {
      expect(_hints({}).announcement, isNull);
      final announcement = _hints({
        'announce': ['Maintenance tonight'],
        'reclash-announceurl': ['https://status.example.test'],
      }).announcement!;
      expect(announcement.text, 'Maintenance tonight');
      expect(announcement.link?.host, 'status.example.test');
    });
  });

  group('provider messages', () {
    test(
      'notice and announcement decode independently and survive storage',
      () {
        final result = readSubscriptionMetadata({
          'announce': ['Plan description'],
          'reclash-announceurl': ['https://example.test/plan'],
          'reclash-notice': ['Maintenance tonight'],
          'reclash-noticeurl': ['https://example.test/status'],
        });
        final hints = ProviderHints(
          SubscriptionMetadata.fromJson(result.metadata.toJson()),
        );
        expect(hints.announcement?.text, 'Plan description');
        expect(hints.announcement?.link?.path, '/plan');
        expect(hints.notice?.text, 'Maintenance tonight');
        expect(hints.notice?.link?.path, '/status');
        expect(
          encodeSubscriptionMetadata(result.metadata)['reclash-notice'],
          'Maintenance tonight',
        );
      },
    );

    test('notice accepts body metadata and HTTP takes precedence', () {
      final result = readSubscriptionMetadata(
        {
          'reclash-notice': ['HTTP notice'],
        },
        body:
            '#reclash-notice: Body notice\n'
            '#reclash-noticeurl: https://example.test/status\n',
      );
      final hints = ProviderHints(result.metadata);
      expect(hints.notice?.text, 'HTTP notice');
      expect(hints.notice?.link?.path, '/status');
      expect(hints.announcement, isNull);
    });

    test('notice needs text and drops unsafe links', () {
      expect(
        _hints({
          'reclash-noticeurl': ['https://example.test'],
        }).notice,
        isNull,
      );
      expect(
        _hints({
          'reclash-notice': ['   '],
        }).notice,
        isNull,
      );
      final notice = _hints({
        'reclash-notice': ['Maintenance'],
        'reclash-noticeurl': ['javascript:alert(1)'],
      }).notice;
      expect(notice?.text, 'Maintenance');
      expect(notice?.link, isNull);
    });
  });

  group('settings engine', () {
    const view = {
      'reclash-view': ['proxies.type:list;app.black:true'],
    };

    test('a dark colour needs the colour and leaves with it', () {
      ProviderSettingsInput withView(String pairs) => _input({
        'reclash-view': [pairs],
      });
      final alone = applyProviderSettings(
        _base,
        withView('app.colordark:#eeddcc'),
      );
      expect(alone.themeProps.primaryColorDark, isNull);

      final both = applyProviderSettings(
        _base,
        withView('app.color:#112233;app.colordark:#eeddcc'),
      );
      expect(both.themeProps.primaryColorDark, 0xFFEEDDCC);
      expect(isProviderManaged(both, 'app.colordark'), isTrue);

      final withdrawn = applyProviderSettings(
        both,
        withView('app.color:#112233'),
      );
      expect(withdrawn.themeProps.primaryColorDark, isNull);
      expect(withdrawn.themeProps.primaryColor, 0xFF112233);
    });

    test('applies a provided value and remembers the user baseline', () {
      final config = applyProviderSettings(_base, _input(view));
      expect(config.proxiesStyleProps.type, ProxiesType.list);
      expect(config.themeProps.pureBlack, isTrue);
      expect(config.providerSettings.applied.keys, contains('proxies.type'));
      expect(
        config.providerSettings.userBaseline['proxies.type'],
        _base.proxiesStyleProps.type.name,
      );
      expect(isProviderManaged(config, 'proxies.type'), isTrue);
    });

    test('a user change is kept and reported as released', () {
      final applied = applyProviderSettings(_base, _input(view));
      final changed = applied.copyWith(
        proxiesStyleProps: applied.proxiesStyleProps.copyWith(
          type: ProxiesType.tab,
        ),
      );
      final after = applyProviderSettings(changed, _input(view));
      expect(after.proxiesStyleProps.type, ProxiesType.tab);
      expect(after.providerSettings.userOwned, contains('proxies.type'));
      expect(isProviderManaged(after, 'proxies.type'), isFalse);
      expect(isProviderReleased(after, _input(view), 'proxies.type'), isTrue);
      expect(after.themeProps.pureBlack, isTrue);
    });

    test('returning hands a released setting back', () {
      final applied = applyProviderSettings(_base, _input(view));
      final changed = applyProviderSettings(
        applied.copyWith(
          proxiesStyleProps: applied.proxiesStyleProps.copyWith(
            type: ProxiesType.tab,
          ),
        ),
        _input(view),
      );
      final returned = returnProviderSettings(changed, _input(view));
      expect(returned.proxiesStyleProps.type, ProxiesType.list);
      expect(returned.providerSettings.userOwned, isEmpty);
    });

    test('returning all also returns changes before the next sync', () {
      final input = _input(view);
      final applied = applyProviderSettings(_base, input);
      final changed = applied.copyWith(
        proxiesStyleProps: applied.proxiesStyleProps.copyWith(
          type: ProxiesType.tab,
        ),
        themeProps: applied.themeProps.copyWith(pureBlack: false),
      );

      final returned = returnProviderSettings(changed, input);

      expect(returned.proxiesStyleProps.type, ProxiesType.list);
      expect(returned.themeProps.pureBlack, isTrue);
      expect(returned.providerSettings.userOwned, isEmpty);
      expect(isProviderManaged(returned, 'proxies.type'), isTrue);
      expect(isProviderManaged(returned, 'app.black'), isTrue);
    });

    test('returning one fresh change keeps other settings released', () {
      final input = _input(view);
      final applied = applyProviderSettings(_base, input);
      final changed = applied.copyWith(
        proxiesStyleProps: applied.proxiesStyleProps.copyWith(
          type: ProxiesType.tab,
        ),
        themeProps: applied.themeProps.copyWith(pureBlack: false),
      );

      final returned = returnProviderSettings(
        changed,
        input,
        ids: ['proxies.type'],
      );

      expect(returned.proxiesStyleProps.type, ProxiesType.list);
      expect(returned.themeProps.pureBlack, isFalse);
      expect(returned.providerSettings.userOwned, {'app.black'});
      expect(isProviderManaged(returned, 'proxies.type'), isTrue);
    });

    test('withdrawing after returning restores the latest user value', () {
      final input = _input(view);
      final applied = applyProviderSettings(_base, input);
      final changed = applied.copyWith(
        proxiesStyleProps: applied.proxiesStyleProps.copyWith(
          type: ProxiesType.tab,
        ),
      );
      final returned = returnProviderSettings(changed, input);

      final withdrawn = applyProviderSettings(returned, _input(const {}));

      expect(returned.proxiesStyleProps.type, ProxiesType.list);
      expect(withdrawn.proxiesStyleProps.type, ProxiesType.tab);
      expect(withdrawn.providerSettings.applied, isEmpty);
    });

    test('returning all clears core overrides without resetting values', () {
      final patch = _base.patchClashConfig.copyWith(
        generalOverrideKeys: {GeneralOverrideKey.ipv6},
        dnsOverrideKeys: {DnsOverrideKey.nameserver},
        tunOverrideKeys: {TunOverrideKey.mtu},
        ipv6: false,
        dns: _base.patchClashConfig.dns.copyWith(nameserver: ['1.1.1.1']),
        tunOverride: _base.patchClashConfig.tunOverride.copyWith(mtu: 1400),
        secret: 'local-controller-secret',
        mixedPort: 8888,
      );
      final config = _base.copyWith(patchClashConfig: patch);

      final returned = returnProviderSettings(config, _input(const {}));

      expect(returned.patchClashConfig.generalOverrideKeys, isEmpty);
      expect(returned.patchClashConfig.dnsOverrideKeys, isEmpty);
      expect(returned.patchClashConfig.tunOverrideKeys, isEmpty);
      expect(returned.patchClashConfig.ipv6, isFalse);
      expect(returned.patchClashConfig.dns, patch.dns);
      expect(returned.patchClashConfig.tunOverride, patch.tunOverride);
      expect(returned.patchClashConfig.secret, patch.secret);
      expect(returned.patchClashConfig.mixedPort, patch.mixedPort);
      expect(returned.patchClashConfig.tun, patch.tun);
    });

    test('returning all restores provider apps in both access modes', () {
      final access = _base.vpnProps.accessControlProps.copyWith(
        enable: true,
        mode: AccessControlMode.acceptSelected,
        acceptList: ['com.user.included'],
        rejectList: ['com.user.excluded'],
        acceptReleased: ['com.provider.included'],
        rejectReleased: ['com.provider.excluded'],
      );
      final config = _base.copyWith(
        vpnProps: _base.vpnProps.copyWith(accessControlProps: access),
      );

      final returned = returnProviderSettings(config, _input(const {}));
      final restoredAccess = returned.vpnProps.accessControlProps;

      expect(restoredAccess.acceptReleased, isEmpty);
      expect(restoredAccess.rejectReleased, isEmpty);
      expect(restoredAccess.acceptList, access.acceptList);
      expect(restoredAccess.rejectList, access.rejectList);
      expect(restoredAccess.mode, access.mode);
      expect(restoredAccess.enable, access.enable);
    });

    test('returning one setting leaves core and app-list overrides alone', () {
      final input = _input(view);
      final applied = applyProviderSettings(_base, input);
      final patch = applied.patchClashConfig.copyWith(
        generalOverrideKeys: {GeneralOverrideKey.ipv6},
        dnsOverrideKeys: {DnsOverrideKey.nameserver},
        tunOverrideKeys: {TunOverrideKey.mtu},
      );
      final vpn = applied.vpnProps.copyWith(
        accessControlProps: applied.vpnProps.accessControlProps.copyWith(
          acceptReleased: ['com.provider.included'],
          rejectReleased: ['com.provider.excluded'],
        ),
      );
      final changed = applied.copyWith(
        patchClashConfig: patch,
        vpnProps: vpn,
        proxiesStyleProps: applied.proxiesStyleProps.copyWith(
          type: ProxiesType.tab,
        ),
      );

      final returned = returnProviderSettings(
        changed,
        input,
        ids: ['proxies.type'],
      );

      expect(returned.proxiesStyleProps.type, ProxiesType.list);
      expect(returned.patchClashConfig, patch);
      expect(returned.vpnProps, vpn);
    });

    test('withdrawing a header restores what the user had', () {
      final applied = applyProviderSettings(_base, _input(view));
      final withdrawn = applyProviderSettings(applied, _input(const {}));
      expect(withdrawn.proxiesStyleProps.type, _base.proxiesStyleProps.type);
      expect(withdrawn.providerSettings.applied, isEmpty);
    });

    test('withdrawing keeps a value the user changed meanwhile', () {
      final applied = applyProviderSettings(_base, _input(view));
      final changed = applied.copyWith(
        proxiesStyleProps: applied.proxiesStyleProps.copyWith(
          type: ProxiesType.tab,
        ),
      );
      final withdrawn = applyProviderSettings(changed, _input(const {}));
      expect(withdrawn.proxiesStyleProps.type, ProxiesType.tab);
    });

    test('a pending background leaves its setting untouched', () {
      final input = ProviderSettingsInput(
        _hints({
          'reclash-background': ['https://img.example.test/bg.png'],
        }),
        backgroundPending: true,
      );
      final config = applyProviderSettings(_base, input);
      expect(
        config.providerSettings.applied.containsKey('background'),
        isFalse,
      );
    });

    test('the announcement token is ignored as unknown', () {
      expect(
        _hints({
          'reclash-widgets': ['announcement'],
        }).widgets,
        isNull,
      );
      final config = applyProviderSettings(
        _base,
        _input({
          'reclash-widgets': ['announcement'],
        }),
      );
      expect(
        config.appSettingProps.dashboardWidgets,
        _base.appSettingProps.dashboardWidgets,
      );
      expect(
        _hints({
          'reclash-widgets': ['announcement,profiles'],
        }).widgets,
        [DashboardWidget.profiles],
      );
    });

    test('widgets keep the current outbound card', () {
      final config = applyProviderSettings(
        _base,
        _input({
          'reclash-widgets': ['profiles'],
        }),
      );
      expect(
        config.appSettingProps.dashboardWidgets,
        containsAll([
          DashboardWidget.currentOutbound,
          DashboardWidget.profiles,
        ]),
      );
    });
  });
}

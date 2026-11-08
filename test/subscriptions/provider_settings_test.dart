import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/subscriptions/provider_settings.dart';

import '../helpers/provider_presentation.dart';

final _base = Config.realFromJson(null);

ProviderHints _hints(Map<String, List<String>> headers) =>
    ProviderHints(readSubscriptionMetadata(headers).metadata);

ProviderSettingsInput _input(Map<String, List<String>> headers) =>
    ProviderSettingsInput(_hints(headers));

void main() {
  group('header decoding', () {
    test('standard headers fill the fields and scale the interval', () {
      final metadata = readSubscriptionMetadata({
        'profile-update-interval': ['12'],
        'support-url': ['https://support.example.test'],
        'profile-title': ['Plan'],
      }).metadata;
      expect(metadata.count('update.intervalMinutes'), 720);
      expect(metadata.text('provider.supportUrl'), isNotNull);
      expect(metadata.text('account.title'), 'Plan');
    });

    test('manifest buy links carry their suffixes', () {
      final metadata = manifestMetadata({
        'provider': {
          'renew': {'url': 'https://buy.example.test/plan', 'days': 7},
          'top-up': {'url': 'https://buy.example.test/gb', 'percent': 80},
        },
      });
      expect(
        metadata.text('provider.buyPlanUrl'),
        'https://buy.example.test/plan',
      );
      expect(metadata.count('provider.buyPlanDays'), 7);
      expect(metadata.count('provider.buyTrafficPercent'), 80);
    });

    test('an out-of-range suffix withdraws the provider section', () {
      final result = parseProviderConfig(
        jsonEncode({
          'version': 1,
          'provider': {
            'name': 'Acme',
            'top-up': {'url': 'https://buy.example.test/gb', 'percent': 500},
          },
        }),
        'en',
      );
      expect(result.config?.fields, isEmpty);
      expect(result.warnings, isNotEmpty);
    });

    test('one malformed package withdraws the apps section', () {
      final result = parseProviderConfig(
        jsonEncode({
          'version': 1,
          'apps': {
            'exclude': ['com.bank.app', 'not a package', 'ru.gov.app'],
          },
        }),
        'en',
      );
      expect(result.config?.fields.containsKey('apps.exclude'), isFalse);
      expect(result.warnings, isNotEmpty);
    });

    test('other reclash headers are unsupported and decode nothing', () {
      final result = readSubscriptionMetadata({
        'reclash-notice': ['Maintenance'],
        'reclash-settings': ['autorun'],
        'flclashx-hideurl': ['true'],
      });
      expect(result.metadata.fields, isEmpty);
      expect(
        result.warnings,
        containsAll([
          'Unsupported provider field: reclash-notice',
          'Unsupported provider field: reclash-settings',
        ]),
      );
    });

    test('the manifest config header needs an HTTPS response', () {
      const headers = {
        'reclash-config': ['https://cdn.example.test/reclash.yaml'],
      };
      expect(
        readSubscriptionMetadata(headers).warnings,
        contains('Provider field needs an HTTPS response: reclash-config'),
      );
      expect(readSubscriptionMetadata(headers, secure: true).warnings, isEmpty);
    });

    test('config package lists join the manifest lists', () {
      final merged = withManifest(
        readSubscriptionMetadata(const {}),
        parseProviderConfig(
          jsonEncode({
            'version': 1,
            'apps': {
              'exclude': ['com.one.app'],
            },
          }),
          'en',
        ).config,
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
      final view = presentedHints({
        'view': {
          'proxies': {'type': 'list', 'sort': 'bogus'},
          'app': {'navbar': 'floating', 'color': '#ff8800'},
          'unknown': {'x': 'y'},
        },
      }).view;
      expect(view.proxiesType, ProxiesType.list);
      expect(view.proxiesSort, isNull);
      expect(view.floatingNavigationBar, isTrue);
      expect(view.primaryColor, 0xffff8800);
      expect(view.primaryColorDark, isNull);
    });

    test('power button pairs fall back to the default per key', () {
      expect(_hints({}).powerButton, defaultProviderPowerButtonHint);
      final flower = presentedHints({
        'power-button': {'shape': 'flower', 'type': 'outline'},
      }).powerButton;
      expect(flower.shapes, [ProviderPowerShape.flower]);
      expect(flower.type, ProviderPowerType.outline);
      final unknown = presentedHints({
        'power-button': {'shape': 'bogus', 'type': 'tonal', 'unknown': 'x'},
      }).powerButton;
      expect(unknown.shapes, [ProviderPowerShape.cookie]);
      expect(unknown.type, ProviderPowerType.tonal);
    });

    test('all power button shapes accept case-insensitive names', () {
      expect(ProviderPowerShape.values, hasLength(21));
      for (final shape in ProviderPowerShape.values) {
        final hint = presentedHints({
          'power-button': {'shape': shape.name.toUpperCase(), 'type': 'bogus'},
        }).powerButton;
        expect(hint.shapes, [shape]);
        expect(hint.type, ProviderPowerType.solid);
      }
    });

    test('random offers every concrete power button shape', () {
      final hint = presentedHints({
        'power-button': {'SHAPE': ' RaNdOm ', 'TYPE': 'OUTLINE'},
      }).powerButton;
      expect(hint.shapes, ProviderPowerShape.values);
      expect(hint.type, ProviderPowerType.outline);
      expect(() => hint.shapes.clear(), throwsUnsupportedError);
    });

    test('power button lists ignore unknown names and duplicate weights', () {
      final hint = presentedHints({
        'power-button': {
          'shape': [
            'PuffyDiamond',
            'cookie',
            'unknown',
            'COOKIE',
            'clover8Leaf',
          ],
          'type': 'tonal',
        },
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
        final hint = presentedHints({
          'power-button': {'shape': value, 'type': 'outline'},
        }).powerButton;
        expect(hint.shapes, [ProviderPowerShape.cookie]);
        expect(hint.type, ProviderPowerType.outline);
      }
    });

    test('power button pools retain only the listed concrete shapes', () {
      final hint = presentedHints({
        'power-button': {'shape': 'random,puffy,puffy'},
      }).powerButton;
      expect(hint.shapes, [ProviderPowerShape.puffy]);
    });

    test('an explicit pool may include every supported shape', () {
      final names = ProviderPowerShape.values.map((shape) => shape.name);
      final hint = presentedHints({
        'power-button': {'shape': names.toList(), 'type': 'tonal'},
      }).powerButton;
      expect(hint.shapes, ProviderPowerShape.values);
      expect(hint.type, ProviderPowerType.tonal);
    });

    test('domestic routing names the region optionally', () {
      ProviderHints routing(String value) => ProviderHints(
        manifestMetadata({
          'apps': {'routing': value},
        }),
      );
      expect(routing('domestic').domesticApps, (enabled: true, region: null));
      expect(routing('domestic:ru').domesticApps, (
        enabled: true,
        region: 'RU',
      ));
      expect(_hints({}).domesticApps.enabled, isFalse);
    });

    test('settings are null without a section and touch only listed keys', () {
      expect(_hints({}).settings, isNull);
      final settings = ProviderHints(
        manifestMetadata({
          'settings': {'launch-at-login': true, 'minimize-on-exit': false},
        }),
      ).settings!;
      expect(settings[ProviderSettingFlag.autorun], isTrue);
      expect(settings[ProviderSettingFlag.minimize], isFalse);
      expect(settings.containsKey(ProviderSettingFlag.openlogs), isFalse);
    });

    test('a non-boolean setting withdraws the whole section', () {
      expect(
        manifestMetadata({
          'settings': {'launch-at-login': true, 'capture-logs': 'yes'},
        }).fields,
        isEmpty,
      );
    });

    test('an announcement needs text and keeps only a safe link', () {
      expect(_hints({}).announcement, isNull);
      final announcement = ProviderHints(
        manifestMetadata({
          'provider': {
            'announce': {
              'text': 'Maintenance tonight',
              'url': 'https://status.example.test',
            },
          },
        }),
      ).announcement!;
      expect(announcement.text, 'Maintenance tonight');
      expect(announcement.link?.host, 'status.example.test');
    });
  });

  group('provider messages', () {
    test(
      'notice and announcement decode independently and survive storage',
      () {
        final result = SubscriptionMetadata.fromJson(
          manifestMetadata({
            'provider': {
              'announce': {
                'text': 'Plan description',
                'url': 'https://example.test/plan',
              },
              'notice': {
                'text': 'Maintenance tonight',
                'url': 'https://example.test/status',
              },
            },
          }).toJson(),
        );
        final hints = ProviderHints(result);
        expect(hints.announcement?.text, 'Plan description');
        expect(hints.announcement?.link?.path, '/plan');
        expect(hints.notice?.text, 'Maintenance tonight');
        expect(hints.notice?.link?.path, '/status');
      },
    );

    test('the announce header is the fallback and the manifest wins', () {
      final headers = readSubscriptionMetadata({
        'announce': ['Header plan'],
      });
      expect(ProviderHints(headers.metadata).announcement?.text, 'Header plan');
      final merged = withManifest(
        headers,
        parseProviderConfig(
          jsonEncode({
            'version': 1,
            'provider': {
              'announce': {'text': 'Manifest plan'},
              'notice': {'text': 'Manifest notice'},
            },
          }),
          'en',
        ).config,
        excluded: const [],
        included: const [],
      );
      final hints = ProviderHints(merged.metadata);
      expect(hints.announcement?.text, 'Manifest plan');
      expect(hints.notice?.text, 'Manifest notice');
    });

    test('notice needs text and an unsafe link withdraws it', () {
      Map<String, Object?> notice(Map<String, Object?> value) => {
        'provider': {'notice': value},
      };
      expect(
        ProviderHints(
          manifestMetadata(notice({'url': 'https://example.test'})),
        ).notice,
        isNull,
      );
      expect(
        ProviderHints(manifestMetadata(notice({'text': '   '}))).notice,
        isNull,
      );
      expect(
        ProviderHints(
          manifestMetadata(
            notice({'text': 'Maintenance', 'url': 'javascript:alert(1)'}),
          ),
        ).notice,
        isNull,
      );
    });
  });

  group('settings engine', () {
    final view = presentedHints({
      'view': {
        'proxies': {'type': 'list'},
        'app': {'black': true},
      },
    });

    test('a dark colour needs the colour and leaves with it', () {
      ProviderSettingsInput withView(Map<String, Object?> app) =>
          ProviderSettingsInput(
            presentedHints({
              'view': {'app': app},
            }),
          );
      final alone = applyProviderSettings(
        _base,
        withView({'color-dark': '#eeddcc'}),
      );
      expect(alone.themeProps.primaryColorDark, isNull);

      final both = applyProviderSettings(
        _base,
        withView({'color': '#112233', 'color-dark': '#eeddcc'}),
      );
      expect(both.themeProps.primaryColorDark, 0xFFEEDDCC);
      expect(isProviderManaged(both, 'app.colordark'), isTrue);

      final withdrawn = applyProviderSettings(
        both,
        withView({'color': '#112233'}),
      );
      expect(withdrawn.themeProps.primaryColorDark, isNull);
      expect(withdrawn.themeProps.primaryColor, 0xFF112233);
    });

    test('applies a provided value and remembers the user baseline', () {
      final config = applyProviderSettings(_base, ProviderSettingsInput(view));
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
      final applied = applyProviderSettings(_base, ProviderSettingsInput(view));
      final changed = applied.copyWith(
        proxiesStyleProps: applied.proxiesStyleProps.copyWith(
          type: ProxiesType.tab,
        ),
      );
      final after = applyProviderSettings(changed, ProviderSettingsInput(view));
      expect(after.proxiesStyleProps.type, ProxiesType.tab);
      expect(after.providerSettings.userOwned, contains('proxies.type'));
      expect(isProviderManaged(after, 'proxies.type'), isFalse);
      expect(
        isProviderReleased(after, ProviderSettingsInput(view), 'proxies.type'),
        isTrue,
      );
      expect(after.themeProps.pureBlack, isTrue);
    });

    test('returning hands a released setting back', () {
      final applied = applyProviderSettings(_base, ProviderSettingsInput(view));
      final changed = applyProviderSettings(
        applied.copyWith(
          proxiesStyleProps: applied.proxiesStyleProps.copyWith(
            type: ProxiesType.tab,
          ),
        ),
        ProviderSettingsInput(view),
      );
      final returned = returnProviderSettings(
        changed,
        ProviderSettingsInput(view),
      );
      expect(returned.proxiesStyleProps.type, ProxiesType.list);
      expect(returned.providerSettings.userOwned, isEmpty);
    });

    test('returning all also returns changes before the next sync', () {
      final input = ProviderSettingsInput(view);
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
      final input = ProviderSettingsInput(view);
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
      final input = ProviderSettingsInput(view);
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
      final input = ProviderSettingsInput(view);
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
      final applied = applyProviderSettings(_base, ProviderSettingsInput(view));
      final withdrawn = applyProviderSettings(applied, _input(const {}));
      expect(withdrawn.proxiesStyleProps.type, _base.proxiesStyleProps.type);
      expect(withdrawn.providerSettings.applied, isEmpty);
    });

    test('withdrawing keeps a value the user changed meanwhile', () {
      final applied = applyProviderSettings(_base, ProviderSettingsInput(view));
      final changed = applied.copyWith(
        proxiesStyleProps: applied.proxiesStyleProps.copyWith(
          type: ProxiesType.tab,
        ),
      );
      final withdrawn = applyProviderSettings(changed, _input(const {}));
      expect(withdrawn.proxiesStyleProps.type, ProxiesType.tab);
    });

    test('a user value outlives a profile without it and a later update', () {
      final applied = applyProviderSettings(_base, ProviderSettingsInput(view));
      final changed = applied.copyWith(
        proxiesStyleProps: applied.proxiesStyleProps.copyWith(
          type: ProxiesType.tab,
        ),
      );
      final other = applyProviderSettings(changed, _input(const {}));
      expect(other.providerSettings.userOwned, contains('proxies.type'));
      final back = applyProviderSettings(other, ProviderSettingsInput(view));
      expect(back.proxiesStyleProps.type, ProxiesType.tab);
      expect(
        isProviderReleased(back, ProviderSettingsInput(view), 'proxies.type'),
        isTrue,
      );
    });

    test('a pending background leaves its setting untouched', () {
      final input = ProviderSettingsInput(
        presentedHints({
          'wallpaper': {'url': 'https://img.example.test/bg.png'},
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
        presentedHints({
          'widgets': ['announcement'],
        }).widgets,
        isNull,
      );
      final config = applyProviderSettings(
        _base,
        ProviderSettingsInput(
          presentedHints({
            'widgets': ['announcement'],
          }),
        ),
      );
      expect(
        config.appSettingProps.dashboardWidgets,
        _base.appSettingProps.dashboardWidgets,
      );
      expect(
        presentedHints({
          'widgets': ['announcement', 'profiles'],
        }).widgets,
        [DashboardWidget.profiles],
      );
    });

    test('widgets keep the current outbound card', () {
      final config = applyProviderSettings(
        _base,
        ProviderSettingsInput(
          presentedHints({
            'widgets': ['profiles'],
          }),
        ),
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

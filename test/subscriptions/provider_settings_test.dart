import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
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

  group('settings engine', () {
    const view = {
      'reclash-view': ['proxies.type:list;app.black:true'],
    };

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

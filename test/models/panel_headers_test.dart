import 'package:reclash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('normalizePanelHeaders', () {
    test('maps wire keys to canonical keys case-insensitively', () {
      final map = normalizePanelHeaders({
        'X-HWID-Max-Devices-Reached': ['true'],
        'Announce': ['panel text'],
        'Support-Url': ['https://support.example.com'],
      });

      expect(map, {
        'hwidMaxDevicesReached': 'true',
        'announce': 'panel text',
        'supportUrl': 'https://support.example.com',
      });
    });

    test('reclash namespace outranks compatibility headers', () {
      final map = normalizePanelHeaders({
        'reclash-autoupdateinterval': ['30'],
        'profile-update-interval': ['5'],
        'reclash-supporturl': ['https://reclash.example.com'],
        'flclashx-supporturl': ['https://flclashx.example.com'],
      });

      expect(map['updateIntervalMinutes'], '30');
      expect(map['supportUrl'], 'https://reclash.example.com');
    });

    test('converts the compatibility interval from hours to minutes', () {
      final map = normalizePanelHeaders({
        'profile-update-interval': ['5'],
      });

      expect(map['updateIntervalMinutes'], '300');
    });

    test('drops unknown and empty headers', () {
      final map = normalizePanelHeaders({
        'x-unknown-panel-header': ['value'],
        'profile-update-interval': ['  '],
        'another': ['', 'ignored'],
      });

      expect(map, isEmpty);
    });

    test('ignores non-positive intervals', () {
      for (final value in ['0', '-3', 'abc']) {
        final map = normalizePanelHeaders({
          'profile-update-interval': [value],
        });
        expect(map, isEmpty, reason: 'interval "$value" must not apply');
      }
    });
  });

  group('PanelMeta.fromHeaders', () {
    test('parses verdicts and interval', () {
      final meta = PanelMeta.fromHeaders({
        'x-hwid-max-devices-reached': ['true'],
        'x-hwid-not-supported': ['True'],
        'announce': ['limit text'],
        'support-url': ['https://support.example.com'],
        'reclash-autoupdateinterval': ['45'],
      });

      expect(meta.hwidMaxDevicesReached, isTrue);
      expect(meta.hwidNotSupported, isTrue);
      expect(meta.announce, 'limit text');
      expect(meta.supportUrl, 'https://support.example.com');
      expect(meta.updateIntervalMinutes, 45);
      expect(meta.hasContent, isTrue);
    });

    test('parses service and widget headers', () {
      final meta = PanelMeta.fromHeaders({
        'reclash-servicename': ['Example VPN'],
        'reclash-servicelogo': ['https://example.com/logo.svg'],
        'reclash-serverinfo': ['Selector'],
        'reclash-widgets': ['announce, metainfo, outboundModeV2'],
        'reclash-custom': ['update'],
      });

      expect(meta.serviceName, 'Example VPN');
      expect(meta.serviceLogo, 'https://example.com/logo.svg');
      expect(meta.serverInfoGroup, 'Selector');
      expect(meta.widgets, ['announce', 'metainfo', 'outboundModeV2']);
      expect(meta.widgetsApplyMode, PanelWidgetsApplyMode.update);
      expect(meta.hasContent, isTrue);
    });

    test('flclashx compatibility spellings map to the same fields', () {
      final meta = PanelMeta.fromHeaders({
        'flclashx-servicename': ['Example VPN'],
        'flclashx-servicelogo': ['https://example.com/logo.svg'],
        'flclashx-serverinfo': ['Selector'],
        'flclashx-buyplan': ['https://example.com/buy/plan'],
        'flclashx-buytraffic': ['https://example.com/buy/traffic'],
      });

      expect(meta.serviceName, 'Example VPN');
      expect(meta.serviceLogo, 'https://example.com/logo.svg');
      expect(meta.serverInfoGroup, 'Selector');
      expect(meta.buyPlanUrl, 'https://example.com/buy/plan');
      expect(meta.buyTrafficUrl, 'https://example.com/buy/traffic');
      expect(meta.hasContent, isTrue);
    });

    test('buy links fall back from buyplan to buytraffic', () {
      final meta = PanelMeta.fromHeaders({
        'flclashx-buytraffic': ['https://example.com/buy/traffic'],
      });

      expect(meta.buyPlanUrl, isNull);
      expect(meta.buyTrafficUrl, 'https://example.com/buy/traffic');
    });

    test('widgets apply mode defaults to add', () {
      final meta = PanelMeta.fromHeaders({
        'reclash-widgets': ['announce'],
      });

      expect(meta.widgetsApplyMode, PanelWidgetsApplyMode.add);
    });

    test('parses app setting tokens lowercased', () {
      final meta = PanelMeta.fromHeaders({
        'reclash-settings': ['Minimize, AUTORUN, closeconnections'],
      });

      expect(meta.settings, [
        'minimize',
        'autorun',
        'closeconnections',
      ]);
    });

    test('empty response yields inert meta', () {
      final meta = PanelMeta.fromHeaders({
        'content-type': ['application/yaml'],
        'server': ['nginx'],
      });

      expect(meta, const PanelMeta());
      expect(meta.hasContent, isFalse);
    });
  });
}

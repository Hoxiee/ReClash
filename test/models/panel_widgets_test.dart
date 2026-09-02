import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('parsePanelWidgets', () {
    test('matches names case-insensitively and keeps order', () {
      final widgets = parsePanelWidgets(
        ['announce', 'MetaInfo', 'outboundModeV2'],
        platform: SupportPlatform.Linux,
      );

      expect(widgets, [
        DashboardWidget.announce,
        DashboardWidget.metaInfo,
        DashboardWidget.outboundModeV2,
      ]);
    });

    test('drops unknown names and duplicates', () {
      final widgets = parsePanelWidgets(
        ['announce', 'nope', 'ANNOUNCE', ''],
        platform: SupportPlatform.Linux,
      );

      expect(widgets, [DashboardWidget.announce]);
    });

    test('drops widgets unavailable on the platform', () {
      final widgets = parsePanelWidgets(
        ['announce', 'vpnButton', 'tunButton'],
        platform: SupportPlatform.Android,
      );

      expect(widgets, [
        DashboardWidget.announce,
        DashboardWidget.vpnButton,
      ]);
    });
  });

  group('applyPanelWidgets', () {
    final panelList = [
      DashboardWidget.announce,
      DashboardWidget.metaInfo,
    ];

    test('update mode replaces the dashboard outright', () {
      final next = applyPanelWidgets(
        panelWidgets: panelList,
        mode: PanelWidgetsApplyMode.update,
        current: defaultDashboardWidgets,
        previousPanelWidgets: const [],
      );

      expect(next, panelList);
    });

    test('add mode takes over from the default list', () {
      final next = applyPanelWidgets(
        panelWidgets: panelList,
        mode: PanelWidgetsApplyMode.add,
        current: defaultDashboardWidgets,
        previousPanelWidgets: const [],
      );

      expect(next, panelList);
    });

    test('add mode takes over from the panel previous list', () {
      final previous = [DashboardWidget.announce];
      final next = applyPanelWidgets(
        panelWidgets: panelList,
        mode: PanelWidgetsApplyMode.add,
        current: previous,
        previousPanelWidgets: previous,
      );

      expect(next, panelList);
    });

    test('add mode only appends to a user-customized list', () {
      final current = [
        DashboardWidget.networkSpeed,
        DashboardWidget.memoryInfo,
      ];
      final next = applyPanelWidgets(
        panelWidgets: panelList,
        mode: PanelWidgetsApplyMode.add,
        current: current,
        previousPanelWidgets: const [],
      );

      expect(next, [...current, ...panelList]);
    });

    test('an empty panel list changes nothing', () {
      final next = applyPanelWidgets(
        panelWidgets: const [],
        mode: PanelWidgetsApplyMode.update,
        current: defaultDashboardWidgets,
        previousPanelWidgets: const [],
      );

      expect(next, defaultDashboardWidgets);
    });
  });
}

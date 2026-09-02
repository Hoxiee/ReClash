import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/config.dart';
import 'package:reclash/models/panel_meta.dart';

List<DashboardWidget> parsePanelWidgets(
  List<String> names, {
  SupportPlatform? platform,
}) {
  final currentPlatform = platform ?? SupportPlatform.currentPlatform;
  final byName = {
    for (final item in DashboardWidget.values) item.name.toLowerCase(): item,
  };
  final result = <DashboardWidget>[];
  for (final name in names) {
    final widget = byName[name.trim().toLowerCase()];
    if (widget == null || !widget.platforms.contains(currentPlatform)) continue;
    if (!result.contains(widget)) {
      result.add(widget);
    }
  }
  return result;
}

// `add` only takes over ordering while the current list is still the app
// default or the panel's own previous list.
List<DashboardWidget> applyPanelWidgets({
  required List<DashboardWidget> panelWidgets,
  required PanelWidgetsApplyMode mode,
  required List<DashboardWidget> current,
  required List<DashboardWidget> previousPanelWidgets,
  List<DashboardWidget> defaults = defaultDashboardWidgets,
}) {
  if (panelWidgets.isEmpty) return current;
  final userCustomized =
      !sameWidgets(current, defaults) &&
      !sameWidgets(current, previousPanelWidgets);
  if (mode == PanelWidgetsApplyMode.update || !userCustomized) {
    return panelWidgets;
  }
  return [
    ...current,
    ...panelWidgets.where((item) => !current.contains(item)),
  ];
}

bool sameWidgets(List<DashboardWidget> a, List<DashboardWidget> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

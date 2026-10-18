import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/tool_route.dart';
import 'package:reclash/views/config/advanced.dart';
import 'package:reclash/views/config/custom_resources.dart';
import 'package:reclash/views/config/dns.dart';
import 'package:reclash/views/config/general.dart';
import 'package:reclash/views/config/network.dart';
import 'package:reclash/views/config/on_demand.dart';
import 'package:reclash/views/config/user_agents.dart';
import 'package:reclash/views/application_setting.dart';

void main() {
  final specs = [
    ...ApplicationSettings.all,
    ...GeneralSettings.all,
    ...advancedToolSettings,
    ...networkToolSettings,
    ...dnsToolSettings,
    ...onDemandToolSettings,
    ...userAgentToolSettings,
    ...customResourceToolSettings,
  ];

  test('view setting specs have unique IDs and routes preserve identity', () {
    final ids = specs.map((spec) => spec.id).toList();
    expect(ids.toSet(), hasLength(ids.length));

    for (final spec in specs) {
      expect(
        spec.route,
        ToolRoute(spec.page, settingId: spec.id),
        reason: spec.id,
      );
      expect(spec.route.page, spec.page, reason: spec.id);
      expect(spec.route.settingId, spec.id, reason: spec.id);
    }
  });
}

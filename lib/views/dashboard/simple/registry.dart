import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/ui/icons/icons.dart';

import 'address_card.dart';
import 'mode_card.dart';
import 'path_card.dart';
import 'services_card.dart';
import 'speed_card.dart';
import 'trusted_networks_card.dart';

extension SimpleDashboardWidgetView on SimpleDashboardWidget {
  Widget get card => switch (this) {
    SimpleDashboardWidget.outboundMode => const SimpleModeCard(),
    SimpleDashboardWidget.speed => const SimpleSpeedCard(),
    SimpleDashboardWidget.services => const SimpleServicesCard(),
    SimpleDashboardWidget.ipQuality => const SimpleAddressCard(),
    SimpleDashboardWidget.trustedNetworks => const SimpleTrustedNetworksCard(),
    SimpleDashboardWidget.path => const SimplePathCard(),
  };

  Glyph get glyph => switch (this) {
    SimpleDashboardWidget.outboundMode => AppGlyphs.shuffle,
    SimpleDashboardWidget.speed => AppGlyphs.speed,
    SimpleDashboardWidget.services => AppGlyphs.verified,
    SimpleDashboardWidget.ipQuality => AppGlyphs.eye,
    SimpleDashboardWidget.trustedNetworks => AppGlyphs.wifi,
    SimpleDashboardWidget.path => AppGlyphs.status,
  };

  String label(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return switch (this) {
      SimpleDashboardWidget.outboundMode => appLocalizations.simpleModeTitle,
      SimpleDashboardWidget.speed => appLocalizations.simpleSpeedTitle,
      SimpleDashboardWidget.services => appLocalizations.simpleServicesTitle,
      SimpleDashboardWidget.ipQuality => appLocalizations.simpleIpTitle,
      SimpleDashboardWidget.trustedNetworks =>
        appLocalizations.simpleTrustedTitle,
      SimpleDashboardWidget.path => appLocalizations.doctorPathTitle,
    };
  }
}

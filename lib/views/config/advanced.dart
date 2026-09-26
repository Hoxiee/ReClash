import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/clash_config.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/views/config/desync.dart';
import 'package:reclash/views/config/dns.dart';
import 'package:reclash/views/config/network.dart';
import 'package:reclash/views/config/smart_pause.dart';
import 'package:reclash/views/config/smart_routing.dart';
import 'package:reclash/views/config/scripts.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rules.dart';

class AdvancedConfigView extends ConsumerWidget {
  const AdvancedConfigView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final generalItems = [
      DecorationListItem.open(
        title: Text(appLocalizations.network),
        subtitle: Text(appLocalizations.networkDesc),
        leading: const GlyphIcon(AppGlyphs.key),
        blur: false,
        widget: BaseScaffold(
          title: appLocalizations.network,
          body: const NetworkListView(),
        ),
      ),
      DecorationListItem.open(
        title: const Text('DNS'),
        subtitle: Text(appLocalizations.dnsDesc),
        leading: const GlyphIcon(AppGlyphs.dns),
        widget: BaseScaffold(
          title: 'DNS',
          actions: [
            Consumer(
              builder: (_, ref, _) {
                return IconButton(
                  onPressed: () async {
                    final res = await dialogs.showMessage(
                      dangerous: true,
                      title: appLocalizations.reset,
                      message: TextSpan(text: appLocalizations.resetTip),
                    );
                    if (res != true) {
                      return;
                    }
                    ref
                        .read(patchClashConfigProvider.notifier)
                        .update((state) => state.copyWith(dns: defaultDns));
                  },
                  tooltip: appLocalizations.reset,
                  icon: const GlyphIcon(AppGlyphs.replay),
                );
              },
            ),
          ],
          body: const DnsListView(),
        ),
        blur: false,
      ),
      DecorationListItem.open(
        title: Text(appLocalizations.addedRules),
        subtitle: Text(appLocalizations.controlGlobalAddedRules),
        leading: const GlyphIcon(AppGlyphs.document),
        widget: const AddedRulesView(),
        blur: false,
      ),
      DecorationListItem.open(
        title: Text(appLocalizations.script),
        subtitle: Text(appLocalizations.overrideScript),
        leading: const GlyphIcon(AppGlyphs.script),
        widget: const ScriptsView(),
        blur: false,
      ),
    ];
    final extraItems = [
      DecorationListItem.open(
        title: Text(appLocalizations.smartPause),
        subtitle: Text(appLocalizations.smartPauseDesc),
        leading: const GlyphIcon(AppGlyphs.signalChart),
        widget: const SmartPauseView(),
        blur: false,
      ),
      DecorationListItem.open(
        title: Text(appLocalizations.smartRouting),
        subtitle: Text(appLocalizations.smartRoutingDesc),
        leading: const GlyphIcon(AppGlyphs.smartRoute),
        trailing: const ExperimentalBadge(),
        widget: const SmartRoutingView(),
        blur: false,
      ),
      // The engine is an Android JNI module; on desktop the entry would only
      // produce rules pointing at a listener that never exists.
      if (ref.watch(byeDpiSupportedProvider))
        DecorationListItem.open(
          title: Text(appLocalizations.desync),
          subtitle: Text(appLocalizations.desyncDesc),
          leading: const GlyphIcon(AppGlyphs.bolt),
          trailing: const ExperimentalBadge(),
          widget: const DesyncView(),
          blur: false,
        ),
    ];
    return BaseScaffold(
      title: appLocalizations.advancedConfig,
      body: SettingsListView(
        children: [
          SettingSection(top: 16, items: generalItems),
          SettingSection(
            title: appLocalizations.extra,
            items: extraItems,
            enterDelay: const Duration(milliseconds: 50),
          ),
          const SettingBottomInset(),
        ],
      ),
    );
  }
}

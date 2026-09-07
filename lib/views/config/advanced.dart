import 'package:reclash/common/common.dart';
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
    final developerMode = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    final generalItems = [
      DecorationListItem.open(
        title: Text(appLocalizations.network),
        subtitle: Text(appLocalizations.networkDesc),
        leading: const Icon(Icons.vpn_key),
        blur: false,
        widget: BaseScaffold(
          title: appLocalizations.network,
          body: const NetworkListView(),
        ),
      ),
      DecorationListItem.open(
        title: const Text('DNS'),
        subtitle: Text(appLocalizations.dnsDesc),
        leading: const Icon(Icons.dns),
        widget: BaseScaffold(
          title: 'DNS',
          actions: [
            Consumer(
              builder: (_, ref, _) {
                return IconButton(
                  onPressed: () async {
                    final res = await dialogs.showMessage(
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
                  icon: const Icon(Icons.replay),
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
        leading: const Icon(Icons.library_books),
        widget: const AddedRulesView(),
        blur: false,
      ),
      DecorationListItem.open(
        title: Text(appLocalizations.script),
        subtitle: Text(appLocalizations.overrideScript),
        leading: const Icon(Icons.rocket, fontWeight: FontWeight.w900),
        widget: const ScriptsView(),
        blur: false,
      ),
    ];
    final extraItems = [
      DecorationListItem.open(
        title: Text(appLocalizations.smartPause),
        subtitle: Text(appLocalizations.smartPauseDesc),
        leading: const Icon(Icons.ssid_chart, fontWeight: FontWeight.w900),
        widget: const SmartPauseView(),
        blur: false,
      ),
      DecorationListItem.open(
        title: Text(appLocalizations.smartRouting),
        subtitle: Text(appLocalizations.smartRoutingDesc),
        leading: const Icon(Icons.alt_route_rounded),
        widget: const SmartRoutingView(),
        blur: false,
      ),
      // The engine is an Android JNI module; on desktop the entry would only
      // produce rules pointing at a listener that never exists.
      if (system.isAndroid && developerMode)
        DecorationListItem.open(
          title: Text(appLocalizations.desync),
          subtitle: Text(appLocalizations.desyncDesc),
          leading: const Icon(Icons.bolt_rounded),
          trailing: const CommonChip(label: 'Experimental'),
          widget: const DesyncView(),
          blur: false,
        ),
    ];
    return BaseScaffold(
      title: appLocalizations.advancedConfig,
      body: ListView(
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

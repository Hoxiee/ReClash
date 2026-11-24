import 'package:reclash/models/tool_route.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/config/dns.dart';
import 'package:reclash/views/config/network.dart';
import 'package:reclash/views/config/routing.dart';
import 'package:reclash/views/config/scripts.dart';
import 'package:reclash/views/site_lock.dart';
import 'package:reclash/views/telegram_proxy.dart';
import 'package:material_ui/material_ui.dart';

import 'rules.dart';

class AdvancedConfigView extends StatelessWidget {
  const AdvancedConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final items = [
      SettingTarget(
        spec: advancedToolSettings[0],
        child: ListItem.open(
          title: Text(advancedToolSettings[0].title(appLocalizations)),
          leading: const GlyphIcon(AppGlyphs.key),
          widget: const NetworkView(),
        ),
      ),
      ListItem.open(
        title: const Text('DNS'),
        leading: const GlyphIcon(AppGlyphs.dns),
        widget: const DnsView(),
      ),
      SettingTarget(
        spec: advancedToolSettings[1],
        child: ListItem.open(
          title: Text(advancedToolSettings[1].title(appLocalizations)),
          leading: const GlyphIcon(AppGlyphs.rules),
          widget: const AddedRulesView(),
        ),
      ),
      ListItem.open(
        title: Text(appLocalizations.siteLockTitle),
        leading: const GlyphIcon(AppGlyphs.lock),
        widget: const SiteLockView(),
      ),
      SettingTarget(
        spec: advancedToolSettings[2],
        child: ListItem.open(
          title: Text(advancedToolSettings[2].title(appLocalizations)),
          leading: const GlyphIcon(AppGlyphs.code),
          widget: const ScriptsView(),
        ),
      ),
    ];
    return BaseScaffold(
      title: appLocalizations.advancedConfig,
      body: SettingsPageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.sectionsTopPadding, bottom: 16),
          child: Column(
            children: [
              generateSection(items: items),
              generateSection(
                title: appLocalizations.rcxTitle,
                items: [
                  ListItem.open(
                    title: Text(appLocalizations.rcxScenarios),
                    leading: const GlyphIcon(AppGlyphs.shuffle),
                    widget: const RoutingScenariosView(),
                  ),
                  ListItem.open(
                    title: Text(appLocalizations.rcxSmartGroups),
                    leading: const GlyphIcon(AppGlyphs.layers),
                    widget: const ScriptedGroupsView(),
                  ),
                ],
              ),
              generateSection(
                title: appLocalizations.extra,
                items: [
                  ListItem.open(
                    title: Text(appLocalizations.telegramProxyTitle),
                    leading: const GlyphIcon(AppGlyphs.send),
                    widget: const TelegramProxyView(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final advancedToolSettings = <SettingSpec>[
  SettingSpec(
    id: 'advanced.network',
    page: ToolPage.advanced,
    title: (l) => l.network,
    keywords: ['network'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'advanced.addedRules',
    page: ToolPage.advanced,
    title: (l) => l.addedRules,
    keywords: ['addedRules'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'advanced.script',
    page: ToolPage.advanced,
    title: (l) => l.script,
    keywords: ['script'],
    condition: SettingCondition.always,
  ),
];

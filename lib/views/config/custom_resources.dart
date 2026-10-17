import 'package:reclash/models/tool_route.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/config/filters.dart';
import 'package:reclash/views/config/icon_sets.dart';
import 'package:reclash/views/config/providers.dart';
import 'package:reclash/views/profiles/custom/custom_proxies.dart';
import 'package:material_ui/material_ui.dart';

class CustomResourcesView extends StatelessWidget {
  const CustomResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final items = [
      SettingTarget(
        spec: customResourceToolSettings[0],
        child: ListItem.open(
          title: Text(customResourceToolSettings[0].title(appLocalizations)),
          leading: const GlyphIcon(AppGlyphs.proxies),
          widget: const CustomProxiesView(),
        ),
      ),
      SettingTarget(
        spec: customResourceToolSettings[1],
        child: ListItem.open(
          title: Text(customResourceToolSettings[1].title(appLocalizations)),
          leading: const GlyphIcon(AppGlyphs.resources),
          widget: const ClashProvidersView(),
        ),
      ),
      SettingTarget(
        spec: customResourceToolSettings[2],
        child: ListItem.open(
          title: Text(customResourceToolSettings[2].title(appLocalizations)),
          leading: const GlyphIcon(AppGlyphs.filter),
          widget: const FiltersView(),
        ),
      ),
      SettingTarget(
        spec: customResourceToolSettings[3],
        child: ListItem.open(
          title: Text(customResourceToolSettings[3].title(appLocalizations)),
          leading: const GlyphIcon(AppGlyphs.photos),
          widget: const IconSetsView(),
        ),
      ),
    ];
    return BaseScaffold(
      title: appLocalizations.customProfileResources,
      body: SettingsPageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.contentTopPadding, bottom: 16),
          child: Column(children: [generateSection(items: items)]),
        ),
      ),
    );
  }
}

final customResourceToolSettings = <SettingSpec>[
  SettingSpec(
    id: 'customResources.proxies',
    page: ToolPage.customResources,
    title: (l) => l.proxies,
    keywords: ['proxies'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'customResources.ruleProviders',
    page: ToolPage.customResources,
    title: (l) => l.ruleProviders,
    keywords: ['ruleProviders'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'customResources.filters',
    page: ToolPage.customResources,
    title: (l) => l.filters,
    keywords: ['filters'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'customResources.iconSets',
    page: ToolPage.customResources,
    title: (l) => l.iconSets,
    keywords: ['iconSets'],
    condition: SettingCondition.always,
  ),
];

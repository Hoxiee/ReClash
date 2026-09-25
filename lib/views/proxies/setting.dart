import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxiesSetting extends StatelessWidget {
  const ProxiesSetting({super.key});

  Glyph _getIconWithProxiesType(ProxiesType type) {
    return switch (type) {
      ProxiesType.tab => AppGlyphs.carousel,
      ProxiesType.list => AppGlyphs.list,
    };
  }

  Glyph _getIconWithProxiesSortType(ProxiesSortType type) {
    return switch (type) {
      ProxiesSortType.none => AppGlyphs.sort,
      ProxiesSortType.delay => AppGlyphs.networkCheck,
      ProxiesSortType.name => AppGlyphs.sortAlpha,
    };
  }

  String _getStringProxiesSortType(BuildContext context, ProxiesSortType type) {
    final appLocalizations = context.appLocalizations;
    return switch (type) {
      ProxiesSortType.none => appLocalizations.defaultText,
      ProxiesSortType.delay => appLocalizations.delay,
      ProxiesSortType.name => appLocalizations.name,
    };
  }

  String getTextForProxiesLayout(
    BuildContext context,
    ProxiesLayout proxiesLayout,
  ) {
    final appLocalizations = context.appLocalizations;
    return switch (proxiesLayout) {
      ProxiesLayout.tight => appLocalizations.tight,
      ProxiesLayout.standard => appLocalizations.standard,
      ProxiesLayout.loose => appLocalizations.loose,
    };
  }

  String _getTextWithProxiesIconStyle(
    BuildContext context,
    ProxiesIconStyle style,
  ) {
    final appLocalizations = context.appLocalizations;
    return switch (style) {
      ProxiesIconStyle.standard => appLocalizations.standard,
      ProxiesIconStyle.none => appLocalizations.none,
      ProxiesIconStyle.icon => appLocalizations.onlyIcon,
    };
  }

  List<Widget> _buildStyleSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      isFirst: true,
      title: appLocalizations.style,
      items: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer(
            builder: (_, ref, _) {
              final proxiesType = ref.watch(
                effectiveProxiesStyleProvider.select((state) => state.type),
              );
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in ProxiesType.values)
                    SettingInfoCard(
                      Info(
                        label: item.label,
                        glyph: _getIconWithProxiesType(item),
                      ),
                      isSelected: proxiesType == item,
                      onPressed: () {
                        ref.read(proxiesStyleSettingProvider.notifier).update((
                          state,
                        ) {
                          return state
                              .claim(ProxiesStyleField.type)
                              .copyWith(type: item);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSortSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.sort,
      items: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer(
            builder: (_, ref, _) {
              final sortType = ref.watch(
                effectiveProxiesStyleProvider.select((state) => state.sortType),
              );
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in ProxiesSortType.values)
                    SettingInfoCard(
                      Info(
                        label: _getStringProxiesSortType(context, item),
                        glyph: _getIconWithProxiesSortType(item),
                      ),
                      isSelected: sortType == item,
                      onPressed: () {
                        ref.read(proxiesStyleSettingProvider.notifier).update((
                          state,
                        ) {
                          return state
                              .claim(ProxiesStyleField.sortType)
                              .copyWith(sortType: item);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSizeSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.size,
      items: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer(
            builder: (_, ref, _) {
              final cardType = ref.watch(
                effectiveProxiesStyleProvider.select((state) => state.cardType),
              );
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in ProxyCardType.values)
                    SettingTextCard(
                      item.label,
                      isSelected: item == cardType,
                      onPressed: () {
                        ref.read(proxiesStyleSettingProvider.notifier).update((
                          state,
                        ) {
                          return state
                              .claim(ProxiesStyleField.cardType)
                              .copyWith(cardType: item);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLayoutSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.layout,
      items: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer(
            builder: (_, ref, _) {
              final layout = ref.watch(
                effectiveProxiesStyleProvider.select((state) => state.layout),
              );
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in ProxiesLayout.values)
                    SettingTextCard(
                      getTextForProxiesLayout(context, item),
                      isSelected: item == layout,
                      onPressed: () {
                        ref.read(proxiesStyleSettingProvider.notifier).update((
                          state,
                        ) {
                          return state
                              .claim(ProxiesStyleField.layout)
                              .copyWith(layout: item);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupStyleSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.iconStyle,
      items: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer(
            builder: (_, ref, _) {
              final iconStyle = ref.watch(
                effectiveProxiesStyleProvider.select(
                  (state) => state.iconStyle,
                ),
              );
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in ProxiesIconStyle.values)
                    SettingTextCard(
                      _getTextWithProxiesIconStyle(context, item),
                      isSelected: iconStyle == item,
                      onPressed: () {
                        ref.read(proxiesStyleSettingProvider.notifier).update((
                          state,
                        ) {
                          return state
                              .claim(ProxiesStyleField.iconStyle)
                              .copyWith(iconStyle: item);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPanelSetting(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Consumer(
      builder: (_, ref, _) {
        final hasPanelView = ref.watch(
          currentProfileProvider.select(
            (state) =>
                parsePanelProxiesView(state?.panelMeta?.proxiesView) != null,
          ),
        );
        if (!hasPanelView) return const SizedBox.shrink();
        final followPanel = ref.watch(
          proxiesStyleSettingProvider.select((state) => state.followPanel),
        );
        void update(bool value) {
          ref
              .read(proxiesStyleSettingProvider.notifier)
              .update(
                (state) => state.copyWith(
                  followPanel: value,
                  userOwned: value ? const {} : state.userOwned,
                ),
              );
        }

        return SettingSection(
          top: 12,
          items: [
            DecorationListItem(
              minVerticalPadding: 8,
              contentPadding: const EdgeInsets.only(left: 16, right: 8),
              title: Text(appLocalizations.providerView),
              subtitle: Text(appLocalizations.providerViewDesc),
              onPressed: () => update(!followPanel),
              trailing: Switch(value: followPanel, onChanged: update),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildStyleSetting(context),
          ..._buildSortSetting(context),
          ..._buildLayoutSetting(context),
          ..._buildSizeSetting(context),
          Consumer(
            builder: (_, ref, child) {
              final isList = ref.watch(
                effectiveProxiesStyleProvider.select(
                  (state) => state.type == ProxiesType.list,
                ),
              );
              if (isList) {
                return child!;
              }
              return Container();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [..._buildGroupStyleSetting(context)],
            ),
          ),
          _buildPanelSetting(context),
        ],
      ),
    );
  }
}

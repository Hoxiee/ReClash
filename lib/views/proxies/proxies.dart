import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/proxies/list.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routing.dart';
import 'tab.dart';

class ProxiesView extends ConsumerStatefulWidget {
  const ProxiesView({super.key, this.picker = false});

  /// Leaves the bar only its search and delay test, for picking a proxy from a
  /// sheet.
  final bool picker;

  @override
  ConsumerState<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<ProxiesView> {
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();

  // The same instance on every build, so the bar changing with the current
  // group or its delay test leaves the page alone.
  late final _tabView = ProxiesTabView(key: _proxiesTabKey);
  bool _isTab = false;

  void _updateStyle(
    ProxiesStyleProps Function(ProxiesStyleProps state) update,
  ) {
    ref.read(proxiesStyleSettingProvider.notifier).update(update);
  }

  String? _providerSubtitle(String id) =>
      switch (ref.watch(providerSettingStatusProvider(id))) {
        ProviderSettingStatus.managed =>
          context.appLocalizations.providerSettingManaged,
        ProviderSettingStatus.released =>
          context.appLocalizations.providerSettingReturn,
        ProviderSettingStatus.none => null,
      };

  List<CommonPopupMenuItem> _buildMenuItems(
    BuildContext context,
    ProxiesStyleProps style,
  ) {
    final appLocalizations = context.appLocalizations;
    return [
      _optionsMenuItem(
        glyph: AppGlyphs.appsList,
        label: appLocalizations.style,
        subtitle: _providerSubtitle('proxies.type'),
        section: const CommonPopupMenuSection(),
        options: ProxiesType.values,
        value: style.type,
        textOf: (type) => type.label,
        onSelected: (type) =>
            _updateStyle((state) => state.copyWith(type: type)),
      ),
      _optionsMenuItem(
        glyph: AppGlyphs.sort,
        label: appLocalizations.sort,
        subtitle: _providerSubtitle('proxies.sort'),
        options: ProxiesSortType.values,
        value: style.sortType,
        textOf: (type) => switch (type) {
          ProxiesSortType.none => appLocalizations.defaultText,
          ProxiesSortType.delay => appLocalizations.delay,
          ProxiesSortType.name => appLocalizations.name,
        },
        onSelected: (type) =>
            _updateStyle((state) => state.copyWith(sortType: type)),
      ),
      _optionsMenuItem(
        glyph: AppGlyphs.dashboard,
        label: appLocalizations.layout,
        subtitle: _providerSubtitle('proxies.layout'),
        options: ProxiesLayout.values,
        value: style.layout,
        textOf: (layout) => switch (layout) {
          ProxiesLayout.tight => appLocalizations.tight,
          ProxiesLayout.standard => appLocalizations.standard,
          ProxiesLayout.loose => appLocalizations.loose,
        },
        onSelected: (layout) =>
            _updateStyle((state) => state.copyWith(layout: layout)),
      ),
      _optionsMenuItem(
        glyph: AppGlyphs.textSize,
        label: appLocalizations.size,
        subtitle: _providerSubtitle('proxies.card'),
        options: ProxyCardType.values,
        value: style.cardType,
        textOf: (type) => type.label,
        onSelected: (type) =>
            _updateStyle((state) => state.copyWith(cardType: type)),
      ),
      if (style.type == ProxiesType.list)
        _optionsMenuItem(
          glyph: AppGlyphs.iconTile,
          label: appLocalizations.iconStyle,
          subtitle: _providerSubtitle('proxies.icon'),
          options: ProxiesIconStyle.values,
          value: style.iconStyle,
          textOf: (iconStyle) => switch (iconStyle) {
            ProxiesIconStyle.filled => appLocalizations.iconStyleFilled,
            ProxiesIconStyle.plain => appLocalizations.iconStylePlain,
            ProxiesIconStyle.hidden => appLocalizations.iconStyleHidden,
          },
          onSelected: (iconStyle) =>
              _updateStyle((state) => state.copyWith(iconStyle: iconStyle)),
        ),
      for (final (id, label) in [
        ('proxies.type', appLocalizations.style),
        ('proxies.sort', appLocalizations.sort),
        ('proxies.layout', appLocalizations.layout),
        ('proxies.card', appLocalizations.size),
        ('proxies.icon', appLocalizations.iconStyle),
      ])
        if (ref.watch(providerSettingStatusProvider(id)) ==
            ProviderSettingStatus.released)
          CommonPopupMenuItem(
            label: context.appLocalizations.providerSettingReturn,
            subtitle: label,
            onPressed: () =>
                ref.read(providerSettingsActionProvider).returnToProvider([id]),
          ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.eyeOff,
        label: appLocalizations.hideTimeoutProxies,
        checked: style.hideTimeoutProxies,
        section: const CommonPopupMenuSection(),
        onPressed: () => _updateStyle(
          (state) =>
              state.copyWith(hideTimeoutProxies: !state.hideTimeoutProxies),
        ),
      ),
    ];
  }

  IconButtonData? _buildPrimaryAction() {
    if (!_isTab) {
      return null;
    }
    final isDelayTesting = ref.watch(currentGroupDelayTestingProvider);
    return IconButtonData(
      glyph: AppGlyphs.bolt,
      onPressed: () {
        _proxiesTabKey.currentState?.delayTestCurrentGroup();
      },
      tooltip: context.appLocalizations.delayTest,
      isLoading: isDelayTesting,
    );
  }

  IconButtonData? _buildRoutingAction() {
    final groupName = ref.watch(
      proxiesTabControllerStateProvider.select(
        (state) => state.currentGroupName,
      ),
    );
    final isSelector = ref.watch(
      groupsProvider.select(
        (groups) =>
            groups.getGroup(groupName ?? '')?.type == GroupType.Selector,
      ),
    );
    if (groupName == null || !isSelector) return null;
    return IconButtonData(
      glyph: AppGlyphs.shuffle,
      onPressed: () => unawaited(showRoutingSheet(context, groupName)),
      tooltip: context.appLocalizations.rcxTitle,
    );
  }

  IconButtonData _buildFoldAction() {
    final groups = ref.watch(
      proxiesListStateProvider.select((state) => state.groups),
    );
    final groupNames = {for (final group in groups) group.name};
    final unfoldSet = ref.watch(unfoldSetProvider);
    final hasExpanded = groupNames.any(unfoldSet.contains);
    return IconButtonData(
      glyph: hasExpanded ? AppGlyphs.collapseAll : AppGlyphs.expandAll,
      tooltip: hasExpanded
          ? context.appLocalizations.collapseAllGroups
          : context.appLocalizations.expandAllGroups,
      onPressed: groupNames.isEmpty
          ? null
          : () {
              final next = Set<String>.of(ref.read(unfoldSetProvider));
              if (hasExpanded) {
                next.removeAll(groupNames);
              } else {
                next.addAll(groupNames);
              }
              ref
                  .read(proxiesActionProvider.notifier)
                  .updateCurrentUnfoldSet(next);
            },
    );
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.proxies).notifier).value = value;
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      proxiesStyleSettingProvider.select(
        (state) => state.type == ProxiesType.tab,
      ),
      (prev, next) {
        if (prev != next) {
          setState(() {
            _isTab = next;
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = ref.watch(proxiesStyleSettingProvider);
    final isLoading = ref.watch(loadingProvider(LoadingTag.proxies));
    final picker = widget.picker;
    final primaryAction = _buildPrimaryAction();
    return CommonScaffold(
      isLoading: isLoading,
      resizeToAvoidBottomInset: false,
      primaryAction: primaryAction,
      searchActions: [?primaryAction],
      actionGroupSize: _isTab && !picker ? 3 : 2,
      iconActions: [
        if (_isTab && !picker)
          IconButtonData(
            glyph: AppGlyphs.locate,
            onPressed: () {
              _proxiesTabKey.currentState?.scrollToGroupSelected();
            },
            tooltip: context.appLocalizations.scrollToSelected,
          ),
        if (_isTab && !picker) ?_buildRoutingAction(),
        if (!_isTab && !picker) _buildFoldAction(),
      ],
      menuItems: picker ? const [] : _buildMenuItems(context, style),
      title: context.appLocalizations.proxies,
      searchState: AppBarSearchState(onSearch: _onSearch),
      body: switch (style.type) {
        ProxiesType.tab => _tabView,
        ProxiesType.list => const ProxiesListView(),
      },
    );
  }
}

CommonPopupMenuItem _optionsMenuItem<T>({
  required Glyph glyph,
  required String label,
  required List<T> options,
  required T value,
  required String Function(T option) textOf,
  required ValueSetter<T> onSelected,
  CommonPopupMenuSection? section,
  String? subtitle,
}) {
  return CommonPopupMenuItem(
    glyph: glyph,
    label: label,
    subtitle: subtitle,
    section: section,
    subItems: [
      for (final option in options)
        CommonPopupMenuItem(
          label: textOf(option),
          checked: option == value,
          onPressed: () => onSelected(option),
        ),
    ],
  );
}

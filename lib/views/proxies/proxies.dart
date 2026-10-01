import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/proxies/list.dart';
import 'package:reclash/views/proxies/providers.dart';
import 'package:reclash/widgets/widgets.dart';

import 'setting.dart';
import 'tab.dart';

class ProxiesView extends ConsumerStatefulWidget {
  const ProxiesView({super.key});

  @override
  ConsumerState<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<ProxiesView> {
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();
  bool _hasProviders = false;
  bool _isTab = false;
  bool _isDelayTesting = false;

  Future<void> _delayTestCurrentGroup() async {
    if (_isDelayTesting) {
      return;
    }
    setState(() => _isDelayTesting = true);
    try {
      await _proxiesTabKey.currentState?.delayTestCurrentGroup();
    } finally {
      if (mounted) {
        setState(() => _isDelayTesting = false);
      }
    }
  }

  IconButtonData? _buildPrimaryAction() {
    if (!_isTab) {
      return null;
    }
    return IconButtonData(
      glyph: AppGlyphs.bolt,
      onPressed: _delayTestCurrentGroup,
      tooltip: context.appLocalizations.delayTest,
      isLoading: _isDelayTesting,
    );
  }

  List<IconButtonData> _buildIconActions(bool smartRoutingPinned) {
    final appLocalizations = context.appLocalizations;
    return [
      if (smartRoutingPinned)
        IconButtonData(
          glyph: AppGlyphs.autoMode,
          tooltip: appLocalizations.smartRoutingBackToAuto,
          onPressed: () {
            ref.read(proxiesActionProvider.notifier).resumeSmartRouting();
          },
        ),
      if (_isTab)
        IconButtonData(
          glyph: AppGlyphs.locate,
          onPressed: () {
            _proxiesTabKey.currentState?.scrollToGroupSelected();
          },
          tooltip: appLocalizations.scrollToSelected,
        ),
    ];
  }

  List<CommonPopupMenuItem> _buildMenuItems(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.sliders,
        label: appLocalizations.settings,
        onPressed: () {
          showSheet(
            context: context,
            props: const SheetProps(isScrollControlled: true),
            builder: (_) {
              return AdaptiveSheetScaffold(
                body: const ProxiesSetting(),
                title: appLocalizations.settings,
              );
            },
          );
        },
      ),
      if (_hasProviders)
        CommonPopupMenuItem(
          glyph: AppGlyphs.layers,
          label: appLocalizations.providers,
          onPressed: () {
            showExtend(
              context,
              builder: (_) {
                return const ProvidersView();
              },
            );
          },
        ),
    ];
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.proxies).notifier).value = value;
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(providersProvider.select((state) => state.isNotEmpty), (
      prev,
      next,
    ) {
      if (prev != next) {
        setState(() {
          _hasProviders = next;
        });
      }
    }, fireImmediately: true);
    ref.listenManual(
      effectiveProxiesStyleProvider.select(
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
    final proxiesType = ref.watch(
      effectiveProxiesStyleProvider.select((state) => state.type),
    );
    final isLoading = ref.watch(loadingProvider(LoadingTag.proxies));
    final smartRoutingPinned = ref.watch(
      smartRoutingStatusProvider.select(
        (state) => state?.enabled == true && state!.pinned,
      ),
    );
    return CommonScaffold(
      isLoading: isLoading,
      floatBody: true,
      resizeToAvoidBottomInset: false,
      primaryAction: _buildPrimaryAction(),
      pinPrimaryAction: true,
      pinPrimaryActionTrailing: true,
      iconActions: _buildIconActions(smartRoutingPinned),
      menuItems: _buildMenuItems(context),
      title: context.appLocalizations.proxies,
      searchState: AppBarSearchState(onSearch: _onSearch),
      body: switch (proxiesType) {
        ProxiesType.tab => ProxiesTabView(key: _proxiesTabKey),
        ProxiesType.list => const ProxiesListView(),
      },
    );
  }
}

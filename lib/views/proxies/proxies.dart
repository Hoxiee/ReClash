import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/proxies/list.dart';
import 'package:reclash/views/proxies/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  List<IconButtonData> _buildIconActions() {
    if (!_isTab) {
      return const [];
    }
    final appLocalizations = context.appLocalizations;
    return [
      IconButtonData(
        glyph: AppGlyphs.bolt,
        onPressed: _delayTestCurrentGroup,
        tooltip: appLocalizations.delayTest,
        isLoading: _isDelayTesting,
      ),
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
    return CommonScaffold(
      isLoading: isLoading,
      floatBody: true,
      resizeToAvoidBottomInset: false,
      iconActions: _buildIconActions(),
      menuItems: _buildMenuItems(context),
      actions: const [_ResumeSmartRoutingButton()],
      title: context.appLocalizations.proxies,
      searchState: AppBarSearchState(onSearch: _onSearch),
      body: switch (proxiesType) {
        ProxiesType.tab => ProxiesTabView(key: _proxiesTabKey),
        ProxiesType.list => const ProxiesListView(),
      },
    );
  }
}

class _ResumeSmartRoutingButton extends ConsumerWidget {
  const _ResumeSmartRoutingButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinned = ref.watch(
      smartRoutingStatusProvider.select(
        (state) => state?.enabled == true && state!.pinned,
      ),
    );
    return FadeScaleBox(
      child: !pinned
          ? const SizedBox()
          : IconButton(
              tooltip: context.appLocalizations.smartRoutingBackToAuto,
              onPressed: () {
                ref.read(proxiesActionProvider.notifier).resumeSmartRouting();
              },
              icon: const GlyphIcon(AppGlyphs.autoMode),
            ),
    );
  }
}

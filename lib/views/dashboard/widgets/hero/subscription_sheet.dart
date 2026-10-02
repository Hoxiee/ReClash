import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/profiles/profiles.dart';
import 'package:reclash/views/profiles/subscription_report.dart';
import 'package:reclash/widgets/widgets.dart';

const _statSpacing = 8.0;

Future<void> showSubscriptionSheet(BuildContext context, {Profile? profile}) {
  return showSheet<void>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) =>
        NestedPagedSheet(builder: (_) => _SubscriptionSheet(profile: profile)),
  );
}

typedef ConfigCounts = ({int groups, int proxies, int rules});

typedef ProfileStats = ({int groups, int proxies, int rules, int providers});

/// Counts what the Core was handed, overwrites included, rather than what the
/// profile file declares.
ConfigCounts configCountsOf(Map<String, dynamic> config) {
  int lengthOf(Object? value) => value is List ? value.length : 0;
  return (
    groups: lengthOf(config['proxy-groups']),
    proxies: lengthOf(config['proxies']),
    rules: lengthOf(config['rules']),
  );
}

ProfileStats profileStatsOf(
  ConfigCounts counts,
  List<ExternalProvider> providers,
) {
  final providedProxies = providers
      .where((provider) => provider.type == 'Proxy')
      .fold(0, (sum, provider) => sum + provider.count);
  return (
    groups: counts.groups,
    proxies: counts.proxies + providedProxies,
    rules: counts.rules,
    providers: providers.length,
  );
}

/// Kept until another config is applied: parsing one is slow on a large profile.
({String md5, ConfigCounts counts})? _countsCache;

ConfigCounts? _cachedCounts() {
  final cache = _countsCache;
  final md5 = globalState.lastConfigMd5;
  return cache != null && cache.md5 == md5 ? cache.counts : null;
}

class _SubscriptionSheet extends ConsumerStatefulWidget {
  const _SubscriptionSheet({this.profile});

  final Profile? profile;

  @override
  ConsumerState<_SubscriptionSheet> createState() => _SubscriptionSheetState();
}

class _SubscriptionSheetState extends ConsumerState<_SubscriptionSheet> {
  ConfigCounts? _counts = _cachedCounts();
  var _failed = false;
  var _loadStarted = false;
  var _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStarted) {
      return;
    }
    _loadStarted = true;
    if (_counts == null) {
      unawaited(_load(afterRoute: true));
    }
  }

  // Decoding a large config mid-transition drops the sheet's frames.
  Future<void> _load({bool afterRoute = false}) async {
    final generation = ++_generation;
    if (afterRoute) {
      await whenRouteSettled(context);
      if (!mounted) {
        return;
      }
    }
    final md5 = globalState.lastConfigMd5;
    ConfigCounts? counts;
    try {
      counts = configCountsOf(
        await ref.read(coreHandlerProvider).getAppliedConfig(),
      );
    } catch (error) {
      commonPrint.log(
        'read applied config error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
    if (!mounted || generation != _generation) {
      return;
    }
    if (counts != null && md5 != null) {
      _countsCache = (md5: md5, counts: counts);
    }
    setState(() {
      _counts = counts ?? _counts;
      _failed = counts == null;
    });
  }

  Future<void> _sync(Profile profile) async {
    try {
      await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile, showLoading: true);
    } catch (error) {
      dialogs.showNotifier(
        userFacingErrorMessage(error, currentAppLocalizations),
        level: MessageLevel.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    // Groups refresh after every applied setup, and after a proxy switch too.
    ref.listen(groupsProvider, (_, _) {
      if (_cachedCounts() == null) {
        unawaited(_load());
      }
    });
    final profile = widget.profile ?? ref.watch(currentProfileProvider);
    if (profile == null) {
      return AdaptiveSheetScaffold(
        title: l10n.metaInfo,
        body: Center(child: Text(l10n.nullProfileDesc)),
      );
    }
    final panelMeta = profile.panelMeta;
    final serviceName = panelMeta?.serviceName?.trim();
    final displayName = serviceName == null || serviceName.isEmpty
        ? profile.realLabel
        : serviceName;
    final supportUrl = panelMeta?.supportUrl;
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    return AdaptiveSheetScaffold(
      title: displayName,
      actions: [
        if (profile.type == ProfileType.url)
          IconButtonData(
            glyph: AppGlyphs.sync,
            tooltip: l10n.sync,
            isLoading: isUpdating,
            onPressed: () => unawaited(_sync(profile)),
          ),
      ],
      menuItems: [
        if (supportUrl != null && supportUrl.isNotEmpty)
          CommonPopupMenuItem(
            label: l10n.support,
            glyph: AppGlyphs.support,
            onPressed: () => unawaited(dialogs.openUrl(supportUrl)),
          ),
      ],
      body: _Body(profile: profile, counts: _counts, failed: _failed),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.profile,
    required this.counts,
    required this.failed,
  });

  final Profile profile;
  final ConfigCounts? counts;
  final bool failed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.appLocalizations;
    final providers = ref.watch(providersProvider);
    final stats = switch (counts) {
      final value? => profileStatsOf(value, providers),
      null => null,
    };
    final info = profile.subscriptionInfo;
    final announce = profile.panelMeta?.announce?.trim();
    return ListView(
      shrinkWrap: true,
      // The scaffold already reserves the toolbar height above the body.
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(bottom: 20 + BottomInsetScope.of(context)),
      children: [
        _StatsGrid(stats: stats, failed: failed),
        if (info != null && info.hasFacts) ...[
          const SizedBox(height: AppSpacing.lg),
          generateSectionV3(
            title: l10n.subscriptionInfo,
            items: [
              DecorationListItem(
                title: SubscriptionInfoView(subscriptionInfo: info),
              ),
            ],
          ),
        ],
        if (announce != null && announce.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          generateSectionV3(
            title: l10n.announce,
            items: [DecorationListItem(title: Text(announce))],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        generateSectionV3(
          title: l10n.profile,
          items: [
            DetailRow(
              title: l10n.lastUpdated,
              value: LastUpdateTimeText(lastUpdateDate: profile.lastUpdateDate),
            ),
            DetailRow(
              title: l10n.overrideMode,
              value: Text(_overwriteLabel(context, profile.overwriteType)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        generateSectionV3(items: _actions(context)),
      ],
    );
  }

  List<Widget> _actions(BuildContext context) {
    final l10n = context.appLocalizations;
    final panelMeta = profile.panelMeta;
    final colorScheme = context.colorScheme;
    final buyPlanUrl = panelMeta?.buyPlanUrl;
    final buyTrafficUrl = panelMeta?.buyTrafficUrl;
    final webPageUrl = panelMeta?.webPageUrl;
    final reportUrl = panelMeta?.reportUrl;
    Widget link() => GlyphIcon(
      AppGlyphs.link,
      size: 18,
      color: colorScheme.onSurfaceVariant,
    );
    Widget chevron() => GlyphIcon(
      AppGlyphs.chevronForward,
      size: 18,
      color: colorScheme.onSurfaceVariant,
    );
    return [
      if (buyPlanUrl != null && buyPlanUrl.isNotEmpty)
        DecorationListItem(
          leading: const GlyphIcon(AppGlyphs.sync),
          title: Text(l10n.renewSubscription),
          trailing: link(),
          onPressed: () => unawaited(dialogs.openUrl(buyPlanUrl)),
        ),
      if (buyTrafficUrl != null && buyTrafficUrl.isNotEmpty)
        DecorationListItem(
          leading: const GlyphIcon(AppGlyphs.install),
          title: Text(l10n.topUpTraffic),
          trailing: link(),
          onPressed: () => unawaited(dialogs.openUrl(buyTrafficUrl)),
        ),
      if (webPageUrl != null && webPageUrl.isNotEmpty)
        DecorationListItem(
          leading: const GlyphIcon(AppGlyphs.account),
          title: Text(l10n.personalCabinet),
          trailing: link(),
          onPressed: () => unawaited(dialogs.openUrl(webPageUrl)),
        ),
      DecorationListItem(
        leading: const GlyphIcon(AppGlyphs.send),
        title: Text(l10n.subscriptionReport),
        trailing: chevron(),
        onPressed: () => unawaited(
          openSubscriptionReportSheet(context, reportUrl: reportUrl),
        ),
      ),
    ];
  }
}

String _overwriteLabel(BuildContext context, OverwriteType type) {
  return switch (type) {
    OverwriteType.standard => context.appLocalizations.standard,
    OverwriteType.script => context.appLocalizations.script,
    OverwriteType.custom => context.appLocalizations.overwriteTypeCustom,
  };
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.failed});

  final ProfileStats? stats;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final stats = this.stats;
    final tiles = <(String, int?)>[
      (l10n.proxyGroup, stats?.groups),
      (l10n.proxyNode, stats?.proxies),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        spacing: _statSpacing,
        children: [
          for (final (label, value) in tiles)
            Expanded(
              child: _StatTile(
                label: label,
                value: value?.toString() ?? (failed ? '-' : null),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainer,
        shape: AppShape.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(
            value ?? '0',
            maxLines: 1,
            style: context.textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

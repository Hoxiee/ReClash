import 'dart:async';
import 'package:reclash/icons/icons.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/announce.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_words.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps one detail block in the surface its host uses: the sheet paints a
/// solid card, the dashboard board a translucent one over the wallpaper.
typedef SubscriptionCardWrap = Widget Function(Widget child, {Color? tone});

/// The single source for the subscription facts. Every surface that shows them
/// -- the sheet, the pager's second page, the split board's right column --
/// builds from this list so a fact lives in one place, not three.
List<Widget> subscriptionDetailCards(
  BuildContext context,
  Profile profile, {
  required SubscriptionCardWrap wrap,
}) {
  final panelMeta = profile.panelMeta;
  final announce = panelMeta?.announce?.trim();
  return [
    for (final notice in _notices(context, profile))
      wrap(_NoticeBody(notice: notice), tone: notice.tone),
    _ProviderCard(profile: profile, wrap: wrap),
    if (announce != null && announce.isNotEmpty)
      wrap(_AnnounceBody(text: announce)),
    wrap(const _SystemBody()),
  ];
}

class SubscriptionOverviewView extends ConsumerWidget {
  const SubscriptionOverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) {
      return CommonScaffold(
        title: appLocalizations.metaInfo,
        floatBody: true,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: context.appBarInset),
            ),
            _sliver(
              _sheetCard(
                _NoticeBody(
                  notice: (
                    icon: AppGlyphs.folder,
                    text: appLocalizations.nullProfileDesc,
                    tone: null,
                  ),
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      );
    }

    return CommonScaffold(
      title: appLocalizations.metaInfo,
      floatBody: true,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: context.appBarInset)),
          for (final card in subscriptionDetailCards(
            context,
            profile,
            wrap: (child, {tone}) => _sheetCard(child, tone: tone),
          ))
            _sliver(card),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

Widget _sliver(Widget child) => SliverPadding(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
  sliver: SliverToBoxAdapter(child: child),
);

/// The sheet's own surface: solid card, tinted when a notice carries a tone.
Widget _sheetCard(Widget child, {Color? tone}) =>
    _Card(tone: tone, child: child);

typedef _Notice = ({Glyph icon, String text, Color? tone});

List<_Notice> _notices(BuildContext context, Profile profile) {
  final appLocalizations = context.appLocalizations;
  final colorScheme = context.colorScheme;
  final panelMeta = profile.panelMeta;
  final newDomain = panelMeta?.newDomain?.trim();
  return [
    if (profile.undialableNodes)
      (
        icon: AppGlyphs.wifiOff,
        text: appLocalizations.subscriptionUndialable,
        tone: colorScheme.error,
      ),
    if (panelMeta?.hwidMaxDevicesReached ?? false)
      (
        icon: AppGlyphs.devices,
        text: appLocalizations.deviceLimitReached,
        tone: colorScheme.error,
      ),
    if (panelMeta?.hwidNotSupported ?? false)
      (
        icon: AppGlyphs.error,
        text: appLocalizations.panelHwidNotSupported,
        tone: colorScheme.tertiary,
      ),
    if (newDomain != null && newDomain.isNotEmpty)
      (
        icon: AppGlyphs.swap,
        text: appLocalizations.subscriptionDomainMoved(newDomain),
        tone: null,
      ),
  ];
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.tone});

  final Widget child;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final tone = this.tone;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: AppShape.xl,
        color: tone == null
            ? context.colorScheme.surfaceContainerHigh
            : tone.withValues(alpha: 0.10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: child,
      ),
    );
  }
}

class _NoticeBody extends StatelessWidget {
  const _NoticeBody({required this.notice});

  final _Notice notice;

  @override
  Widget build(BuildContext context) {
    final tone = notice.tone ?? context.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlyphIcon(notice.icon, size: 20, color: tone),
        const SizedBox(width: 12),
        Expanded(child: Text(notice.text, style: context.textTheme.bodyMedium)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final Glyph icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        GlyphIcon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// The provider card at a glance: identity, when it ends, when it last
/// refreshed and on what cadence, with a manual refresh in its header.
class _ProviderCard extends ConsumerWidget {
  const _ProviderCard({required this.profile, required this.wrap});

  final Profile profile;
  final SubscriptionCardWrap wrap;

  Future<void> _handleUpdate(WidgetRef ref) async {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final panelMeta = profile.panelMeta;
    final serviceName = panelMeta?.serviceName?.trim();
    final displayName = serviceName == null || serviceName.isEmpty
        ? profile.realLabel
        : serviceName;
    final info = profile.subscriptionInfo;
    final hasFacts = info != null && info.hasFacts;
    final expire = info?.expire ?? 0;
    final expireDate = subscriptionExpireDate(expire);
    final perpetual = expire > 0 && expireDate == null;

    final ownMinutes = profile.autoUpdateDuration.inMinutes;
    final panelMinutes = panelMeta?.updateIntervalMinutes;
    final suggestedMinutes = panelMinutes != null && panelMinutes > 0
        ? panelMinutes
        : ownMinutes;
    final autoUpdateValue = profile.realAutoUpdate
        ? heroDurationWords(ownMinutes)
        : (suggestedMinutes > 0
              ? appLocalizations.autoUpdateOffSuggested(
                  heroDurationWords(suggestedMinutes),
                )
              : appLocalizations.off);

    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final lastUpdateDate = profile.lastUpdateDate;

    return wrap(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: 44,
                child: panelMeta?.serviceLogo?.isNotEmpty ?? false
                    ? ImageCacheWidget(
                        src: panelMeta!.serviceLogo!,
                        defaultWidget: const GlyphIcon(
                          AppGlyphs.cloud,
                          size: 28,
                        ),
                      )
                    : const GlyphIcon(AppGlyphs.cloud, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (displayName != profile.realLabel) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.realLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (profile.type == ProfileType.url)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: appLocalizations.update,
                  onPressed: isUpdating
                      ? null
                      : () => unawaited(_handleUpdate(ref)),
                  icon: isUpdating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const GlyphIcon(AppGlyphs.refresh),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (expire > 0) ...[
            _DetailRow(
              label: appLocalizations.expireTime,
              value: perpetual
                  ? appLocalizations.perpetualSubscription
                  : expireDate!.show,
            ),
            const SizedBox(height: 10),
          ],
          _DetailRow(
            label: appLocalizations.subscriptionUpdated,
            value: lastUpdateDate?.show ?? appLocalizations.noData,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: appLocalizations.autoUpdate,
            value: autoUpdateValue,
          ),
          if (!hasFacts && expire <= 0) ...[
            const SizedBox(height: 12),
            Text(
              appLocalizations.subscriptionNoQuota,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnnounceBody extends StatelessWidget {
  const _AnnounceBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlyphIcon(AppGlyphs.announce, size: 20, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                appLocalizations.announce,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SelectionArea(
          child: AnnounceText(
            text: text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Runtime facts about the app itself: how much memory the core holds and,
/// on desktop, whether traffic leaves through the tunnel or the proxy.
class _SystemBody extends ConsumerWidget {
  const _SystemBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: AppGlyphs.memory,
          label: appLocalizations.system,
        ),
        const SizedBox(height: 14),
        const _MemoryRow(),
        if (!context.isMobileView) ...[
          const SizedBox(height: 10),
          _DetailRow(
            label: appLocalizations.connectionType,
            value: ref.watch(tunEnabledProvider)
                ? appLocalizations.tun
                : appLocalizations.connectionProxy,
          ),
        ],
      ],
    );
  }
}

class _MemoryRow extends ConsumerStatefulWidget {
  const _MemoryRow();

  @override
  ConsumerState<_MemoryRow> createState() => _MemoryRowState();
}

class _MemoryRowState extends ConsumerState<_MemoryRow>
    with WidgetsBindingObserver, ActivePollingMixin<_MemoryRow> {
  final _memory = ValueNotifier<num>(0);

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  Duration get pollInterval => const Duration(seconds: 2);

  @override
  void dispose() {
    _memory.dispose();
    super.dispose();
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final connected = ref.read(coreStatusProvider) == CoreStatus.connected;
    final value = connected ? (await _core.getMemoryStats())?.rss ?? 0 : 0;
    if (!isCurrent()) return;
    _memory.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _memory,
      builder: (context, memory, _) => _DetailRow(
        label: context.appLocalizations.memory,
        value: memory > 0
            ? memory.traffic.show
            : context.appLocalizations.noData,
      ),
    );
  }
}

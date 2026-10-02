import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/companion.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/companion.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/widgets/widgets.dart';

import 'companion_ui.dart';

// Phone panel over one paired target: it polls the target only while visible, keeps the last known
// snapshot when a poll misses (I20), and never turns a lost command reply into "done" (I13). No
// subscription URL or credential is stored on the phone; mutations go over the pinned channel.
class CompanionControlPanel extends ConsumerStatefulWidget {
  const CompanionControlPanel({
    super.key,
    required this.deviceId,
    required this.title,
  });

  final String deviceId;
  final String title;

  @override
  ConsumerState<CompanionControlPanel> createState() =>
      _CompanionControlPanelState();
}

class _CompanionControlPanelState extends ConsumerState<CompanionControlPanel>
    with WidgetsBindingObserver, ActivePollingMixin<CompanionControlPanel> {
  final _client = CompanionClient.instance;
  CompanionStateSnapshot? _state;
  List<CompanionGroupView> _groups = const [];
  List<CompanionProfileView> _profiles = const [];
  CompanionReachability _reachability = CompanionReachability.checking;
  int? _lastOkAtMs;
  bool _busy = false;
  String? _busyTag;
  bool? _pendingRunning;

  @override
  Duration get pollInterval => const Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    unawaited(_loadProfiles());
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final result = await _client.readStateResult(widget.deviceId);
    if (!isCurrent()) return;
    if (result.snapshot == null) {
      // A pending toggle can never settle against an unreachable target, so drop it here or the
      // switch stays locked forever once the command lands right before the target drops off.
      setState(() {
        _reachability = result.reachability;
        _pendingRunning = null;
      });
      return;
    }
    final groups = await _client.readGroups(widget.deviceId);
    if (!isCurrent()) return;
    setState(() {
      _state = result.snapshot;
      if (groups != null) _groups = groups;
      _reachability = CompanionReachability.reachable;
      _lastOkAtMs = DateTime.now().millisecondsSinceEpoch;
      if (_pendingRunning != null &&
          result.snapshot!.running == _pendingRunning) {
        _pendingRunning = null;
      }
    });
  }

  Future<void> _loadProfiles() async {
    final profiles = await _client.readProfiles(widget.deviceId);
    if (!mounted || profiles == null) return;
    setState(() => _profiles = profiles);
  }

  // _busyTag names the in-flight target so the tapped control shows its own spinner, not just the
  // far-off app-bar one; the global _busy still gates every other action for the round-trip.
  Future<void> _run(
    Future<CompanionCommandOutcome> Function() action, {
    String? successMessage,
    String? tag,
  }) async {
    setState(() {
      _busy = true;
      _busyTag = tag;
    });
    final outcome = await action();
    if (!mounted) return;
    final l = context.appLocalizations;
    if (outcome.unknown) {
      context.showNotifier(l.companionOutcomeUnknown);
    } else if (!outcome.succeeded) {
      context.showNotifier(l.companionCommandFailed);
    } else if (outcome.restartRequired) {
      context.showNotifier(l.companionRestartRequired);
    } else if (successMessage != null) {
      context.showNotifier(successMessage);
    }
    restartPolling();
    if (mounted) {
      setState(() {
        _busy = false;
        _busyTag = null;
      });
    }
  }

  // The switch flips once and locks; the value only settles when a poll confirms it, and a failed or
  // unconfirmed command rolls it straight back — no on/off/on flicker (I13).
  Future<void> _toggle(bool running) async {
    setState(() {
      _pendingRunning = running;
      _busy = true;
    });
    final outcome = await _client.command(
      widget.deviceId,
      'connection.setRunning',
      arguments: {'running': running},
    );
    if (!mounted) return;
    final l = context.appLocalizations;
    if (outcome.unknown) {
      context.showNotifier(l.companionOutcomeUnknown);
      setState(() => _pendingRunning = null);
    } else if (!outcome.succeeded) {
      context.showNotifier(l.companionCommandFailed);
      setState(() => _pendingRunning = null);
    }
    if (mounted) setState(() => _busy = false);
    restartPolling();
  }

  Future<void> _setMode(UiOutboundMode mode) => _run(
    () => _client.command(
      widget.deviceId,
      'settings.setOutboundMode',
      arguments: {'mode': mode.name},
    ),
    successMessage: context.appLocalizations.companionCommandDone,
    tag: 'mode:${mode.name}',
  );

  Future<void> _selectNodeByName(String groupName) async {
    final group = _groups.firstWhereOrNull((item) => item.name == groupName);
    if (group == null) return;
    final picked = await BaseNavigator.push<String>(
      context,
      _NodePickerPage(group: group),
    );
    if (picked == null) return;
    await _run(
      () => _client.command(
        widget.deviceId,
        'groups.select',
        arguments: {'groupName': group.name, 'proxyName': picked},
      ),
      tag: 'node',
    );
  }

  Future<void> _selectProfile(int id) async {
    await _run(
      () => _client.command(
        widget.deviceId,
        'profiles.select',
        arguments: {'id': id},
      ),
      successMessage: context.appLocalizations.companionCommandDone,
      tag: 'profile:$id',
    );
    await _loadProfiles();
  }

  Future<void> _updateCurrent() async {
    await _run(
      () => _client.command(widget.deviceId, 'profiles.updateCurrent'),
      successMessage: context.appLocalizations.companionCommandDone,
      tag: 'update',
    );
    await _loadProfiles();
  }

  Future<void> _setSubscription() async {
    final profiles = ref
        .read(profilesProvider)
        .where((p) => p.type == ProfileType.url && p.url.trim().isNotEmpty)
        .toList();
    if (profiles.isEmpty) {
      await _enterUrl();
      return;
    }
    final choice = await dialogs
        .showCommonDialog<({Profile? profile, bool manual})>(
          child: _SubscriptionSourceDialog(profiles: profiles),
        );
    if (choice == null || !mounted) return;
    if (choice.manual) {
      await _enterUrl();
      return;
    }
    final profile = choice.profile!;
    await _run(
      () => _client.command(
        widget.deviceId,
        'profiles.importUrl',
        arguments: {'url': profile.url, 'name': profile.label},
      ),
      successMessage: context.appLocalizations.companionCommandDone,
      tag: 'set',
    );
    await _loadProfiles();
  }

  Future<void> _enterUrl() async {
    final l = context.appLocalizations;
    final url = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: l.companionSetSubscription,
        value: '',
        labelText: l.companionNewSubscriptionUrl,
        keyboardType: TextInputType.url,
      ),
    );
    if (url == null || url.trim().isEmpty) return;
    await _run(
      () => _client.command(
        widget.deviceId,
        'profiles.importUrl',
        arguments: {'url': url.trim()},
      ),
      successMessage: l.companionCommandDone,
      tag: 'set',
    );
    await _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final state = _state;
    return CommonScaffold(
      title: widget.title,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.refresh,
          tooltip: l.companionReload,
          isLoading: _busy,
          onPressed: restartPolling,
        ),
      ],
      body: state == null
          ? _Placeholder(reachability: _reachability)
          : _body(context, state),
    );
  }

  Widget _body(BuildContext context, CompanionStateSnapshot state) {
    final running = _pendingRunning ?? state.running;
    final children = <Widget>[
      if (_reachability != CompanionReachability.reachable)
        _StaleBanner(reachability: _reachability, lastOkAtMs: _lastOkAtMs),
      _HeroStatusCard(
        running: running,
        busy: _pendingRunning != null,
        onChanged: (_busy || _pendingRunning != null)
            ? null
            : (value) => unawaited(_toggle(value)),
      ),
      _ModeCard(
        current: state.outboundMode,
        busyMode: _busyTag,
        onSelect: _busy ? null : (mode) => unawaited(_setMode(mode)),
      ),
      if (state.groupName != null)
        _NodeCard(
          nodeName: state.nodeName,
          busy: _busyTag == 'node',
          onTap: _busy
              ? null
              : () => unawaited(_selectNodeByName(state.groupName!)),
        ),
      _TrafficCard(state: state),
      if (state.subscription != null && state.subscription!.hasFacts)
        _SubscriptionCard(info: state.subscription!),
      _ProfilesCard(
        profiles: _profiles,
        fallbackLabel: state.profileLabel,
        busyTag: _busyTag,
        onSelect: _busy ? null : (id) => unawaited(_selectProfile(id)),
        onUpdate: _busy ? null : () => unawaited(_updateCurrent()),
        onSet: _busy ? null : () => unawaited(_setSubscription()),
      ),
    ];
    final list = ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) => children[index],
    );
    return CompanionPage(child: list);
  }
}

class _HeroStatusCard extends StatelessWidget {
  const _HeroStatusCard({
    required this.running,
    required this.busy,
    required this.onChanged,
  });

  final bool running;
  final bool busy;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final tone = running ? colorScheme.primary : colorScheme.onSurfaceVariant;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      accent: running ? colorScheme.primary : null,
      padding: const EdgeInsets.all(18),
      onPressed: onChanged == null ? null : () => onChanged!(!running),
      child: Row(
        children: [
          AppMedallion(
            icon: AppGlyphs.shield,
            tone: tone,
            size: 52,
            busy: busy,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  running ? l.companionStatusOn : l.companionStatusOff,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: running
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l.companionControllingHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ExcludeFocus(
            child: IgnorePointer(
              child: Switch(value: running, onChanged: (_) {}),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.current,
    required this.busyMode,
    required this.onSelect,
  });

  final String? current;
  final String? busyMode;
  final ValueChanged<UiOutboundMode>? onSelect;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    const modes = UiOutboundMode.values;
    // Two-by-two instead of four-across: four equal columns truncate the longer localized labels
    // (e.g. "Глобально") on a phone, so a wider two-column grid keeps every label whole on both
    // phone and D-pad.
    Widget chip(UiOutboundMode mode) => _ModeChip(
      mode: mode,
      selected: mode.name == current,
      busy: busyMode == 'mode:${mode.name}',
      onTap: onSelect == null ? null : () => onSelect!(mode),
    );
    Widget row(UiOutboundMode left, UiOutboundMode right) => Row(
      spacing: AppSpacing.sm,
      children: [
        Expanded(child: chip(left)),
        Expanded(child: chip(right)),
      ],
    );
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      info: Info(label: l.outboundMode, glyph: AppGlyphs.split),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          spacing: AppSpacing.sm,
          children: [row(modes[0], modes[1]), row(modes[2], modes[3])],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.mode,
    required this.selected,
    required this.busy,
    required this.onTap,
  });

  final UiOutboundMode mode;
  final bool selected;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final smart = mode == UiOutboundMode.auto;
    final fg = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.full,
      isSelected: selected,
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (busy) ...[
            SizedBox.square(
              dimension: 14,
              child: CommonCircleLoading(color: fg),
            ),
            const SizedBox(width: AppSpacing.xs),
          ] else if (smart) ...[
            GlyphIcon(AppGlyphs.autoMode, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              _modeLabel(context, mode.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.nodeName,
    required this.busy,
    required this.onTap,
  });

  final String? nodeName;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final name = nodeName ?? '-';
    final flag = flagToCountryCode(name);
    final emoji = flag == null ? null : countryCodeToEmoji(flag);
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      padding: AppInsets.lg,
      onPressed: onTap,
      child: Row(
        children: [
          if (emoji != null)
            Text(emoji, style: const TextStyle(fontSize: 26))
          else
            AppMedallion(
              icon: AppGlyphs.dns,
              tone: colorScheme.primary,
              size: 40,
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.companionCurrentNode,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  stripLeadingEmoji(name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (busy)
            SizedBox.square(
              dimension: 18,
              child: CommonCircleLoading(color: colorScheme.onSurfaceVariant),
            )
          else
            GlyphIcon(
              AppGlyphs.chevronForward,
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _TrafficCard extends StatelessWidget {
  const _TrafficCard({required this.state});

  final CompanionStateSnapshot state;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      info: Info(label: l.trafficUsage, glyph: AppGlyphs.swap),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: CompanionMetric(
                icon: AppGlyphs.arrowUp,
                label: l.upload,
                value: state.trafficUp.traffic.show,
                tone: colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CompanionMetric(
                icon: AppGlyphs.arrowDown,
                label: l.download,
                value: state.trafficDown.traffic.show,
                tone: colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.info});

  final CompanionSubscriptionInfo info;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final used = info.used;
    final total = info.total;
    final fraction = total > 0 ? used / total : 0.0;
    final expireDate = subscriptionExpireDate(info.expire);
    final perpetual = info.expire > 0 && expireDate == null;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      info: Info(label: l.companionActiveProfile, glyph: AppGlyphs.dataUsage),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!info.unlimited) ...[
              CompanionQuotaBar(fraction: fraction),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: l.usedTraffic,
                value: '${used.traffic.show} / ${total.traffic.show}',
              ),
            ] else
              _DetailRow(label: l.usedTraffic, value: used.traffic.show),
            if (info.expire > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: l.expireTime,
                value: perpetual
                    ? l.perpetualSubscription
                    : expireDate!.showFull,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfilesCard extends StatelessWidget {
  const _ProfilesCard({
    required this.profiles,
    required this.fallbackLabel,
    required this.busyTag,
    required this.onSelect,
    required this.onUpdate,
    required this.onSet,
  });

  final List<CompanionProfileView> profiles;
  final String fallbackLabel;
  final String? busyTag;
  final ValueChanged<int>? onSelect;
  final VoidCallback? onUpdate;
  final VoidCallback? onSet;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      info: Info(label: l.companionProfiles, glyph: AppGlyphs.cloudSync),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profiles.isEmpty)
              _ProfileRow(
                label: fallbackLabel.isEmpty ? '-' : fallbackLabel,
                active: true,
                busy: false,
                onTap: null,
              )
            else
              for (final profile in profiles)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ProfileRow(
                    label: profile.label,
                    active: profile.active,
                    busy: busyTag == 'profile:${profile.id}',
                    onTap: (profile.active || onSelect == null)
                        ? null
                        : () => onSelect!(profile.id),
                  ),
                ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onUpdate,
                    icon: busyTag == 'update'
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CommonCircleLoading(),
                          )
                        : const GlyphIcon(AppGlyphs.refresh, size: 18),
                    label: Text(l.companionUpdateSubscription),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onSet,
                    icon: busyTag == 'set'
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CommonCircleLoading(),
                          )
                        : const GlyphIcon(AppGlyphs.link, size: 18),
                    label: Text(l.companionSetSubscription),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.active,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.md,
      isSelected: active,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      onPressed: onTap,
      child: Row(
        children: [
          GlyphIcon(
            active ? AppGlyphs.cloudSync : AppGlyphs.folder,
            size: 20,
            color: active ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (busy)
            SizedBox.square(
              dimension: 18,
              child: CommonCircleLoading(color: colorScheme.primary),
            )
          else if (active)
            GlyphIcon(AppGlyphs.check, size: 18, color: colorScheme.primary),
        ],
      ),
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
        const SizedBox(width: AppSpacing.lg),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.reachability, required this.lastOkAtMs});

  final CompanionReachability reachability;
  final int? lastOkAtMs;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final tone = companionReachabilityColor(context, reachability);
    final seen = lastOkAtMs == null
        ? l.companionStaleState
        : DateTime.fromMillisecondsSinceEpoch(
            lastOkAtMs!,
          ).getLastUpdateTimeDesc(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: ShapeDecoration(
        shape: AppShape.lg,
        color: tone.withValues(alpha: 0.10),
      ),
      child: Row(
        children: [
          GlyphIcon(AppGlyphs.cloudOff, size: 18, color: tone),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${_reachabilityMessage(context, reachability)} · $seen',
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.reachability});

  final CompanionReachability reachability;

  @override
  Widget build(BuildContext context) {
    if (reachability == CompanionReachability.checking) {
      return const Center(
        child: SizedBox.square(dimension: 48, child: CommonCircleLoading()),
      );
    }
    final tone = companionReachabilityColor(context, reachability);
    return Center(
      child: Padding(
        padding: AppInsets.xxxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppMedallion(icon: AppGlyphs.cloudOff, tone: tone, size: 64),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _reachabilityMessage(context, reachability),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

String _modeLabel(BuildContext context, String? name) {
  final l = context.appLocalizations;
  return switch (name) {
    'auto' => l.auto,
    'global' => l.global,
    'direct' => l.direct,
    _ => l.rule,
  };
}

String _reachabilityMessage(
  BuildContext context,
  CompanionReachability reachability,
) {
  final l = context.appLocalizations;
  return switch (reachability) {
    CompanionReachability.identityChanged => l.companionIdentityChanged,
    CompanionReachability.accessRevoked => l.companionAccessRevoked,
    _ => l.companionUnreachable,
  };
}

class _SubscriptionSourceDialog extends StatelessWidget {
  const _SubscriptionSourceDialog({required this.profiles});

  final List<Profile> profiles;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return CommonDialog(
      title: l.companionSetSubscription,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final profile in profiles)
              ListItem(
                leading: const GlyphIcon(AppGlyphs.cloud),
                title: Text(
                  profile.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  Uri.tryParse(profile.url)?.host ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.of(
                  context,
                ).pop((profile: profile, manual: false)),
              ),
            const Divider(height: AppSpacing.sm),
            ListItem(
              leading: GlyphIcon(AppGlyphs.link, color: colorScheme.primary),
              title: Text(l.companionEnterUrl),
              onTap: () =>
                  Navigator.of(context).pop((profile: null, manual: true)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NodePickerPage extends StatefulWidget {
  const _NodePickerPage({required this.group});

  final CompanionGroupView group;

  @override
  State<_NodePickerPage> createState() => _NodePickerPageState();
}

class _NodePickerPageState extends State<_NodePickerPage> {
  final _scrollController = ScrollController();
  String _keyword = '';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final keyword = _keyword.trim().toLowerCase();
    final options = keyword.isEmpty
        ? widget.group.options
        : widget.group.options
              .where((node) => node.name.toLowerCase().contains(keyword))
              .toList();
    final autofocusName = options.any((n) => n.name == widget.group.selected)
        ? widget.group.selected
        : (options.isEmpty ? null : options.first.name);
    final list = ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const GlyphIcon(AppGlyphs.search),
            hintText: l.companionSelectNode,
            filled: true,
          ),
          onChanged: (value) => setState(() => _keyword = value),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final node in options)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _NodeOption(
              node: node,
              selected: node.name == widget.group.selected,
              autofocus: keyword.isEmpty && node.name == autofocusName,
              onTap: () => Navigator.of(context).pop(node.name),
            ),
          ),
      ],
    );
    return CommonScaffold(
      title: l.companionSelectNode,
      body: CompanionPage(
        // A node option carries its own autofocus; never fall back to focusing the search field,
        // which pops the on-screen keyboard on a TV.
        autofocus: false,
        child: FocusedScrollView(controller: _scrollController, child: list),
      ),
    );
  }
}

class _NodeOption extends StatelessWidget {
  const _NodeOption({
    required this.node,
    required this.selected,
    required this.autofocus,
    required this.onTap,
  });

  final CompanionNodeView node;
  final bool selected;
  final bool autofocus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final flag = flagToCountryCode(node.name);
    final emoji = flag == null ? null : countryCodeToEmoji(flag);
    final delay = node.delayMs;
    final Widget delayWidget;
    if (delay == null || delay <= 0) {
      delayWidget = Text(
        l.companionNoMeasurement,
        style: context.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      final color =
          colorScheme.delayColor(delay) ?? colorScheme.onSurfaceVariant;
      delayWidget = AppTag(
        '$delay ms',
        mono: true,
        foreground: color,
        background: color.withValues(alpha: 0.14),
      );
    }
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      isSelected: selected,
      autofocus: autofocus,
      padding: AppInsets.lg,
      onPressed: onTap,
      child: Row(
        children: [
          if (emoji != null)
            Text(emoji, style: const TextStyle(fontSize: 24))
          else
            GlyphIcon(AppGlyphs.dns, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stripLeadingEmoji(node.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (node.type.isNotEmpty)
                  Text(
                    node.type,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          delayWidget,
          if (selected) ...[
            const SizedBox(width: AppSpacing.sm),
            GlyphIcon(AppGlyphs.check, size: 18, color: colorScheme.primary),
          ],
        ],
      ),
    );
  }
}

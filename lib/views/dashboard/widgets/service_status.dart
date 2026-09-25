import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/ip_quality/ip_quality_text.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/outbound_ip.dart';
import 'package:reclash/providers/routed_probe.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

String _statusLabel(AppLocalizations l, ServiceProbeStatus status) {
  return switch (status) {
    ServiceProbeStatus.available => l.serviceAvailable,
    ServiceProbeStatus.restricted => l.serviceRestricted,
    ServiceProbeStatus.unavailable => l.serviceUnavailable,
    ServiceProbeStatus.disallowedIsp => l.serviceDisallowedIsp,
    ServiceProbeStatus.blocked => l.serviceBlocked,
    ServiceProbeStatus.unsupportedRegion => l.serviceUnsupportedRegion,
    ServiceProbeStatus.originalsOnly => l.serviceOriginalsOnly,
    ServiceProbeStatus.comingSoon => l.serviceComingSoon,
    ServiceProbeStatus.timeout => l.timeout,
    ServiceProbeStatus.failed => l.serviceFailed,
  };
}

// Traffic-light semantics so the three verdict classes read apart at a glance:
// available is success, a partial verdict warning, every hard failure error.
Color _statusColor(BuildContext context, ServiceProbeStatus status) {
  final colorScheme = context.colorScheme;
  return switch (status) {
    ServiceProbeStatus.available => colorScheme.success,
    ServiceProbeStatus.restricted ||
    ServiceProbeStatus.disallowedIsp ||
    ServiceProbeStatus.blocked ||
    ServiceProbeStatus.unsupportedRegion ||
    ServiceProbeStatus.originalsOnly ||
    ServiceProbeStatus.comingSoon => colorScheme.warning,
    ServiceProbeStatus.unavailable ||
    ServiceProbeStatus.timeout ||
    ServiceProbeStatus.failed => colorScheme.error,
  };
}

(String, Color) _statusOf(
  BuildContext context,
  ProbeEntry<ServiceCheck> entry,
) {
  final l = context.appLocalizations;
  final check = entry.value;
  if (entry.isLoading) {
    return (l.loading, context.colorScheme.onSurfaceVariant);
  }
  if (check != null) {
    return (_statusLabel(l, check.status), _statusColor(context, check.status));
  }
  if (entry.phase == ProbePhase.failed) {
    return (
      _statusLabel(l, ServiceProbeStatus.failed),
      _statusColor(context, ServiceProbeStatus.failed),
    );
  }
  return (l.servicePending, context.colorScheme.onSurfaceVariant);
}

Widget _serviceGlyph(BuildContext context, ServiceTarget target, Color color) {
  return SizedBox.square(
    dimension: 28,
    child: SvgPicture.asset(
      'assets/images/services/${target.icon}.svg',
      semanticsLabel: target.label,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    ),
  );
}

class ServiceStatusCard extends ConsumerStatefulWidget {
  const ServiceStatusCard({super.key});

  @override
  ConsumerState<ServiceStatusCard> createState() => _ServiceStatusCardState();
}

class _ServiceStatusCardState extends ConsumerState<ServiceStatusCard> {
  static const _gap = 16.0;
  static const _nodeMinWidth = 220.0;

  late final PageController _controller;
  late final ServiceStatus _services;
  late final OutboundIpProbe _ips;
  ServiceTarget? _shown;
  String? _node;
  bool _scrolling = false;

  static ServiceTarget _savedIn(List<ServiceTarget> targets, String id) {
    final saved = id.isEmpty ? null : ServiceTarget.byId(id);
    return saved != null && targets.contains(saved) ? saved : targets.first;
  }

  ServiceTarget _targetIn(List<ServiceTarget> targets) =>
      _savedIn(targets, ref.read(appSettingProvider).currentService);

  void _select(ServiceTarget target) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(currentService: target.id));
  }

  @override
  void initState() {
    super.initState();
    _services = ref.read(serviceStatusProvider.notifier);
    _ips = ref.read(outboundIpProbeProvider.notifier);
    final targets = ref.read(enabledServiceTargetsProvider);
    _controller = PageController(
      initialPage: targets.indexOf(_targetIn(targets)),
      viewportFraction: 0.36,
    );
  }

  @override
  void dispose() {
    _show(null);
    _showNode(null);
    _controller.dispose();
    super.dispose();
  }

  /// Watches the shown service so its probe mounts, and lets the predecessor's
  /// keep-alive entry expire; the shown node feeds the IP readout.
  void _show(ServiceTarget? target) {
    final previous = _shown;
    if (target == previous) return;
    _shown = target;
    if (target != null) _services.watch(target);
    if (previous != null) _services.unwatch(previous);
  }

  void _showNode(String? node) {
    final previous = _node;
    if (node == previous) return;
    _node = node;
    if (node != null) _ips.watch(node);
    if (previous != null) _ips.unwatch(previous);
  }

  void _openSheet() {
    unawaited(
      showSheet(
        context: context,
        props: const SheetProps(isScrollControlled: true),
        builder: (_) => const ServiceStatusSheet(),
      ),
    );
  }

  void _onTargetChanged(List<ServiceTarget> targets, int index) {
    final target = targets[index];
    if (target == _targetIn(targets)) return;
    _select(target);
  }

  /// A swipe or an animated jump passes through the services in between; only
  /// the one the picker settles on is worth watching.
  bool _onPickerScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification) {
      _scrolling = true;
    } else if (notification is ScrollEndNotification) {
      _show(_targetIn(ref.read(enabledServiceTargetsProvider)));
      if (mounted) setState(() => _scrolling = false);
    }
    return false;
  }

  void _onTargetsChanged(
    List<ServiceTarget>? previous,
    List<ServiceTarget> next,
  ) {
    final current = _targetIn(previous ?? next);
    final kept = next.contains(current);
    final index = kept
        ? next.indexOf(current)
        : (previous?.indexOf(current) ?? 0).clamp(0, next.length - 1);
    _select(next[index]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      if (_controller.page?.round() != index) _controller.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(enabledServiceTargetsProvider, _onTargetsChanged);
    final targets = ref.watch(enabledServiceTargetsProvider);
    final target = _savedIn(
      targets,
      ref.watch(appSettingProvider.select((state) => state.currentService)),
    );
    if (!_scrolling) _show(target);
    final entry = ref.watch(
      serviceStatusProvider.select((state) => state.entryOf(target)),
    );
    final check = entry.value;
    final loading =
        entry.isLoading || (_scrolling && entry.phase != ProbePhase.fresh);
    final (label, color) = _statusOf(context, entry);
    final delay = check?.delay;
    final node = check?.node;
    _showNode(node);
    final ipEntry = node == null
        ? null
        : ref.watch(
            outboundIpProbeProvider.select((state) => state.entryOf(node)),
          );
    final outboundIp = ipEntry?.value;
    final ipPending =
        ipEntry != null &&
        ipEntry.phase != ProbePhase.failed &&
        outboundIp == null;
    final title = context.textTheme.titleSmall?.toSoftBold;
    final secondary = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      child: RepaintBoundary(
        child: CommonCard(
          radius: DashboardWidgetMetrics.radiusOf(context),
          onPressed: _openSheet,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pickerWidth = (constraints.maxWidth * 0.38).clamp(
                  88.0,
                  164.0,
                );
                final showNode =
                    constraints.maxWidth - pickerWidth - _gap >= _nodeMinWidth;
                return Row(
                  children: [
                    SizedBox(
                      width: pickerWidth,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _onPickerScroll,
                        child: _ServicePicker(
                          controller: _controller,
                          targets: targets,
                          index: targets.indexOf(target),
                          onChanged: (index) =>
                              _onTargetChanged(targets, index),
                        ),
                      ),
                    ),
                    const SizedBox(width: _gap),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              Expanded(
                                flex: 3,
                                child: FadeThroughBox(
                                  child: !loading && outboundIp != null
                                      ? _OutboundIp(
                                          ipInfo: outboundIp,
                                          style: title,
                                        )
                                      : loading || ipPending
                                      ? SkeletonText(width: 104, style: title)
                                      : Text(
                                          '—',
                                          style: title?.copyWith(
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                ),
                              ),
                              if (showNode && loading)
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: SkeletonText(
                                      width: 72,
                                      style: secondary,
                                    ),
                                  ),
                                )
                              else if (showNode && node != null)
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    node,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: secondary,
                                  ),
                                ),
                            ],
                          ),
                          Semantics(
                            liveRegion: true,
                            label: loading ? label : null,
                            child: FadeThroughBox(
                              child: Row(
                                key: ValueKey((label, delay)),
                                spacing: 6,
                                children: [
                                  Expanded(
                                    child: Text(
                                      label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(color: color),
                                    ),
                                  ),
                                  if (delay != null)
                                    Text(
                                      '$delay ms',
                                      style: secondary?.copyWith(
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Lists every enabled service at once and probes them on open, reading the
/// keep-alive cache so a re-open shows the last verdicts without new traffic.
class ServiceStatusSheet extends ConsumerStatefulWidget {
  const ServiceStatusSheet({super.key});

  @override
  ConsumerState<ServiceStatusSheet> createState() => _ServiceStatusSheetState();
}

class _ServiceStatusSheetState extends ConsumerState<ServiceStatusSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final targets = ref.read(enabledServiceTargetsProvider);
      ref.read(serviceStatusProvider.notifier).refresh(targets);
    });
  }

  void _openManage(BuildContext context) {
    unawaited(
      showSheet(
        context: context,
        props: const SheetProps(isScrollControlled: true),
        builder: (_) => const ServiceManageView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final targets = ref.watch(enabledServiceTargetsProvider);
    final state = ref.watch(serviceStatusProvider);
    final services = ref.read(serviceStatusProvider.notifier);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: ref.sheetHeight(context, 0.7)),
      child: CommonScaffold(
        title: l.serviceStatus,
        floatBody: true,
        iconActions: [
          IconButtonData(
            glyph: AppGlyphs.bolt,
            tooltip: l.serviceCheckAll,
            isLoading: targets.every(state.isLoading),
            onPressed: () => services.refresh(targets),
          ),
          IconButtonData(
            glyph: AppGlyphs.sliders,
            tooltip: l.serviceManage,
            onPressed: () => _openManage(context),
          ),
        ],
        body: ListView.builder(
          padding: EdgeInsets.fromLTRB(16, context.contentTopPadding, 16, 20),
          itemCount: targets.length,
          itemBuilder: (context, index) {
            final target = targets[index];
            return ItemPositionProvider(
              position: ItemPosition.get(index, targets.length),
              child: _ServiceRow(
                target: target,
                check: state.valueOf(target),
                loading: state.isLoading(target),
                onCheck: () => services.refresh([target]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.target,
    required this.check,
    required this.loading,
    required this.onCheck,
  });

  final ServiceTarget target;
  final ServiceCheck? check;
  final bool loading;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final secondary = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    final check = this.check;
    final (label, color) = loading
        ? (l.loading, context.colorScheme.onSurfaceVariant)
        : check != null
        ? (_statusLabel(l, check.status), _statusColor(context, check.status))
        : (l.servicePending, context.colorScheme.onSurfaceVariant);
    final region = check?.region;
    final flag = (region != null && region.isNotEmpty)
        ? countryCodeToEmoji(region)
        : null;
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 4),
      leading: _serviceGlyph(
        context,
        target,
        context.colorScheme.onSurfaceVariant,
      ),
      title: Text(target.label),
      subtitle: Row(
        spacing: 6,
        children: [
          if (loading)
            const SizedBox.square(
              dimension: 10,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          if (flag != null)
            Text(
              flag,
              style: secondary?.copyWith(fontFamily: FontFamily.twEmoji.value),
            )
          else if (region != null && region.isNotEmpty)
            Text(region.toUpperCase(), style: secondary),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: secondary?.copyWith(color: color),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          _ServiceRowTrailing(check: check, style: secondary),
          IconButton(
            tooltip: l.serviceCheck,
            onPressed: loading ? null : onCheck,
            icon: const GlyphIcon(AppGlyphs.refresh),
          ),
        ],
      ),
    );
  }
}

class _ServiceRowTrailing extends StatelessWidget {
  const _ServiceRowTrailing({required this.check, this.style});

  final ServiceCheck? check;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final delay = check?.delay;
    final checkedAt = check?.checkedAt;
    if (delay == null && checkedAt == null) {
      return const SizedBox.shrink();
    }
    final numeric = style?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (delay != null) Text('$delay ms', style: numeric),
        if (checkedAt != null)
          Text(
            checkedAt.showTime.trim(),
            style: numeric?.copyWith(color: context.colorScheme.outline),
          ),
      ],
    );
    if (checkedAt == null) {
      return column;
    }
    return Tooltip(
      message: context.appLocalizations.serviceCheckedAt(checkedAt.showFull),
      child: column,
    );
  }
}

/// The egress IP with its quality verdict, keyed to the shown service's node;
/// tapping opens the detail sheet.
class _OutboundIp extends StatelessWidget {
  const _OutboundIp({required this.ipInfo, this.style});

  final IpInfo ipInfo;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final flag = countryCodeToEmoji(ipInfo.countryCode);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (flag != null)
          Text(
            flag,
            style: style?.copyWith(fontFamily: FontFamily.twEmoji.value),
          ),
        Flexible(
          child: IpQualityText(ip: ipInfo.ip, openDetails: true, style: style),
        ),
      ],
    );
  }
}

/// Reorders the region catalog and toggles services on or off, writing the
/// user's order and disabled set back through [appSettingProvider].
class ServiceManageView extends ConsumerWidget {
  const ServiceManageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final targets = ref.watch(serviceTargetsProvider);
    final enabled = ref.watch(enabledServiceTargetsProvider);
    final settings = ref.read(appSettingProvider.notifier);

    void reorder(int oldIndex, int newIndex) {
      settings.update(
        (state) => state.copyWith(
          serviceOrder: [
            for (final target in targets.copyAndReorder(oldIndex, newIndex))
              target.id,
          ],
        ),
      );
    }

    void toggle(ServiceTarget target, bool value) {
      settings.update((state) {
        final disabled = {...state.disabledServices};
        if (value) {
          disabled.remove(target.id);
        } else {
          disabled.add(target.id);
        }
        return state.copyWith(disabledServices: disabled.toList());
      });
    }

    Widget itemAt(int index) {
      final target = targets[index];
      final isEnabled = enabled.contains(target);
      final locked = isEnabled && enabled.length == 1;
      return _ServiceManageItem(
        key: ValueKey(target),
        target: target,
        index: index,
        position: ItemPosition.get(index, targets.length),
        enabled: isEnabled,
        onChanged: locked ? null : (value) => toggle(target, value),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: ref.sheetHeight(context, 0.8)),
      child: CommonScaffold(
        title: l.serviceManage,
        floatBody: true,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: context.contentTopPadding),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverReorderableList(
                itemBuilder: (_, index) => itemAt(index),
                itemCount: targets.length,
                proxyDecorator: (child, index, animation) =>
                    commonProxyDecorator(itemAt(index), index, animation),
                onReorderItem: reorder,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          ],
        ),
      ),
    );
  }
}

class _ServiceManageItem extends StatelessWidget {
  const _ServiceManageItem({
    super.key,
    required this.target,
    required this.index,
    required this.position,
    required this.enabled,
    required this.onChanged,
  });

  final ServiceTarget target;
  final int index;
  final ItemPosition position;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return ItemPositionProvider(
      position: position,
      child: DecorationListItem(
        minVerticalPadding: 8,
        contentPadding: const EdgeInsets.only(left: 16, right: 0),
        onPressed: onChanged == null ? null : () => onChanged(!enabled),
        leading: _serviceGlyph(
          context,
          target,
          context.colorScheme.onSurfaceVariant,
        ),
        title: Text(target.label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: enabled, onChanged: onChanged),
            ReorderableDelayedDragStartListener(
              index: index,
              child: Container(
                color: Colors.transparent,
                padding: AppInsets.md,
                child: const GlyphIcon(AppGlyphs.dragHandle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A horizontal reel of service glyphs: the centered one sits on a pill and
/// its neighbours shrink and fade toward the edges. Settling on a glyph hands
/// its index back so the card can probe that service.
class _ServicePicker extends StatefulWidget {
  const _ServicePicker({
    required this.controller,
    required this.targets,
    required this.index,
    required this.onChanged,
  });

  final PageController controller;
  final List<ServiceTarget> targets;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  State<_ServicePicker> createState() => _ServicePickerState();
}

class _ServicePickerState extends State<_ServicePicker> {
  bool _moving = false;

  Future<void> _select(int index) async {
    if (_moving || !widget.controller.hasClients) return;
    final next = index.clamp(0, widget.targets.length - 1);
    if (next == widget.index) return;
    _moving = true;
    try {
      await widget.controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _moving = false;
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    if (delta == 0) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      _select(widget.index + (delta > 0 ? 1 : -1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    final targets = widget.targets;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _select(index - 1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _select(index + 1),
      },
      child: Focus(
        child: Semantics(
          label: context.appLocalizations.serviceStatus,
          value: targets[index].label,
          increasedValue: index < targets.length - 1
              ? targets[index + 1].label
              : null,
          decreasedValue: index > 0 ? targets[index - 1].label : null,
          onIncrease: index < targets.length - 1
              ? () => _select(index + 1)
              : null,
          onDecrease: index > 0 ? () => _select(index - 1) : null,
          child: Listener(
            onPointerSignal: _onPointerSignal,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: context.colorScheme.secondaryContainer,
                    shape: AppShape.md,
                  ),
                ),
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0, 0.2, 0.8, 1],
                  ).createShader(bounds),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: PointerDeviceKind.values.toSet(),
                      scrollbars: false,
                    ),
                    child: PageView.builder(
                      controller: widget.controller,
                      itemCount: targets.length,
                      onPageChanged: widget.onChanged,
                      itemBuilder: (context, itemIndex) {
                        final target = targets[itemIndex];
                        return AnimatedBuilder(
                          animation: widget.controller,
                          builder: (context, child) {
                            final page =
                                widget.controller.hasClients &&
                                    widget
                                        .controller
                                        .position
                                        .hasContentDimensions
                                ? widget.controller.page ?? index.toDouble()
                                : index.toDouble();
                            final distance = (page - itemIndex).abs().clamp(
                              0.0,
                              1.0,
                            );
                            return Transform.scale(
                              scale: 1 - distance * 0.3,
                              child: Opacity(
                                opacity: 1 - distance * 0.55,
                                child: child,
                              ),
                            );
                          },
                          child: Center(
                            child: Tooltip(
                              message: target.label,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _select(itemIndex),
                                child: SizedBox.square(
                                  dimension: 44,
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/images/services/${target.icon}.svg',
                                      width: 28,
                                      height: 28,
                                      semanticsLabel: target.label,
                                      colorFilter: ColorFilter.mode(
                                        context
                                            .colorScheme
                                            .onSecondaryContainer,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

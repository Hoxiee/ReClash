import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
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

// No success/warning roles here: available reads as primary, a partial verdict
// as tertiary, and every hard failure as error.
Color _statusColor(BuildContext context, ServiceProbeStatus status) {
  final colorScheme = context.colorScheme;
  return switch (status) {
    ServiceProbeStatus.available => colorScheme.primary,
    ServiceProbeStatus.restricted ||
    ServiceProbeStatus.disallowedIsp ||
    ServiceProbeStatus.blocked ||
    ServiceProbeStatus.unsupportedRegion ||
    ServiceProbeStatus.originalsOnly ||
    ServiceProbeStatus.comingSoon => colorScheme.tertiary,
    ServiceProbeStatus.unavailable ||
    ServiceProbeStatus.timeout ||
    ServiceProbeStatus.failed => colorScheme.error,
  };
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

class ServiceStatusCard extends ConsumerWidget {
  const ServiceStatusCard({super.key});

  void _openSheet(BuildContext context) {
    unawaited(
      showSheet(
        context: context,
        props: const SheetProps(isScrollControlled: true),
        builder: (_) => const ServiceStatusSheet(),
      ),
    );
  }

  Color _glyphColor(BuildContext context, ServiceStatusState state, ServiceTarget target) {
    final check = state.checkOf(target);
    return check == null
        ? context.colorScheme.onSurfaceVariant.opacity38
        : _statusColor(context, check.status);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(enabledServiceTargetsProvider);
    final state = ref.watch(serviceStatusProvider);
    return DashboardInfoCard(
      height: getWidgetHeight(1),
      icon: Icons.travel_explore_rounded,
      label: context.appLocalizations.serviceStatus,
      onPressed: () => _openSheet(context),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final target in targets)
              _serviceGlyph(context, target, _glyphColor(context, state, target)),
          ],
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
      unawaited(ref.read(serviceStatusProvider.notifier).refresh(targets));
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
        actions: [
          IconButton(
            tooltip: l.serviceCheckAll,
            onPressed: targets.every(state.isLoading)
                ? null
                : () => services.refresh(targets),
            icon: const GlyphIcon(AppGlyphs.bolt, size: 20),
          ),
          IconButton(
            tooltip: l.serviceManage,
            onPressed: () => _openManage(context),
            icon: const GlyphIcon(AppGlyphs.sliders, size: 20),
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
                check: state.checkOf(target),
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
          if (check?.region case final region? when region.isNotEmpty)
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
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
                padding: const EdgeInsets.all(12),
                child: const GlyphIcon(AppGlyphs.dragHandle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

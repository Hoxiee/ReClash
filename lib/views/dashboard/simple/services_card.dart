import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/routed_probe.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/probe_start_hold.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/dashboard/widgets/service_status.dart';
import 'package:reclash/widgets/service_icon.dart';

/// Services a split profile keeps off the tunnel, so they read as direct
/// until a check says where they really went.
const _domestic = {
  ServiceTarget.sberbank,
  ServiceTarget.gosuslugi,
  ServiceTarget.vk,
  ServiceTarget.kinopoisk,
  ServiceTarget.yandex,
};

const _maxShown = 4;

/// Up to [_maxShown] targets, split evenly between the tunnel and home ones
/// when both exist, so the card proves both at once.
List<ServiceTarget> _pick(List<ServiceTarget> enabled) {
  final abroad = enabled.where((target) => !_domestic.contains(target));
  final home = enabled.where(_domestic.contains);
  const half = _maxShown ~/ 2;
  final homeCount = home.length.clamp(
    0,
    _maxShown - abroad.length.clamp(0, half),
  );
  return [...abroad.take(_maxShown - homeCount), ...home.take(homeCount)];
}

enum _Reach { ok, partial, down, unknown }

_Reach _reachOf(ServiceCheck? check, ProbePhase phase) => switch (check) {
  null when phase == ProbePhase.failed => _Reach.down,
  null => _Reach.unknown,
  ServiceCheck(status: ServiceProbeStatus.available) => _Reach.ok,
  ServiceCheck(
    status: ServiceProbeStatus.unavailable ||
        ServiceProbeStatus.timeout ||
        ServiceProbeStatus.failed,
  ) =>
    _Reach.down,
  _ => _Reach.partial,
};

String? _sentenceOf(
  BuildContext context,
  ServiceTarget target,
  _Reach reach,
  ServiceProbeStatus? status,
) {
  final appLocalizations = context.appLocalizations;
  final name = target.label;
  return switch ((reach, status)) {
    (_Reach.ok || _Reach.unknown, _) => null,
    (_, ServiceProbeStatus.originalsOnly) =>
      appLocalizations.simpleServiceOriginalsOnly(name),
    (_, ServiceProbeStatus.unsupportedRegion) =>
      appLocalizations.simpleServiceUnsupportedRegion(name),
    (_, ServiceProbeStatus.blocked || ServiceProbeStatus.disallowedIsp) =>
      appLocalizations.simpleServiceBlocked(name),
    (_, ServiceProbeStatus.restricted) =>
      appLocalizations.simpleServiceRestricted(name),
    (_, ServiceProbeStatus.comingSoon) =>
      appLocalizations.simpleServiceComingSoon(name),
    _ => appLocalizations.simpleServiceUnavailable(name),
  };
}

typedef _Service = ({
  ServiceTarget target,
  _Reach reach,
  ServiceProbeStatus? status,
  bool direct,
});

/// The service probes split by the route each one took: abroad through the
/// tunnel, home services straight, so one card shows both that the VPN works
/// and that it broke nothing. Only exceptions get words.
class SimpleServicesCard extends ConsumerStatefulWidget {
  const SimpleServicesCard({super.key, this.random});

  @visibleForTesting
  final Random? random;

  @override
  ConsumerState<SimpleServicesCard> createState() => _SimpleServicesCardState();
}

class _SimpleServicesCardState extends ConsumerState<SimpleServicesCard>
    with ProbeStartHold<SimpleServicesCard> {
  late final ServiceStatus _services;
  late final bool _variant;
  Set<ServiceTarget> _watched = const {};
  Set<ServiceTarget> _shown = const {};
  var _syncScheduled = false;

  @override
  void initState() {
    super.initState();
    _services = ref.read(serviceStatusProvider.notifier);
    _variant = ServiceIcon.selectVariant(widget.random);
  }

  @override
  void dispose() {
    for (final target in _watched) {
      _services.unwatch(target);
    }
    super.dispose();
  }

  void _syncShown(Set<ServiceTarget> shown) {
    if (setEquals(shown, _shown)) return;
    _shown = shown;
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;
      final shown = _shown;
      for (final target in shown.difference(_watched)) {
        _services.watch(target);
      }
      for (final target in _watched.difference(shown)) {
        _services.unwatch(target);
      }
      _watched = shown;
      ref.read(shownServiceTargetsProvider.notifier).value = shown;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = DashboardColors.of(context);
    final live = ref.watch(isStartProvider) && !ref.watch(suspendProvider);
    final settings = ref.watch(
      appSettingProvider.select(
        (settings) => (
          auto:
              settings.autoCheckActiveServices || settings.autoCheckAllServices,
          onlyConnected: settings.serviceCheckOnlyWhenConnected,
        ),
      ),
    );
    final shown = _pick(ref.watch(enabledServiceTargetsProvider));
    _syncShown(shown.toSet());
    final state = ref.watch(serviceStatusProvider);
    final waiting = !live && settings.onlyConnected;
    final services = <_Service>[
      for (final target in shown)
        _service(target, state.entryOf(target), waiting),
    ];
    final checked = services.where(
      (service) => service.reach != _Reach.unknown,
    );
    final problems = checked.where((service) => service.reach != _Reach.ok);
    final chip = waiting && settings.auto
        ? DashboardChip(label: appLocalizations.simpleServicesAfterConnect)
        : problems.isNotEmpty
        ? DashboardChip(
            label: appLocalizations.serviceAbnormalCount(problems.length),
            tone: DashboardChipTone.warn,
          )
        : services.isNotEmpty && checked.length == services.length
        ? DashboardChip(
            label: appLocalizations.simpleServicesAllGood,
            tone: DashboardChipTone.ok,
            dot: true,
          )
        : !settings.auto
        ? DashboardChip(label: appLocalizations.simpleServicesManual)
        : null;
    final sentences = [
      for (final service in problems)
        ?_sentenceOf(context, service.target, service.reach, service.status),
    ];
    return DashboardCard(
      semanticLabel: appLocalizations.simpleServicesTitle,
      onTap: () => showServiceStatusSheet(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.verified,
            title: appLocalizations.simpleServicesTitle,
            leading: [?chip],
            chevron: true,
          ),
          if (services.isEmpty)
            Text(
              appLocalizations.regionNoServices,
              style: DashboardText.label(context),
            ),
          if (services.isNotEmpty)
            _ServiceRow(
              variant: _variant,
              groups: [
                for (final (direct, title) in [
                  (false, appLocalizations.simpleServicesViaVpn),
                  (true, appLocalizations.simpleServicesDirect),
                ])
                  if (services.where((service) => service.direct == direct)
                      case final group when group.isNotEmpty)
                    (title: title, services: group.toList()),
              ],
            ),
          if (sentences.isNotEmpty)
            DashboardBlock(
              radius: DashboardCorner.mobileBlock,
              color: colors.warnContainer,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                spacing: 10,
                children: [
                  GlyphIcon(
                    AppGlyphs.info,
                    size: 18,
                    color: colors.onWarnContainer,
                  ),
                  Expanded(
                    child: Text(
                      sentences.take(2).join('\n'),
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(color: colors.onWarnContainer),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  _Service _service(
    ServiceTarget target,
    ProbeEntry<ServiceCheck> entry,
    bool waiting,
  ) {
    final phase = shownPhase(entry);
    final check = phase == entry.phase ? entry.value : null;
    final chains = check?.chains ?? const [];
    return (
      target: target,
      reach: waiting ? _Reach.unknown : _reachOf(check, phase),
      status: check?.status,
      direct: chains.isEmpty
          ? _domestic.contains(target)
          : chains.contains(directOutbound),
    );
  }
}

/// One row of [_maxShown] equal slots, each route's name over its tiles.
class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.groups, required this.variant});

  static const _gap = 8.0;

  final List<({String title, List<_Service> services})> groups;
  final bool variant;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final slot =
            (constraints.maxWidth - _gap * (_maxShown - 1)) / _maxShown;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: _gap,
          children: [
            for (final (:title, :services) in groups)
              SizedBox(
                width: slot * services.length + _gap * (services.length - 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DashboardText.label(context),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: _gap,
                      children: [
                        for (final service in services)
                          SizedBox(
                            width: slot,
                            child: _ServiceTile(
                              service: service,
                              variant: variant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.variant});

  final _Service service;
  final bool variant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final reach = service.reach;
    final dot = switch (reach) {
      _Reach.ok => colors.ok,
      _Reach.partial => colors.warn,
      _Reach.down => colorScheme.error,
      _Reach.unknown => null,
    };
    final ink = reach == _Reach.unknown
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;
    return Column(
      spacing: 6,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            DashboardBlock(
              radius: AppCorner.md,
              child: SizedBox(
                height: 52,
                child: Center(
                  child: ServiceIcon(
                    target: service.target,
                    size: 24,
                    variant: variant,
                    colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            if (dot != null)
              PositionedDirectional(
                top: 6,
                end: 6,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: dot,
                    shape: AppShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 8),
                ),
              ),
          ],
        ),
        Text(
          service.target.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.caption2
              .of(context)
              .copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

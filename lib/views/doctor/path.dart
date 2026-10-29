import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/widgets.dart';

extension PathStepView on PathStep {
  String label(AppLocalizations l) => switch (this) {
    PathStep.network => l.network,
    PathStep.clock => l.doctorStepClock,
    PathStep.core => l.doctorStepCore,
    PathStep.profile => l.profile,
    PathStep.tunnel => l.doctorStepTunnel,
    PathStep.dns => l.doctorStepDns,
    PathStep.server => l.server,
    PathStep.internet => l.internet,
    PathStep.services => l.simpleServicesTitle,
  };

  Glyph get glyph => switch (this) {
    PathStep.network => AppGlyphs.wifi,
    PathStep.clock => AppGlyphs.clock,
    PathStep.core => AppGlyphs.cpu,
    PathStep.profile => AppGlyphs.profiles,
    PathStep.tunnel => AppGlyphs.vpn,
    PathStep.dns => AppGlyphs.dns,
    PathStep.server => AppGlyphs.proxies,
    PathStep.internet => AppGlyphs.language,
    PathStep.services => AppGlyphs.verified,
  };
}

String causeText(AppLocalizations l, FailureCause cause) => switch (cause) {
  FailureCause.noNetwork => l.doctorCauseNoNetwork,
  FailureCause.captivePortal => l.doctorCauseCaptivePortal,
  FailureCause.clockSkew => l.doctorCauseClockSkew,
  FailureCause.coreDown => l.doctorCauseCoreDown,
  FailureCause.profileInvalid => l.doctorCauseProfileInvalid,
  FailureCause.subscriptionExpired => l.doctorCauseSubscriptionExpired,
  FailureCause.trafficExhausted => l.doctorCauseTrafficExhausted,
  FailureCause.tunnelDenied => l.doctorCauseTunnelDenied,
  FailureCause.tunnelTaken => l.doctorCauseTunnelTaken,
  FailureCause.dnsFailed => l.doctorCauseDnsFailed,
  FailureCause.serverDns => l.doctorCauseServerDns,
  FailureCause.refused => l.doctorCauseRefused,
  FailureCause.timeout => l.doctorCauseTimeout,
  FailureCause.reset => l.doctorCauseReset,
  FailureCause.tlsHandshake => l.doctorCauseTlsHandshake,
  FailureCause.authRejected => l.doctorCauseAuthRejected,
  FailureCause.udpBlocked => l.doctorCauseUdpBlocked,
  FailureCause.noUpstream => l.doctorCauseNoUpstream,
  FailureCause.serviceBlocked => l.doctorCauseServiceBlocked,
  FailureCause.unknown => l.doctorCauseUnknown,
};

/// What a failed step says: its cause, or that it is simply not up.
String failureText(AppLocalizations l, PathStepResult step) =>
    step.cause == null ? l.doctorPathNotStarted : causeText(l, step.cause!);

String _milliseconds(Duration duration) => '${duration.inMilliseconds} ms';

/// The steps of [path] as a grouped list with their status and timing.
class PathStepList extends StatelessWidget {
  const PathStepList({super.key, required this.path, this.total = false});

  final PathResult path;

  /// Closes the group with the summed timing.
  final bool total;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return generateGroup([
      for (final step in path.steps)
        DecorationListItem(
          leading: CommonCard(
            shape: AppShape.full,
            padding: const EdgeInsets.all(8),
            child: step.status == PathStepStatus.running
                ? const CommonCircleLoading(size: 20)
                : GlyphIcon(
                    switch (step.status) {
                      PathStepStatus.pass => AppGlyphs.check,
                      PathStepStatus.fail => AppGlyphs.error,
                      PathStepStatus.unknown => AppGlyphs.info,
                      _ => step.step.glyph,
                    },
                    size: 20,
                    color: switch (step.status) {
                      PathStepStatus.pass => colorScheme.success,
                      PathStepStatus.fail =>
                        step.cause == null
                            ? colorScheme.warning
                            : colorScheme.error,
                      PathStepStatus.skipped ||
                      PathStepStatus.waiting => colorScheme.outline,
                      _ => colorScheme.onSurfaceVariant,
                    },
                  ),
          ),
          title: Text(step.step.label(l)),
          subtitle: Text(
            switch (step.status) {
              PathStepStatus.pass => step.detail ?? l.doctorPathStepPassed,
              PathStepStatus.fail => [
                failureText(l, step),
                ?step.detail,
              ].join('\n'),
              PathStepStatus.running => l.doctorPathChecking,
              PathStepStatus.waiting => l.doctorPathStepWaiting,
              PathStepStatus.skipped => l.setupNotChecked,
              PathStepStatus.unknown => step.detail ?? l.doctorPathStepUnknown,
            },
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(
                  color: switch (step.status) {
                    PathStepStatus.running => colorScheme.primary,
                    PathStepStatus.fail when step.cause != null =>
                      colorScheme.error,
                    _ => colorScheme.onSurfaceVariant,
                  },
                ),
          ),
          trailing: step.duration == null
              ? null
              : Text(
                  _milliseconds(step.duration!),
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: colorScheme.onSurfaceVariant),
                ),
        ),
      if (total)
        DecorationListItem(
          title: Text(l.total),
          trailing: Text(
            _milliseconds(path.duration),
            style: AppTextStyle.subheadline.of(context, emphasized: true),
          ),
        ),
    ]);
  }
}

Future<void> showPathSheet(BuildContext context) {
  return showSheet<void>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) => NestedPagedSheet(builder: (_) => const PathSheet()),
  );
}

/// The full connection path with each step's timing.
class PathSheet extends ConsumerStatefulWidget {
  const PathSheet({super.key});

  @override
  ConsumerState<PathSheet> createState() => _PathSheetState();
}

class _PathSheetState extends ConsumerState<PathSheet> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(diagnosticKernelProvider).runPath());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final path = ref.watch(pathProvider).value;
    final running = path != null && !path.complete;
    return CommonScaffold(
      title: l.doctorPathTitle,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.refresh,
          tooltip: l.setupRepeat,
          isLoading: running,
          onPressed: running
              ? null
              : () => unawaited(
                  ref.read(diagnosticKernelProvider).runPath(force: true),
                ),
        ),
      ],
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(
          16,
          context.contentTopPadding,
          16,
          16 + context.bottomInset,
        ),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 16),
            child: Text(
              path?.cancelled == true
                  ? l.doctorPathCancelled
                  : l.doctorPathDescription,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
          if (path != null) PathStepList(path: path, total: path.complete),
        ],
      ),
    );
  }
}

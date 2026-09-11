import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:material_ui/material_ui.dart';
import 'package:dynamic_color/dynamic_color.dart';

typedef _DoctorPathState = DoctorStageState;

class _DoctorPathStage {
  const _DoctorPathStage({
    required this.id,
    required this.label,
    required this.icon,
    required this.state,
  });

  final String id;
  final String label;
  final IconData icon;
  final _DoctorPathState state;
}

class ConnectionDoctorPathMap extends StatelessWidget {
  const ConnectionDoctorPathMap({super.key, required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final stageStates = snapshot.isFresh
        ? {for (final stage in snapshot.stages) stage.id: stage.state}
        : const <String, DoctorStageState>{};
    final stages = [
      _DoctorPathStage(
        id: 'app',
        label: appLocalizations.doctorPathApp,
        icon: Icons.apps_rounded,
        state: stageStates['app'] ?? DoctorStageState.unknown,
      ),
      _DoctorPathStage(
        id: 'ingress',
        label: _ingressLabel(context, snapshot.pathKind),
        icon: _ingressIcon(snapshot.pathKind),
        state: stageStates['ingress'] ?? DoctorStageState.unknown,
      ),
      _DoctorPathStage(
        id: 'route',
        label: appLocalizations.doctorPathRoute,
        icon: Icons.alt_route_rounded,
        state: stageStates['route'] ?? DoctorStageState.unknown,
      ),
      _DoctorPathStage(
        id: 'internet',
        label: appLocalizations.doctorPathInternet,
        icon: Icons.public_rounded,
        state: stageStates['internet'] ?? DoctorStageState.unknown,
      ),
      _DoctorPathStage(
        id: 'response',
        label: appLocalizations.doctorPathResponse,
        icon: Icons.mark_email_read_outlined,
        state: stageStates['response'] ?? DoctorStageState.unknown,
      ),
    ];
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.doctorPathTitle,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 320 || textScale > 1.3) {
              return _VerticalDoctorPath(stages: stages);
            }
            return _HorizontalDoctorPath(stages: stages);
          },
        ),
      ],
    );
  }
}

String _ingressLabel(BuildContext context, DoctorPathKind pathKind) {
  final appLocalizations = context.appLocalizations;
  return switch (pathKind) {
    DoctorPathKind.vpn => appLocalizations.doctorPathIngressVpn,
    DoctorPathKind.tun => appLocalizations.doctorPathIngressTun,
    DoctorPathKind.localProxy => appLocalizations.doctorPathIngressLocalProxy,
    DoctorPathKind.direct => appLocalizations.doctorPathIngressDirect,
    DoctorPathKind.byeDpi => appLocalizations.doctorPathIngressByeDpi,
    DoctorPathKind.unknown => appLocalizations.doctorPathIngress,
  };
}

IconData _ingressIcon(DoctorPathKind pathKind) => switch (pathKind) {
  DoctorPathKind.vpn || DoctorPathKind.tun => Icons.vpn_lock_outlined,
  DoctorPathKind.localProxy => Icons.lan_outlined,
  DoctorPathKind.direct => Icons.arrow_forward_rounded,
  DoctorPathKind.byeDpi => Icons.shield_outlined,
  DoctorPathKind.unknown => Icons.device_unknown_rounded,
};

class _HorizontalDoctorPath extends StatelessWidget {
  const _HorizontalDoctorPath({required this.stages});

  final List<_DoctorPathStage> stages;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < stages.length; index++) ...[
          Expanded(child: _DoctorPathNode(stage: stages[index])),
          if (index < stages.length - 1)
            _DoctorPathConnector(
              state: _connectorState(stages[index], stages[index + 1]),
            ),
        ],
      ],
    );
  }
}

class _VerticalDoctorPath extends StatelessWidget {
  const _VerticalDoctorPath({required this.stages});

  final List<_DoctorPathStage> stages;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < stages.length; index++) ...[
          _DoctorPathNode(stage: stages[index], vertical: true),
          if (index < stages.length - 1)
            _DoctorPathConnector(
              state: _connectorState(stages[index], stages[index + 1]),
              vertical: true,
            ),
        ],
      ],
    );
  }
}

class _DoctorPathNode extends StatelessWidget {
  const _DoctorPathNode({required this.stage, this.vertical = false});

  final _DoctorPathStage stage;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final stateLabel = _pathStateLabel(context, stage.state);
    final visual = _pathVisual(context, stage.state);
    final marker = Container(
      width: 40,
      height: 40,
      decoration: ShapeDecoration(
        color: visual.background,
        shape: CircleBorder(
          side: BorderSide(color: visual.foreground, width: 2),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        visual.icon ?? stage.icon,
        color: visual.foreground,
        size: 22,
      ),
    );
    final content = Semantics(
      key: ValueKey('doctor_path_${stage.id}'),
      label: '${stage.label}, $stateLabel',
      child: Tooltip(
        message: stateLabel,
        child: vertical
            ? Row(
                children: [
                  marker,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stage.label, style: context.textTheme.bodyMedium),
                        Text(
                          stateLabel,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: visual.foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  marker,
                  const SizedBox(height: 7),
                  Text(
                    stage.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
    return vertical
        ? SizedBox(width: double.infinity, child: content)
        : content;
  }
}

class _DoctorPathConnector extends StatelessWidget {
  const _DoctorPathConnector({required this.state, this.vertical = false});

  final _DoctorPathState state;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final color = _pathVisual(context, state).foreground;
    if (vertical) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 3,
          height: 18,
          margin: const EdgeInsets.only(left: 19),
          color: color,
        ),
      );
    }
    return Container(
      width: 10,
      height: 3,
      margin: const EdgeInsets.only(top: 19),
      color: color,
    );
  }
}

_DoctorPathState _connectorState(
  _DoctorPathStage current,
  _DoctorPathStage next,
) {
  if (next.state == DoctorStageState.failed) return DoctorStageState.failed;
  if (next.state == DoctorStageState.checking) {
    return DoctorStageState.checking;
  }
  if (current.state == DoctorStageState.passed &&
      next.state == DoctorStageState.passed) {
    return DoctorStageState.passed;
  }
  if (next.state == DoctorStageState.consequence) {
    return DoctorStageState.consequence;
  }
  return DoctorStageState.unknown;
}

({Color foreground, Color background, IconData? icon}) _pathVisual(
  BuildContext context,
  _DoctorPathState state,
) {
  final colors = context.colorScheme;
  final success = Colors.green.harmonizeWith(colors.primary);
  final successBackground = Color.alphaBlend(
    success.withValues(alpha: 0.16),
    colors.surfaceContainerHighest,
  );
  return switch (state) {
    DoctorStageState.passed => (
      foreground: success,
      background: successBackground,
      icon: Icons.check_rounded,
    ),
    DoctorStageState.failed => (
      foreground: colors.error,
      background: colors.errorContainer,
      icon: Icons.close_rounded,
    ),
    DoctorStageState.checking => (
      foreground: colors.primary,
      background: colors.primaryContainer,
      icon: Icons.sync_rounded,
    ),
    DoctorStageState.notApplicable => (
      foreground: colors.outline,
      background: colors.surfaceContainerHighest,
      icon: Icons.remove_rounded,
    ),
    DoctorStageState.consequence => (
      foreground: colors.outline,
      background: colors.surfaceContainerHighest,
      icon: Icons.subdirectory_arrow_right_rounded,
    ),
    DoctorStageState.unknown => (
      foreground: colors.outline,
      background: colors.surfaceContainerHighest,
      icon: Icons.question_mark_rounded,
    ),
  };
}

String _pathStateLabel(BuildContext context, _DoctorPathState state) {
  final appLocalizations = context.appLocalizations;
  return switch (state) {
    DoctorStageState.passed => appLocalizations.doctorPathPassed,
    DoctorStageState.failed => appLocalizations.doctorPathFailed,
    DoctorStageState.checking => appLocalizations.doctorPathChecking,
    DoctorStageState.unknown => appLocalizations.doctorPathUnknown,
    DoctorStageState.notApplicable => appLocalizations.doctorPathNotApplicable,
    DoctorStageState.consequence => appLocalizations.doctorPathConsequence,
  };
}

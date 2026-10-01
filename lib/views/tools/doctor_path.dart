import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';

/// The five connection-path stages, in travel order. Shared by the doctor
/// journey map and the classic-dashboard strip so both draw the same picture.
const doctorPathStageIds = ['app', 'ingress', 'route', 'internet', 'response'];

/// One resolved stage: its identity, localized label, glyph, verdict state, and
/// whether it is the blamed culprit or a dimmed downstream consequence.
class DoctorPathStage {
  const DoctorPathStage({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.state,
    required this.dimmed,
    required this.culprit,
  });

  final String id;
  final String label;

  /// A plain-language line under the station name saying what this stage does
  /// or why it failed. Empty while a stage is only being checked or is unknown.
  final String description;
  final Glyph icon;
  final DoctorStageState state;
  final bool dimmed;
  final bool culprit;
}

/// Turns a snapshot into the ordered stage list, resolving the culprit exactly
/// as the verdict above the map does: an explicit failed stage wins, else the
/// blamed stage is forced to read as the fault so picture and answer agree.
List<DoctorPathStage> resolveDoctorPathStages(
  BuildContext context,
  DoctorSnapshot snapshot,
  String? blame,
) {
  final appLocalizations = context.appLocalizations;
  final stageStates = snapshot.isFresh
      ? {for (final stage in snapshot.stages) stage.id: stage.state}
      : const <String, DoctorStageState>{};
  final labels = {
    'app': appLocalizations.doctorPathApp,
    'ingress': doctorPathIngressLabel(context, snapshot.pathKind),
    'route': appLocalizations.doctorPathRoute,
    'internet': appLocalizations.doctorPathInternet,
    'response': appLocalizations.doctorPathResponse,
  };
  final icons = {
    'app': AppGlyphs.appsList,
    'ingress': doctorPathIngressIcon(snapshot.pathKind),
    'route': AppGlyphs.route,
    'internet': AppGlyphs.language,
    'response': AppGlyphs.mailRead,
  };
  final failedIndex = doctorPathStageIds.indexWhere(
    (id) => stageStates[id] == DoctorStageState.failed,
  );
  final blameIndex = snapshot.isFresh && blame != null
      ? doctorPathStageIds.indexOf(blame)
      : -1;
  final culpritIndex = failedIndex != -1 ? failedIndex : blameIndex;
  return [
    for (final (index, id) in doctorPathStageIds.indexed)
      () {
        final dimmed = culpritIndex != -1 && index > culpritIndex;
        final DoctorStageState state;
        if (dimmed) {
          // Nothing past the break was validly reached, so a raw "passed" probe
          // below it must never read as a working station — that green check
          // fights the "skipped, break upstream" line under it.
          state = DoctorStageState.consequence;
        } else if (index == culpritIndex && failedIndex == -1) {
          state = DoctorStageState.failed;
        } else {
          state = stageStates[id] ?? DoctorStageState.unknown;
        }
        return DoctorPathStage(
          id: id,
          label: labels[id]!,
          description: _doctorPathDescription(context, id, state, dimmed),
          icon: icons[id]!,
          state: state,
          culprit: index == culpritIndex,
          dimmed: dimmed,
        );
      }(),
  ];
}

/// The line under a station name. Passed stages describe what they do; a failed
/// stage says what broke; a downstream consequence says it was skipped. Stages
/// still being checked or never reached carry no line, so the state chip alone
/// speaks for them.
String _doctorPathDescription(
  BuildContext context,
  String id,
  DoctorStageState state,
  bool dimmed,
) {
  final appLocalizations = context.appLocalizations;
  if (dimmed || state == DoctorStageState.consequence) {
    return appLocalizations.doctorPathDescConsequence;
  }
  if (state == DoctorStageState.passed) {
    return switch (id) {
      'app' => appLocalizations.doctorPathDescAppOk,
      'ingress' => appLocalizations.doctorPathDescIngressOk,
      'route' => appLocalizations.doctorPathDescRouteOk,
      'internet' => appLocalizations.doctorPathDescInternetOk,
      'response' => appLocalizations.doctorPathDescResponseOk,
      _ => '',
    };
  }
  if (state == DoctorStageState.failed) {
    return switch (id) {
      'app' => appLocalizations.doctorPathDescAppFail,
      'ingress' => appLocalizations.doctorPathDescIngressFail,
      'route' => appLocalizations.doctorPathDescRouteFail,
      'internet' => appLocalizations.doctorPathDescInternetFail,
      'response' => appLocalizations.doctorPathDescResponseFail,
      _ => '',
    };
  }
  return '';
}

/// One plain-language sentence for the hero subtitle that reads the whole path
/// at a glance: examining, idle, stale, a named break, or an all-clear.
String doctorPathSummary(
  BuildContext context,
  DoctorSnapshot snapshot,
  List<DoctorPathStage> stages,
) {
  final appLocalizations = context.appLocalizations;
  if (!snapshot.supported) return appLocalizations.doctorPathSummaryUnsupported;
  if (snapshot.state == DoctorExamState.examining) {
    return appLocalizations.doctorPathSummaryExamining;
  }
  final hasData = snapshot.stages.isNotEmpty || snapshot.evidence.isNotEmpty;
  if (!hasData) return appLocalizations.doctorPathSummaryIdle;
  if (!snapshot.isFresh) return appLocalizations.doctorPathSummaryStale;
  for (final stage in stages) {
    if (stage.culprit) return appLocalizations.doctorPathSummaryBreak(stage.label);
  }
  return appLocalizations.doctorPathSummaryHealthy;
}

String doctorPathIngressLabel(BuildContext context, DoctorPathKind pathKind) {
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

Glyph doctorPathIngressIcon(DoctorPathKind pathKind) => switch (pathKind) {
  DoctorPathKind.vpn || DoctorPathKind.tun => AppGlyphs.vpn,
  DoctorPathKind.localProxy => AppGlyphs.router,
  DoctorPathKind.direct => AppGlyphs.arrowForward,
  DoctorPathKind.byeDpi => AppGlyphs.shield,
  DoctorPathKind.unknown => AppGlyphs.deviceInfo,
};

typedef DoctorPathVisual = ({Color foreground, Color background, Glyph? icon});

DoctorPathVisual doctorPathVisual(BuildContext context, DoctorStageState state) {
  final colors = context.colorScheme;
  final success = colors.success;
  final successBackground = Color.alphaBlend(
    success.withValues(alpha: 0.16),
    colors.surfaceContainerHighest,
  );
  return switch (state) {
    DoctorStageState.passed => (
      foreground: success,
      background: successBackground,
      icon: AppGlyphs.check,
    ),
    DoctorStageState.failed => (
      foreground: colors.error,
      background: colors.errorContainer,
      icon: AppGlyphs.error,
    ),
    DoctorStageState.checking => (
      foreground: colors.primary,
      background: colors.primaryContainer,
      icon: AppGlyphs.sync,
    ),
    DoctorStageState.notApplicable => (
      foreground: colors.outline,
      background: colors.surfaceContainerHighest,
      icon: AppGlyphs.remove,
    ),
    DoctorStageState.consequence => (
      foreground: colors.outline,
      background: colors.surfaceContainerHighest,
      icon: AppGlyphs.subItem,
    ),
    DoctorStageState.unknown => (
      foreground: colors.outline,
      background: colors.surfaceContainerHighest,
      icon: AppGlyphs.circleOutline,
    ),
  };
}

String doctorPathStateLabel(BuildContext context, DoctorStageState state) {
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

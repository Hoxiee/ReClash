part of '../application_notification.dart';

enum NotificationPreviewScenario {
  normal,
  routing,
  problem,
  paused,
  lockScreen,
}

typedef _PreviewLine = ({IconData icon, String text, bool alert});

Widget _previewLineRow(BuildContext context, _PreviewLine line) {
  final colorScheme = context.colorScheme;
  final color = line.alert ? colorScheme.error : colorScheme.onSurfaceVariant;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(line.icon, size: 16, color: color),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          line.text,
          style: context.textTheme.bodySmall?.copyWith(color: color),
        ),
      ),
    ],
  );
}

class NotificationPreview extends StatefulWidget {
  const NotificationPreview({super.key, required this.settings});

  final NotificationSettings settings;

  @override
  State<NotificationPreview> createState() => _NotificationPreviewState();
}

class _NotificationPreviewState extends State<NotificationPreview> {
  NotificationPreviewScenario _scenario = NotificationPreviewScenario.normal;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final hidden = widget.settings.visibility == NotificationVisibility.off;
    return CommonCard(
      radius: AppCorner.xl,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: hidden
              ? [_buildEmptyShade(context, l)]
              : [
                  _buildNotification(context, l),
                  _buildScenarioSelector(context, l),
                ],
        ),
      ),
    );
  }

  Widget _buildEmptyShade(BuildContext context, AppLocalizations l) {
    final colorScheme = context.colorScheme;
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: AppShape.lg.copyWith(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 28),
      child: Column(
        spacing: 10,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          Text(
            l.notificationPreviewHidden,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotification(BuildContext context, AppLocalizations l) {
    final colorScheme = context.colorScheme;
    final settings = widget.settings;
    final locked =
        _scenario == NotificationPreviewScenario.lockScreen &&
        settings.hideSensitiveOnLockScreen;
    final isPaused = _scenario == NotificationPreviewScenario.paused;
    final isProblem = _scenario == NotificationPreviewScenario.problem;
    final (glyphIcon, glyphColor) = _previewGlyph(
      context,
      locked: locked,
      paused: isPaused,
      problem: isProblem,
    );
    final title = locked
        ? l.notificationPreviewLocked
        : isPaused
        ? l.notificationPreviewPaused
        : l.notificationPreviewProfile;
    final lines = locked || isPaused
        ? const <_PreviewLine>[]
        : _previewDetails(l, settings.components, _scenario);
    final showPause = !locked && !isPaused && settings.showPauseAction;
    final showStop = !locked && !isPaused && settings.showStopAction;
    return Container(
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: AppShape.lg.copyWith(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: glyphColor.opacity12,
                  shape: AppShape.sm,
                ),
                child: Icon(glyphIcon, color: glyphColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          if (locked) ...[
            const SizedBox(height: 14),
            _maskBar(context, 168),
            const SizedBox(height: 8),
            _maskBar(context, 104),
          ] else if (lines.isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                for (final line in lines) _previewLineRow(context, line),
              ],
            ),
          ],
          if (showPause || showStop) ...[
            const SizedBox(height: 12),
            Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: 4),
            AbsorbPointer(
              child: Row(
                children: [
                  if (showPause)
                    _buildAction(
                      context,
                      Icons.pause_rounded,
                      l.pause,
                      colorScheme.primary,
                    ),
                  if (showStop)
                    _buildAction(
                      context,
                      Icons.stop_rounded,
                      l.stop,
                      colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _maskBar(BuildContext context, double width) {
    return Container(
      width: width,
      height: 9,
      decoration: ShapeDecoration(
        color: context.colorScheme.onSurfaceVariant.opacity12,
        shape: AppShape.full,
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return TextButton.icon(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: context.textTheme.labelLarge,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _buildScenarioSelector(BuildContext context, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.notificationPreviewScenario,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final scenario in NotificationPreviewScenario.values)
              ChoiceChip(
                label: Text(_scenarioLabel(l, scenario)),
                selected: _scenario == scenario,
                onSelected: (_) => setState(() => _scenario = scenario),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color: Theme.of(context).dividerColor.opacity15,
                ),
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ],
    );
  }

  (IconData, Color) _previewGlyph(
    BuildContext context, {
    required bool locked,
    required bool paused,
    required bool problem,
  }) {
    final colorScheme = context.colorScheme;
    if (locked) {
      return (Icons.lock_outline_rounded, colorScheme.onSurfaceVariant);
    }
    if (paused) {
      return (Icons.pause_circle_outline_rounded, colorScheme.onSurfaceVariant);
    }
    if (problem) return (Icons.warning_amber_rounded, colorScheme.error);
    return (Icons.shield_rounded, colorScheme.primary);
  }

  List<_PreviewLine> _previewDetails(
    AppLocalizations l,
    List<NotificationComponent> components,
    NotificationPreviewScenario scenario,
  ) {
    final lines = <_PreviewLine>[];
    for (final component in components) {
      if (!_showsInScenario(component, scenario)) continue;
      final isDoctorProblem =
          component.type == NotificationComponentType.connectionDoctor &&
          scenario == NotificationPreviewScenario.problem;
      lines.add((
        icon: isDoctorProblem
            ? Icons.warning_amber_rounded
            : _componentIcon(component.type),
        text: isDoctorProblem
            ? l.notificationPreviewProblem
            : _componentSampleLine(l, component.type),
        alert: isDoctorProblem,
      ));
    }
    if (lines.isEmpty) {
      lines.add((
        icon: Icons.verified_user_rounded,
        text: l.heroProtected,
        alert: false,
      ));
    }
    return lines;
  }

  bool _showsInScenario(
    NotificationComponent component,
    NotificationPreviewScenario scenario,
  ) => switch (component.type) {
    NotificationComponentType.connectionDoctor => _showDoctor(
      component.doctorPriority ?? DoctorNotificationPriority.problems,
      scenario,
    ),
    NotificationComponentType.networkState =>
      scenario == NotificationPreviewScenario.routing ||
          scenario == NotificationPreviewScenario.problem,
    NotificationComponentType.smartRouting =>
      scenario == NotificationPreviewScenario.routing,
    NotificationComponentType.speed =>
      scenario != NotificationPreviewScenario.normal ||
          component.hideWhenIdle != true,
    NotificationComponentType.currentServer ||
    NotificationComponentType.sessionTraffic => true,
  };

  bool _showDoctor(
    DoctorNotificationPriority priority,
    NotificationPreviewScenario scenario,
  ) => switch (priority) {
    DoctorNotificationPriority.always => true,
    DoctorNotificationPriority.problems =>
      scenario == NotificationPreviewScenario.problem,
  };
}

String _scenarioLabel(
  AppLocalizations l,
  NotificationPreviewScenario scenario,
) => switch (scenario) {
  NotificationPreviewScenario.normal => l.notificationScenarioNormal,
  NotificationPreviewScenario.routing => l.notificationScenarioRouting,
  NotificationPreviewScenario.problem => l.notificationScenarioProblem,
  NotificationPreviewScenario.paused => l.notificationScenarioPaused,
  NotificationPreviewScenario.lockScreen => l.notificationScenarioLockScreen,
};

import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/views/tools/connection_doctor.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkDetection extends ConsumerWidget {
  const NetworkDetection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final networkDetection = ref.watch(networkDetectionProvider);
    final snapshot = ref.watch(connectionDoctorProvider);
    final ipInfo = networkDetection.ipInfo;
    final titleColor = context.colorScheme.onSurfaceVariant;
    final flag = ipInfo == null ? null : countryCodeToEmoji(ipInfo.countryCode);
    return DashboardInfoCard(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      icon: AppGlyphs.healthMonitor,
      label: appLocalizations.networkDetection,
      leading: flag == null
          ? null
          : Text(
              flag,
              style: context.textTheme.titleSmall?.copyWith(
                fontFamily: FontFamily.twEmoji.value,
              ),
            ),
      action: const GlyphIcon(AppGlyphs.chevronForward, size: 20),
      onPressed: () =>
          showExtend(context, builder: (_) => const ConnectionDoctorView()),
      child: FadeThroughBox(
        child: Row(
          key: ValueKey('${snapshot.health}:${ipInfo?.ip}'),
          children: [
            Expanded(
              child: TooltipText(
                text: Text(
                  connectionDoctorTitle(appLocalizations, snapshot),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: _statusColor(context, appLocalizations, snapshot),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (ipInfo != null)
              Text(
                ipInfo.ip,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: titleColor,
                  fontFamily: FontFamily.jetBrainsMono.value,
                ),
              )
            else if (networkDetection.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CommonCircleLoading(),
              )
            else
              Text(
                appLocalizations.doctorIpUnavailable,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(color: titleColor),
              ),
          ],
        ),
      ),
    );
  }
}

Color _statusColor(
  BuildContext context,
  AppLocalizations appLocalizations,
  DoctorSnapshot snapshot,
) {
  if (!snapshot.supported || !snapshot.isFresh) {
    return context.colorScheme.onSurfaceVariant;
  }
  return switch (connectionDoctorAnswer(appLocalizations, snapshot).tone) {
    DoctorAnswerTone.bad => context.colorScheme.error,
    DoctorAnswerTone.warning => Colors.orange,
    _ => context.colorScheme.onSurface,
  };
}

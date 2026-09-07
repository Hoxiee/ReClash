import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeServerButton extends ConsumerWidget {
  const ChangeServerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(activeServerProvider);
    final code = server.countryCode;
    final name = server.displayName.isEmpty
        ? context.appLocalizations.unknown
        : server.displayName;
    final delay = server.measuring
        ? context.appLocalizations.heroChecking
        : switch (server.delay) {
            final value? when value > 0 => '${value}ms',
            _ => context.appLocalizations.timeout,
          };
    return DashboardInfoCard(
      height: getWidgetHeight(1),
      icon: Icons.swap_horiz_rounded,
      label: context.appLocalizations.changeServer,
      action: const Icon(Icons.chevron_right_rounded, size: 20),
      onPressed: () =>
          ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.proxies),
      child: Row(
        children: [
          Text(
            code == null ? '🌐' : _countryCodeToEmoji(code),
            style: context.textTheme.titleLarge?.copyWith(
              fontFamily: FontFamily.twEmoji.value,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            delay,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color:
                  getDelayColor(server.delay) ??
                  context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _countryCodeToEmoji(String code) {
  if (code.length != 2) return '🌐';
  final upper = code.toUpperCase();
  return String.fromCharCodes([
    0x1F1E6 - 0x41 + upper.codeUnitAt(0),
    0x1F1E6 - 0x41 + upper.codeUnitAt(1),
  ]);
}

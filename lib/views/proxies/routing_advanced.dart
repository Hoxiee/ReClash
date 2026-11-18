import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool watchRoutingAdvanced(WidgetRef ref) =>
    ref.watch(appSettingProvider.select((state) => state.routingAdvanced));

class RoutingAdvancedToggle extends ConsumerWidget {
  const RoutingAdvancedToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    return generateSection(
      footer: l.rcxAdvancedModeHint,
      items: [
        ListItem.toggle(
          title: Text(l.rcxAdvancedMode),
          value: watchRoutingAdvanced(ref),
          onChanged: (value) => ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(routingAdvanced: value)),
        ),
      ],
    );
  }
}

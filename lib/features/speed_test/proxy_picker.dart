import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/speed_test.dart';
import 'package:reclash/widgets/widgets.dart';

class SpeedTestProxyPicker extends ConsumerStatefulWidget {
  const SpeedTestProxyPicker({super.key});

  @override
  ConsumerState<SpeedTestProxyPicker> createState() =>
      _SpeedTestProxyPickerState();
}

class _SpeedTestProxyPickerState extends ConsumerState<SpeedTestProxyPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final groups = ref.watch(groupsProvider);
    final selected = ref.watch(speedTestProxyProvider);
    final active = ref.watch(isStartProvider) && !ref.watch(suspendProvider);
    final names = {
      for (final group in groups) group.name,
      for (final group in groups)
        for (final proxy in group.all)
          if (!proxy.type.toUpperCase().startsWith('REJECT')) proxy.name,
    }..removeAll(['DIRECT', 'REJECT', 'REJECT-DROP']);
    final entries =
        [
              ('', l.speedTestCurrentRoute),
              ('DIRECT', l.speedTestDirect),
              if (active)
                for (final name in names) (name, name),
            ]
            .where(
              (entry) => entry.$2.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();
    return CommonScaffold(
      title: l.speedTestProxy,
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          16,
          context.contentTopPadding + 12,
          16,
          context.bottomInset + 24,
        ),
        itemCount: entries.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  SearchField(
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  Text(
                    l.speedTestProxyHint,
                    style: AppTextStyle.footnote.of(context),
                  ),
                ],
              ),
            );
          }
          final (name, label) = entries[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CommonCard(
              child: ListItem(
                title: Text(label),
                isSelected: selected == name,
                trailing: selected == name ? const SelectionCheck() : null,
                onTap: () {
                  ref.read(speedTestProxyProvider.notifier).select(name);
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

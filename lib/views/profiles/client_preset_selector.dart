import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

class ClientPresetSelector extends StatelessWidget {
  const ClientPresetSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.customUserAgentController,
  });

  final SubscriptionClient selected;

  final ValueChanged<SubscriptionClient> onChanged;

  /// Only visible for the custom preset; its text becomes the profile's
  /// `customUserAgent`. Null hides the field (read-only contexts).
  final TextEditingController? customUserAgentController;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final chips = [
      for (final client in SubscriptionClient.values)
        ChoiceChip(
          label: Text(_labelOf(client, appLocalizations)),
          selected: selected == client,
          onSelected: (_) => onChanged(client),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: Theme.of(context).dividerColor.opacity15),
          labelStyle: Theme.of(context).textTheme.bodyMedium,
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appLocalizations.subscriptionClientLabel),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
        if (selected == SubscriptionClient.custom &&
            customUserAgentController != null) ...[
          const SizedBox(height: 8),
          TextField(
            controller: customUserAgentController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: appLocalizations.customUserAgentLabel,
              helperText: appLocalizations.subscriptionClientDesc,
            ),
          ),
        ],
      ],
    );
  }

  String _labelOf(
    SubscriptionClient client,
    AppLocalizations appLocalizations,
  ) => switch (client) {
        SubscriptionClient.auto => appLocalizations.subscriptionClientAuto,
        SubscriptionClient.clash => appLocalizations.subscriptionClientClash,
        SubscriptionClient.happ => appLocalizations.subscriptionClientHapp,
        SubscriptionClient.incy => appLocalizations.subscriptionClientIncy,
        SubscriptionClient.singbox =>
          appLocalizations.subscriptionClientSingbox,
        SubscriptionClient.v2rayng =>
          appLocalizations.subscriptionClientV2rayNG,
        SubscriptionClient.custom => appLocalizations.subscriptionClientCustom,
      };
}

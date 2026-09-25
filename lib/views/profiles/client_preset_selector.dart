import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/widgets/widgets.dart';
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
        TvFocusOutline(
          child: ChoiceChip(
            label: Text(subscriptionClientLabel(client, appLocalizations)),
            selected: selected == client,
            onSelected: (_) => onChanged(client),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(color: Theme.of(context).dividerColor.opacity15),
            labelStyle: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
    ];
    final compatibilityProfile = !isNativeSubscriptionClient(selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          children: [
            Flexible(child: Text(appLocalizations.subscriptionClientLabel)),
            if (compatibilityProfile)
              CommonChip(
                label: appLocalizations.subscriptionClientExperimentalLabel,
                icon: AppGlyphs.beaker,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
        if (compatibilityProfile) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            appLocalizations.subscriptionClientExperimentalTip,
            style: context.textTheme.bodySmall?.toLighter,
          ),
        ],
        if (selected == SubscriptionClient.custom &&
            customUserAgentController != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: customUserAgentController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: appLocalizations.customUserAgentLabel,
              helperText: appLocalizations.subscriptionClientDesc,
            ),
          ),
        ],
      ],
    );
  }
}

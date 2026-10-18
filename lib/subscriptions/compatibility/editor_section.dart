import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/models/profile.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'client_labels.dart';
import 'client_picker.dart';
import 'clients.dart';

class SubscriptionCompatibilityEditor extends StatelessWidget {
  const SubscriptionCompatibilityEditor({
    super.key,
    required this.preset,
    required this.userAgentController,
    required this.onPresetChanged,
    required this.onUserAgentChanged,
    required this.onCheck,
    required this.onCancel,
    required this.onApply,
    required this.onPin,
    required this.onForgetConsent,
    this.lastSuccessful,
    this.prepared,
    this.checking = false,
    this.saving = false,
    this.invalid = false,
    this.hasConsent = false,
  });

  final SubscriptionClientPreset preset;
  final TextEditingController userAgentController;
  final ValueChanged<SubscriptionClientPreset> onPresetChanged;
  final ValueChanged<String> onUserAgentChanged;
  final VoidCallback? onCheck;
  final VoidCallback onCancel;
  final VoidCallback onApply;
  final ValueChanged<SubscriptionClientPreset> onPin;
  final VoidCallback onForgetConsent;
  final SubscriptionClientPreset? lastSuccessful;
  final PreparedSubscriptionUpdate? prepared;
  final bool checking;
  final bool saving;
  final bool invalid;
  final bool hasConsent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final candidate = prepared;
    final pinnable = candidate?.client ?? lastSuccessful;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        generateSection(
          title: l10n.subscriptionCompatibilityTitle,
          items: [
            SubscriptionClientPresetRow(
              value: preset,
              onChanged: onPresetChanged,
            ),
            if (preset == SubscriptionClientPreset.custom)
              SubscriptionCustomUserAgentRow(
                controller: userAgentController,
                invalid: invalid,
                onChanged: onUserAgentChanged,
              ),
            FormRow(
              title: checking
                  ? l10n.cancel
                  : l10n.subscriptionCompatibilityCheck,
              onPressed: saving
                  ? null
                  : checking
                  ? onCancel
                  : onCheck,
              trailing: checking
                  ? CommonCircleLoading(size: 16.ap(context))
                  : const GlyphIcon(AppGlyphs.refresh),
            ),
            if (lastSuccessful != null)
              FormRow(
                title: l10n.subscriptionCompatibilityLastSuccessful,
                trailing: PopupValueText(lastSuccessful!.label),
              ),
            if (preset == SubscriptionClientPreset.auto &&
                pinnable != null &&
                pinnable != SubscriptionClientPreset.auto)
              FormRow(
                title: l10n.subscriptionCompatibilityPinSuccessful,
                leading: const GlyphIcon(AppGlyphs.pin),
                onPressed: saving || checking ? null : () => onPin(pinnable),
                trailing: PopupValueText(pinnable.label),
              ),
            if (hasConsent)
              FormRow(
                title: l10n.subscriptionCompatibilityForgetConsent,
                onPressed: saving || checking ? null : onForgetConsent,
                trailing: const GlyphIcon(AppGlyphs.remove),
              ),
          ],
          footer:
              '${l10n.subscriptionCompatibilityCheckHint} ${l10n.subscriptionClientDeviceDataHint}',
        ),
        if (candidate != null)
          generateSection(
            items: [
              ListItem(
                title: Text(
                  l10n.subscriptionCompatibilityPrepared(
                    candidate.client.label,
                    candidate.payload.format.label,
                    candidate.summary.nodes,
                  ),
                ),
                leading: const GlyphIcon(AppGlyphs.checkCircle),
              ),
              if (candidate.summary.hasLosses)
                ListItem(
                  title: Text(l10n.subscriptionCompatibilityNeedsReview),
                  leading: const GlyphIcon(AppGlyphs.warning),
                ),
              FormRow(
                title: l10n.subscriptionCompatibilityApplyPrepared,
                onPressed: saving ? null : onApply,
                trailing: const GlyphIcon(AppGlyphs.check),
              ),
            ],
            footer: l10n.subscriptionCompatibilityPreparedHint,
          ),
      ],
    );
  }
}

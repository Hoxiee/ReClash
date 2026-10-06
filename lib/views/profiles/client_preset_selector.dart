import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/widgets/widgets.dart';

const _nativeClients = [
  SubscriptionClient.auto,
  SubscriptionClient.clashMeta,
  SubscriptionClient.clash,
];

const _compatibilityClients = [
  SubscriptionClient.happ,
  SubscriptionClient.incy,
  SubscriptionClient.singbox,
  SubscriptionClient.v2rayng,
  SubscriptionClient.custom,
];

/// One shared consent so add and edit warn identically before a compatibility
/// preset makes ReClash impersonate another client.
Future<bool> confirmSubscriptionClientExperimental(BuildContext context) {
  final appLocalizations = context.appLocalizations;
  return dialogs.showExperimentalNotice(
    context: context,
    message: appLocalizations.subscriptionClientExperimentalNotice,
    confirmText: appLocalizations.experimentalEnable,
  );
}

class ClientPresetSelector extends StatelessWidget {
  const ClientPresetSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.customUserAgentController,
    this.resolvedClient,
  });

  final SubscriptionClient selected;

  final ValueChanged<SubscriptionClient> onChanged;

  /// Only visible for the custom preset; its text becomes the profile's
  /// `customUserAgent`. Null hides the field (read-only contexts).
  final TextEditingController? customUserAgentController;

  /// What `auto` settled on, so an edit screen can show the resolved client and
  /// pin it in one tap. Null when unknown or when a preset is already pinned.
  final SubscriptionClient? resolvedClient;

  bool get _compatibilityProfile => !isNativeSubscriptionClient(selected);

  /// A pinnable auto result only makes sense while the profile still rides
  /// `auto`; a concrete resolved preset of `auto` is not worth surfacing.
  SubscriptionClient? get _pinnableResolved {
    if (selected != SubscriptionClient.auto) return null;
    final resolved = resolvedClient;
    if (resolved == null || resolved == SubscriptionClient.auto) return null;
    return resolved;
  }

  Future<void> _select(BuildContext context, SubscriptionClient client) async {
    if (client == selected) return;
    final needsConsent =
        !isNativeSubscriptionClient(client) &&
        isNativeSubscriptionClient(selected);
    if (needsConsent) {
      final confirmed = await confirmSubscriptionClientExperimental(context);
      if (!confirmed || !context.mounted) return;
    }
    onChanged(client);
  }

  Widget _group(
    BuildContext context,
    String title,
    List<SubscriptionClient> clients,
  ) {
    final appLocalizations = context.appLocalizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.labelMedium?.toLighter,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final client in clients)
              TvFocusOutline(
                child: CommonChoiceChip(
                  label: subscriptionClientLabel(client, appLocalizations),
                  selected: selected == client,
                  onSelected: () => _select(context, client),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final pinnable = _pinnableResolved;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          children: [
            Flexible(child: Text(appLocalizations.subscriptionClientLabel)),
            if (_compatibilityProfile) const ExperimentalBadge(),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _group(
          context,
          appLocalizations.subscriptionClientNativeGroup,
          _nativeClients,
        ),
        const SizedBox(height: AppSpacing.sm),
        _group(
          context,
          appLocalizations.subscriptionClientCompatibilityGroup,
          _compatibilityClients,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subscriptionClientHint(selected, appLocalizations),
          style: context.textTheme.bodySmall?.toLighter,
        ),
        if (pinnable != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            spacing: 8,
            children: [
              Flexible(
                child: Text(
                  appLocalizations.subscriptionClientResolvedTo(
                    subscriptionClientLabel(pinnable, appLocalizations),
                  ),
                  style: context.textTheme.bodySmall?.toLighter,
                ),
              ),
              TextButton(
                onPressed: () => onChanged(pinnable),
                child: Text(appLocalizations.subscriptionClientPin),
              ),
            ],
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

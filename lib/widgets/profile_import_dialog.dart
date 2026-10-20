import 'package:reclash/common/common.dart';
import 'package:reclash/subscriptions/compatibility/client_labels.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/external_link.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

Future<SubscriptionClientSettings?> showProfileImportDialog(
  BuildContext context,
  ProfileLinkSource source,
) => showFloatingDialog<SubscriptionClientSettings>(
  context: context,
  child: _ProfileImportDialog(source: source),
);

class _ProfileImportDialog extends StatefulWidget {
  const _ProfileImportDialog({required this.source});

  final ProfileLinkSource source;

  @override
  State<_ProfileImportDialog> createState() => _ProfileImportDialogState();
}

class _ProfileImportDialogState extends State<_ProfileImportDialog> {
  late SubscriptionClientPreset _preset =
      widget.source.preset ?? SubscriptionClientPreset.auto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final source = widget.source;
    final name = source.name;
    final summary = source.url != null
        ? Uri.tryParse(source.url!)?.host ?? ''
        : source.shareLink != null
        ? profileLinkDisplaySource(source.shareLink!)
        : source.bytes != null
        ? l10n.urlSchemeEmbeddedConfig
        : '';
    final settings = const SubscriptionClientSettings.forNewProfile().copyWith(
      preset: _preset,
    );
    return CommonDialog(
      title: l10n.addProfile,
      trailing: const GlyphIcon(AppGlyphs.cloudDownload),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(settings),
          child: Text(l10n.import),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (name != null && name.isNotEmpty) Text(name),
          if (summary.isNotEmpty) Text(summary),
          if (source.preset != null) ...[
            const SizedBox(height: 16),
            generateSection(
              title: l10n.subscriptionClientRequestAs,
              items: [
                for (final option in [
                  source.preset!,
                  SubscriptionClientPreset.auto,
                ])
                  DecorationListItem(
                    title: Text(option.label),
                    isSelected: option == _preset,
                    trailing: option == _preset ? const SelectionCheck() : null,
                    onPressed: () => setState(() => _preset = option),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

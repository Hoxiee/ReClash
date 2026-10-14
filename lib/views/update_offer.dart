import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_surface.dart';
import 'package:reclash/views/setup/widgets.dart';
import 'package:reclash/widgets/widgets.dart';

enum UpdateOfferChoice { install, skip, dismiss }

/// A full screen offering a release instead of a dialog, so the prompt is a
/// deliberate surface the user acts on rather than something that can land
/// mid-flow. It only presents the release and returns the choice; installing,
/// opening the download page, or muting auto-checks is the caller's call.
class UpdateOfferScreen extends StatelessWidget {
  const UpdateOfferScreen({
    super.key,
    required this.release,
    required this.primaryLabel,
    this.subtitle,
    this.skipLabel,
  });

  final Map<String, dynamic> release;
  final String primaryLabel;
  final String? subtitle;

  /// Null hides the secondary action, leaving only the primary and the back
  /// gesture (which resolves to [UpdateOfferChoice.dismiss]).
  final String? skipLabel;

  static const routeName = 'update-offer';

  static Future<UpdateOfferChoice> show(
    BuildContext context, {
    required Map<String, dynamic> release,
    required String primaryLabel,
    String? subtitle,
    String? skipLabel,
  }) async =>
      await BaseNavigator.push<UpdateOfferChoice>(
        context,
        UpdateOfferScreen(
          release: release,
          primaryLabel: primaryLabel,
          subtitle: subtitle,
          skipLabel: skipLabel,
        ),
        settings: const RouteSettings(name: routeName),
      ) ??
      UpdateOfferChoice.dismiss;

  Future<bool> _dismiss(BuildContext context) async {
    Navigator.of(context).pop(UpdateOfferChoice.dismiss);
    return false;
  }

  void _choose(BuildContext context, UpdateOfferChoice choice) {
    Navigator.of(context).pop(choice);
  }

  List<Widget> _notes(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final body = release['body'] as String?;
    final version = parseReleaseChangelog(body);
    if (version == null) {
      return [
        for (final line in parseReleaseBody(body))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('• $line', style: textTheme.bodyMedium),
          ),
      ];
    }
    final l10n = context.appLocalizations;
    return [
      for (final group in version.visibleGroups) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
          child: Text(
            changelogGroupTitle(l10n, group.type),
            style: textTheme.labelLarge?.copyWith(
              color: group.type == ChangelogType.breaking
                  ? colorScheme.error
                  : colorScheme.primary,
            ),
          ),
        ),
        for (final entry in group.entries)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Text('• ${entry.text}', style: textTheme.bodyMedium),
          ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final tag = release['tag_name'] as String? ?? '';
    return CommonPopScope(
      onPop: _dismiss,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: heroBoardMaxWidth),
              child: SetupStepScaffold(
                header: const SetupLogo(),
                title: l10n.discoverNewVersion,
                subtitle: subtitle,
                body: tag.isEmpty
                    ? null
                    : Text(
                        tag,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                fillBody: SetupScrollCard(children: _notes(context)),
                actions: [
                  SetupPrimaryButton(
                    label: primaryLabel,
                    onPressed: () =>
                        _choose(context, UpdateOfferChoice.install),
                  ),
                  if (skipLabel case final label?)
                    OutlinedButton(
                      onPressed: () =>
                          _choose(context, UpdateOfferChoice.skip),
                      child: Text(label),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

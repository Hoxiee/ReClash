import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets.dart';

class SetupLegalStep extends ConsumerStatefulWidget {
  const SetupLegalStep({
    super.key,
    required this.onAgree,
    required this.onBack,
  });

  final VoidCallback onAgree;
  final VoidCallback onBack;

  @override
  ConsumerState<SetupLegalStep> createState() => _SetupLegalStepState();
}

class _SetupLegalStepState extends ConsumerState<SetupLegalStep> {
  bool _crashlytics = false;
  bool _detailsExpanded = false;

  void _handleAgree() {
    ref
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            disclaimerAccepted: true,
            crashlyticsTip: true,
            crashlytics: system.isAndroid && _crashlytics,
          ),
        );
    widget.onAgree();
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: appName,
      applicationVersion: 'v${globalState.packageInfo.version}',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset('assets/images/icon.png', width: 48, height: 48),
      ),
      applicationLegalese: 'GPL-3.0',
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SetupStepScaffold(
      title: appLocalizations.setupLegalTitle,
      subtitle: appLocalizations.setupLegalSummary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SetupCard(
            child: Column(
              children: [
                ListItem(
                  title: Text(appLocalizations.setupLegalDetails),
                  onTap: () =>
                      setState(() => _detailsExpanded = !_detailsExpanded),
                  trailing: CommonExpandIcon(expand: _detailsExpanded),
                ),
                AnimatedSize(
                  duration: context.motionDuration(midDuration),
                  alignment: Alignment.topCenter,
                  child: _detailsExpanded
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            appLocalizations.disclaimerDesc,
                            style: context.textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                            ),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                ListItem(
                  title: Text(appLocalizations.setupLegalLicense),
                  subtitle: const Text('GPL-3.0'),
                  onTap: _showLicenses,
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                ),
              ],
            ),
          ),
          if (system.isAndroid) ...[
            const SizedBox(height: 12),
            SetupCard(
              child: ListItem.toggle(
                title: Text(appLocalizations.setupDataCollection),
                subtitle: Text(appLocalizations.setupDataCollectionDesc),
                value: _crashlytics,
                onChanged: (value) => setState(() => _crashlytics = value),
              ),
            ),
          ],
        ],
      ),
      actions: [
        SetupPrimaryButton(
          label: appLocalizations.agree,
          onPressed: _handleAgree,
        ),
        OutlinedButton(
          onPressed: widget.onBack,
          child: Text(appLocalizations.setupBack),
        ),
        TextButton(
          onPressed: () => ref.read(systemActionProvider.notifier).handleExit(),
          child: Text(appLocalizations.setupDecline),
        ),
      ],
    );
  }
}

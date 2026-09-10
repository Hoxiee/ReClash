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
  late bool _crashlytics;

  @override
  void initState() {
    super.initState();
    _crashlytics = ref.read(appSettingProvider).crashlytics;
  }

  void _handleAgree() {
    ref
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            disclaimerAccepted: true,
            crashlyticsTip: true,
            crashlytics: system.isAndroid ? _crashlytics : state.crashlytics,
          ),
        );
    widget.onAgree();
  }

  Future<void> _handleDecline() async {
    await ref.read(systemActionProvider.notifier).handleExit();
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
      body: SetupSectionLabel(caption: appLocalizations.setupLegalDetails),
      fillBody: SetupScrollCard(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              appLocalizations.disclaimerDesc,
              style: context.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
      tail: SetupCard(
        child: Column(
          children: [
            if (system.isAndroid)
              ListItem.toggle(
                title: Text(appLocalizations.setupDataCollection),
                subtitle: Text(appLocalizations.setupDataCollectionDesc),
                value: _crashlytics,
                onChanged: (value) => setState(() => _crashlytics = value),
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
      actions: [
        SetupPrimaryButton(
          label: appLocalizations.agree,
          onPressed: _handleAgree,
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onBack,
                child: Text(appLocalizations.setupBack),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: _handleDecline,
                child: Text(
                  appLocalizations.setupDecline,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

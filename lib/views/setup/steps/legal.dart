import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets.dart';

class SetupLegalStep extends ConsumerStatefulWidget {
  const SetupLegalStep({super.key, required this.onAgree});

  final VoidCallback onAgree;

  @override
  ConsumerState<SetupLegalStep> createState() => _SetupLegalStepState();
}

class _SetupLegalStepState extends ConsumerState<SetupLegalStep> {
  bool _crashlytics = false;

  void _handleAgree() {
    // Written before the step changes, so a failure further along the wizard
    // cannot lose a consent the user already gave.
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

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SetupStepScaffold(
      title: appLocalizations.setupLegalTitle,
      subtitle: appLocalizations.disclaimer,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SetupCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                appLocalizations.disclaimerDesc,
                style: context.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ),
          ),
          if (system.isAndroid) ...[
            const SizedBox(height: 12),
            SetupCard(
              child: ListItem.toggle(
                title: Text(appLocalizations.setupDataCollection),
                subtitle: Text(appLocalizations.dataCollectionContent),
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
        TextButton(
          onPressed: () => ref.read(systemActionProvider.notifier).handleExit(),
          child: Text(appLocalizations.exit),
        ),
      ],
    );
  }
}

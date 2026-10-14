import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/views/settings/access.dart';
import 'package:reclash/widgets/widgets.dart';

import '../coverage_choice.dart';
import '../region.dart';
import '../widgets.dart';

/// Asks the one question the wizard cannot answer by itself and the profile
/// cannot answer either: how much of the device goes through ReClash. Each
/// option carries its own consequence, so no step has to explain TUN.
class SetupCoverageStep extends ConsumerWidget {
  const SetupCoverageStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final coverage = setupCoverageOf(ref);
    return SetupStepScaffold(
      header: const SetupDetectedStrip(),
      title: l.setupCoverageTitle,
      subtitle: l.setupCoverageDesc,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          RadioGroup<SetupCoverage>(
            groupValue: coverage,
            onChanged: (value) {
              if (value == null) return;
              applySetupCoverage(ref, value);
            },
            child: SetupCard(
              child: Column(
                children: [
                  for (final option in setupCoverageOptions())
                    ListItem<SetupCoverage>.radio(
                      key: ValueKey('setup-coverage-${option.name}'),
                      value: option,
                      title: Text(setupCoverageLabel(context, option)),
                      subtitle: Text(
                        setupCoverageDescription(context, option),
                      ),
                      onTap: () => applySetupCoverage(ref, option),
                    ),
                ],
              ),
            ),
          ),
          if (coverage == SetupCoverage.selectedApps)
            SetupCard(
              child: ListItem.next(
                key: const ValueKey('setup-coverage-apps'),
                leading: const GlyphIcon(AppGlyphs.appsList),
                title: Text(l.accessControl),
                subtitle: Text(l.accessControlDesc),
                widget: const AccessView(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              l.setupAdvancedLater,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      actions: [
        SetupPrimaryButton(label: l.setupNext, onPressed: onNext),
        OutlinedButton(onPressed: onBack, child: Text(l.setupBack)),
      ],
    );
  }
}

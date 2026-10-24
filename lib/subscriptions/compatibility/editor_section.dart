import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/models/profile.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'client_labels.dart';
import 'client_picker.dart';
import 'clients.dart';

class SubscriptionCompatibilityView {
  const SubscriptionCompatibilityView({
    required this.preset,
    required this.error,
    required this.lastSuccessful,
    required this.prepared,
    required this.checking,
    required this.saving,
    required this.invalid,
    required this.hasConsent,
    required this.canCheck,
  });

  final SubscriptionClientPreset preset;
  final String? error;
  final SubscriptionClientPreset? lastSuccessful;
  final PreparedSubscriptionUpdate? prepared;
  final bool checking;
  final bool saving;
  final bool invalid;
  final bool hasConsent;
  final bool canCheck;
}

class SubscriptionCompatibilityEntryRow extends StatelessWidget {
  const SubscriptionCompatibilityEntryRow({
    super.key,
    required this.preset,
    required this.onPressed,
  });

  final SubscriptionClientPreset preset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FormRow(
      title: context.appLocalizations.subscriptionCompatibilityTitle,
      leading: const GlyphIcon(AppGlyphs.swap),
      onPressed: onPressed,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          PopupValueText(preset.label),
          const GlyphIcon(AppGlyphs.chevronForward),
        ],
      ),
    );
  }
}

class SubscriptionCompatibilityPage extends StatelessWidget {
  const SubscriptionCompatibilityPage({
    super.key,
    required this.listenable,
    required this.read,
    required this.userAgentController,
    required this.onPresetChanged,
    required this.onUserAgentChanged,
    required this.onCheck,
    required this.onCancel,
    required this.onApply,
    required this.onForgetConsent,
  });

  final Listenable listenable;
  final SubscriptionCompatibilityView Function() read;
  final TextEditingController userAgentController;
  final ValueChanged<SubscriptionClientPreset> onPresetChanged;
  final ValueChanged<String> onUserAgentChanged;
  final VoidCallback onCheck;
  final VoidCallback onCancel;
  final VoidCallback onApply;
  final VoidCallback onForgetConsent;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: context.appLocalizations.subscriptionCompatibilityTitle,
      body: Builder(
        builder: (context) => ListenableBuilder(
          listenable: listenable,
          builder: (context, _) {
            final view = read();
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                top: context.contentTopPadding,
                bottom: context.bottomInset + 16,
              ),
              children: [
                ErrorBanner(message: view.error),
                _ClientGrid(
                  value: view.preset,
                  enabled: !view.saving,
                  onChanged: onPresetChanged,
                ),
                if (view.preset == SubscriptionClientPreset.custom)
                  generateSection(
                    items: [
                      SubscriptionCustomUserAgentRow(
                        controller: userAgentController,
                        invalid: view.invalid,
                        onChanged: onUserAgentChanged,
                      ),
                    ],
                  ),
                _CheckPanel(
                  view: view,
                  onCheck: onCheck,
                  onCancel: onCancel,
                  onApply: onApply,
                ),
                if (view.lastSuccessful != null || view.hasConsent)
                  generateSection(
                    items: [
                      if (view.lastSuccessful case final last?)
                        FormRow(
                          title: context
                              .appLocalizations
                              .subscriptionCompatibilityLastSuccessful,
                          leading: const GlyphIcon(AppGlyphs.pin),
                          onPressed:
                              view.preset == SubscriptionClientPreset.auto &&
                                  last != SubscriptionClientPreset.auto &&
                                  !view.saving &&
                                  !view.checking
                              ? () => onPresetChanged(last)
                              : null,
                          trailing: PopupValueText(last.label),
                        ),
                      if (view.hasConsent)
                        FormRow(
                          title: context
                              .appLocalizations
                              .subscriptionCompatibilityForgetConsent,
                          leading: const GlyphIcon(AppGlyphs.reset),
                          onPressed: view.saving || view.checking
                              ? null
                              : onForgetConsent,
                        ),
                    ],
                  ),
              ].separated(const SizedBox(height: 16)).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _ClientGrid extends StatelessWidget {
  const _ClientGrid({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  static const _spacing = 8.0;
  static const _wideBreakpoint = 560.0;

  final SubscriptionClientPreset value;
  final bool enabled;
  final ValueChanged<SubscriptionClientPreset> onChanged;

  @override
  Widget build(BuildContext context) {
    final presets = [
      SubscriptionClientPreset.auto,
      ...subscriptionClientPresetOrder,
      SubscriptionClientPreset.custom,
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= _wideBreakpoint ? 3 : 2;
        final width =
            (constraints.maxWidth - _spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final preset in presets)
              SizedBox(
                width: width,
                child: _ClientTile(
                  preset: preset,
                  selected: preset == value,
                  onPressed: enabled ? () => onChanged(preset) : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ClientTile extends StatelessWidget {
  const _ClientTile({
    required this.preset,
    required this.selected,
    required this.onPressed,
  });

  static const _wellSize = 36.0;
  static const _height = 60.0;

  final SubscriptionClientPreset preset;
  final bool selected;
  final VoidCallback? onPressed;

  Glyph? get _glyph => switch (preset) {
    SubscriptionClientPreset.auto => AppGlyphs.sparkle,
    SubscriptionClientPreset.custom => AppGlyphs.code,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final label = preset.label;
    return SizedBox(
      height: _height,
      child: CommonCard(
        isSelected: selected,
        radius: AppCorner.lg,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onPressed: onPressed,
        child: Row(
          spacing: 12,
          children: [
            SizedBox.square(
              dimension: _wellSize,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: AppShape.circle,
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: switch (_glyph) {
                    final glyph? => GlyphIcon(
                      glyph,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    null => Text(
                      label.characters.first.toUpperCase(),
                      style: AppTextStyle.headline
                          .of(context)
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  },
                ),
              ),
            ),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.subheadline
                    .of(context, emphasized: selected)
                    .copyWith(color: colorScheme.onSurface),
              ),
            ),
            if (selected) const SelectionBadge(),
          ],
        ),
      ),
    );
  }
}

class _CheckPanel extends StatelessWidget {
  const _CheckPanel({
    required this.view,
    required this.onCheck,
    required this.onCancel,
    required this.onApply,
  });

  final SubscriptionCompatibilityView view;
  final VoidCallback onCheck;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final prepared = view.prepared;
    final style = AppTextStyle.subheadline.of(context);
    return CommonCard(
      inert: true,
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (prepared != null) ...[
            Row(
              spacing: 12,
              children: [
                GlyphIcon(
                  AppGlyphs.checkCircle,
                  fill: 1,
                  color: colorScheme.success,
                ),
                Expanded(
                  child: Text(
                    l10n.subscriptionCompatibilityPrepared(
                      prepared.client.label,
                      prepared.payload.format.label,
                      prepared.summary.nodes,
                    ),
                    style: style.copyWith(color: colorScheme.onSurface),
                  ),
                ),
              ],
            ),
            if (prepared.summary.hasLosses)
              Row(
                spacing: 12,
                children: [
                  GlyphIcon(
                    AppGlyphs.warning,
                    fill: 1,
                    color: colorScheme.warning,
                  ),
                  Expanded(
                    child: Text(
                      l10n.subscriptionCompatibilityNeedsReview,
                      style: style.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            FilledButton.icon(
              onPressed: view.saving ? null : onApply,
              icon: const GlyphIcon(AppGlyphs.check, fill: 1),
              label: Text(l10n.subscriptionCompatibilityApplyPrepared),
            ),
          ],
          if (view.checking)
            FilledButton.tonalIcon(
              onPressed: onCancel,
              icon: CommonCircleLoading(size: 16.ap(context)),
              label: Text(l10n.cancel),
            )
          else
            _CheckButton(
              tonal: prepared != null,
              onPressed: view.saving || !view.canCheck ? null : onCheck,
            ),
        ],
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.tonal, required this.onPressed});

  final bool tonal;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = GlyphIcon(AppGlyphs.refresh, fill: tonal ? 0 : 1);
    final label = Text(context.appLocalizations.subscriptionCompatibilityCheck);
    return tonal
        ? FilledButton.tonalIcon(onPressed: onPressed, icon: icon, label: label)
        : FilledButton.icon(onPressed: onPressed, icon: icon, label: label);
  }
}

import 'package:reclash/common/common.dart';
import 'package:reclash/views/dashboard/widgets/hero_surface.dart';
import 'package:material_ui/material_ui.dart';

/// Every step is the same column so the wizard reads as one screen changing its
/// contents, not four screens taking turns.
class SetupStepScaffold extends StatelessWidget {
  const SetupStepScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
    this.subtitle,
    this.header,
    this.scrollable = true,
  });

  final String title;
  final String? subtitle;
  final Widget? header;
  final Widget body;
  final List<Widget> actions;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (header != null) ...[header!, const SizedBox(height: 24)],
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 24),
        body,
      ],
    );
    return Column(
      children: [
        Expanded(
          child: scrollable
              ? SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: content,
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: content,
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: actions,
          ),
        ),
      ],
    );
  }
}

class SetupPrimaryButton extends StatelessWidget {
  const SetupPrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
    child: Text(label),
  );
}

class SetupLogo extends StatelessWidget {
  const SetupLogo({super.key});

  @override
  Widget build(BuildContext context) {
    const size = 88.0;
    return Center(
      child: ClipRSuperellipse(
        borderRadius: AppRadius.all(AppCorner.fit(size)),
        child: Image.asset(
          'assets/images/icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class SetupProgress extends StatelessWidget {
  const SetupProgress({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: midDuration,
            curve: Curves.easeOutCubic,
            width: i == index ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: AppRadius.full,
              color: i == index
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
      ],
    );
  }
}

/// The dashboard's own material, hosting list rows. The inner `Material` is what
/// their ink paints on: without it a `ListTile` would splash on the ancestor
/// above this card's background and be invisible.
class SetupCard extends StatelessWidget {
  const SetupCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: heroSurfaceDecoration(context),
    clipBehavior: Clip.antiAlias,
    child: Material(type: MaterialType.transparency, child: child),
  );
}

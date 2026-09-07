import 'package:reclash/common/common.dart';
import 'package:reclash/views/dashboard/widgets/hero_surface.dart';
import 'package:material_ui/material_ui.dart';

class SetupStepScaffold extends StatelessWidget {
  const SetupStepScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
    this.subtitle,
    this.header,
  });

  final String title;
  final String? subtitle;
  final Widget? header;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) ...[header!, const SizedBox(height: 24)],
              Focus(
                autofocus: true,
                descendantsAreFocusable: false,
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
              const SizedBox(height: 24),
              ...actions.expand(
                (action) => [action, const SizedBox(height: 8)],
              ),
            ],
          ),
        ),
      ),
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
    return ExcludeSemantics(
      child: Center(
        child: ClipRSuperellipse(
          borderRadius: AppRadius.all(AppCorner.fit(size)),
          child: Image.asset(
            'assets/images/icon.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class SetupProgress extends StatelessWidget {
  const SetupProgress({
    super.key,
    required this.count,
    required this.index,
    required this.label,
  });

  final int count;
  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Semantics(
      label: label,
      value: '${index + 1}/$count',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: context.motionDuration(midDuration),
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
        ),
      ),
    );
  }
}

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

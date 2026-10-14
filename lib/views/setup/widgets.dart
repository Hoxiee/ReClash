import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_surface.dart';
import 'package:reclash/widgets/widgets.dart';

/// The widest the wizard grows: a decision column with the receipt beside it.
/// Past that it centres, because a form read across a 4K window is unreadable.
const double setupIslandMaxWidth = 1160;

const double setupLogoSize = 88;

/// Side inset shared by the body, the receipt and the action bar, so the
/// buttons land under the receipt's edge instead of floating mid-column.
const double _gutter = AppSpacing.xl;

const double _asideWidth = 320;
const double _actionHeight = 52;

/// Carries the shell's layout decision and its chrome down to the step, which
/// lays both out: the action bar can then span the window while its buttons
/// still line up with the column above them.
class SetupLayoutScope extends InheritedWidget {
  const SetupLayoutScope({
    super.key,
    required this.wide,
    this.aside,
    this.banner,
    required super.child,
  });

  final bool wide;

  /// The receipt, beside the step body on a wide window.
  final Widget? aside;

  /// The dot progress, above the step body everywhere else.
  final Widget? banner;

  static SetupLayoutScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SetupLayoutScope>();

  static bool isWide(BuildContext context) => of(context)?.wide ?? false;

  @override
  bool updateShouldNotify(SetupLayoutScope oldWidget) =>
      wide != oldWidget.wide ||
      aside != oldWidget.aside ||
      banner != oldWidget.banner;
}

class SetupStepScaffold extends StatefulWidget {
  const SetupStepScaffold({
    super.key,
    required this.title,
    required this.actions,
    this.subtitle,
    this.header,
    this.inlineHeader = false,
    this.body,
    this.fillBody,
    this.tail,
  });

  final String title;
  final String? subtitle;
  final Widget? header;

  /// Puts a [setupLogoSize] header beside the heading on a wide window, where
  /// a masthead stacked over a left-aligned title reads as two headings.
  final bool inlineHeader;

  final Widget? body;

  /// Gets a bounded slot of its own between the heading block and [tail], so a
  /// long list scrolls inside the step instead of stretching it.
  final Widget? fillBody;

  /// Sits under [fillBody] and stays out of its scroll.
  final Widget? tail;

  final List<Widget> actions;

  @override
  State<SetupStepScaffold> createState() => _SetupStepScaffoldState();
}

class _SetupStepScaffoldState extends State<SetupStepScaffold> {
  /// Below this the heading block and a slot worth scrolling cannot both fit,
  /// so the step gives up its bounded slot and scrolls as one page instead.
  static const _fillMinExtent = 520.0;

  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _heading(BuildContext context, bool wide) {
    final textTheme = context.textTheme;
    // A wide window reads as a document column, where centred headings drift
    // away from the cards below them; a phone keeps the centred masthead.
    final align = wide ? TextAlign.start : TextAlign.center;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            widget.title,
            textAlign: align,
            style: (wide ? textTheme.headlineMedium : textTheme.headlineSmall)
                ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
          ),
        ),
        if (widget.subtitle case final subtitle?) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            textAlign: align,
            style: textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _head(BuildContext context) {
    final wide = SetupLayoutScope.isWide(context);
    final heading = _heading(context, wide);
    final header = widget.header;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header == null)
          heading
        else if (wide && widget.inlineHeader)
          Row(
            spacing: AppSpacing.xl,
            children: [
              SizedBox.square(dimension: setupLogoSize, child: header),
              Expanded(child: heading),
            ],
          )
        else ...[
          header,
          const SizedBox(height: AppSpacing.xxl),
          heading,
        ],
        if (widget.body case final body?) ...[
          const SizedBox(height: AppSpacing.xxl),
          body,
        ],
      ],
    );
  }

  Widget _pageView(BuildContext context) {
    return FocusedScrollView(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        padding: const EdgeInsets.only(
          top: AppSpacing.xl,
          bottom: AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.xl,
          children: [_head(context), ?widget.fillBody, ?widget.tail],
        ),
      ),
    );
  }

  /// Loose flex, not [Expanded]: the slot caps the body at the screen instead
  /// of stretching a short list over empty space.
  Widget _fillView(BuildContext context, Widget fillBody) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xl,
            bottom: AppSpacing.xl,
          ),
          child: _head(context),
        ),
        Flexible(child: fillBody),
        if (widget.tail case final tail?)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: tail,
          ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    final actions = [
      for (final action in widget.actions)
        SizedBox(height: _actionHeight, child: TvFocusOutline(child: action)),
    ];
    if (SetupLayoutScope.isWide(context)) {
      // Wrap, not Row: a step can offer three actions, and the check step's
      // labels are long enough to overflow a single line in a narrow column.
      return Wrap(
        alignment: WrapAlignment.end,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: actions.reversed.toList(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.sm,
      children: actions,
    );
  }

  /// The centred column every band shares. [SizedBox.expand] keeps it at the
  /// window width under a loose constraint, so a short step still fills it.
  Widget _island(BuildContext context, {required bool wide, Widget? child}) =>
      Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: wide ? setupIslandMaxWidth : heroBoardMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final scope = SetupLayoutScope.of(context);
    final wide = scope?.wide ?? false;
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final fillBody = widget.fillBody;
        final fits =
            constraints.maxHeight >=
            MediaQuery.textScalerOf(context).scale(_fillMinExtent);
        if (fillBody == null || !fits) {
          return _pageView(context);
        }
        return _fillView(context, fillBody);
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _island(
            context,
            wide: wide,
            child: switch (scope?.aside) {
              final aside? => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xxl,
                children: [
                  Expanded(child: body),
                  SizedBox(
                    width: _asideWidth,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                      ),
                      child: aside,
                    ),
                  ),
                ],
              ),
              null => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [?scope?.banner, Expanded(child: body)],
              ),
            },
          ),
        ),
        // A band across the window, not a button adrift in the column: the
        // divider and the raised surface are what separate decision from act.
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: _island(
            context,
            wide: wide,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: _footer(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// One system permission the wizard can ask for, with its own status line so
/// the row says what happened rather than only what it wants.
class SetupPermissionRow extends StatelessWidget {
  const SetupPermissionRow({
    super.key,
    required this.title,
    required this.desc,
    required this.status,
    this.granted = false,
    this.failed = false,
    this.pending = false,
    this.onPressed,
    this.trailing,
  });

  final String title;
  final String desc;
  final String status;
  final bool granted;
  final bool failed;
  final bool pending;
  final VoidCallback? onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tone = failed
        ? colorScheme.error
        : granted
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    return ListItem(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(desc),
          Text(
            status,
            style: context.textTheme.bodySmall?.copyWith(
              color: tone,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      onTap: pending ? null : onPressed,
      trailing: pending
          ? const SizedBox.square(dimension: 20, child: CommonCircleLoading())
          : trailing ??
                (onPressed == null
                    ? GlyphIcon(AppGlyphs.check, size: 20, color: tone)
                    : const GlyphIcon(AppGlyphs.chevronForward, size: 20)),
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
    // A finite minimum: the stacked footer stretches the button itself, and a
    // Size.fromHeight minimum would force infinite width inside a footer row.
    style: FilledButton.styleFrom(minimumSize: const Size(160, _actionHeight)),
    child: Text(label),
  );
}

class SetupLogo extends StatelessWidget {
  const SetupLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Align(
        alignment: SetupLayoutScope.isWide(context)
            ? AlignmentDirectional.centerStart
            : Alignment.center,
        child: ClipRSuperellipse(
          borderRadius: AppRadius.all(AppCorner.fit(setupLogoSize)),
          child: Image.asset(
            'assets/images/icon.png',
            width: setupLogoSize,
            height: setupLogoSize,
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

class SetupSectionLabel extends StatelessWidget {
  const SetupSectionLabel({super.key, required this.caption, this.description});

  final String caption;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            caption,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (description case final description?) ...[
          const SizedBox(height: AppSpacing.xxs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              description,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SetupSection extends StatelessWidget {
  const SetupSection({
    super.key,
    required this.caption,
    this.description,
    required this.child,
  });

  final String caption;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SetupSectionLabel(caption: caption, description: description),
      const SizedBox(height: AppSpacing.sm),
      child,
    ],
  );
}

/// Fills the slot the step hands it and scrolls inside that box; where the step
/// has no bounded slot to give, the same children shrink-wrap into its page.
class SetupScrollCard extends StatefulWidget {
  const SetupScrollCard({super.key, this.revealIndex, required this.children});

  final int? revealIndex;
  final List<Widget> children;

  @override
  State<SetupScrollCard> createState() => _SetupScrollCardState();
}

class _SetupScrollCardState extends State<SetupScrollCard> {
  final _controller = ScrollController();
  final _revealKey = GlobalKey();
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reveal() {
    if (_revealed || !mounted || widget.revealIndex == null) return;
    final target = _revealKey.currentContext?.findRenderObject();
    if (target == null || !_controller.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
      return;
    }
    _revealed = true;
    _controller.position.ensureVisible(
      target,
      alignment: 0.5,
      duration: context.motionDuration(midDuration),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scrolls = constraints.hasBoundedHeight;
      final list = ListView(
        controller: _controller,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: scrolls ? null : const NeverScrollableScrollPhysics(),
        children: [
          for (var index = 0; index < widget.children.length; index++)
            if (index == widget.revealIndex)
              KeyedSubtree(key: _revealKey, child: widget.children[index])
            else
              widget.children[index],
        ],
      );
      return SetupCard(
        child: scrolls
            ? CommonScrollBar(
                controller: _controller,
                thumbVisibility: true,
                child: ScrollConfiguration(
                  behavior: const HiddenBarScrollBehavior(),
                  child: FocusedScrollView(
                    controller: _controller,
                    child: list,
                  ),
                ),
              )
            : list,
      );
    },
  );
}

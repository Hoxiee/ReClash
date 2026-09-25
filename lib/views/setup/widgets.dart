import 'package:reclash/common/common.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_surface.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class SetupStepScaffold extends StatefulWidget {
  const SetupStepScaffold({
    super.key,
    required this.title,
    required this.actions,
    this.subtitle,
    this.header,
    this.body,
    this.fillBody,
    this.tail,
  });

  final String title;
  final String? subtitle;
  final Widget? header;
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
  bool _scrolledUnder = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setScrolledUnder(bool value) {
    if (value == _scrolledUnder) return;
    // Metrics land during layout, where the flag cannot be applied in place.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || value == _scrolledUnder) return;
      setState(() => _scrolledUnder = value);
    });
  }

  bool _onScroll(int depth, ScrollMetrics metrics) {
    if (depth == 0) {
      _setScrolledUnder(metrics.extentAfter > 0.5);
    }
    return false;
  }

  Widget _head(BuildContext context) {
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.header case final header?) ...[
          header,
          const SizedBox(height: AppSpacing.xxl),
        ],
        Semantics(
          header: true,
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (widget.subtitle case final subtitle?) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (widget.body case final body?) ...[
          const SizedBox(height: AppSpacing.xxl),
          body,
        ],
      ],
    );
  }

  Widget _pageView(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) =>
          _onScroll(notification.depth, notification.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) =>
            _onScroll(notification.depth, notification.metrics),
        child: FocusedScrollView(
          controller: _controller,
          child: SingleChildScrollView(
            controller: _controller,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [_head(context), ?widget.fillBody, ?widget.tail],
            ),
          ),
        ),
      ),
    );
  }

  /// Loose flex, not [Expanded]: the slot caps the body at the screen instead
  /// of stretching a short list over empty space.
  Widget _fillView(BuildContext context, Widget fillBody) {
    _setScrolledUnder(false);
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: _head(context),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: fillBody,
            ),
          ),
          if (widget.tail case final tail?)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: tail,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final footerChildren = <Widget>[];
    for (var index = 0; index < widget.actions.length; index++) {
      footerChildren.add(TvFocusOutline(child: widget.actions[index]));
      if (index < widget.actions.length - 1) {
        footerChildren.add(const SizedBox(height: AppSpacing.sm));
      }
    }
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
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
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: _scrolledUnder
                    ? colorScheme.outlineVariant
                    : Colors.transparent,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: footerChildren,
            ),
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

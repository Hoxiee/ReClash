import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/shape.dart';
import 'package:reclash/ui/inherited.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';

class SettingsRevealScope extends InheritedWidget {
  const SettingsRevealScope({
    super.key,
    required super.child,
    this.targetId,
    this.nonce = 0,
    this.active = true,
  });

  final String? targetId;
  final int nonce;
  final bool active;

  static SettingsRevealScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsRevealScope>();

  @override
  bool updateShouldNotify(SettingsRevealScope oldWidget) =>
      targetId != oldWidget.targetId ||
      nonce != oldWidget.nonce ||
      active != oldWidget.active;
}

class SettingsPageScroll extends StatelessWidget {
  const SettingsPageScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: child);
  }
}

class SettingTarget extends StatefulWidget {
  const SettingTarget({super.key, required this.spec, required this.child});

  final SettingSpec spec;
  final Widget child;

  @override
  State<SettingTarget> createState() => _SettingTargetState();
}

class _SettingTargetState extends State<SettingTarget>
    with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode(skipTraversal: true);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  late final Animation<double> _highlight = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  (String?, int)? _handledRequest;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _revealIfRequested();
  }

  @override
  void didUpdateWidget(covariant SettingTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _revealIfRequested();
  }

  void _revealIfRequested() {
    final scope = SettingsRevealScope.maybeOf(context);
    if (scope == null ||
        !scope.active ||
        scope.targetId != widget.spec.id ||
        (scope.targetId, scope.nonce) == _handledRequest) {
      return;
    }
    _handledRequest = (scope.targetId, scope.nonce);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !PageActivityScope.isActiveOf(context)) return;
      final current = SettingsRevealScope.maybeOf(context);
      if (current == null ||
          !current.active ||
          current.targetId != widget.spec.id ||
          current.nonce != scope.nonce) {
        return;
      }
      final reduced = MediaQuery.disableAnimationsOf(context);
      Scrollable.ensureVisible(
        context,
        duration: reduced ? Duration.zero : const Duration(milliseconds: 220),
        alignment: 0.25,
        curve: Curves.easeInOut,
      );
      _focusNode.requestFocus();
      if (!reduced) _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    (_highlight as CurvedAnimation).dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: AnimatedBuilder(
        animation: Listenable.merge([_highlight, _focusNode]),
        builder: (context, child) => DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: ShapeDecoration(
            shape: AppShape.xl.copyWith(
              side: _focusNode.hasPrimaryFocus
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : BorderSide.none,
            ),
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: _highlight.value * 0.10),
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

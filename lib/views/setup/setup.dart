import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';

import 'layout.dart';
import 'steps/check.dart';
import 'steps/coverage.dart';
import 'steps/language.dart';
import 'steps/legal.dart';
import 'steps/subscription.dart';

enum SetupWizardMode { firstRun, revisit }

class SetupWizard extends ConsumerStatefulWidget {
  const SetupWizard({super.key, bool revisit = false})
    : mode = revisit ? SetupWizardMode.revisit : SetupWizardMode.firstRun;

  const SetupWizard.revisit({super.key}) : mode = SetupWizardMode.revisit;

  final SetupWizardMode mode;

  bool get revisit => mode == SetupWizardMode.revisit;

  /// Names the route so a breakpoint crossing that resets stranded tools spares
  /// the wizard, which owns the whole screen at any width.
  static const routeName = 'setup-wizard';

  static Future<void> show(BuildContext context, {bool revisit = false}) =>
      BaseNavigator.push<void>(
        context,
        revisit ? const SetupWizard.revisit() : const SetupWizard(),
        settings: const RouteSettings(name: routeName),
      );

  @override
  ConsumerState<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends ConsumerState<SetupWizard>
    with SingleTickerProviderStateMixin {
  static const _switchDuration = Duration(milliseconds: 140);

  /// First-run walks every stage; a revisit skips the one-time legal gate.
  List<SetupStage> get _stages => widget.revisit
      ? const [
          SetupStage.welcome,
          SetupStage.subscription,
          SetupStage.coverage,
          SetupStage.check,
        ]
      : const [
          SetupStage.welcome,
          SetupStage.legal,
          SetupStage.subscription,
          SetupStage.coverage,
          SetupStage.check,
        ];

  int get _stepCount => _stages.length;

  late final AnimationController _switchController = AnimationController(
    vsync: this,
    duration: _switchDuration,
    value: 1,
  );
  late final CurvedAnimation _switchIn = CurvedAnimation(
    parent: _switchController,
    curve: Easing.standardDecelerate,
  );
  late final Animation<double> _fade = _switchIn.drive(
    Tween(begin: 0.4, end: 1),
  );
  late Animation<Offset> _slide = _switchIn.drive(
    Tween(begin: Offset.zero, end: Offset.zero),
  );
  late int _index;
  SetupCheckOutcome _outcome = SetupCheckOutcome.pending;
  String? _outcomeDetail;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(appSettingProvider).setupStep;
    // A revisit always restarts at the top; a first run resumes where it left
    // off. The stage order guarantees any resumable index past the legal gate
    // was only reached by passing it, so resuming never skips consent.
    _index = widget.revisit ? 0 : saved.clamp(0, _stepCount - 1);
    if (!widget.revisit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _seedRegion();
      });
    }
  }

  void _seedRegion() {
    final locale =
        getLocaleForString(ref.read(appSettingProvider).locale) ??
        Localizations.localeOf(context);
    seedRegionIfUnset(ref.read, ref.read(regionSignalsProvider), locale);
  }

  @override
  void dispose() {
    _switchIn.dispose();
    _switchController.dispose();
    super.dispose();
  }

  // The same fade-forwards a tab switch uses: a jump, never a scroll, so the
  // steps in between are never built.
  void _toStep(int index) {
    if (index < 0 || index >= _stepCount || index == _index) return;
    final direction = (index - _index).sign.toDouble();
    setState(() => _index = index);
    if (!widget.revisit) {
      ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(setupStep: index));
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (context.disableAnimations ||
        ref.read(appSettingProvider).tabAnimation == TabAnimation.off) {
      _switchController.value = 1;
      return;
    }
    _slide = _switchIn.drive(
      Tween(begin: Offset(direction * 0.08, 0), end: Offset.zero),
    );
    _switchController.forward(from: 0);
  }

  Future<bool> _handlePop(BuildContext context) async {
    if (_index > 0) {
      _toStep(_index - 1);
      return false;
    }
    if (widget.revisit) {
      Navigator.of(context).pop();
    } else if (globalState.escapeBackDepth == 0) {
      await ref.read(systemActionProvider.notifier).handleClose();
    }
    return false;
  }

  void _handleOutcome(SetupCheckOutcome outcome, String? detail) {
    if (!mounted || (outcome == _outcome && detail == _outcomeDetail)) return;
    setState(() {
      _outcome = outcome;
      _outcomeDetail = detail;
    });
  }

  void _handleDone() {
    if (!widget.revisit) {
      ref
          .read(appSettingProvider.notifier)
          .update(
            (state) => state.copyWith(setupCompleted: true, setupStep: 0),
          );
    }
    Navigator.of(context).pop();
  }

  List<Widget> _steps() => widget.revisit
      ? [
          SetupLanguageStep(onNext: () => _toStep(1)),
          SetupSubscriptionStep(
            recommendAutoRun: false,
            onNext: () => _toStep(2),
            onBack: () => _toStep(0),
          ),
          SetupCoverageStep(onNext: () => _toStep(3), onBack: () => _toStep(1)),
          SetupCheckStep(
            revisit: true,
            onDone: _handleDone,
            onBack: () => _toStep(2),
            onOutcome: _handleOutcome,
          ),
        ]
      : [
          SetupLanguageStep(onNext: () => _toStep(1)),
          SetupLegalStep(onAgree: () => _toStep(2), onBack: () => _toStep(0)),
          SetupSubscriptionStep(
            onNext: () => _toStep(3),
            onBack: () => _toStep(1),
          ),
          SetupCoverageStep(onNext: () => _toStep(4), onBack: () => _toStep(2)),
          SetupCheckStep(
            onDone: _handleDone,
            onBack: () => _toStep(3),
            onOutcome: _handleOutcome,
          ),
        ];

  @override
  Widget build(BuildContext context) {
    return CommonPopScope(
      onPop: _handlePop,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: SafeArea(
          child: FocusTraversalGroup(
            policy: PageTraversalPolicy(),
            child: PageFocusScope(
              child: SetupShell(
                stages: _stages,
                index: _index,
                onJump: _toStep,
                outcome: _outcome,
                outcomeDetail: _outcomeDetail,
                child: SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    // One step at a time, with no pager underneath it: a pager
                    // is a scrollable, and anything that reveals a focused
                    // widget through its ancestors would scroll the wizard off
                    // the step it just opened.
                    child: PageFocusScope(
                      key: ValueKey(_index),
                      autofocus: true,
                      child: _steps()[_index],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_surface.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'steps/finish.dart';
import 'steps/language.dart';
import 'steps/legal.dart';
import 'steps/subscription.dart';
import 'widgets.dart';

enum SetupWizardMode { firstRun, revisit }

class SetupWizard extends ConsumerStatefulWidget {
  const SetupWizard({super.key, bool revisit = false})
    : mode = revisit ? SetupWizardMode.revisit : SetupWizardMode.firstRun;

  const SetupWizard.revisit({super.key}) : mode = SetupWizardMode.revisit;

  final SetupWizardMode mode;

  bool get revisit => mode == SetupWizardMode.revisit;

  static Future<void> show(BuildContext context, {bool revisit = false}) =>
      BaseNavigator.push<void>(
        context,
        revisit ? const SetupWizard.revisit() : const SetupWizard(),
      );

  @override
  ConsumerState<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends ConsumerState<SetupWizard>
    with SingleTickerProviderStateMixin {
  static const _firstRunStepCount = 4;
  static const _revisitStepCount = 3;
  static const _switchDuration = Duration(milliseconds: 140);

  int get _stepCount => widget.revisit ? _revisitStepCount : _firstRunStepCount;

  late final int _initialIndex;
  late final PageController _controller;
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

  @override
  void initState() {
    super.initState();
    final saved = ref.read(appSettingProvider).setupStep;
    _initialIndex = widget.revisit ? 0 : saved.clamp(0, _stepCount - 1);
    _index = _initialIndex;
    _controller = PageController(initialPage: _initialIndex);
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
    _controller.dispose();
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
    _controller.jumpToPage(index);
    FocusManager.instance.primaryFocus?.unfocus();
    if (context.disableAnimations ||
        !ref.read(appSettingProvider).isAnimateToPage) {
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
          SetupFinishStep(
            revisit: true,
            onDone: _handleDone,
            onBack: () => _toStep(1),
          ),
        ]
      : [
          SetupLanguageStep(onNext: () => _toStep(1)),
          SetupLegalStep(onAgree: () => _toStep(2), onBack: () => _toStep(0)),
          SetupSubscriptionStep(
            onNext: () => _toStep(3),
            onBack: () => _toStep(1),
          ),
          SetupFinishStep(onDone: _handleDone, onBack: () => _toStep(2)),
        ];

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonPopScope(
      onPop: _handlePop,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: heroBoardMaxWidth),
              child: FocusTraversalGroup(
                policy: PageTraversalPolicy(),
                child: PageFocusScope(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: SetupProgress(
                          count: _stepCount,
                          index: _index,
                          label: appLocalizations.setupStepProgress(
                            _index + 1,
                            _stepCount,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SlideTransition(
                          position: _slide,
                          child: FadeTransition(
                            opacity: _fade,
                            child: PageView(
                              controller: _controller,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                for (final (index, step) in _steps().indexed)
                                  ExcludeFocus(
                                    excluding: index != _index,
                                    child: PageFocusScope(
                                      autofocus: index == _index,
                                      child: step,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

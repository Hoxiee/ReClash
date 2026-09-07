import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/hero_surface.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'steps/finish.dart';
import 'steps/language.dart';
import 'steps/legal.dart';
import 'steps/subscription.dart';
import 'widgets.dart';

class SetupWizard extends ConsumerStatefulWidget {
  const SetupWizard({super.key, this.revisit = false});

  final bool revisit;

  static Future<void> show(BuildContext context, {bool revisit = false}) =>
      BaseNavigator.push<void>(context, SetupWizard(revisit: revisit));

  @override
  ConsumerState<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends ConsumerState<SetupWizard>
    with SingleTickerProviderStateMixin {
  static const _stepCount = 4;

  late final int _initialIndex;
  late final PageController _controller;
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: commonDuration,
    value: 1,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeOutCubic,
  );
  late int _index;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(appSettingProvider).setupStep;
    _initialIndex = widget.revisit ? 0 : saved.clamp(0, _stepCount - 1);
    _index = _initialIndex;
    _controller = PageController(initialPage: _initialIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fadeController.duration = context.motionDuration(commonDuration);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toStep(int index) {
    if (index < 0 || index >= _stepCount || index == _index) return;
    setState(() => _index = index);
    if (!widget.revisit) {
      ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(setupStep: index));
    }
    _controller.jumpToPage(index);
    FocusManager.instance.primaryFocus?.unfocus();
    if (context.disableAnimations) {
      _fadeController.value = 1;
    } else {
      _fadeController.forward(from: 0);
    }
  }

  Future<bool> _handlePop(BuildContext context) async {
    if (_index > 0) {
      _toStep(_index - 1);
      return false;
    }
    if (widget.revisit) {
      Navigator.of(context).pop();
    } else {
      await ref.read(systemActionProvider.notifier).handleClose();
    }
    return false;
  }

  void _handleDone() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(setupCompleted: true, setupStep: 0));
    Navigator.of(context).pop();
  }

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
                        child: FadeTransition(
                          opacity: _fade,
                          child: PageView(
                            controller: _controller,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              SetupLanguageStep(onNext: () => _toStep(1)),
                              SetupLegalStep(
                                onAgree: () => _toStep(2),
                                onBack: () => _toStep(0),
                              ),
                              SetupSubscriptionStep(
                                onNext: () => _toStep(3),
                                onBack: () => _toStep(1),
                              ),
                              SetupFinishStep(
                                onDone: _handleDone,
                                onBack: () => _toStep(2),
                              ),
                            ],
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

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

/// The first-run flow. It writes into the same providers the settings screens
/// write to and never starts the tunnel itself: the `autoRun` toggle it sets is
/// what `initStatus` reads once the wizard is gone.
class SetupWizard extends ConsumerStatefulWidget {
  const SetupWizard({super.key});

  static Future<void> show(BuildContext context) =>
      BaseNavigator.push<void>(context, const SetupWizard());

  @override
  ConsumerState<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends ConsumerState<SetupWizard>
    with SingleTickerProviderStateMixin {
  static const _stepCount = 4;

  final _controller = PageController();
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: commonDuration,
    value: 1,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeOutCubic,
  );
  int _index = 0;

  @override
  void dispose() {
    _fadeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// A jump behind a crossfade, the same movement a tab change makes: scrolling
  /// would build every step in between.
  void _toStep(int index) {
    if (index < 0 || index >= _stepCount || index == _index) {
      return;
    }
    setState(() => _index = index);
    _controller.jumpToPage(index);
    _fadeController.forward(from: 0);
  }

  Future<bool> _handlePop(BuildContext context) async {
    if (_index > 0) {
      _toStep(_index - 1);
      return false;
    }
    await ref.read(systemActionProvider.notifier).handleClose();
    return false;
  }

  void _handleDone() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(setupCompleted: true));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CommonPopScope(
      onPop: _handlePop,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: heroBoardMaxWidth),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: SetupProgress(count: _stepCount, index: _index),
                  ),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fade,
                      child: PageView(
                        controller: _controller,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          SetupLanguageStep(onNext: () => _toStep(1)),
                          SetupLegalStep(onAgree: () => _toStep(2)),
                          SetupSubscriptionStep(onNext: () => _toStep(3)),
                          SetupFinishStep(onDone: _handleDone),
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
    );
  }
}

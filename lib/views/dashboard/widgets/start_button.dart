import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/smart_pause_network_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _widthAnimationDuration = Duration(milliseconds: 200);
const _buttonHeight = 56.0;

TextStyle? _runTimeTextStyle(BuildContext context) {
  return context.textTheme.titleMedium?.toSoftBold.copyWith(
    color: context.colorScheme.onPrimaryContainer,
  );
}

TextStyle? _hundredsTextStyle(BuildContext context) {
  return context.textTheme.titleMedium?.toSoftBold.copyWith(
    color: context.colorScheme.primary,
    fontWeight: FontWeight.w600,
  );
}

double _computeRunTimeTextWidth(BuildContext context, String text) {
  final daySeparator = text.indexOf('d ');
  final placeholder = daySeparator == -1
      ? '99:99:99'
      : '${'9' * daySeparator}d 99:99:99';
  return globalState.measure
          .computeTextSize(Text(placeholder, style: _runTimeTextStyle(context)))
          .width +
      16;
}

class RunTimeText extends StatelessWidget {
  final int? timeStamp;

  const RunTimeText({super.key, required this.timeStamp});

  @override
  Widget build(BuildContext context) {
    final text = getTimeText(timeStamp);
    final style = _runTimeTextStyle(context);
    final daySeparator = text.indexOf('d ');
    final textWidget = daySeparator == -1
        ? Text(text, maxLines: 1, overflow: TextOverflow.visible, style: style)
        : Text.rich(
            TextSpan(
              text: text.substring(0, daySeparator + 1),
              style: _hundredsTextStyle(context),
              children: [
                TextSpan(text: text.substring(daySeparator + 1), style: style),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: style,
          );
    return textWidget;
  }
}

class StartButton extends ConsumerStatefulWidget {
  const StartButton({super.key});

  @override
  ConsumerState<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends ConsumerState<StartButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;
  final _runTimeTextWidths = <int, double>{};
  double? _pausedTextWidth;
  int? _displayRunTime;

  @override
  void initState() {
    super.initState();
    final isStart = ref.read(isStartProvider);
    _displayRunTime = ref.read(runTimeProvider);
    _controller = AnimationController(
      vsync: this,
      value: isStart ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller!, curve: Easing.standard);
    ref.listenManual(runTimeProvider, (_, next) {
      _updateDisplayRunTime(next);
    });
    ref.listenManual(isStartProvider, (prev, next) {
      updateController(next);
    }, fireImmediately: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller!.duration = context.disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);
    _runTimeTextWidths.clear();
    _pausedTextWidth = null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void handleSwitchStart() {
    ref.read(commonActionProvider.notifier).toggleRunning();
  }

  void _updateDisplayRunTime(int? runTime) {
    if (!mounted ||
        _displayRunTime == runTime ||
        (runTime == null && !(_controller?.isDismissed ?? true))) {
      return;
    }
    setState(() {
      _displayRunTime = runTime;
    });
  }

  void updateController(bool isStart) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controller = _controller;
      if (controller == null) {
        return;
      }
      if (isStart) {
        controller.forward();
        return;
      }
      controller.reverse().whenCompleteOrCancel(() {
        if (mounted && controller.isDismissed) {
          _updateDisplayRunTime(ref.read(runTimeProvider));
        }
      });
    });
  }

  double _getRunTimeTextWidth(BuildContext context, String text) {
    return _runTimeTextWidths.putIfAbsent(
      text.length,
      () => _computeRunTimeTextWidth(context, text),
    );
  }

  double _getPausedTextWidth(BuildContext context, String pausedText) {
    return _pausedTextWidth ??=
        globalState.measure
            .computeTextSize(
              Text(pausedText, style: context.textTheme.titleMedium),
            )
            .width +
        24;
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final byedpiMode = ref.watch(
      effectiveDesyncSettingProvider.select(
        (state) => state.enabled && state.onlyDpi,
      ),
    );
    if (!hasProfile && !byedpiMode) {
      return Container();
    }
    final paused = ref.watch(pausedProvider);
    final isStart = ref.watch(isStartProvider);
    final showPauseButton =
        isStart && (ref.watch(tunEnabledProvider) || paused);
    final theme = Theme.of(context);
    final appLocalizations = context.appLocalizations;
    final textWidth = paused
        ? _getPausedTextWidth(context, appLocalizations.paused)
        : _getRunTimeTextWidth(context, getTimeText(_displayRunTime));
    final widthDuration = context.motionDuration(_widthAnimationDuration);
    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widthDuration == Duration.zero
              ? (showPauseButton ? const _PauseFab() : const SizedBox(width: 8))
              : AnimatedSize(
                  duration: widthDuration,
                  curve: Easing.standard,
                  alignment: Alignment.centerRight,
                  child: showPauseButton
                      ? const _PauseFab()
                      : const SizedBox(width: 8),
                ),
          Theme(
            data: theme.copyWith(
              floatingActionButtonTheme: theme.floatingActionButtonTheme
                  .copyWith(
                    sizeConstraints: const BoxConstraints(
                      minWidth: 56,
                      minHeight: _buttonHeight,
                      maxHeight: _buttonHeight,
                    ),
                  ),
            ),
            child: FloatingActionButton(
              clipBehavior: Clip.antiAlias,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              heroTag: null,
              tooltip: isStart ? appLocalizations.stop : appLocalizations.start,
              onPressed: () {
                handleSwitchStart();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (_, child) {
                      return Container(
                        height: _buttonHeight,
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16 - 8 * _animation.value,
                        ),
                        alignment: Alignment.centerLeft,
                        child: child,
                      );
                    },
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _animation,
                    ),
                  ),
                  SizeTransition(
                    axis: Axis.horizontal,
                    alignment: Alignment.centerLeft,
                    sizeFactor: _animation,
                    child: AnimatedContainer(
                      width: textWidth,
                      duration: context.motionDuration(_widthAnimationDuration),
                      curve: Easing.standard,
                      child: paused
                          ? Text(
                              appLocalizations.paused,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: context.colorScheme.onPrimaryContainer,
                              ),
                            )
                          : RunTimeText(timeStamp: _displayRunTime),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stays on screen while paused: pause keeps the service alive to resume.
class _PauseFab extends ConsumerWidget {
  const _PauseFab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final paused = ref.watch(pausedProvider);
    return GestureDetector(
      onLongPress: () => showSmartPauseNetworkSheet(context, ref),
      child: FloatingActionButton.small(
        heroTag: null,
        tooltip: paused ? appLocalizations.resume : appLocalizations.pause,
        onPressed: () => ref.read(commonActionProvider.notifier).togglePaused(),
        child: Icon(paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
      ),
    );
  }
}

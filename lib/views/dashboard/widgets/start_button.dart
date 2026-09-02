import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _threeDigitHourThreshold = 100 * 60 * 60 * 1000;
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

double _computeRunTimeTextWidth(
  BuildContext context, {
  required bool hasThreeDigitHours,
}) {
  final regularWidth = globalState.measure
      .computeTextSize(Text('99:99:99', style: _runTimeTextStyle(context)))
      .width;
  if (!hasThreeDigitHours) {
    return regularWidth + 16;
  }
  final hundredsWidth = globalState.measure
      .computeTextSize(Text('9', style: _hundredsTextStyle(context)))
      .width;
  return hundredsWidth + regularWidth + 16;
}

class RunTimeText extends StatelessWidget {
  final int? timeStamp;

  const RunTimeText({super.key, required this.timeStamp});

  @override
  Widget build(BuildContext context) {
    final text = getTimeText(timeStamp);
    final style = _runTimeTextStyle(context);
    final textWidget = text.length < 9
        ? Text(text, maxLines: 1, overflow: TextOverflow.visible, style: style)
        : Text.rich(
            TextSpan(
              text: text.substring(0, 1),
              style: _hundredsTextStyle(context),
              children: [TextSpan(text: text.substring(1), style: style)],
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
  double? _twoDigitTextWidth;
  double? _threeDigitTextWidth;
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
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeOutBack,
    );
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
    _twoDigitTextWidth = null;
    _threeDigitTextWidth = null;
    _pausedTextWidth = null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void handleSwitchStart() {
    if (ref.read(pausedProvider)) {
      ref.read(commonActionProvider.notifier).togglePaused();
      return;
    }
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

  double _getRunTimeTextWidth(
    BuildContext context, {
    required bool hasThreeDigitHours,
  }) {
    if (hasThreeDigitHours) {
      return _threeDigitTextWidth ??= _computeRunTimeTextWidth(
        context,
        hasThreeDigitHours: true,
      );
    }
    return _twoDigitTextWidth ??= _computeRunTimeTextWidth(
      context,
      hasThreeDigitHours: false,
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
    if (!hasProfile) {
      return Container();
    }
    final paused = ref.watch(pausedProvider);
    final isStart = ref.watch(isStartProvider);
    final showPauseButton = isStart && !paused && ref.watch(tunEnabledProvider);
    final hasThreeDigitHours =
        (_displayRunTime ?? 0) >= _threeDigitHourThreshold;
    final theme = Theme.of(context);
    final appLocalizations = context.appLocalizations;
    final textWidth = paused
        ? _getPausedTextWidth(context, appLocalizations.paused)
        : _getRunTimeTextWidth(context, hasThreeDigitHours: hasThreeDigitHours);
    // While paused the service still runs, so the text panel stays open but
    // the glyph flips to play — the next tap resumes.
    final iconAnimation = paused
        ? const AlwaysStoppedAnimation<double>(0)
        : _animation;
    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: _widthAnimationDuration,
            curve: Curves.easeOut,
            alignment: Alignment.centerRight,
            child: showPauseButton
                ? FloatingActionButton.small(
                    heroTag: null,
                    tooltip: appLocalizations.pause,
                    onPressed: () {
                      ref.read(commonActionProvider.notifier).togglePaused();
                    },
                    child: const Icon(Icons.pause_rounded),
                  )
                : const SizedBox(width: 8),
          ),
          Theme(
            data: theme.copyWith(
              floatingActionButtonTheme: theme.floatingActionButtonTheme
                  .copyWith(
                    sizeConstraints: const BoxConstraints(
                      minWidth: 56,
                      maxWidth: 220,
                      minHeight: _buttonHeight,
                      maxHeight: _buttonHeight,
                    ),
                  ),
            ),
            child: FloatingActionButton(
              clipBehavior: Clip.antiAlias,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              heroTag: null,
              tooltip: paused
                  ? appLocalizations.resume
                  : isStart
                  ? appLocalizations.stop
                  : appLocalizations.start,
              onPressed: () {
                handleSwitchStart();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: iconAnimation,
                    builder: (_, child) {
                      return Container(
                        height: _buttonHeight,
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16 - 8 * iconAnimation.value,
                        ),
                        alignment: Alignment.centerLeft,
                        child: child,
                      );
                    },
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: iconAnimation,
                    ),
                  ),
                  SizeTransition(
                    axis: Axis.horizontal,
                    alignment: Alignment.centerLeft,
                    sizeFactor: _animation,
                    child: AnimatedContainer(
                      width: textWidth,
                      duration: _widthAnimationDuration,
                      curve: Curves.easeOut,
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

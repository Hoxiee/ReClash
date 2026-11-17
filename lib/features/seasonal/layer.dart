import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'calendar.dart';
import 'painter.dart';
import 'providers.dart';

/// Paints the season's effects between the page background and [child].
class SeasonalBackdrop extends ConsumerStatefulWidget {
  const SeasonalBackdrop({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SeasonalBackdrop> createState() => _SeasonalBackdropState();
}

class _SeasonalBackdropState extends ConsumerState<SeasonalBackdrop>
    with TickerProviderStateMixin {
  late final AnimationController _presence = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
    reverseDuration: const Duration(milliseconds: 500),
  )..addStatusListener(_onPresence);
  late final Ticker _ticker = createTicker(_onTick);
  final _time = ValueNotifier<double>(0);
  late final AppLifecycleListener _lifecycle;
  AppLifecycleState? _lifecycleState;
  Timer? _midnight;
  List<SeasonalEffect> _effects = const [];
  bool _still = false;

  @override
  void initState() {
    super.initState();
    _lifecycleState = SchedulerBinding.instance.lifecycleState;
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycle);
    _scheduleMidnight();
    ref.listenManual(
      seasonalEffectsProvider,
      (_, next) => _show(next),
      fireImmediately: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still && _effects.isNotEmpty) _presence.value = 1;
    _syncTicker();
  }

  void _show(List<SeasonalEffect> next) {
    if (next.isNotEmpty) {
      if (!mounted) return;
      setState(() => _effects = next);
      if (_still) {
        _presence.value = 1;
      } else {
        _presence.forward();
      }
    } else if (_still || _presence.isDismissed) {
      _presence.value = 0;
      if (_effects.isNotEmpty) setState(() => _effects = const []);
    } else {
      _presence.reverse();
    }
    _syncTicker();
  }

  void _onPresence(AnimationStatus status) {
    if (status.isDismissed && mounted) {
      setState(() => _effects = const []);
      _syncTicker();
    }
  }

  void _onLifecycle(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      ref.read(seasonalTodayProvider.notifier).refresh();
      _scheduleMidnight();
    }
    _syncTicker();
  }

  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = ref.read(seasonalClockProvider)();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(next.difference(now), () {
      ref.read(seasonalTodayProvider.notifier).refresh();
      _scheduleMidnight();
    });
  }

  void _syncTicker() {
    final visible = switch (_lifecycleState) {
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => false,
      _ => true,
    };
    final run = _effects.isNotEmpty && !_still && visible;
    if (run && !_ticker.isActive) {
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration _) {
    _time.value =
        SchedulerBinding.instance.currentFrameTimeStamp.inMicroseconds / 1e6;
  }

  @override
  void dispose() {
    _midnight?.cancel();
    _lifecycle.dispose();
    _ticker.dispose();
    _presence
      ..removeStatusListener(_onPresence)
      ..dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effects = _effects;
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (effects.isEmpty)
          const SizedBox.shrink()
        else
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: SeasonalPainter(
                      effects: effects,
                      time: _time,
                      presence: _presence,
                      dark: colorScheme.brightness == Brightness.dark,
                      tint: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}

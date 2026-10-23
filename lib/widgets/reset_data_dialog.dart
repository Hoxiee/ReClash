import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';

class ResetDataDialog extends StatefulWidget {
  const ResetDataDialog({super.key, required this.onReset});

  final Future<void> Function() onReset;

  @override
  State<ResetDataDialog> createState() => _ResetDataDialogState();
}

class _ResetDataDialogState extends State<ResetDataDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countdown;
  late final Timer _confirmationTimer;
  bool _ready = false;
  bool _busy = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _countdown = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
    _confirmationTimer = Timer(const Duration(seconds: 3), () {
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _confirmationTimer.cancel();
    _countdown.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_busy || !_ready) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onReset();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final danger = context.colorScheme.destructive;
    return PopScope(
      canPop: !_busy,
      child: AnimatedBuilder(
        animation: _countdown,
        builder: (context, _) {
          final ready = _ready;
          final seconds = (3 * (1 - _countdown.value)).ceil();
          return CommonDialog(
            title: l.resetAllData,
            destructive: true,
            actions: [
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: ready && !_busy ? _reset : null,
                child: Text(_busy ? l.resettingAllData : l.resetAllDataConfirm),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.resetAllDataDescription),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: !ready || _busy ? 1 : 0),
                  duration: const Duration(milliseconds: 300),
                  curve: Easing.standard,
                  builder: (context, value, child) => ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: value,
                      child: Opacity(opacity: value, child: child),
                    ),
                  ),
                  child: ExcludeSemantics(
                    excluding: ready && !_busy,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: _busy ? null : _countdown.value,
                          color: danger,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _busy
                              ? l.resettingAllData
                              : l.resetAllDataWait(seconds.clamp(1, 3)),
                          style: AppTextStyle.footnote.of(context),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_error case final error?) ...[
                  const SizedBox(height: 16),
                  Text(
                    l.clearDataFailed(compactError(error)),
                    style: AppTextStyle.footnote
                        .of(context)
                        .copyWith(color: danger),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

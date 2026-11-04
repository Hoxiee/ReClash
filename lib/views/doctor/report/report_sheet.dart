import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/report/collector.dart';
import 'package:reclash/features/doctor/report/redact.dart';
import 'package:reclash/features/doctor/report/report.dart';
import 'package:reclash/features/doctor/report/sweep.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

import 'capture.dart';
import 'delivery.dart';
import 'options.dart';
import 'progress.dart';
import 'result.dart';
import 'stage.dart';
import 'start.dart';

/// Pushes the report into the sheet [context] is a page of, and opens a
/// paged sheet for it anywhere else, so its options page can follow.
Future<void> showReportSheet(BuildContext context) {
  if (isSheetPage(context)) {
    return Navigator.of(
      context,
    ).push(PagedSheetRoute<void>(builder: (_) => const ReportSheet()));
  }
  return showSheet<void>(
    context: context,
    props: const SheetProps(
      backgroundColor: Colors.transparent,
      detents: [0.9],
    ),
    builder: (_) => NestedPagedSheet(builder: (_) => const ReportSheet()),
  );
}

/// The sweep's own pace once it has some, but never past what its timeout
/// allows for the nodes left.
Duration? reportSweepEta(ReportProgress progress, Duration elapsed) {
  final ReportProgress(:phase, :done, :total) = progress;
  if (phase != ReportPhase.sweep || done == 0 || done >= total) return null;
  if (elapsed < const Duration(seconds: 2)) return null;
  final left = total - done;
  final paced = elapsed * (left / done);
  final bound = sweepNodeTimeout * (left / sweepConcurrency).ceil();
  return paced < bound ? paced : bound;
}

enum _Stage { start, recording, building, result, failed }

/// "Report a problem": what went wrong, an optional recording, the checks
/// with their progress, and the finished report with its way out.
class ReportSheet extends ConsumerStatefulWidget {
  const ReportSheet({super.key});

  @override
  ConsumerState<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<ReportSheet> {
  final _note = TextEditingController();
  final _draft = ReportDraft();
  final _sweepClock = Stopwatch();
  var _stage = _Stage.start;
  var _secondsLeft = 0;
  Timer? _timer;
  LogCaptureSession? _capture;
  List<String>? _captureLines;
  ReportControl? _control;
  ReportProgress _progress = const ReportProgress(ReportPhase.snapshot);
  ReportResult? _result;
  bool _leaked = false;

  @override
  void dispose() {
    _timer?.cancel();
    _capture?.stop();
    _control?.cancel();
    _note.dispose();
    _draft.dispose();
    super.dispose();
  }

  void _create() {
    FocusScope.of(context).unfocus();
    if (!_draft.reproduce) {
      unawaited(_build(null));
      return;
    }
    _capture = ref.read(logCaptureProvider)(
      ProviderScope.containerOf(context, listen: false),
    );
    setState(() {
      _stage = _Stage.recording;
      _secondsLeft = reportCaptureLength.inSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _finishRecording();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _finishRecording() {
    _timer?.cancel();
    _timer = null;
    final lines = _capture?.stop();
    _capture = null;
    unawaited(_build(lines));
  }

  void _onProgress(ReportControl control, ReportProgress progress) {
    if (!mounted || !identical(_control, control)) return;
    if (progress.phase == ReportPhase.sweep && progress.done == 0) {
      _sweepClock
        ..reset()
        ..start();
    } else if (progress.phase != ReportPhase.sweep) {
      _sweepClock.stop();
    }
    setState(() => _progress = progress);
  }

  Future<void> _build(List<String>? captureLines) async {
    final control = ReportControl();
    _control = control;
    _captureLines = captureLines;
    setState(() {
      _stage = _Stage.building;
      _progress = const ReportProgress(ReportPhase.snapshot);
    });
    final note = _note.text.trim();
    final ReportResult result;
    try {
      result = await ref.read(reportRunnerProvider)(
        ReportOptions(
          note: note.isEmpty ? null : note,
          redaction: _draft.redaction,
          sections: _draft.sections,
          captureLines: captureLines,
        ),
        onProgress: (progress) => _onProgress(control, progress),
        control: control,
      );
    } on ReportCancelled {
      return;
    } on Object catch (error) {
      if (mounted && identical(_control, control)) {
        _control = null;
        setState(() {
          _leaked = error is ReportLeak;
          _stage = _Stage.failed;
        });
      }
      return;
    }
    if (!mounted || !identical(_control, control)) return;
    _control = null;
    setState(() {
      _result = result;
      _stage = _Stage.result;
    });
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
    _capture?.stop();
    _capture = null;
    _control?.cancel();
    _control = null;
    setState(() => _stage = _Stage.start);
  }

  void _skipServers() {
    _control?.stopSweep();
    setState(() {});
  }

  void _openOptions() => unawaited(
    showInSheet<void>(
      context,
      builder: (_) => ReportOptionsPage(draft: _draft),
    ),
  );

  void _changeContents() {
    setState(() => _stage = _Stage.start);
    _openOptions();
  }

  Widget _buildStage() {
    final l = context.appLocalizations;
    return switch (_stage) {
      _Stage.start => ReportStartView(
        note: _note,
        draft: _draft,
        onCreate: _create,
        onOptions: _openOptions,
      ),
      _Stage.recording => ReportRecordingView(
        secondsLeft: _secondsLeft,
        onFinish: _finishRecording,
        onCancel: _cancel,
      ),
      _Stage.building => ReportBuildingView(
        progress: _progress,
        recorded: _captureLines != null,
        sweepStopped: _control?.sweepStopped ?? false,
        eta: reportSweepEta(_progress, _sweepClock.elapsed),
        onSkip: _skipServers,
        onCancel: _cancel,
      ),
      _Stage.result => ReportResultView(result: _result!),
      _Stage.failed => CommonScaffold(
        title: l.reportProblem,
        body: ReportStageLayout(
          hero: ReportHero(
            badge: ReportBadge(
              color: reportAlertColor(context),
              value: 1,
              child: GlyphIcon(_leaked ? AppGlyphs.lock : AppGlyphs.error),
            ),
            title: _leaked ? l.reportLeak : l.reportFailed,
            subtitle: Text(_leaked ? l.reportLeakHint : l.reportFailedHint),
          ),
          primary: _leaked
              ? FilledButton(
                  key: const ValueKey('report-change'),
                  onPressed: _changeContents,
                  child: Text(l.reportChangeContents),
                )
              : FilledButton.icon(
                  key: const ValueKey('report-retry'),
                  onPressed: () => unawaited(_build(_captureLines)),
                  icon: const GlyphIcon(AppGlyphs.refresh, fill: 1),
                  label: Text(l.retry),
                ),
          secondary: TextButton(
            key: const ValueKey('report-back'),
            onPressed: () => setState(() => _stage = _Stage.start),
            child: Text(l.reportStartOver),
          ),
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: context.motionDuration(midDuration),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: KeyedSubtree(key: ValueKey(_stage), child: _buildStage()),
    );
  }
}

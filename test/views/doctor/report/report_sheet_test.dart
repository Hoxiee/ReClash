import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/report/collector.dart';
import 'package:reclash/features/doctor/report/redact.dart';
import 'package:reclash/features/doctor/report/report.dart';
import 'package:reclash/views/doctor/report/capture.dart';
import 'package:reclash/features/doctor/report/sweep.dart';
import 'package:reclash/views/doctor/report/delivery.dart';
import 'package:reclash/views/doctor/report/progress.dart';
import 'package:reclash/views/doctor/report/report_sheet.dart';
import 'package:reclash/views/doctor/report/result.dart';

import '../../../helpers/preferences.dart';
import '../../../helpers/test_app.dart';

final _result = ReportResult(
  id: 'RC-AB12-CD34',
  path: '/tmp/reclash-report-2026-11-04-1200-RC-AB12-CD34.zip',
  summary: '# ReClash report RC-AB12-CD34\n\n- Verdict: fail at server\n',
  sizes: const {'README.md': 900, '01-summary.md': 300},
  createdAt: DateTime.utc(2026, 11, 4, 12),
  redaction: ReportRedaction.provider,
);

class _Runner {
  final calls = <ReportOptions>[];
  ReportProgressCallback? onProgress;
  ReportControl? control;
  Completer<ReportResult> completer = Completer();

  Future<ReportResult> call(
    ReportOptions options, {
    ReportProgressCallback? onProgress,
    ReportControl? control,
  }) {
    calls.add(options);
    this.onProgress = onProgress;
    this.control = control;
    completer = Completer();
    return completer.future;
  }
}

class _Capture implements LogCaptureSession {
  bool stopped = false;

  @override
  List<String> stop() {
    stopped = true;
    return const ['12:00 DEBUG dial'];
  }
}

class _Delivery extends ReportDelivery {
  _Delivery({required super.canShare});

  final calls = <String>[];

  @override
  Future<bool> share(ReportResult report) async {
    calls.add('share');
    return true;
  }

  @override
  Future<bool> save(ReportResult report) async {
    calls.add('save');
    return true;
  }

  @override
  Future<bool> saveToDownloads(ReportResult report) async {
    calls.add('downloads');
    return true;
  }

  @override
  Future<void> copySummary(ReportResult report) async {
    calls.add('copy');
  }
}

class _Uploader extends ReportUploader {
  _Uploader(this.answers);

  final List<Object> answers;
  final targets = <Uri>[];

  @override
  Future<ReportReceipt> upload(Uri target, ReportResult report) async {
    targets.add(target);
    final answer = answers.removeAt(0);
    if (answer is ReportReceipt) return answer;
    throw answer as ReportUploadFailure;
  }
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  RequestOptions? request;
  String body = '';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final bytes = <int>[];
    await requestStream?.forEach(bytes.addAll);
    body = String.fromCharCodes(bytes);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => mockPreferences());

  Future<_Runner> pump(
    WidgetTester tester, {
    ReportSupport support = const ReportSupport(),
    ReportDelivery? delivery,
    ReportUploader? uploader,
    LogCaptureSession? capture,
  }) async {
    final runner = _Runner();
    tester.view
      ..physicalSize = const Size(800, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestApp(
        locale: const Locale('en'),
        withStatusManager: true,
        overrides: [
          reportRunnerProvider.overrideWithValue(runner.call),
          reportSupportProvider.overrideWithValue(support),
          reportDeliveryProvider.overrideWithValue(
            delivery ?? _Delivery(canShare: false),
          ),
          if (uploader != null)
            reportUploaderProvider.overrideWithValue(uploader),
          if (capture != null)
            logCaptureProvider.overrideWithValue((_) => capture),
        ],
        child: const ReportSheet(),
      ),
    );
    await tester.pumpAndSettle();
    return runner;
  }

  Future<void> create(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('report-create')));
    await tester.pump();
  }

  Future<void> finish(WidgetTester tester, _Runner runner) async {
    runner.completer.complete(_result);
    await tester.pumpAndSettle();
  }

  testWidgets('creates a report, counts the servers and skips the rest', (
    tester,
  ) async {
    final runner = await pump(tester);
    final l = currentAppLocalizations;
    await tester.enterText(find.byType(TextField), '  no internet  ');
    await tester.tap(find.text(l.reportSymptomSlow));
    await create(tester);

    expect(runner.calls.single.note, 'no internet\n${l.reportSymptomSlow}');
    expect(runner.calls.single.captureLines, isNull);
    runner.onProgress!(const ReportProgress(ReportPhase.sweep, total: 10));
    runner.onProgress!(
      const ReportProgress(ReportPhase.sweep, done: 3, total: 10),
    );
    await tester.pump();
    expect(find.text(l.reportCount(3, 10)), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('report-skip')));
    await tester.pump();
    expect(runner.control!.sweepStopped, isTrue);
    expect(runner.control!.cancelled, isFalse);
    expect(find.byKey(const ValueKey('report-skip')), findsNothing);
    expect(find.text(l.reportPhaseSkipped), findsOneWidget);
    runner.onProgress!(const ReportProgress(ReportPhase.services));
    await tester.pump();
    expect(find.text(l.reportPhaseSkipped), findsOneWidget);

    await finish(tester, runner);
    expect(find.text(l.reportReady), findsOneWidget);
    expect(find.text('RC-AB12-CD34'), findsOneWidget);
    expect(find.text('Verdict: fail at server'), findsOneWidget);
  });

  testWidgets('a second tap on a phrase takes it out of the note', (
    tester,
  ) async {
    await pump(tester);
    final l = currentAppLocalizations;
    final note = find.byType(TextField);
    await tester.tap(find.text(l.reportSymptomDrops));
    await tester.pump();
    expect(
      tester.widget<TextField>(note).controller!.text,
      l.reportSymptomDrops,
    );

    await tester.tap(find.text(l.reportSymptomDrops).last);
    await tester.pump();
    expect(tester.widget<TextField>(note).controller!.text, isEmpty);
  });

  testWidgets('options pick the audience and leave sections out', (
    tester,
  ) async {
    final runner = await pump(tester);
    final l = currentAppLocalizations;
    expect(find.textContaining(l.reportPrivacyNote), findsOneWidget);

    await tester.tap(find.byTooltip(l.options));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey(('report-audience', ReportRedaction.public))),
    );
    await tester.ensureVisible(find.text(l.reportSectionConfig));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.reportSectionConfig));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).last).pop();
    await tester.pumpAndSettle();

    expect(find.textContaining(l.reportPrivacyNotePublic), findsOneWidget);
    await create(tester);
    expect(runner.calls.single.redaction, ReportRedaction.public);
    expect(runner.calls.single.sections, isNot(contains(ReportSection.config)));
  });

  testWidgets('cancel stops the build and returns to the start', (
    tester,
  ) async {
    final runner = await pump(tester);
    await create(tester);
    await tester.tap(find.byKey(const ValueKey('report-cancel')));
    await tester.pump();

    expect(runner.control!.cancelled, isTrue);
    runner.completer.completeError(const ReportCancelled());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('report-create')), findsOneWidget);
  });

  testWidgets('a failure retries the build and can start over', (tester) async {
    final runner = await pump(tester);
    final l = currentAppLocalizations;
    await create(tester);
    runner.completer.completeError(StateError('core gone'));
    await tester.pumpAndSettle();
    expect(find.text(l.reportFailed), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('report-retry')));
    await tester.pump();
    expect(runner.calls, hasLength(2));
    runner.completer.completeError(StateError('core gone'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('report-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('report-create')), findsOneWidget);
  });

  testWidgets('a leak sends the user to what is included', (tester) async {
    final runner = await pump(tester);
    final l = currentAppLocalizations;
    await create(tester);
    runner.completer.completeError(const ReportLeak('logs'));
    await tester.pumpAndSettle();
    expect(find.text(l.reportLeak), findsOneWidget);
    expect(find.byKey(const ValueKey('report-retry')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('report-change')));
    await tester.pumpAndSettle();
    expect(find.text(l.reportContents), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator).last).pop();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('report-create')), findsOneWidget);
  });

  testWidgets('records the problem before building', (tester) async {
    final capture = _Capture();
    final runner = await pump(tester, capture: capture);
    final l = currentAppLocalizations;
    await tester.tap(find.byTooltip(l.options));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-reproduce')));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).last).pop();
    await tester.pumpAndSettle();
    expect(find.text(l.reportRecordStart), findsOneWidget);
    await create(tester);

    final seconds = find.byKey(const ValueKey('report-seconds'));
    expect(find.text(l.reportRecording), findsOneWidget);
    expect(tester.widget<Text>(seconds).data, '30');
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<Text>(seconds).data, '29');
    expect(runner.calls, isEmpty);

    await tester.tap(find.byKey(const ValueKey('report-finish')));
    await tester.pump();
    expect(capture.stopped, isTrue);
    expect(runner.calls.single.captureLines, ['12:00 DEBUG dial']);
    expect(find.text(l.reportPhaseRecorded), findsOneWidget);
    await finish(tester, runner);
  });

  testWidgets('uploads to the named provider after confirming the domain', (
    tester,
  ) async {
    final uploader = _Uploader([
      const ReportUploadFailure(ReportUploadError.offline),
      const ReportReceipt(ticket: 'T-7', message: 'We will reply soon'),
    ]);
    final runner = await pump(
      tester,
      support: ReportSupport(
        upload: Uri.parse('https://help.example.com/r'),
        provider: 'Help VPN',
      ),
      uploader: uploader,
    );
    final l = currentAppLocalizations;
    await create(tester);
    await finish(tester, runner);

    expect(find.text(l.reportSendToProvider('Help VPN')), findsOneWidget);
    expect(find.text(l.reportNextUpload), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('report-send')));
    await tester.pumpAndSettle();
    expect(find.text(l.reportSendTo('help.example.com')), findsOneWidget);
    await tester.tap(find.text(l.reportSendConfirm));
    await tester.pumpAndSettle();

    expect(find.text(l.reportSendOffline), findsOneWidget);
    await tester.tap(find.text(l.retry));
    await tester.pumpAndSettle();

    expect(uploader.targets, hasLength(2));
    expect(find.text(l.reportSentTo('Help VPN')), findsOneWidget);
    expect(find.text(l.reportTicket('T-7')), findsOneWidget);
    expect(find.text('We will reply soon'), findsOneWidget);
    expect(find.byKey(const ValueKey('report-send')), findsNothing);
    expect(find.byKey(const ValueKey('report-done')), findsOneWidget);
  });

  testWidgets('a chat link on desktop saves, copies and hints', (tester) async {
    final delivery = _Delivery(canShare: false);
    final runner = await pump(
      tester,
      support: ReportSupport(chat: Uri.parse('https://t.me/help')),
      delivery: delivery,
    );
    final l = currentAppLocalizations;
    await create(tester);
    await finish(tester, runner);

    expect(find.text(l.reportOpenChat), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('report-send')));
    await tester.pumpAndSettle();
    expect(delivery.calls, ['downloads', 'copy']);
    expect(find.text(l.reportDropHint), findsOneWidget);
  });

  testWidgets('without support the button saves on desktop', (tester) async {
    final delivery = _Delivery(canShare: false);
    final runner = await pump(tester, delivery: delivery);
    final l = currentAppLocalizations;
    await create(tester);
    await finish(tester, runner);

    final send = find.byKey(const ValueKey('report-send'));
    expect(
      find.descendant(of: send, matching: find.text(l.save)),
      findsOneWidget,
    );
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(delivery.calls, ['save']);
  });

  testWidgets('lists the archive files once expanded', (tester) async {
    final runner = await pump(tester);
    await create(tester);
    await finish(tester, runner);

    expect(find.text('README.md'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('report-files')));
    await tester.pumpAndSettle();
    expect(find.text('README.md'), findsOneWidget);
    expect(find.text('01-summary.md'), findsOneWidget);
  });

  group('send target', () {
    final upload = Uri.parse('https://help.example.com/r');
    final chat = Uri.parse('https://t.me/help');

    test('prefers the upload, then the chat, then the platform', () {
      expect(
        reportSendOf(
          ReportSupport(upload: upload, chat: chat),
          canShare: false,
        ),
        ReportSend.upload,
      );
      expect(
        reportSendOf(ReportSupport(chat: chat), canShare: true),
        ReportSend.shareToChat,
      );
      expect(
        reportSendOf(ReportSupport(chat: chat), canShare: false),
        ReportSend.downloadsToChat,
      );
      expect(
        reportSendOf(const ReportSupport(), canShare: true),
        ReportSend.share,
      );
      expect(
        reportSendOf(const ReportSupport(), canShare: false),
        ReportSend.save,
      );
    });

    test('names the provider on the upload button when it is known', () {
      final l = currentAppLocalizations;
      expect(
        reportSendLabel(l, ReportSend.upload, provider: 'Help VPN'),
        l.reportSendToProvider('Help VPN'),
      );
      expect(reportSendLabel(l, ReportSend.upload), l.reportSend);
      expect(reportSendLabel(l, ReportSend.save), l.save);
    });
  });

  group('progress', () {
    ReportProgress sweep(int done, int total) =>
        ReportProgress(ReportPhase.sweep, done: done, total: total);

    test('the sweep gets an estimate only once it has a pace', () {
      const elapsed = Duration(seconds: 10);
      expect(reportSweepEta(sweep(0, 12), elapsed), isNull);
      expect(reportSweepEta(sweep(12, 12), elapsed), isNull);
      expect(reportSweepEta(sweep(4, 12), const Duration(seconds: 1)), isNull);
      expect(
        reportSweepEta(const ReportProgress(ReportPhase.services), elapsed),
        isNull,
      );
    });

    test('the estimate follows the pace up to the timeout bound', () {
      const elapsed = Duration(seconds: 10);
      expect(reportSweepEta(sweep(50, 100), elapsed), elapsed);
      expect(
        reportSweepEta(sweep(10, 100), elapsed),
        sweepNodeTimeout * (90 / sweepConcurrency).ceil(),
      );
    });

    test('the overall share only grows through the phases', () {
      final shares = [
        for (final phase in ReportPhase.values)
          if (phase == ReportPhase.sweep) ...[
            reportOverallProgress(sweep(0, 10)),
            reportOverallProgress(sweep(10, 10)),
          ] else
            reportOverallProgress(ReportProgress(phase)),
      ];
      expect(shares, orderedEquals([...shares]..sort()));
      expect(shares.toSet(), hasLength(shares.length));
      expect(shares.last, lessThan(1));
    });
  });

  group('uploader', () {
    late Directory dir;
    late ReportResult report;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('report_upload');
      final file = File('${dir.path}/reclash-report-RC-AB12-CD34.zip')
        ..writeAsBytesSync([80, 75, 5, 6]);
      report = ReportResult(
        id: _result.id,
        path: file.path,
        summary: _result.summary,
        sizes: _result.sizes,
        createdAt: _result.createdAt,
        redaction: _result.redaction,
      );
    });

    tearDown(() => dir.delete(recursive: true));

    ReportUploader uploader(_Adapter adapter) =>
        ReportUploader(Dio()..httpClientAdapter = adapter);

    test('posts the id, summary and archive and reads the answer', () async {
      final adapter = _Adapter(
        (_) => ResponseBody.fromString(
          '{"ticket": 42, "message": "${'x' * 300}"}',
          201,
        ),
      );
      final receipt = await uploader(
        adapter,
      ).upload(Uri.parse('https://help.example.com/r'), report);

      expect(adapter.request!.method, 'POST');
      expect(adapter.body, contains('name="id"'));
      expect(adapter.body, contains('RC-AB12-CD34'));
      expect(adapter.body, contains('name="summary"'));
      expect(
        adapter.body,
        contains('name="report"; filename="reclash-report-RC-AB12-CD34.zip"'),
      );
      expect(adapter.body, contains('application/zip'));
      expect(receipt.ticket, '42');
      expect(receipt.message, hasLength(200));
    });

    test('a plain body is a success without a ticket', () async {
      final receipt = await uploader(
        _Adapter((_) => ResponseBody.fromString('ok', 200)),
      ).upload(Uri.parse('https://help.example.com/r'), report);
      expect(receipt.ticket, isNull);
      expect(receipt.message, isNull);
    });

    test('a refusal carries its status', () async {
      await expectLater(
        uploader(
          _Adapter((_) => ResponseBody.fromString('too big', 413)),
        ).upload(Uri.parse('https://help.example.com/r'), report),
        throwsA(
          isA<ReportUploadFailure>()
              .having((e) => e.error, 'error', ReportUploadError.rejected)
              .having((e) => e.status, 'status', 413),
        ),
      );
    });

    test('a connection error reads as offline', () async {
      await expectLater(
        uploader(
          _Adapter(
            (options) => throw DioException.connectionError(
              requestOptions: options,
              reason: 'refused',
            ),
          ),
        ).upload(Uri.parse('https://help.example.com/r'), report),
        throwsA(
          isA<ReportUploadFailure>().having(
            (e) => e.error,
            'error',
            ReportUploadError.offline,
          ),
        ),
      );
    });

    test('refuses a plain http target', () async {
      await expectLater(
        uploader(
          _Adapter((_) => ResponseBody.fromString('', 200)),
        ).upload(Uri.parse('http://help.example.com/r'), report),
        throwsArgumentError,
      );
    });
  });
}

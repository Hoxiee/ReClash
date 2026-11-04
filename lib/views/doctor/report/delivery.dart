import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/report/builder.dart';
import 'package:reclash/features/doctor/report/collector.dart';
import 'package:reclash/features/doctor/report/report.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:url_launcher/url_launcher.dart';

const _zip = 'application/zip';
const _messageLimit = 200;
const _ticketLimit = 64;

typedef ReportRunner =
    Future<ReportResult> Function(
      ReportOptions options, {
      ReportProgressCallback? onProgress,
      ReportControl? control,
    });

final reportRunnerProvider = Provider<ReportRunner>(
  (ref) => ref.read(reportBuilderProvider).build,
);

/// Where "Send to support" goes: [upload] takes the archive itself, [chat]
/// is the subscription's support link the user drops it into.
@immutable
final class ReportSupport {
  const ReportSupport({this.upload, this.chat, this.provider});

  final Uri? upload;
  final Uri? chat;
  final String? provider;

  bool get available => upload != null || chat != null;
}

ReportSupport reportSupportOf(Profile? profile) {
  final metadata = profile?.subscriptionSnapshot?.metadata;
  if (metadata == null) return const ReportSupport();
  final upload = switch (metadata.supportUploadUrl) {
    final value? => Uri.tryParse(value),
    null => null,
  };
  return ReportSupport(
    provider: switch (metadata.name?.trim()) {
      final name? when name.isNotEmpty => name,
      _ => null,
    },
    upload: upload?.scheme == 'https' ? upload : null,
    chat: switch (metadata.text('provider.supportUrl')) {
      final value? => safeSubscriptionSupportLink(value),
      null => null,
    },
  );
}

final reportSupportProvider = Provider<ReportSupport>(
  (ref) => reportSupportOf(ref.watch(currentProfileProvider)),
);

@immutable
final class ReportReceipt {
  const ReportReceipt({this.ticket, this.message});

  /// Reads the optional `{ticket?, message?}` answer; anything else is a
  /// plain success.
  factory ReportReceipt.parse(Object? body) {
    final Object? json;
    try {
      json = body is String && body.trimLeft().startsWith('{')
          ? jsonDecode(body)
          : body;
    } on FormatException {
      return const ReportReceipt();
    }
    if (json is! Map) return const ReportReceipt();
    String? text(Object? value, int limit) => switch (value) {
      final String text when text.trim().isNotEmpty => _clip(
        text.trim(),
        limit,
      ),
      final num number => '$number',
      _ => null,
    };
    return ReportReceipt(
      ticket: text(json['ticket'], _ticketLimit),
      message: text(json['message'], _messageLimit),
    );
  }

  final String? ticket;
  final String? message;
}

String _clip(String text, int limit) =>
    text.length <= limit ? text : '${text.substring(0, limit - 1)}…';

enum ReportUploadError { offline, rejected }

final class ReportUploadFailure implements Exception {
  const ReportUploadFailure(this.error, {this.status});

  final ReportUploadError error;
  final int? status;

  @override
  String toString() => 'ReportUploadFailure(${error.name}, $status)';
}

class ReportUploader {
  ReportUploader([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(minutes: 2),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  final Dio _dio;

  Future<ReportReceipt> upload(Uri target, ReportResult report) async {
    if (target.scheme != 'https') {
      throw ArgumentError.value(target, 'target', 'not https');
    }
    final form = FormData.fromMap({
      'id': report.id,
      'summary': report.summary,
      'report': await MultipartFile.fromFile(
        report.path,
        filename: p.basename(report.path),
        contentType: DioMediaType.parse(_zip),
      ),
    });
    try {
      final response = await _dio.postUri<String>(
        target,
        data: form,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );
      return ReportReceipt.parse(response.data);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw status == null
          ? const ReportUploadFailure(ReportUploadError.offline)
          : ReportUploadFailure(ReportUploadError.rejected, status: status);
    }
  }
}

final reportUploaderProvider = Provider<ReportUploader>(
  (ref) => ReportUploader(),
);

class ReportDelivery {
  const ReportDelivery({required this.canShare});

  final bool canShare;

  Future<File> _copy(ReportResult report, String directory) async {
    await Directory(directory).create(recursive: true);
    return File(report.path).copy(p.join(directory, p.basename(report.path)));
  }

  Future<bool> share(ReportResult report) async {
    final android = app;
    if (android == null) return false;
    final file = await _copy(report, p.join(await appPath.tempPath, 'reports'));
    return android.shareFile(file.path, mimeType: _zip, text: report.summary);
  }

  /// [picker] removes the file it saves, so it gets a copy.
  Future<bool> save(ReportResult report) async {
    final file = await _copy(
      report,
      p.join(await appPath.tempPath, 'report-save'),
    );
    return await picker.saveFileWithPath(p.basename(report.path), file.path) !=
        null;
  }

  /// False when there is no Downloads folder.
  Future<bool> saveToDownloads(ReportResult report) async {
    final downloads = await getDownloadsDirectory();
    if (downloads == null) return false;
    await _copy(report, downloads.path);
    await launchUrl(Uri.directory(downloads.path));
    return true;
  }

  Future<void> copySummary(ReportResult report) =>
      Clipboard.setData(ClipboardData(text: report.summary));
}

final reportDeliveryProvider = Provider<ReportDelivery>(
  (ref) => ReportDelivery(canShare: system.isAndroid),
);

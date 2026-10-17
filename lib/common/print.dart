import 'package:dio/dio.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';

String compactError(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    return statusCode != null
        ? 'DioException(${error.type.name}, HTTP $statusCode)'
        : 'DioException(${error.type.name})';
  }
  return error.toString();
}

class CommonPrint {
  static CommonPrint? _instance;

  CommonPrint._internal();

  factory CommonPrint() {
    _instance ??= CommonPrint._internal();
    return _instance!;
  }

  void log(String? text, {LogLevel logLevel = LogLevel.info}) {
    final payload = '[APP] $text';
    debugPrint(payload);
    if (!globalState.isAttach) {
      return;
    }
    globalState.container
        .read(logsProvider.notifier)
        .add(Log.app(payload).copyWith(logLevel: logLevel));
  }
}

final commonPrint = CommonPrint();

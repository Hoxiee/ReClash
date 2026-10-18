import 'dart:io';

import 'package:reclash/common/common.dart';

import '../imports/import.dart';
import '../transport/transport.dart';

Future<void> validateSubscriptionImport(
  SubscriptionImportResult payload, {
  required Future<String> Function(String path, String key) validate,
  bool Function()? isCancelled,
}) async {
  void checkCurrent() {
    if (isCancelled?.call() ?? false) {
      throw const SubscriptionException(SubscriptionFailure.cancelled);
    }
  }

  checkCurrent();
  final path = await appPath.tempFilePath;
  final temporary = File(
    '$path.subscription.${DateTime.now().microsecondsSinceEpoch}',
  );
  try {
    checkCurrent();
    await temporary.safeWriteAsBytes(payload.bytes);
    checkCurrent();
    final message = await validate(temporary.path, '');
    checkCurrent();
    if (message.isNotEmpty) {
      throw const SubscriptionImportException(
        'Core rejected subscription import',
      );
    }
  } finally {
    await temporary.safeDelete();
  }
}

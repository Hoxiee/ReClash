import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/util/exception.dart';

void main() {
  test('MessageException renders as the bare message', () {
    expect(
      const MessageException('profile is invalid').toString(),
      'profile is invalid',
    );
  });

  test('MessageException is catchable as an Exception', () {
    Object? caught;
    try {
      throw const MessageException('core rejected the config');
    } on Exception catch (error) {
      caught = error;
    }

    expect(caught, isA<MessageException>());
  });

  test('MessageException carries a stack trace to its catcher', () {
    StackTrace? stackTrace;
    try {
      throw const MessageException('boom');
    } catch (_, trace) {
      stackTrace = trace;
    }

    expect(stackTrace, isNotNull);
    expect(stackTrace.toString(), isNotEmpty);
  });

  test('coreSetupException classifies the config-apply token', () {
    final error = coreSetupException(
      'config-apply-failed: proxy group[0]: Proxy: `use` or `proxies` missing',
    );

    expect(error, isA<ConfigInvalidException>());
    expect(
      (error as ConfigInvalidException).detail,
      'proxy group[0]: Proxy: `use` or `proxies` missing',
    );
  });

  test('coreSetupException leaves other messages as MessageException', () {
    final error = coreSetupException('transport disconnected');

    expect(error, isA<MessageException>());
    expect(error.toString(), 'transport disconnected');
  });
}

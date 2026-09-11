import 'package:dio/dio.dart';
import 'package:reclash/common/app_localizations.dart';
import 'package:reclash/common/exception.dart';
import 'package:reclash/common/incy_links.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/launch_policy.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations appLocalizations;

  setUpAll(() async {
    appLocalizations = await AppLocalizations.load(const Locale('en'));
  });

  test('maps badResponse DioException to the network exception message', () {
    final message = networkErrorMessage(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
      ),
      appLocalizations,
    );
    expect(message, appLocalizations.networkException);
  });

  test(
    'maps other DioException types to the unknown network error message',
    () {
      final message = networkErrorMessage(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
        appLocalizations,
      );
      expect(message, appLocalizations.unknownNetworkError);
    },
  );

  test('returns null for non-Dio exceptions', () {
    expect(networkErrorMessage(StateError('boom'), appLocalizations), isNull);
  });

  test('maps Core request failures using the same network categories', () {
    expect(
      networkErrorMessage(
        const CoreMethodException(
          code: 'request_bad_response',
          message: '503 Service Unavailable',
        ),
        appLocalizations,
      ),
      appLocalizations.networkException,
    );
    expect(
      networkErrorMessage(
        const CoreMethodException(
          code: 'request_error',
          message: 'request timed out',
        ),
        appLocalizations,
      ),
      appLocalizations.unknownNetworkError,
    );
  });

  test('uses the Core message for non-request failures', () {
    expect(
      userFacingErrorMessage(
        const CoreMethodException(
          code: 'provider_update_error',
          message: 'proxy 0: unsupported type',
        ),
        appLocalizations,
      ),
      'proxy 0: unsupported type',
    );
  });

  group('profile import failures', () {
    test('maps every failure to a localized safe message', () {
      expect(
        profileImportFailureMessage(
          ProfileImportFailure.invalidUrl,
          appLocalizations,
        ),
        appLocalizations.profileUrlInvalidValidationDesc,
      );
      expect(
        profileImportFailureMessage(
          ProfileImportFailure.invalidQrCode,
          appLocalizations,
        ),
        appLocalizations.pleaseUploadValidQrcode,
      );
      expect(
        profileImportFailureMessage(
          ProfileImportFailure.invalidConfig,
          appLocalizations,
        ),
        appLocalizations.profileImportInvalidConfig,
      );
      expect(
        profileImportFailureMessage(
          ProfileImportFailure.fetchRejected,
          appLocalizations,
        ),
        appLocalizations.networkException,
      );
      expect(
        profileImportFailureMessage(
          ProfileImportFailure.fetchFailed,
          appLocalizations,
        ),
        appLocalizations.unknownNetworkError,
      );
      expect(
        profileImportFailureMessage(
          ProfileImportFailure.emptyResponse,
          appLocalizations,
        ),
        appLocalizations.profileImportEmptyResponse,
      );
      expect(
        profileImportFailureMessage(
          ProfileImportFailure.fileReadFailed,
          appLocalizations,
        ),
        appLocalizations.profileImportFileReadFailed,
      );
      expect(
        profileImportFailureMessage(
          ProfileImportFailure.unexpected,
          appLocalizations,
        ),
        appLocalizations.profileImportFailed,
      );
    });

    test('does not expose details from unsupported import links', () {
      const error = IncyLinkException('sensitive parser diagnostic');
      expect(
        incyLinkErrorMessage(error, appLocalizations),
        appLocalizations.profileImportUnsupportedLink,
      );
    });
  });

  group('policy-blocked Core launch', () {
    const blocked = DesktopCoreFailure(
      code: 'start_failed',
      phase: DesktopCorePhase.starting,
      revision: 1,
      cause: HelperException(
        code: 'processLaunchFailed',
        message: 'spawn failed',
        details: {'osError': 577},
      ),
    );

    tearDown(() {
      smartAppControlStateReader = readSmartAppControlState;
    });

    test('names Smart App Control when it is on', () {
      smartAppControlStateReader = () => SmartAppControlState.on;

      expect(
        userFacingErrorMessage(blocked, appLocalizations),
        appLocalizations.coreBlockedBySmartAppControlTip,
      );
    });

    test('names the generic policy with its error code otherwise', () {
      smartAppControlStateReader = () => SmartAppControlState.off;

      expect(
        userFacingErrorMessage(blocked, appLocalizations),
        appLocalizations.coreBlockedByPolicyTip(577),
      );
    });

    test('leaves other start failures on the raw description', () {
      smartAppControlStateReader = () => SmartAppControlState.on;
      const timedOut = DesktopCoreFailure(
        code: 'start_failed',
        phase: DesktopCorePhase.starting,
        revision: 1,
        cause: HelperException(
          code: 'transportError',
          message: 'Helper start request failed',
        ),
      );

      expect(
        userFacingErrorMessage(timedOut, appLocalizations),
        timedOut.toString(),
      );
    });
  });
}

final class MessageException implements Exception {
  final String message;

  const MessageException(this.message);

  @override
  String toString() => message;
}

enum ProfileImportFailure {
  invalidUrl,
  invalidQrCode,
  invalidConfig,
  fetchRejected,
  fetchFailed,
  emptyResponse,
  fileReadFailed,
  unexpected,
}

final class ProfileImportUrlException implements Exception {
  const ProfileImportUrlException();

  @override
  String toString() => 'Invalid profile import URL';
}

final class ProfileValidationException implements Exception {
  const ProfileValidationException({required this.diagnostic});

  final String diagnostic;

  @override
  String toString() => 'Profile validation failed: $diagnostic';
}

enum ProfileFetchFailure { failed, emptyResponse }

final class ProfileFetchException implements Exception {
  const ProfileFetchException.failed() : failure = ProfileFetchFailure.failed;

  const ProfileFetchException.emptyResponse()
    : failure = ProfileFetchFailure.emptyResponse;

  final ProfileFetchFailure failure;

  @override
  String toString() => 'Profile fetch failed: ${failure.name}';
}

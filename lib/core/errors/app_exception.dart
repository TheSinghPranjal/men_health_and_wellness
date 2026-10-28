/// Failures surfaced to the presentation layer.
///
/// Messages are user-safe: they never contain stored values, answers or
/// raw platform exception text.
sealed class AppException implements Exception {
  const AppException(this.userMessage);
  final String userMessage;

  @override
  String toString() => '$runtimeType: $userMessage';
}

class StorageException extends AppException {
  const StorageException([super.userMessage = 'Your data could not be saved on this device. Please try again.']);
}

class ValidationException extends AppException {
  const ValidationException(super.userMessage);
}

class NotFoundException extends AppException {
  const NotFoundException([super.userMessage = 'This item is no longer available.']);
}

class PlatformFeatureException extends AppException {
  const PlatformFeatureException(super.userMessage);
}

/// Maps any thrown object to a message that is safe to show.
String userMessageFor(Object error) =>
    error is AppException ? error.userMessage : 'Something unexpected happened. Please try again.';

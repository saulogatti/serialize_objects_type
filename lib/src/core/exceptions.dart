/// Base class for every error raised by this package.
///
/// Lower layers (codec, storage) throw the specialized subtypes so the calling
/// layer can decide how to react (log, retry, surface to the user) instead of
/// catching opaque [Exception]s.
sealed class SerializeException implements Exception {
  const SerializeException(this.message, {this.cause});

  /// Human-readable description of what went wrong.
  final String message;

  /// The original error that triggered this exception, when available.
  final Object? cause;

  @override
  String toString() {
    final causeText = cause == null ? '' : ' (cause: $cause)';
    return '$runtimeType: $message$causeText';
  }
}

/// Thrown when a [typeId] is empty or otherwise invalid.
final class InvalidTypeException extends SerializeException {
  const InvalidTypeException(super.message, {super.cause});
}

/// Thrown when no deserializer is registered for a given [typeId].
final class UnknownTypeException extends SerializeException {
  const UnknownTypeException(this.typeId, {Object? cause})
      : super('No deserializer registered for type: $typeId', cause: cause);

  /// The type identifier that could not be resolved.
  final String typeId;
}

/// Thrown when a deserializer is registered twice for the same [typeId].
final class DuplicateTypeException extends SerializeException {
  const DuplicateTypeException(this.typeId, {Object? cause})
      : super('Deserializer already registered for type: $typeId',
            cause: cause);

  /// The type identifier that was registered more than once.
  final String typeId;
}

/// Thrown when stored data cannot be decoded back into an object
/// (malformed payload, missing type discriminator, etc.).
final class CorruptedDataException extends SerializeException {
  const CorruptedDataException(super.message, {super.cause});
}

/// Thrown when an underlying storage operation (read/write/delete) fails.
final class StorageException extends SerializeException {
  const StorageException(super.message, {super.cause});
}

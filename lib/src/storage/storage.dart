/// Identifies a single serialized object within a [Storage] backend.
///
/// A key is composed of the object's [typeId] (which groups objects of the
/// same kind), a unique [id] for the individual object, and the [extension]
/// of the payload (for example `json`). Backends are free to map these parts
/// onto whatever physical location they use (a file path, a map entry, etc.).
class StorageKey {
  /// Creates a key for an object of type [typeId] identified by [id] and
  /// stored using the given file [extension].
  const StorageKey({
    required this.typeId,
    required this.id,
    required this.extension,
  });

  /// Logical type of the stored object; groups objects of the same kind.
  final String typeId;

  /// Unique identifier of the individual object within its [typeId].
  final String id;

  /// Extension of the stored payload, without a leading dot (e.g. `json`).
  final String extension;

  @override
  bool operator ==(Object other) =>
      other is StorageKey &&
      other.typeId == typeId &&
      other.id == id &&
      other.extension == extension;

  @override
  int get hashCode => Object.hash(typeId, id, extension);

  @override
  String toString() => 'StorageKey($typeId/$id.$extension)';
}

/// Abstraction over a persistence backend for serialized payloads.
///
/// Implementations translate a [StorageKey] into a concrete location and
/// expose simple string-based read/write/delete operations. All operations
/// are asynchronous so the same interface can back files, databases or
/// network stores.
abstract interface class Storage {
  /// Writes [contents] for the object identified by [key], creating or
  /// overwriting any previously stored payload.
  Future<void> write(StorageKey key, String contents);

  /// Reads the payload stored for [key], or returns `null` when nothing is
  /// stored under that key.
  Future<String?> read(StorageKey key);

  /// Returns whether a payload is currently stored for [key].
  Future<bool> exists(StorageKey key);

  /// Deletes the payload stored for [key].
  ///
  /// Returns `true` when an existing payload was removed, or `false` when
  /// there was nothing to delete.
  Future<bool> delete(StorageKey key);
}

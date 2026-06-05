import 'dart:io';

import 'package:serialize_objects_type/src/core/exceptions.dart';
import 'package:serialize_objects_type/src/storage/storage.dart';

/// A [Storage] implementation backed by the local file system.
///
/// Each [StorageKey] is mapped to a file at
/// `<basePath>/<typeId>/<id>.<extension>`. Parent directories are created
/// lazily on the first write, never in the constructor. Every underlying
/// `dart:io` failure is rethrown as a [StorageException] with the original
/// error preserved as its `cause`.
class FileStorage implements Storage {
  /// Creates a file-backed storage rooted at [basePath].
  ///
  /// The directory is not created until the first [write]; the constructor
  /// performs no I/O.
  FileStorage(this.basePath);

  /// Root directory under which all payloads are stored.
  final String basePath;

  /// Builds the directory that holds every object of the given [typeId].
  String _directoryPathFor(StorageKey key) => '$basePath/${key.typeId}';

  /// Builds the file path for [key] using forward slashes.
  String _filePathFor(StorageKey key) =>
      '${_directoryPathFor(key)}/${key.id}.${key.extension}';

  @override
  Future<void> write(StorageKey key, String contents) async {
    try {
      await Directory(_directoryPathFor(key)).create(recursive: true);
      await File(_filePathFor(key)).writeAsString(contents);
    } on Object catch (error) {
      throw StorageException(
        'Failed to write storage entry for $key',
        cause: error,
      );
    }
  }

  @override
  Future<String?> read(StorageKey key) async {
    try {
      final file = File(_filePathFor(key));
      if (!await file.exists()) {
        return null;
      }
      return await file.readAsString();
    } on Object catch (error) {
      throw StorageException(
        'Failed to read storage entry for $key',
        cause: error,
      );
    }
  }

  @override
  Future<bool> exists(StorageKey key) async {
    try {
      return await File(_filePathFor(key)).exists();
    } on Object catch (error) {
      throw StorageException(
        'Failed to check existence of storage entry for $key',
        cause: error,
      );
    }
  }

  @override
  Future<bool> delete(StorageKey key) async {
    try {
      final file = File(_filePathFor(key));
      if (!await file.exists()) {
        return false;
      }
      await file.delete();
      return true;
    } on Object catch (error) {
      throw StorageException(
        'Failed to delete storage entry for $key',
        cause: error,
      );
    }
  }
}

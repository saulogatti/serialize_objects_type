import 'package:serialize_objects_type/src/storage/storage.dart';

/// An in-memory [Storage] implementation backed by a [Map].
///
/// Payloads are kept in process memory keyed by a string derived from the
/// [StorageKey], so nothing is persisted across runs. It performs no file
/// I/O and is primarily useful for tests and ephemeral scenarios.
class InMemoryStorage implements Storage {
  /// Creates an empty in-memory storage.
  InMemoryStorage();

  /// Stored payloads keyed by [_keyOf].
  final Map<String, String> _entries = <String, String>{};

  /// Derives the map key for [key] as `<typeId>/<id>.<extension>`.
  String _keyOf(StorageKey key) => '${key.typeId}/${key.id}.${key.extension}';

  @override
  Future<void> write(StorageKey key, String contents) async {
    _entries[_keyOf(key)] = contents;
  }

  @override
  Future<String?> read(StorageKey key) async => _entries[_keyOf(key)];

  @override
  Future<bool> exists(StorageKey key) async =>
      _entries.containsKey(_keyOf(key));

  @override
  Future<bool> delete(StorageKey key) async =>
      _entries.remove(_keyOf(key)) != null;
}

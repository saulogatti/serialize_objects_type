import 'package:serialize_objects_type/src/codec/data_codec.dart';
import 'package:serialize_objects_type/src/codec/json_data_codec.dart';
import 'package:serialize_objects_type/src/core/exceptions.dart';
import 'package:serialize_objects_type/src/core/serializable.dart';
import 'package:serialize_objects_type/src/core/serializer_registry.dart';
import 'package:serialize_objects_type/src/storage/storage.dart';

/// Orchestrates serialization by wiring together a [SerializerRegistry]
/// (type id -> deserializer), a [DataCodec] (object <-> text) and a [Storage]
/// backend (text <-> persistent location).
///
/// Dependencies are injected so the service can be configured and tested in
/// isolation. By default it uses a [JsonDataCodec] and a fresh
/// [SerializerRegistry]; a [Storage] backend is always required.
class SerializeService {
  final Storage _storage;

  final DataCodec _codec;
  final SerializerRegistry _registry;

  /// Creates a service backed by [storage].
  ///
  /// A [JsonDataCodec] is used when [codec] is omitted, and a new empty
  /// [SerializerRegistry] when [registry] is omitted.
  SerializeService({
    required Storage storage,
    DataCodec? codec,
    SerializerRegistry? registry,
  }) : _storage = storage, // ignore: prefer_initializing_formals
       _codec = codec ?? const JsonDataCodec(),
       _registry = registry ?? SerializerRegistry();

  /// Deletes the object of type [typeId] stored under [id].
  ///
  /// Returns `true` when an object was removed, or `false` when there was
  /// nothing to delete. Throws [StorageException] if the deletion fails.
  Future<bool> delete(String typeId, String id) async {
    _requireNotEmpty(typeId, 'type id');
    _requireNotEmpty(id, 'id');
    return _storage.delete(_keyFor(typeId, id));
  }

  /// Loads and reconstructs the object of type [typeId] stored under [id].
  ///
  /// Returns `null` when no object is stored for that key.
  ///
  /// Throws [UnknownTypeException] if [typeId] has no registered deserializer,
  /// [CorruptedDataException] if the stored payload cannot be decoded, and
  /// [StorageException] if reading fails.
  Future<Serializable?> load(String typeId, String id) async {
    final deserializer = _registry.resolve(typeId);
    _requireNotEmpty(id, 'id');
    final contents = await _storage.read(_keyFor(typeId, id));
    if (contents == null) {
      return null;
    }
    final json = _codec.decode(contents);
    return deserializer(json);
  }

  /// Registers [deserializer] for [typeId] so objects of that type can be
  /// loaded back later.
  ///
  /// Throws [InvalidTypeException] if [typeId] is empty and
  /// [DuplicateTypeException] if already registered.
  void register(String typeId, Deserializer deserializer) {
    _registry.register(typeId, deserializer);
  }

  /// Serializes [object] and stores it under [id].
  ///
  /// Multiple objects of the same type can coexist as long as they use
  /// distinct [id]s.
  ///
  /// Throws [InvalidTypeException] if the object's [Serializable.typeId] or
  /// [id] is empty, and [StorageException] if writing fails.
  Future<void> save(String id, Serializable object) async {
    _requireNotEmpty(object.typeId, 'type id');
    _requireNotEmpty(id, 'id');
    final contents = _codec.encode(object);
    await _storage.write(_keyFor(object.typeId, id), contents);
  }

  StorageKey _keyFor(String typeId, String id) =>
      StorageKey(typeId: typeId, id: id, extension: _codec.fileExtension);

  void _requireNotEmpty(String value, String field) {
    if (value.isEmpty) {
      throw InvalidTypeException('$field cannot be empty');
    }
  }
}

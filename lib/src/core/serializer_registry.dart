import 'exceptions.dart';
import 'serializable.dart';

/// Factory that rebuilds a [Serializable] from its decoded JSON map.
typedef Deserializer = Serializable Function(Map<String, dynamic> json);

/// Maps a [Serializable.typeId] to the factory able to reconstruct it.
///
/// Types must be registered before they can be loaded, so the package never
/// needs compile-time knowledge of the concrete classes. The future codegen
/// will emit the [register] calls automatically.
class SerializerRegistry {
  final Map<String, Deserializer> _deserializers = {};

  /// Registers [deserializer] for [typeId].
  ///
  /// Throws [InvalidTypeException] if [typeId] is empty and
  /// [DuplicateTypeException] if a deserializer is already registered for it.
  void register(String typeId, Deserializer deserializer) {
    _validate(typeId);
    if (_deserializers.containsKey(typeId)) {
      throw DuplicateTypeException(typeId);
    }
    _deserializers[typeId] = deserializer;
  }

  /// Returns the deserializer registered for [typeId].
  ///
  /// Throws [InvalidTypeException] if [typeId] is empty and
  /// [UnknownTypeException] if no deserializer is registered.
  Deserializer resolve(String typeId) {
    _validate(typeId);
    final deserializer = _deserializers[typeId];
    if (deserializer == null) {
      throw UnknownTypeException(typeId);
    }
    return deserializer;
  }

  /// Whether a deserializer is registered for [typeId].
  bool contains(String typeId) => _deserializers.containsKey(typeId);

  void _validate(String typeId) {
    if (typeId.isEmpty) {
      throw const InvalidTypeException('Type id cannot be empty');
    }
  }
}

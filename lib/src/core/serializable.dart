/// Contract implemented by any object that can be serialized and later
/// reconstructed by this package.
///
/// Implementations must expose a stable [typeId] (which is persisted alongside
/// the payload and used by the [SerializerRegistry] to resolve the matching
/// deserializer) and a [toJson] method that produces the serializable map.
///
/// The [typeId] must NOT be derived from `runtimeType`, since that value is not
/// stable under AOT/obfuscated builds. Prefer a `static const String typeId`
/// per class (this is what the future codegen will generate).
abstract interface class Serializable {
  /// Stable identifier of the concrete type, persisted with the payload.
  String get typeId;

  /// Returns the JSON-compatible representation of this object.
  Map<String, dynamic> toJson();
}

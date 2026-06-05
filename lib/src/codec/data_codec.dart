import 'package:serialize_objects_type/src/core/serializable.dart';

/// Format-agnostic contract that converts a [Serializable] object to and from
/// its textual representation.
///
/// Concrete implementations (for example a JSON or YAML codec) encapsulate a
/// single wire format so the storage layer can persist payloads without knowing
/// how they are serialized.
abstract interface class DataCodec {
  /// Stable identifier of the wire format implemented by this codec, e.g.
  /// `'json'`. Useful for diagnostics and for selecting a codec at runtime.
  String get formatId;

  /// File extension associated with this format (without a leading dot), e.g.
  /// `'json'`. Used by the storage layer when naming persisted files.
  String get fileExtension;

  /// Encodes [object] into its textual representation in this format.
  ///
  /// The produced payload is expected to be self-describing, carrying the
  /// object's type discriminator so it can later be resolved during decoding.
  String encode(Serializable object);

  /// Decodes [raw] back into a JSON-compatible map.
  ///
  /// Throws a [CorruptedDataException] when [raw] cannot be parsed into a map
  /// in this format.
  Map<String, dynamic> decode(String raw);
}

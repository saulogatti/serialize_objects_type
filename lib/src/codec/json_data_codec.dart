import 'dart:convert';

import 'package:serialize_objects_type/src/codec/data_codec.dart';
import 'package:serialize_objects_type/src/core/exceptions.dart';
import 'package:serialize_objects_type/src/core/serializable.dart';

/// [DataCodec] implementation that serializes objects to and from JSON.
///
/// On [encode] the object's map is augmented with a type discriminator under
/// [typeKey] so the persisted payload is self-describing. On [decode] the raw
/// string is parsed back into a [Map] of String keys to dynamic values.
final class JsonDataCodec implements DataCodec {
  /// Creates a JSON codec.
  const JsonDataCodec();

  /// Map key under which the type discriminator is stored.
  ///
  /// Exposed so other layers can reference the same key when reading the
  /// discriminator back from a decoded payload.
  static const String typeKey = 'type';

  @override
  String get formatId => 'json';

  @override
  String get fileExtension => 'json';

  @override
  String encode(Serializable object) {
    final map = object.toJson();
    // Ensure the persisted payload is self-describing by overwriting/inserting
    // the type discriminator under [typeKey].
    map[typeKey] = object.typeId;
    return jsonEncode(map);
  }

  @override
  Map<String, dynamic> decode(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw CorruptedDataException(
        'Failed to parse JSON payload.',
        cause: error,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw CorruptedDataException(
        'Expected a JSON object but got ${decoded.runtimeType}.',
        cause: decoded,
      );
    }

    return decoded;
  }
}

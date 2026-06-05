// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:json_annotation/json_annotation.dart';
import 'package:serialize_objects_type/serialize_objects_type.dart';

part 'segundo.g.dart';

/// Example domain type with its own typed fields.
///
/// Note: the generated [_$SegundoFromJson] ignores the injected `type` key
/// added during serialization, because json_serializable ignores unknown keys
/// by default.
@JsonSerializable()
class Segundo implements Serializable {
  /// Stable type identifier persisted alongside the payload.
  ///
  /// Declared with a distinct name from the [typeId] instance getter because
  /// Dart does not allow a static and an instance member to share a name.
  static const String kTypeId = 'Segundo';

  final String name;

  Segundo(this.name);

  factory Segundo.fromJson(Map<String, dynamic> json) =>
      _$SegundoFromJson(json);

  @override
  String get typeId => Segundo.kTypeId;

  @override
  Map<String, dynamic> toJson() => _$SegundoToJson(this);

  @override
  String toString() => 'Segundo(name: $name)';
}

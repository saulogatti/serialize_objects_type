// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:json_annotation/json_annotation.dart';
import 'package:serialize_objects_type/serialize_objects_type.dart';

part 'primeiro.g.dart';

/// Example domain type with its own typed fields.
///
/// Note: the generated [_$PrimeiroFromJson] ignores the injected `type` key
/// added during serialization, because json_serializable ignores unknown keys
/// by default.
@JsonSerializable()
class Primeiro implements Serializable {
  /// Stable type identifier persisted alongside the payload.
  ///
  /// Declared with a distinct name from the [typeId] instance getter because
  /// Dart does not allow a static and an instance member to share a name.
  static const String kTypeId = 'Primeiro';

  final int total;

  Primeiro(this.total);

  factory Primeiro.fromJson(Map<String, dynamic> json) =>
      _$PrimeiroFromJson(json);

  @override
  String get typeId => Primeiro.kTypeId;

  @override
  Map<String, dynamic> toJson() => _$PrimeiroToJson(this);

  @override
  String toString() => 'Primeiro(total: $total)';
}

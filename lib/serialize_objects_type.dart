/// Type-aware object serialization: register a type, then serialize and
/// reconstruct its instances through a pluggable storage backend.
library;

// Core contracts.
export 'src/core/serializable.dart';
export 'src/core/serializer_registry.dart' show SerializerRegistry, Deserializer;
export 'src/core/exceptions.dart';

// Codec layer (JSON is the default format in this version).
export 'src/codec/data_codec.dart';
export 'src/codec/json_data_codec.dart';

// Storage layer.
export 'src/storage/storage.dart';
export 'src/storage/file_storage.dart';
export 'src/storage/memory_storage.dart';

// Service.
export 'src/service/serialize_service.dart';

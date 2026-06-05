## 0.1.0 - 2026-06-05

- New layered architecture for type-aware object serialization:
  - `Serializable` contract (`typeId` + `toJson()`) for persistable objects.
  - Pluggable `DataCodec` with `JsonDataCodec` as the default format.
  - Pluggable `Storage` with `FileStorage` (file-based) and `InMemoryStorage` backends.
  - `SerializeService` wiring storage, codec, and `SerializerRegistry` via dependency injection.
  - Typed exceptions as subclasses of `SerializeException`.
  - Id-based keys, allowing multiple stored instances per type.

## 1.0.0

- Initial version.

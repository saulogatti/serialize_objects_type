## Unreleased

- `SerializeService.loadAll(typeId)` reconstructs every stored instance of a
  type, backed by a new `Storage.listIds(typeId, extension)` operation
  (implemented by `FileStorage` and `InMemoryStorage`).
- `SerializeService.streamAll(typeId)` lazily emits stored instances one at a
  time, keeping at most a single payload in memory; `loadAll` now delegates to
  it.

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

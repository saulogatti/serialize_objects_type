## Task list and reminders for developing the object-to-file serialization package.

----
# Code implemented:

- [x] `Storage` interface plus `FileStorage` and `InMemoryStorage` backends, responsible for file operations (checking existence, reading, writing, deleting). Files are laid out as `<basePath>/<typeId>/<id>.<extension>`.
- [x] `DataCodec` interface with a `JsonDataCodec` implementation, responsible for encoding/decoding object data to and from bytes.
- [x] Serialization protocol via the `Serializable` contract (`String get typeId;` + `Map<String, dynamic> toJson();`), where concrete classes declare a stable `static const String typeId`.
- [x] Serialize/deserialize flow: `SerializeService` encodes a `Serializable` through the codec and writes it via storage, then reads it back, identifies the type, and rebuilds the object through the registered deserializer.
- [x] Service initialization and registry: `SerializeService` wires `Storage`, `DataCodec`, and `SerializerRegistry` via dependency injection, and `register(typeId, deserializer)` maps each type to its `Deserializer` factory.
- [x] Custom error types: typed subclasses of `SerializeException` for situations such as unknown object types and read/write failures.

# Open items:

- [ ] Code generation that produces the `typeId` constant and `register` boilerplate automatically (configurable in a future version).
- [ ] Large-file / streaming reads and writes, processing data in parts to avoid loading everything into memory.
- [ ] Additional formats: more `DataCodec` implementations beyond JSON.

----

# Documentation to do:

- [ ] Write a contribution guide explaining how other developers can contribute improvements or fixes.
- [ ] Expand API documentation and add more usage examples for the core, codec, storage, and service layers.

----

# Idea notes:
- The package works with object types that can be serialized and deserialized: converted to a format that can be stored or transmitted, then reconstructed back to their original state. This relies on a serialization protocol (the `Serializable` contract) that carries the type identity. Every type that implements the protocol is registered with the service so it knows how to recreate the object from its stored representation. The service can create, read, and delete files. Objects are keyed by an `id`, allowing multiple instances of the same type.

Next steps:
- Support large files by reading and writing in chunks so memory is not overloaded, while keeping robust handling of corrupted files and invalid paths, and an API that is easy to use and integrate.
- Provide a codegen that generates serialization/deserialization boilerplate from the protocol to reduce human error, later made configurable for different formats and type-identification strategies.

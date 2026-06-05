# serialize_objects_type

A type-aware object serialization library for Dart. It persists and restores
your domain objects through a small, layered API: each object declares a stable
type identifier, is encoded by a pluggable data codec, and is written to a
pluggable storage backend.

## Architecture

The package is organized into four cooperating layers:

### Core

- **`Serializable`** — the contract every persistable object implements. It
  exposes `String get typeId;` and `Map<String, dynamic> toJson();`. Concrete
  classes declare a stable `static const String kTypeId` (surfaced through the
  `typeId` getter) so the type can be identified independently of the runtime
  class name.
- **`SerializerRegistry`** — maps a `typeId` to a `Deserializer` factory
  (`Serializable Function(Map<String, dynamic>)`). This is how the service knows
  how to rebuild an object from its stored representation.

### Codec

- **`DataCodec`** — the interface that turns a `Map<String, dynamic>` into bytes
  and back. The codec is pluggable so new wire formats can be added without
  touching the rest of the stack.
- **`JsonDataCodec`** — the JSON implementation, shipped as the default codec in
  this version.

### Storage

- **`Storage`** — the interface for the physical persistence backend, addressed
  by a **`StorageKey`**.
- **`FileStorage`** — a filesystem-backed implementation. Files are laid out as
  `<basePath>/<typeId>/<id>.<extension>`, so each type gets its own directory
  and each instance is addressed by its `id`.
- **`InMemoryStorage`** — an in-memory implementation, useful for tests and
  ephemeral use.

### Service

- **`SerializeService`** — the high-level entry point that wires the layers
  together via dependency injection:
  `SerializeService({ required Storage storage, DataCodec? codec, SerializerRegistry? registry })`.
  It exposes `register(typeId, deserializer)`, `save(String id, Serializable)`,
  `load(String typeId, String id)`, `loadAll(String typeId)` (reconstructs every
  stored instance of a type), and `delete(String typeId, String id)`.
  Failures are reported as typed subclasses of `SerializeException`.

## Quick Start

```dart
import 'package:serialize_objects_type/serialize_objects_type.dart';

class User implements Serializable {
  User({required this.name, required this.age});

  // Declared with a distinct name from the `typeId` instance getter because
  // Dart does not allow a static field and an instance member to share a name.
  static const String kTypeId = 'User';

  final String name;
  final int age;

  @override
  String get typeId => User.kTypeId;

  @override
  Map<String, dynamic> toJson() => {'name': name, 'age': age};

  static User fromJson(Map<String, dynamic> json) =>
      User(name: json['name'] as String, age: json['age'] as int);
}

Future<void> main() async {
  // Wire the service to a filesystem backend (JSON codec is the default).
  final service = SerializeService(storage: FileStorage('example_data'));

  // Register how to rebuild a User from its stored map.
  service.register(User.kTypeId, User.fromJson);

  // Save an instance under an id.
  final user = User(name: 'Ada', age: 36);
  await service.save('user-1', user);

  // Load it back by type id + id.
  final loaded = await service.load(User.kTypeId, 'user-1') as User;
  print('${loaded.name}, ${loaded.age}'); // Ada, 36

  // Delete it.
  await service.delete(User.kTypeId, 'user-1');
}
```

Because objects are keyed by an `id`, you can store many instances of the same
type side by side under `<basePath>/<typeId>/`.

## Formats and extensibility

JSON is the only format shipped in this version, via `JsonDataCodec`. Both the
codec (`DataCodec`) and the storage backend (`Storage`) are interfaces, so you
can plug in other serialization formats or persistence targets without changing
the service or your `Serializable` types.

## Roadmap

- **Code generation** — generate the `typeId` constant and `register`
  boilerplate automatically from annotations.
- **Large-file / streaming support** — read and write big payloads in chunks to
  avoid loading everything into memory.
- **Additional formats** — ship more `DataCodec` implementations beyond JSON.

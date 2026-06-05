# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Dart package for **type-aware object serialization**: register a type, then save and reconstruct its instances through a pluggable codec and storage backend. JSON + filesystem are the only shipped implementations, but the codec and storage are interfaces so other formats/backends can be added without touching the rest of the stack. A future codegen (not implemented) will generate the per-class `typeId` constant and `register` calls.

## Commands

```bash
dart pub get                                          # install deps
dart analyze                                          # lint (must be clean; CI gate)
dart test                                             # run all tests
dart test --plain-name "streamAll emits every"        # run a single test by name
dart test test/serialize_objects_type_test.dart       # run one test file
dart run build_runner build --delete-conflicting-outputs   # regenerate *.g.dart (json_serializable) — needed after touching example/*.dart
dart run example/serialize_objects_type_example.dart  # end-to-end smoke check
```

The validation gate before any commit is: `dart analyze` clean → `dart test` green → `example/` runs.

## Architecture

Four cooperating layers under `lib/src/`, wired together by `SerializeService`. The key design move is keeping **format**, **persistence**, and **type resolution** independent:

- **`core/`** — `Serializable` (contract: `typeId` + `toJson()`), `SerializerRegistry` (maps `typeId` → `Deserializer` factory), and the `sealed SerializeException` hierarchy (`Invalid/Unknown/Duplicate/Corrupted/Storage`).
- **`codec/`** — `DataCodec` interface + `JsonDataCodec`. `encode` injects the type discriminator under the key `JsonDataCodec.typeKey` (`'type'`) so payloads are self-describing; `decode` throws `CorruptedDataException` on malformed input.
- **`storage/`** — `Storage` interface keyed by `StorageKey(typeId, id, extension)`, with `FileStorage` (`<basePath>/<typeId>/<id>.<extension>`) and `InMemoryStorage` (tests). Every `dart:io` failure is rethrown as `StorageException` with the original error as `cause`.
- **`service/`** — `SerializeService`, the public entry point, takes `Storage` (required) + optional `DataCodec`/`SerializerRegistry` via DI. Flow: `save(id, obj)` → codec encodes → storage writes; `load`/`loadAll`/`streamAll` → storage reads → codec decodes → registry's deserializer rebuilds. `loadAll` delegates to `streamAll` (lazy, one payload in memory at a time).

`lib/serialize_objects_type.dart` is the single public barrel export.

## Conventions that bite

- **`typeId` is explicit and stable, never `runtimeType`** (which breaks under AOT/obfuscation). Concrete classes declare `static const String kTypeId = '...'` and override the `typeId` getter to return it. The static is named `kTypeId`, **not** `typeId`, because Dart forbids a static field and an instance member sharing a name (`conflicting_static_and_instance`).
- **`id` is separate from `typeId`** — passed to `save(id, obj)`, so many instances of one type coexist. The object never carries its own id.
- **Errors are typed** — throw the relevant `SerializeException` subclass, never a bare `Exception`. No `print` in library code.
- `analysis_options.yaml` promotes `invalid_override_of_non_virtual_member` to an error and ignores `type_literal_in_constant_pattern`. Do not suppress analyzer warnings unless explicitly asked.

## Dart style (`.github/instructions/dart-n-flutter.instructions.md`)

Effective Dart applies. Notably: never edit `*.g.dart` by hand (regenerate via build_runner); `dart:` then `package:` then relative imports, sorted; `///` doc comments on public APIs; when editing existing code, apply rules only to lines you add/modify and don't reformat surrounding code. Test services/repositories/ViewModels (here: the service, registry, codec, storage) with fakes — `InMemoryStorage` is the storage fake.

## Git

`main` is the default branch; the GitHub remote is `origin` (`saulogatti/serialize_objects_type`, public). Feature work goes on branches (e.g. `feature/stream-all`) and lands via PR. `pubspec.lock`, `example_data/`, and `testData/` are gitignored.

import 'package:serialize_objects_type/serialize_objects_type.dart';
import 'package:test/test.dart';

/// Minimal [Serializable] fixture used across the test suite.
class Sample implements Serializable {
  const Sample(this.value);

  final String value;

  @override
  String get typeId => 'Sample';

  @override
  Map<String, dynamic> toJson() => {'value': value};

  /// Rebuilds a [Sample] from its decoded JSON map.
  static Sample fromJson(Map<String, dynamic> json) =>
      Sample(json['value'] as String);

  @override
  bool operator ==(Object other) => other is Sample && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

void main() {
  group('SerializerRegistry', () {
    late SerializerRegistry registry;

    setUp(() => registry = SerializerRegistry());

    test('register then resolve returns the registered deserializer', () {
      registry.register('Sample', Sample.fromJson);

      final deserializer = registry.resolve('Sample');
      final result = deserializer({'value': 'hello'});

      expect(result, equals(const Sample('hello')));
    });

    test('contains reflects registration state', () {
      expect(registry.contains('Sample'), isFalse);

      registry.register('Sample', Sample.fromJson);

      expect(registry.contains('Sample'), isTrue);
    });

    test('resolving an unknown type throws UnknownTypeException', () {
      expect(
        () => registry.resolve('Unknown'),
        throwsA(isA<UnknownTypeException>()),
      );
    });

    test('registering an empty type throws InvalidTypeException', () {
      expect(
        () => registry.register('', Sample.fromJson),
        throwsA(isA<InvalidTypeException>()),
      );
    });

    test('double registering the same type throws DuplicateTypeException', () {
      registry.register('Sample', Sample.fromJson);

      expect(
        () => registry.register('Sample', Sample.fromJson),
        throwsA(isA<DuplicateTypeException>()),
      );
    });
  });

  group('JsonDataCodec', () {
    const codec = JsonDataCodec();

    test('decode(encode(obj)) yields the fields plus the type discriminator',
        () {
      const sample = Sample('hello');

      final decoded = codec.decode(codec.encode(sample));

      expect(
        decoded,
        equals({'value': 'hello', JsonDataCodec.typeKey: 'Sample'}),
      );
      expect(decoded[JsonDataCodec.typeKey], equals(sample.typeId));
    });

    test('decode of non-JSON input throws CorruptedDataException', () {
      expect(
        () => codec.decode('not json'),
        throwsA(isA<CorruptedDataException>()),
      );
    });

    test('decode of valid JSON that is not an object throws '
        'CorruptedDataException', () {
      expect(
        () => codec.decode('[1,2,3]'),
        throwsA(isA<CorruptedDataException>()),
      );
    });
  });

  group('InMemoryStorage', () {
    late InMemoryStorage storage;
    const key = StorageKey(typeId: 'Sample', id: 'a', extension: 'json');

    setUp(() => storage = InMemoryStorage());

    test('read of a missing key returns null', () async {
      expect(await storage.read(key), isNull);
    });

    test('write then read returns the stored contents', () async {
      await storage.write(key, 'payload');

      expect(await storage.read(key), equals('payload'));
    });

    test('exists reflects the stored state', () async {
      expect(await storage.exists(key), isFalse);

      await storage.write(key, 'payload');

      expect(await storage.exists(key), isTrue);
    });

    test('delete returns true when present and false when absent', () async {
      expect(await storage.delete(key), isFalse);

      await storage.write(key, 'payload');

      expect(await storage.delete(key), isTrue);
      expect(await storage.exists(key), isFalse);
    });

    test('listIds returns every id stored under a type', () async {
      expect(await storage.listIds('Sample', 'json'), isEmpty);

      await storage.write(key, 'a');
      await storage.write(
        const StorageKey(typeId: 'Sample', id: 'b', extension: 'json'),
        'b',
      );
      await storage.write(
        const StorageKey(typeId: 'Other', id: 'c', extension: 'json'),
        'c',
      );

      expect(
        await storage.listIds('Sample', 'json'),
        unorderedEquals(<String>['a', 'b']),
      );
    });
  });

  group('SerializeService end-to-end', () {
    late SerializeService service;

    setUp(() {
      service = SerializeService(storage: InMemoryStorage());
      service.register('Sample', Sample.fromJson);
    });

    test('save then load reconstructs an object equal to the original',
        () async {
      const original = Sample('hello');

      await service.save('id-1', original);
      final loaded = await service.load('Sample', 'id-1');

      expect(loaded, equals(original));
    });

    test('load of a missing id returns null', () async {
      expect(await service.load('Sample', 'missing'), isNull);
    });

    test('load of an unregistered type throws UnknownTypeException', () async {
      expect(
        () => service.load('Unregistered', 'id-1'),
        throwsA(isA<UnknownTypeException>()),
      );
    });

    test('two ids of the same type coexist independently', () async {
      await service.save('id-1', const Sample('first'));
      await service.save('id-2', const Sample('second'));

      expect(
        await service.load('Sample', 'id-1'),
        equals(const Sample('first')),
      );
      expect(
        await service.load('Sample', 'id-2'),
        equals(const Sample('second')),
      );
    });

    test('loadAll returns every stored object of a type', () async {
      await service.save('id-1', const Sample('first'));
      await service.save('id-2', const Sample('second'));

      final all = await service.loadAll('Sample');

      expect(
        all,
        unorderedEquals(<Sample>[
          const Sample('first'),
          const Sample('second'),
        ]),
      );
    });

    test('loadAll returns an empty list when nothing is stored', () async {
      expect(await service.loadAll('Sample'), isEmpty);
    });

    test('loadAll of an unregistered type throws UnknownTypeException', () {
      expect(
        () => service.loadAll('Unregistered'),
        throwsA(isA<UnknownTypeException>()),
      );
    });

    test('delete removes the object so a later load returns null', () async {
      await service.save('id-1', const Sample('hello'));

      expect(await service.delete('Sample', 'id-1'), isTrue);
      expect(await service.load('Sample', 'id-1'), isNull);
    });

    test('save with an empty id throws InvalidTypeException', () async {
      expect(
        () => service.save('', const Sample('hello')),
        throwsA(isA<InvalidTypeException>()),
      );
    });

    test('load with an empty id throws InvalidTypeException', () async {
      expect(
        () => service.load('Sample', ''),
        throwsA(isA<InvalidTypeException>()),
      );
    });

    test('delete with an empty id throws InvalidTypeException', () async {
      expect(
        () => service.delete('Sample', ''),
        throwsA(isA<InvalidTypeException>()),
      );
    });
  });
}

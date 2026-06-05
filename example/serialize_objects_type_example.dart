import 'package:serialize_objects_type/serialize_objects_type.dart';

import 'primeiro.dart';
import 'segundo.dart';

void main() async {
  final service = SerializeService(storage: FileStorage('example_data'));

  try {
    // Register a deserializer for each type id.
    service.register(Primeiro.kTypeId, Primeiro.fromJson);
    service.register(Segundo.kTypeId, Segundo.fromJson);

    // Build typed instances.
    final primeiro = Primeiro(42);
    final segundo = Segundo('example');

    // Persist each object under an explicit id.
    await service.save('1', primeiro);
    await service.save('1', segundo);

    // Load the objects back and reconstruct their concrete types.
    final loadedPrimeiro = await service.load(Primeiro.kTypeId, '1');
    print(loadedPrimeiro);

    final loadedSegundo = await service.load(Segundo.kTypeId, '1');
    print(loadedSegundo);
  } catch (e) {
    print('Error during serialization: $e');
  }
}

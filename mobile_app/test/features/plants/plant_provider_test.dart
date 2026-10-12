import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/plants/models/plant.dart';
import 'package:mobile_app/features/plants/providers/plant_provider.dart';

class _ImmediatePlantNotifier extends PlantNotifier {
  @override
  Future<List<Plant>> build() async => initialPlants;
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [plantProvider.overrideWith(_ImmediatePlantNotifier.new)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state berisi data mock tanaman', () async {
    final plants = await container.read(plantProvider.future);

    expect(plants, hasLength(2));
    expect(plants.first.name, 'Tomat Pot Depan');
    expect(plants.last.name, 'Tomat Kebun Belakang');
  });

  test('addPlant menambahkan tanaman secara immutable', () async {
    final initial = await container.read(plantProvider.future);
    final newPlant = Plant(
      id: 'TMT-003',
      name: 'Tomat Balkon',
      location: 'Balkon',
      plantedDate: '12 Okt 2026',
      lastInspectionDate: 'Belum ada pemeriksaan',
      status: 'Sehat',
    );

    await container.read(plantProvider.notifier).addPlant(newPlant);
    final updated = container.read(plantProvider).requireValue;

    expect(updated, hasLength(3));
    expect(updated.last, newPlant);
    expect(identical(updated, initial), isFalse);
  });

  test('deletePlant menghapus tanaman berdasarkan ID', () async {
    await container.read(plantProvider.future);

    await container.read(plantProvider.notifier).deletePlant('TMT-001');

    expect(
      container.read(plantProvider).requireValue.map((plant) => plant.id),
      ['TMT-002'],
    );
  });

  test('updatePlant memperbarui tanaman berdasarkan ID', () async {
    await container.read(plantProvider.future);
    const updatedPlant = Plant(
      id: 'TMT-001',
      name: 'Tomat Teras',
      location: 'Teras',
      plantedDate: '28 Sep 2026',
      lastInspectionDate: '12 Okt 2026',
      status: 'Perlu perhatian',
    );

    await container.read(plantProvider.notifier).updatePlant(updatedPlant);

    expect(container.read(plantProvider).requireValue.first, updatedPlant);
  });
}

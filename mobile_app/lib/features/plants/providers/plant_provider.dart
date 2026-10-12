import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plant.dart';

const List<Plant> initialPlants = [
  Plant(
    id: 'TMT-001',
    name: 'Tomat Pot Depan',
    location: 'Teras depan',
    plantedDate: '28 Sep 2026',
    lastInspectionDate: '28 Sep 2026',
    status: 'Sehat',
  ),
  Plant(
    id: 'TMT-002',
    name: 'Tomat Kebun Belakang',
    location: 'Kebun belakang',
    plantedDate: '25 Sep 2026',
    lastInspectionDate: '25 Sep 2026',
    status: 'Perlu perhatian',
  ),
];

class PlantNotifier extends AsyncNotifier<List<Plant>> {
  @override
  Future<List<Plant>> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return initialPlants;
  }

  Future<void> addPlant(Plant plant) async {
    final current = state.value ?? await future;
    state = AsyncData([...current, plant]);
  }

  Future<void> deletePlant(String plantId) async {
    final current = state.value ?? await future;
    state = AsyncData(current.where((plant) => plant.id != plantId).toList());
  }

  Future<void> updatePlant(Plant updatedPlant) async {
    final current = state.value ?? await future;
    state = AsyncData([
      for (final plant in current)
        if (plant.id == updatedPlant.id) updatedPlant else plant,
    ]);
  }

  Future<void> refreshPlants() async {
    final current = state.value ?? initialPlants;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return current;
    });
  }
}

final AsyncNotifierProvider<PlantNotifier, List<Plant>> plantProvider =
    AsyncNotifierProvider<PlantNotifier, List<Plant>>(PlantNotifier.new);

final plantByIdProvider = Provider.family<Plant?, String>((ref, plantId) {
  final plants = ref.watch(plantProvider).value;
  if (plants == null) {
    return null;
  }

  for (final plant in plants) {
    if (plant.id == plantId) {
      return plant;
    }
  }

  return null;
});

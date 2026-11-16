import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../data/models/scan_record_model.dart';
import '../models/plant.dart';

class PlantNotifier extends AsyncNotifier<List<Plant>> {
  @override
  Future<List<Plant>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    final repository = ref.watch(plantRepositoryProvider);
    await repository.claimLegacyPlants(userId);
    return repository.getAll(userId: userId);
  }

  Future<void> addPlant(Plant plant) async {
    final current = state.value ?? await future;
    final userId = ref.read(currentUserIdProvider);
    final ownedPlant = plant.userId == userId
        ? plant
        : plant.copyWith(userId: userId);
    await ref.read(plantRepositoryProvider).create(ownedPlant);
    state = AsyncData([...current, ownedPlant]);
  }

  Future<String> nextPlantId() {
    return ref.read(plantRepositoryProvider).nextPlantId();
  }

  Future<void> deletePlant(String plantId) async {
    final current = state.value ?? await future;
    final userId = ref.read(currentUserIdProvider);
    final deleted = await ref
        .read(plantRepositoryProvider)
        .softDelete(plantId, userId: userId);
    if (deleted == 0) {
      throw StateError(
        'Tanaman $plantId tidak ditemukan di penyimpanan lokal.',
      );
    }
    state = AsyncData(current.where((plant) => plant.id != plantId).toList());
  }

  Future<void> updatePlant(Plant updatedPlant) async {
    final current = state.value ?? await future;
    final userId = ref.read(currentUserIdProvider);
    final ownedPlant = updatedPlant.userId == userId
        ? updatedPlant
        : updatedPlant.copyWith(userId: userId);
    final updated = await ref.read(plantRepositoryProvider).update(ownedPlant);
    if (updated == 0) {
      throw StateError(
        'Tanaman ${ownedPlant.id} tidak ditemukan di penyimpanan akun ini.',
      );
    }
    state = AsyncData([
      for (final plant in current)
        if (plant.id == ownedPlant.id) ownedPlant else plant,
    ]);
  }

  Future<void> refreshPlants() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = ref.read(currentUserIdProvider);
      final repository = ref.read(plantRepositoryProvider);
      await repository.claimLegacyPlants(userId);
      return repository.getAll(userId: userId);
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

final plantScanHistoryProvider =
    FutureProvider.family<List<ScanRecordModel>, String>((ref, plantId) {
      final userId = ref.watch(currentUserIdProvider);
      return ref
          .read(scanRepositoryProvider)
          .getScansByPlantId(plantId, userId);
    });

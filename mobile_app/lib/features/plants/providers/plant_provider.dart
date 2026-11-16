import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../data/models/scan_record_model.dart';
import '../models/plant.dart';

class PlantNotifier extends AsyncNotifier<List<Plant>> {
  @override
  Future<List<Plant>> build() => ref.watch(plantRepositoryProvider).getAll();

  Future<void> addPlant(Plant plant) async {
    final current = state.value ?? await future;
    await ref.read(plantRepositoryProvider).create(plant);
    state = AsyncData([...current, plant]);
  }

  Future<void> deletePlant(String plantId) async {
    final current = state.value ?? await future;
    final deleted = await ref.read(plantRepositoryProvider).softDelete(plantId);
    if (deleted == 0) {
      throw StateError(
        'Tanaman $plantId tidak ditemukan di penyimpanan lokal.',
      );
    }
    state = AsyncData(current.where((plant) => plant.id != plantId).toList());
  }

  Future<void> updatePlant(Plant updatedPlant) async {
    final current = state.value ?? await future;
    final updated = await ref
        .read(plantRepositoryProvider)
        .update(updatedPlant);
    if (updated == 0) {
      throw StateError(
        'Tanaman ${updatedPlant.id} tidak ditemukan di penyimpanan lokal.',
      );
    }
    state = AsyncData([
      for (final plant in current)
        if (plant.id == updatedPlant.id) updatedPlant else plant,
    ]);
  }

  Future<void> refreshPlants() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(plantRepositoryProvider).getAll(),
    );
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
      final userId = Firebase.apps.isEmpty
          ? 'user-local'
          : FirebaseAuth.instance.currentUser?.uid ?? 'user-local';
      return ref
          .read(scanRepositoryProvider)
          .getScansByPlantId(plantId, userId);
    });

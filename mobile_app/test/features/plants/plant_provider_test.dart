import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/providers/database_providers.dart';
import 'package:mobile_app/data/repositories/plant_repository.dart';
import 'package:mobile_app/features/plants/models/plant.dart';
import 'package:mobile_app/features/plants/providers/plant_provider.dart';

class _MemoryPlantRepository extends PlantRepository {
  _MemoryPlantRepository(this.plants);

  final List<Plant> plants;

  @override
  Future<List<Plant>> getAll({String userId = 'user-local'}) async =>
      List.of(plants.where((plant) => plant.userId == userId));

  @override
  Future<void> create(Plant plant) async {
    plants.add(plant);
  }

  @override
  Future<void> claimLegacyPlants(String userId) async {
    for (var index = 0; index < plants.length; index++) {
      if (plants[index].userId == 'user-local') {
        plants[index] = plants[index].copyWith(userId: userId);
      }
    }
  }

  @override
  Future<int> softDelete(String id, {String userId = 'user-local'}) async {
    plants.removeWhere((plant) => plant.id == id && plant.userId == userId);
    return 1;
  }

  @override
  Future<int> update(Plant plant) async {
    final index = plants.indexWhere(
      (item) => item.id == plant.id && item.userId == plant.userId,
    );
    if (index < 0) return 0;
    plants[index] = plant;
    return 1;
  }
}

class _AccountUserIdNotifier extends CurrentUserIdNotifier {
  _AccountUserIdNotifier(this.userId);

  final String userId;

  @override
  String build() => userId;
}

class _SwitchableUserIdNotifier extends CurrentUserIdNotifier {
  _SwitchableUserIdNotifier(this.userId);

  final String userId;

  @override
  String build() => userId;

  void switchTo(String nextUserId) {
    state = nextUserId;
  }
}

void main() {
  late ProviderContainer container;
  late _MemoryPlantRepository repository;

  const initialPlants = [
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

  setUp(() {
    repository = _MemoryPlantRepository(initialPlants.toList());
    container = ProviderContainer(
      overrides: [plantRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state dibaca dari repository', () async {
    final plants = await container.read(plantProvider.future);

    expect(plants, hasLength(2));
    expect(plants.first.name, 'Tomat Pot Depan');
    expect(plants.last.name, 'Tomat Kebun Belakang');
  });

  test('provider hanya memuat tanaman milik akun aktif', () async {
    final accountPlants = _MemoryPlantRepository([
      initialPlants.first.copyWith(userId: 'user-1'),
      initialPlants.last.copyWith(userId: 'user-2'),
    ]);
    final accountContainer = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWith(
          () => _AccountUserIdNotifier('user-2'),
        ),
        plantRepositoryProvider.overrideWithValue(accountPlants),
      ],
    );
    addTearDown(accountContainer.dispose);

    final plants = await accountContainer.read(plantProvider.future);

    expect(plants.map((plant) => plant.id), ['TMT-002']);
    expect(plants.single.userId, 'user-2');
  });

  test('provider memuat ulang tanaman saat akun berganti', () async {
    late _SwitchableUserIdNotifier userNotifier;
    final accountPlants = _MemoryPlantRepository([
      initialPlants.first.copyWith(userId: 'user-1'),
      initialPlants.last.copyWith(userId: 'user-2'),
    ]);
    final accountContainer = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWith(() {
          userNotifier = _SwitchableUserIdNotifier('user-1');
          return userNotifier;
        }),
        plantRepositoryProvider.overrideWithValue(accountPlants),
      ],
    );
    addTearDown(accountContainer.dispose);

    expect(
      (await accountContainer.read(plantProvider.future)).single.userId,
      'user-1',
    );

    final switchedAccountPlants = Completer<List<Plant>>();
    final subscription = accountContainer.listen(plantProvider, (
      previous,
      next,
    ) {
      if (next.hasValue && next.requireValue.single.userId == 'user-2') {
        switchedAccountPlants.complete(next.requireValue);
      }
    });
    addTearDown(subscription.close);
    userNotifier.switchTo('user-2');

    expect((await switchedAccountPlants.future).single.userId, 'user-2');
  });

  test('addPlant menyimpan ke repository sebelum memperbarui state', () async {
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
    expect(await repository.getAll(), contains(newPlant));
  });

  test('deletePlant menghapus dari state dan repository', () async {
    await container.read(plantProvider.future);

    await container.read(plantProvider.notifier).deletePlant('TMT-001');

    expect(
      container.read(plantProvider).requireValue.map((plant) => plant.id),
      ['TMT-002'],
    );
    expect((await repository.getAll()).map((plant) => plant.id), ['TMT-002']);
  });

  test('updatePlant memperbarui state dan repository', () async {
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
    expect((await repository.getAll()).first, updatedPlant);
  });
}

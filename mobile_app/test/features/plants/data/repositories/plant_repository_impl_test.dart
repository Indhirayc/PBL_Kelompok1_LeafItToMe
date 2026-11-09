import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/errors/failures.dart';
import 'package:mobile_app/core/network/api_config.dart';
import 'package:mobile_app/core/network/network_info.dart';
import 'package:mobile_app/features/plants/data/datasources/plant_remote_datasource.dart';
import 'package:mobile_app/features/plants/data/models/plant_model.dart';
import 'package:mobile_app/features/plants/data/repositories/plant_repository_impl.dart';

void main() {
  const configuredApi = ApiConfig(baseUrl: 'https://api.leafittome.test');
  const plant = PlantModel(
    id: 'plant-1',
    name: 'Tomat Pot Depan',
    location: 'Teras',
    plantedDate: '28 Sep 2026',
    status: 'Sehat',
    lastInspectionDate: '12 Okt 2026',
  );

  group('PlantRepositoryImpl', () {
    test('returns a configuration failure before checking the network', () {
      final dataSource = FakePlantRemoteDataSource();
      final network = FakeNetworkInfo(isConnected: true);
      final repository = PlantRepositoryImpl(
        remoteDataSource: dataSource,
        networkInfo: network,
        apiConfig: const ApiConfig(),
      );

      expect(
        repository.getRemotePlants(),
        throwsA(isA<ConfigurationFailure>()),
      );
      expect(network.checkCount, 0);
      expect(dataSource.getPlantsCount, 0);
    });

    test('does not request remote data when there is no connection', () async {
      final dataSource = FakePlantRemoteDataSource();
      final repository = PlantRepositoryImpl(
        remoteDataSource: dataSource,
        networkInfo: FakeNetworkInfo(isConnected: false),
        apiConfig: configuredApi,
      );

      await expectLater(
        repository.getRemotePlants(),
        throwsA(isA<NetworkFailure>()),
      );
      expect(dataSource.getPlantsCount, 0);
    });

    test('maps remote models into the existing Plant entity', () async {
      final dataSource = FakePlantRemoteDataSource(plants: const [plant]);
      final repository = PlantRepositoryImpl(
        remoteDataSource: dataSource,
        networkInfo: FakeNetworkInfo(isConnected: true),
        apiConfig: configuredApi,
      );

      final plants = await repository.getRemotePlants();

      expect(plants, hasLength(1));
      expect(plants.single.id, plant.id);
      expect(plants.single.name, plant.name);
      expect(dataSource.getPlantsCount, 1);
    });

    test('serializes an entity when creating a remote plant', () async {
      final dataSource = FakePlantRemoteDataSource();
      final repository = PlantRepositoryImpl(
        remoteDataSource: dataSource,
        networkInfo: FakeNetworkInfo(isConnected: true),
        apiConfig: configuredApi,
      );

      final created = await repository.createRemotePlant(plant.toEntity());

      expect(dataSource.createdPlant?.id, plant.id);
      expect(dataSource.createdPlant?.note, plant.note);
      expect(created.name, plant.name);
    });
  });
}

class FakeNetworkInfo implements NetworkInfo {
  FakeNetworkInfo({required this._isConnected});

  final bool _isConnected;

  int checkCount = 0;

  @override
  Future<bool> get isConnected async {
    checkCount++;
    return _isConnected;
  }
}

class FakePlantRemoteDataSource implements PlantRemoteDataSource {
  FakePlantRemoteDataSource({this.plants = const []});

  final List<PlantModel> plants;
  int getPlantsCount = 0;
  PlantModel? createdPlant;

  @override
  Future<List<PlantModel>> getPlants() async {
    getPlantsCount++;
    return plants;
  }

  @override
  Future<PlantModel> getPlantById(String id) async => plants.first;

  @override
  Future<PlantModel> createPlant(PlantModel plant) async {
    createdPlant = plant;
    return plant;
  }

  @override
  Future<PlantModel> updatePlant(PlantModel plant) async => plant;

  @override
  Future<void> deletePlant(String id) async {}
}

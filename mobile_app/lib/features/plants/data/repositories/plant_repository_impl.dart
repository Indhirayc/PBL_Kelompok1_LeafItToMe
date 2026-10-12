import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/plant_repository.dart';
import '../../models/plant.dart';
import '../datasources/plant_remote_datasource.dart';
import '../models/plant_model.dart';

class PlantRepositoryImpl implements PlantRepository {
  PlantRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    this.apiConfig = ApiConfig.defaultConfig,
  });

  final PlantRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final ApiConfig apiConfig;

  static const _notConfiguredMessage =
      'Backend LeafItToMe belum dikonfigurasi.';

  @override
  Future<List<Plant>> getRemotePlants() {
    return _runRemote(() async {
      final models = await remoteDataSource.getPlants();
      return models.map((model) => model.toEntity()).toList(growable: false);
    });
  }

  @override
  Future<Plant> getRemotePlantById(String id) {
    return _runRemote(
      () async => (await remoteDataSource.getPlantById(id)).toEntity(),
    );
  }

  @override
  Future<Plant> createRemotePlant(Plant plant) {
    return _runRemote(
      () async =>
          (await remoteDataSource.createPlant(PlantModel.fromEntity(plant)))
              .toEntity(),
    );
  }

  @override
  Future<Plant> updateRemotePlant(Plant plant) {
    return _runRemote(
      () async =>
          (await remoteDataSource.updatePlant(PlantModel.fromEntity(plant)))
              .toEntity(),
    );
  }

  @override
  Future<void> deleteRemotePlant(String id) {
    return _runRemote(() => remoteDataSource.deletePlant(id));
  }

  Future<T> _runRemote<T>(Future<T> Function() operation) async {
    try {
      _ensureConfigured();
      await _ensureConnected();
      return await operation();
    } on Failure {
      rethrow;
    } on ConfigurationException {
      throw const ConfigurationFailure(_notConfiguredMessage);
    } on NetworkException catch (error) {
      throw NetworkFailure(error.message);
    } on ServerException catch (error) {
      throw ServerFailure(error.message);
    } catch (error) {
      throw UnknownFailure(error.toString());
    }
  }

  void _ensureConfigured() {
    if (!apiConfig.isConfigured) {
      throw const ConfigurationFailure(_notConfiguredMessage);
    }
  }

  Future<void> _ensureConnected() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure(
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    }
  }
}

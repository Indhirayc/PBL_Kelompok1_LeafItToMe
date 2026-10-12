import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/plant_model.dart';

abstract interface class PlantRemoteDataSource {
  Future<List<PlantModel>> getPlants();
  Future<PlantModel> getPlantById(String id);
  Future<PlantModel> createPlant(PlantModel plant);
  Future<PlantModel> updatePlant(PlantModel plant);
  Future<void> deletePlant(String id);
}

class PlantRemoteDataSourceImpl implements PlantRemoteDataSource {
  PlantRemoteDataSourceImpl(
    this._dio, {
    this.apiConfig = ApiConfig.defaultConfig,
  });

  final Dio _dio;
  final ApiConfig apiConfig;

  static const _notConfiguredMessage =
      'Backend LeafItToMe belum dikonfigurasi.';

  Future<T> _request<T>(Future<T> Function() request) async {
    if (!apiConfig.isConfigured) {
      throw const ConfigurationException(_notConfiguredMessage);
    }

    try {
      return await request();
    } on DioException catch (error) {
      final cause = error.error;
      if (cause is Exception) {
        throw cause;
      }
      throw mapDioException(error);
    }
  }

  @override
  Future<List<PlantModel>> getPlants() {
    return _request(() async {
      final response = await _dio.get<dynamic>('/plants');
      final data = response.data;
      if (data is! List) {
        throw const ServerException('Invalid plants response.');
      }
      if (data.any((item) => item is! Map)) {
        throw const ServerException('Invalid plant in plants response.');
      }

      return data
          .map((item) => PlantModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    });
  }

  @override
  Future<PlantModel> getPlantById(String id) {
    return _request(() async {
      final response = await _dio.get<dynamic>(
        '/plants/${Uri.encodeComponent(id)}',
      );
      return PlantModel.fromJson(_readObject(response.data));
    });
  }

  @override
  Future<PlantModel> createPlant(PlantModel plant) {
    return _request(() async {
      final response = await _dio.post<dynamic>(
        '/plants',
        data: plant.toJson(),
      );
      return PlantModel.fromJson(_readObject(response.data));
    });
  }

  @override
  Future<PlantModel> updatePlant(PlantModel plant) {
    return _request(() async {
      final response = await _dio.patch<dynamic>(
        '/plants/${Uri.encodeComponent(plant.id)}',
        data: plant.toJson(),
      );
      return PlantModel.fromJson(_readObject(response.data));
    });
  }

  @override
  Future<void> deletePlant(String id) {
    return _request(() async {
      await _dio.delete<void>('/plants/${Uri.encodeComponent(id)}');
    });
  }

  Map<String, dynamic> _readObject(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw const ServerException('Invalid plant response.');
  }
}

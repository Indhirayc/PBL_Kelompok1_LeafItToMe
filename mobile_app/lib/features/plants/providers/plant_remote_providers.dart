import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/providers/network_providers.dart';

import '../data/datasources/plant_remote_datasource.dart';
import '../data/repositories/plant_repository_impl.dart';
import '../domain/repositories/plant_repository.dart';

final Provider<PlantRemoteDataSource> plantRemoteDataSourceProvider =
    Provider<PlantRemoteDataSource>(
      (ref) => PlantRemoteDataSourceImpl(
        ref.watch(dioProvider),
        apiConfig: ref.watch(apiConfigProvider),
      ),
    );

final Provider<PlantRepository> plantRepositoryProvider =
    Provider<PlantRepository>(
      (ref) => PlantRepositoryImpl(
        remoteDataSource: ref.watch(plantRemoteDataSourceProvider),
        networkInfo: ref.watch(networkInfoProvider),
        apiConfig: ref.watch(apiConfigProvider),
      ),
    );

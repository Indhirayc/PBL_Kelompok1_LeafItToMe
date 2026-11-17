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

/// Provider untuk PlantRepository remote (legacy/REST API).
/// Gunakan `plantRepositoryProvider` dari `core/providers/database_providers.dart`
/// untuk operasi lokal SQLite utama.
final Provider<PlantRepository> plantRemoteRepositoryProvider =
    Provider<PlantRepository>(
      (ref) => PlantRepositoryImpl(
        remoteDataSource: ref.watch(plantRemoteDataSourceProvider),
        networkInfo: ref.watch(networkInfoProvider),
        apiConfig: ref.watch(apiConfigProvider),
      ),
    );

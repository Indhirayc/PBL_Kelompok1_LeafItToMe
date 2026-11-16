import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/repositories/plant_repository.dart';
import '../../data/repositories/scan_repository.dart';

// Provider untuk AppDatabase instance
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

// Provider untuk PlantRepository
final plantRepositoryProvider = Provider<PlantRepository>((ref) {
  return PlantRepository();
});

// Provider untuk ScanRepository
final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository();
});

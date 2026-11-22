import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/plant_repository.dart';
import '../../data/repositories/scan_repository.dart';
import '../../data/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository.instance;
});

final currentUserIdProvider = NotifierProvider<CurrentUserIdNotifier, String>(
  CurrentUserIdNotifier.new,
);

class CurrentUserIdNotifier extends Notifier<String> {
  StreamSubscription<UserModel?>? _authSubscription;

  @override
  String build() {
    final userRepo = ref.watch(userRepositoryProvider);
    _authSubscription = userRepo.authStateChanges.listen((user) {
      state = user?.uid ?? 'user-local';
    });
    ref.onDispose(() => _authSubscription?.cancel());
    return userRepo.currentUserId ?? 'user-local';
  }
}

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

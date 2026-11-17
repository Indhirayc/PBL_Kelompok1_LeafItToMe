import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/repositories/plant_repository.dart';
import '../../data/repositories/scan_repository.dart';

final currentUserIdProvider = NotifierProvider<CurrentUserIdNotifier, String>(
  CurrentUserIdNotifier.new,
);

class CurrentUserIdNotifier extends Notifier<String> {
  StreamSubscription<User?>? _authSubscription;

  @override
  String build() {
    FirebaseApp? defaultApp;
    for (final app in Firebase.apps) {
      if (app.name == '[DEFAULT]') {
        defaultApp = app;
        break;
      }
    }

    if (defaultApp == null) return 'user-local';

    final auth = FirebaseAuth.instanceFor(app: defaultApp);
    _authSubscription = auth.authStateChanges().listen((user) {
      state = user?.uid ?? 'user-local';
    });
    ref.onDispose(() => _authSubscription?.cancel());
    return auth.currentUser?.uid ?? 'user-local';
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

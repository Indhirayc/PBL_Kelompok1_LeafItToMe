import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'offline_database.dart';

/// Sumber tunggal pembuka database lokal.
///
/// Inilah satu-satunya tempat database dibuka; fitur lain bergantung pada
/// abstraksi repository, bukan pada `sqflite` (Clean Architecture: DI).
final offlineDatabaseProvider = FutureProvider<Database>(
  (ref) => OfflineDatabase.open(),
);
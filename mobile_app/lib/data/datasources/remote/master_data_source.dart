import '../local/app_database.dart';

/// Sumber data master (diseases/guides/tools) dari SQLite lokal / MySQL backend.
class MasterDataSource {
  const MasterDataSource();

  /// Ambil semua dokumen dari satu koleksi master.
  Future<List<Map<String, dynamic>>> fetchCollection(String collection) async {
    final cached = await AppDatabase.instance.getMasterCache(collection);
    return cached ?? const [];
  }
}

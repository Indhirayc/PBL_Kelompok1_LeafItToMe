import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_schema.dart';

/// Pembuka database SQLite lokal LeafItToMe (offline-first).
///
/// Aplikasi membuat database-nya sendiri di perangkat saat pertama dijalankan,
/// memakai cetak biru [kLeafItToMeSchema]. Dipisah dari UI dan dari operasi
/// tabel agar mudah diganti (mis. database in-memory) saat pengujian.
class OfflineDatabase {
  const OfflineDatabase._();

  static const String fileName = 'leafittome.db';
  static const int version = kLeafItToMeDatabaseVersion;

  static Future<Database> open() async {
    final databasesPath = await getDatabasesPath();
    return openDatabase(
      p.join(databasesPath, fileName),
      version: version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON;'),
      onCreate: _createSchema,
      onUpgrade: _rebuildSchema,
    );
  }

  static Future<void> _createSchema(Database db, int version) async {
    final batch = db.batch();
    for (final statement in kLeafItToMeSchema) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _rebuildSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Database lokal bersifat salinan + antrian: saat versi skema naik, bangun
    // ulang saja agar tidak perlu migrasi bertahap. Isi akan tersinkron ulang.
    final batch = db.batch();
    for (final view in kLeafItToMeViews) {
      batch.execute('DROP VIEW IF EXISTS $view');
    }
    for (final table in kLeafItToMeTables) {
      batch.execute('DROP TABLE IF EXISTS $table');
    }
    await batch.commit(noResult: true);
    await _createSchema(db, newVersion);
  }
}
import 'package:sqflite/sqflite.dart';

import '../models/detection_model.dart';

/// Sumber data lokal (SQLite) untuk riwayat scan.
///
/// Menangani penyimpanan riwayat beserta PATH gambar (`images`) dan status
/// antrian sinkronisasi (`is_synced`). Tidak menyentuh UI maupun jaringan.
class DetectionLocalDataSource {
  const DetectionLocalDataSource(this._openDb);

  final Future<Database> Function() _openDb;

  static const String _viewQuery =
      'SELECT * FROM v_detection_details';

  Future<List<DetectionModel>> getDetections() async {
    final database = await _openDb();
    final rows = await database.rawQuery(
      '$_viewQuery ORDER BY inspected_at DESC',
    );
    return rows.map(DetectionModel.fromViewMap).toList(growable: false);
  }

  Future<List<DetectionModel>> getPendingDetections() async {
    final database = await _openDb();
    final rows = await database.rawQuery(
      '$_viewQuery WHERE is_synced = 0 ORDER BY inspected_at ASC',
    );
    return rows.map(DetectionModel.fromViewMap).toList(growable: false);
  }

  Future<int> insertDetection(
    DetectionModel detection, {
    required String userEmail,
    required String userName,
  }) async {
    final database = await _openDb();
    return database.transaction<int>((txn) async {
      final userId = await _ensureUser(
        txn,
        email: userEmail,
        fullName: userName,
      );
      final plantId = await _ensurePlant(
        txn,
        code: detection.plantCode,
        userId: userId,
        name: detection.plantName,
        location: detection.plantLocation,
      );
      final imageId = detection.photoPath == null
          ? null
          : await _upsertImage(
              txn,
              filePath: detection.photoPath!,
              source: detection.photoSource ?? 'camera',
            );
      final diseaseId = await _diseaseIdByName(txn, detection.diseaseName);

      return txn.insert(
        'detections',
        detection.toDetectionInsertMap(
          userId: userId,
          plantId: plantId,
          imageId: imageId,
          diseaseId: diseaseId,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<int> markSynced(String code, DateTime syncedAt) async {
    final database = await _openDb();
    return database.update(
      'detections',
      <String, Object?>{
        'is_synced': 1,
        'synced_at': syncedAt.toIso8601String(),
      },
      where: 'code = ?',
      whereArgs: <Object?>[code],
    );
  }

  Future<int> _ensureUser(
    Transaction txn, {
    required String email,
    required String fullName,
  }) async {
    final rows = await txn.query(
      'users',
      columns: const <String>['id'],
      where: 'email = ?',
      whereArgs: <Object?>[email],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return rows.first['id']! as int;
    }
    return txn.insert('users', <String, Object?>{
      'email': email,
      'full_name': fullName,
    });
  }

  Future<int> _ensurePlant(
    Transaction txn, {
    required String code,
    required int userId,
    required String name,
    String? location,
  }) async {
    final rows = await txn.query(
      'plants',
      columns: const <String>['id'],
      where: 'code = ?',
      whereArgs: <Object?>[code],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return rows.first['id']! as int;
    }
    return txn.insert('plants', <String, Object?>{
      'code': code,
      'user_id': userId,
      'name': name,
      'location': location,
    });
  }

  Future<int> _upsertImage(
    Transaction txn, {
    required String filePath,
    required String source,
  }) async {
    final rows = await txn.query(
      'images',
      columns: const <String>['id'],
      where: 'file_path = ?',
      whereArgs: <Object?>[filePath],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return rows.first['id']! as int;
    }
    return txn.insert('images', <String, Object?>{
      'file_path': filePath,
      'source': source,
    });
  }

  Future<int?> _diseaseIdByName(Transaction txn, String? name) async {
    if (name == null || name.isEmpty) {
      return null;
    }
    final rows = await txn.query(
      'diseases',
      columns: const <String>['id'],
      where: 'name = ?',
      whereArgs: <Object?>[name],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['id'] as int?;
  }
}
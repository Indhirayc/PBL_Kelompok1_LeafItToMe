import 'package:sqflite/sqflite.dart';

typedef DatabaseProvider = Future<Database> Function();

class SyncQueueDao {
  SyncQueueDao(this._databaseProvider);

  final DatabaseProvider _databaseProvider;

  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseProvider();
    await db.insert('sync_queue', {
      'id': '$entityType:$entityId:$operation',
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'payload': payload,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'attempts': 0,
      'last_error': null,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, Object?>>> getPending({int limit = 100}) async {
    final db = await _databaseProvider();
    return db.query('sync_queue', orderBy: 'created_at', limit: limit);
  }

  Future<int> remove({
    required String entityType,
    required String entityId,
    required String operation,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseProvider();
    return db.delete(
      'sync_queue',
      where: 'entity_type = ? AND entity_id = ? AND operation = ?',
      whereArgs: [entityType, entityId, operation],
    );
  }

  Future<int> recordFailure({
    required String entityType,
    required String entityId,
    required String operation,
    required String error,
  }) async {
    final db = await _databaseProvider();
    return db.rawUpdate(
      '''
      UPDATE sync_queue
      SET attempts = attempts + 1, last_error = ?
      WHERE entity_type = ? AND entity_id = ? AND operation = ?
      ''',
      [error, entityType, entityId, operation],
    );
  }
}

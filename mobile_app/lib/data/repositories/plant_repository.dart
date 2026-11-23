import '../../features/plants/models/plant.dart';
import '../datasources/local/app_database.dart';

class PlantRepository {
  PlantRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<void> create(Plant plant) async {
    final db = await _database.database;
    final now = _utcNow();
    await db.insert('plants', {
      ..._toDatabaseMap(plant),
      'created_at': now,
      'updated_at': now,
      'deleted_at': null,
    });
  }

  Future<void> claimLegacyPlants(String userId) async {
    if (userId == 'user-local') return;

    final db = await _database.database;
    await db.transaction((transaction) async {
      final claim = await transaction.query(
        'app_meta',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['legacy_plants_claimed'],
        limit: 1,
      );
      if (claim.isNotEmpty) return;

      final now = _utcNow();
      await transaction.update(
        'plants',
        {'user_id': userId, 'updated_at': now},
        where: 'user_id = ?',
        whereArgs: ['user-local'],
      );
      await transaction.insert('app_meta', {
        'key': 'legacy_plants_claimed',
        'value': userId,
        'updated_at': now,
      });
    });
  }

  Future<String> nextPlantId() async {
    final db = await _database.database;
    final rows = await db.query('plants', columns: ['id']);
    var maxNumber = 0;
    for (final row in rows) {
      final match = RegExp(r'^TMT-(\d+)$').firstMatch(row['id']! as String);
      final number = int.tryParse(match?.group(1) ?? '');
      if (number != null && number > maxNumber) {
        maxNumber = number;
      }
    }

    return 'TMT-${(maxNumber + 1).toString().padLeft(3, '0')}';
  }

  Future<Plant?> getById(String id, {String userId = 'user-local'}) async {
    final db = await _database.database;
    final rows = await db.query(
      'plants',
      where: 'id = ? AND user_id = ? AND deleted_at IS NULL',
      whereArgs: [id, userId],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromDatabaseMap(rows.single);
  }

  Future<List<Plant>> getAll({String userId = 'user-local'}) async {
    final db = await _database.database;
    final rows = await db.query(
      'plants',
      where: 'user_id = ? AND deleted_at IS NULL',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromDatabaseMap).toList();
  }

  Future<int> update(Plant plant) async {
    final db = await _database.database;
    return db.update(
      'plants',
      {..._toDatabaseMap(plant), 'updated_at': _utcNow()},
      where: 'id = ? AND user_id = ? AND deleted_at IS NULL',
      whereArgs: [plant.id, plant.userId],
    );
  }

  Future<int> softDelete(String id, {String userId = 'user-local'}) async {
    final db = await _database.database;
    final now = _utcNow();
    return db.update(
      'plants',
      {'deleted_at': now, 'updated_at': now},
      where: 'id = ? AND user_id = ? AND deleted_at IS NULL',
      whereArgs: [id, userId],
    );
  }
}

Map<String, Object?> _toDatabaseMap(Plant plant) => {
  'id': plant.id,
  'user_id': plant.userId,
  'name': plant.name,
  'location': plant.location,
  'planted_at': _parseDate(plant.plantedDate).toIso8601String(),
  'last_inspection_at': _parseOptionalDate(plant.lastInspectionDate)
      ?.toIso8601String(),
  'status': plant.status,
  'note': plant.note,
  'image_path': plant.imagePath,
};

Plant _fromDatabaseMap(Map<String, Object?> map) => Plant(
  id: map['id']! as String,
  userId: map['user_id'] as String? ?? 'user-local',
  name: map['name']! as String,
  location: map['location']! as String,
  plantedDate: _formatDate(DateTime.parse(map['planted_at']! as String)),
  lastInspectionDate: map['last_inspection_at'] == null
      ? 'Belum ada pemeriksaan'
      : _formatDate(DateTime.parse(map['last_inspection_at']! as String)),
  status: map['status']! as String,
  note: map['note'] as String?,
  imagePath: map['image_path'] as String?,
);

DateTime _parseDate(String value) {
  final parsed = _tryParseDate(value);
  if (parsed == null) {
    throw FormatException('Tanggal tanaman tidak valid: $value');
  }
  return parsed;
}

DateTime? _parseOptionalDate(String value) {
  if (value.trim().isEmpty ||
      value.toLowerCase().contains('belum ada pemeriksaan')) {
    return null;
  }
  return _parseDate(value);
}

DateTime? _tryParseDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed != null) return parsed.toUtc();

  final match = RegExp(r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})$')
      .firstMatch(value.trim());
  if (match == null) return null;
  const months = <String, int>{
    'jan': 1,
    'januari': 1,
    'feb': 2,
    'februari': 2,
    'mar': 3,
    'maret': 3,
    'apr': 4,
    'april': 4,
    'mei': 5,
    'may': 5,
    'jun': 6,
    'juni': 6,
    'jul': 7,
    'juli': 7,
    'agu': 8,
    'agustus': 8,
    'aug': 8,
    'sep': 9,
    'september': 9,
    'oktober': 10,
    'oct': 10,
    'okt': 10,
    'nov': 11,
    'november': 11,
    'des': 12,
    'desember': 12,
    'dec': 12,
  };
  final month = months[match.group(2)!.toLowerCase()];
  if (month == null) return null;
  return DateTime.utc(
    int.parse(match.group(3)!),
    month,
    int.parse(match.group(1)!),
  );
}

String _formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final utc = value.toUtc();
  return '${utc.day} ${months[utc.month - 1]} ${utc.year}';
}

String _utcNow() => DateTime.now().toUtc().toIso8601String();

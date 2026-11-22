import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/data/models/scan_record_model.dart';

void main() {
  group('ScanRecordModel', () {
    final testDate = DateTime(2026, 10, 23, 12, 0, 0);
    final model = ScanRecordModel(
      id: 'scan-123',
      userId: 'user-001',
      diseaseName: 'Tomato Early Blight',
      confidence: 0.95,
      localImagePath: '/data/user/0/cache/scan_123.jpg',
      cloudImageUrl: 'https://storage.googleapis.com/leafittome/scan_123.jpg',
      notes: 'Bercak kecokelatan pada daun bagian bawah',
      scannedAt: testDate,
      isSynced: true,
    );

    test(
      'toSqliteMap dan fromSqliteMap serializes & deserializes dengan benar',
      () {
        final map = model.toSqliteMap();

        expect(map['id'], 'scan-123');
        expect(map['user_id'], 'user-001');
        expect(map['disease_label'], 'Tomato Early Blight');
        expect(map['confidence'], 0.95);
        expect(map['local_image_path'], '/data/user/0/cache/scan_123.jpg');
        expect(
          map['cloud_image_url'],
          'https://storage.googleapis.com/leafittome/scan_123.jpg',
        );
        expect(map['notes'], 'Bercak kecokelatan pada daun bagian bawah');
        expect(map['scanned_at'], testDate.toUtc().toIso8601String());
        expect(map['sync_status'], 'synced');

        final fromMap = ScanRecordModel.fromSqliteMap(map);
        expect(fromMap.id, model.id);
        expect(fromMap.userId, model.userId);
        expect(fromMap.diseaseName, model.diseaseName);
        expect(fromMap.confidence, model.confidence);
        expect(fromMap.localImagePath, model.localImagePath);
        expect(fromMap.cloudImageUrl, model.cloudImageUrl);
        expect(fromMap.notes, model.notes);
        expect(fromMap.scannedAt, model.scannedAt.toUtc());
        expect(fromMap.isSynced, isTrue);
      },
    );

    test('toApiJson serializes untuk backend MySQL API', () {
      final apiJson = model.toApiJson();

      expect(apiJson['id_riwayat'], 'scan-123');
      expect(apiJson['id_pengguna'], 'user-001');
      expect(apiJson['nama_penyakit'], 'Tomato Early Blight');
      expect(apiJson['confidence_score'], 0.95);
      expect(apiJson['catatan'], 'Bercak kecokelatan pada daun bagian bawah');
    });

    test('copyWith membuat salinan dengan atribut baru yang diubah', () {
      final updated = model.copyWith(
        cloudImageUrl: 'https://new-url.com/image.jpg',
        isSynced: false,
      );

      expect(updated.cloudImageUrl, 'https://new-url.com/image.jpg');
      expect(updated.isSynced, isFalse);
      expect(updated.id, model.id);
      expect(updated.diseaseName, model.diseaseName);
    });
  });
}

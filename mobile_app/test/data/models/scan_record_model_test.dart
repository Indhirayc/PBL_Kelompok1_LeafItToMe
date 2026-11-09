import 'package:cloud_firestore/cloud_firestore.dart';
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

    test('toSqliteMap dan fromSqliteMap serializes & deserializes dengan benar', () {
      final map = model.toSqliteMap();

      expect(map['id'], 'scan-123');
      expect(map['user_id'], 'user-001');
      expect(map['disease_name'], 'Tomato Early Blight');
      expect(map['confidence'], 0.95);
      expect(map['local_image_path'], '/data/user/0/cache/scan_123.jpg');
      expect(map['cloud_image_url'], 'https://storage.googleapis.com/leafittome/scan_123.jpg');
      expect(map['notes'], 'Bercak kecokelatan pada daun bagian bawah');
      expect(map['scanned_at'], testDate.toIso8601String());
      expect(map['is_synced'], 1);

      final fromMap = ScanRecordModel.fromSqliteMap(map);
      expect(fromMap.id, model.id);
      expect(fromMap.userId, model.userId);
      expect(fromMap.diseaseName, model.diseaseName);
      expect(fromMap.confidence, model.confidence);
      expect(fromMap.localImagePath, model.localImagePath);
      expect(fromMap.cloudImageUrl, model.cloudImageUrl);
      expect(fromMap.notes, model.notes);
      expect(fromMap.scannedAt, model.scannedAt);
      expect(fromMap.isSynced, isTrue);
    });

    test('toFirestore serializes dengan Timestamp Firestore', () {
      final firestoreMap = model.toFirestore();

      expect(firestoreMap['id'], 'scan-123');
      expect(firestoreMap['user_id'], 'user-001');
      expect(firestoreMap['disease_name'], 'Tomato Early Blight');
      expect(firestoreMap['confidence'], 0.95);
      expect(firestoreMap['cloud_image_url'], 'https://storage.googleapis.com/leafittome/scan_123.jpg');
      expect(firestoreMap['notes'], 'Bercak kecokelatan pada daun bagian bawah');
      expect(firestoreMap['scanned_at'], isA<Timestamp>());
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

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
      plantId: 'TMT-001',
      plantName: 'Tomat Pot Depan',
      plantLocation: 'Teras depan',
    );

    test('atribut tanaman tersimpan pada model', () {
      expect(model.plantId, 'TMT-001');
      expect(model.plantName, 'Tomat Pot Depan');
      expect(model.plantLocation, 'Teras depan');
    });

    test('toApiJson mengirim field yang dibutuhkan backend', () {
      final apiMap = model.toApiJson();

      expect(apiMap['id_riwayat'], 'scan-123');
      expect(apiMap['id_pengguna'], 'user-001');
      expect(apiMap['id_tanaman'], 'TMT-001');
      expect(apiMap['nama_tanaman'], 'Tomat Pot Depan');
      expect(apiMap['lokasi'], 'Teras depan');
      expect(apiMap['nama_penyakit'], 'Tomato Early Blight');
      expect(apiMap['confidence_score'], 0.95);
      expect(apiMap['tanggal_pemeriksaan'], testDate.toIso8601String());
      expect(apiMap['catatan'], 'Bercak kecokelatan pada daun bagian bawah');
      expect(apiMap['foto_daun'], '/data/user/0/cache/scan_123.jpg');
    });

    test('toFirestore serializes dengan Timestamp Firestore', () {
      final firestoreMap = model.toFirestore();

      expect(firestoreMap['id'], 'scan-123');
      expect(firestoreMap['user_id'], 'user-001');
      expect(firestoreMap['disease_name'], 'Tomato Early Blight');
      expect(firestoreMap['confidence'], 0.95);
      expect(
        firestoreMap['cloud_image_url'],
        'https://storage.googleapis.com/leafittome/scan_123.jpg',
      );
      expect(
        firestoreMap['notes'],
        'Bercak kecokelatan pada daun bagian bawah',
      );
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
      expect(updated.plantId, model.plantId);
      expect(updated.plantName, model.plantName);
      expect(updated.plantLocation, model.plantLocation);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/providers/database_providers.dart';
import 'package:mobile_app/core/services/tflite_service.dart';
import 'package:mobile_app/data/models/scan_record_model.dart';
import 'package:mobile_app/features/detection/presentation/pages/data_inspection_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/detection_result_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/photo_preview_page.dart';
import 'package:mobile_app/features/detection/presentation/widgets/confidence_indicator.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/plants/providers/plant_provider.dart';

import '../../../sync/fake_scan_repository.dart';

class _TestUserIdNotifier extends CurrentUserIdNotifier {
  @override
  String build() => 'user-local';
}

class _MemoryScanRepository extends FakeScanRepository {
  final List<ScanRecordModel> scans = [];
  int plantHistoryReadCount = 0;

  @override
  Future<void> saveScanResult(ScanRecordModel record) async {
    scans.add(record);
  }

  @override
  Future<List<ScanRecordModel>> getScansByPlantId(
    String plantId,
    String userId,
  ) async {
    plantHistoryReadCount++;
    return scans
        .where((scan) => scan.plantId == plantId && scan.userId == userId)
        .toList();
  }
}

void main() {
  setUp(() {
    HistoryData.records.clear();
  });

  tearDown(() {
    HistoryData.records.clear();
  });

  testWidgets(
    'halaman hasil deteksi tidak menampilkan persentase akurasi atau confidence indicator',
    (tester) async {
      final selection = InspectionPhotoSelection(
        draft: InspectionDraft(
          plant: const InspectionPlant(
            name: 'Tomat Kebun Belakang',
            id: 'TMT-002',
            location: 'Kebun belakang',
          ),
          inspectionDate: DateTime(2026, 10, 10),
          note: 'Ada bercak pada daun.',
        ),
        source: 'Galeri',
        predictionResult: const PredictionResult(
          label: 'Bacterial_spot',
          confidence: 0.884,
          allScores: {
            'Bacterial_spot': 0.884,
            'Late_blight': 0.05,
            'Leaf_Mold': 0.03,
            'Tomato_Yellow_Leaf_Curl_Virus': 0.02,
            'healthy': 0.016,
          },
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: DetectionResultPage(selection: selection)),
        ),
      );
      await tester.pumpAndSettle();

      // Pastikan informasi esensial tetap tampil
      expect(find.text('Hasil Deteksi'), findsOneWidget);
      expect(find.text('Tomat Kebun Belakang'), findsOneWidget);
      expect(find.text('Bacterial Spot (Bercak Bakteri)'), findsOneWidget);
      expect(find.text('Lihat Penanganan ›'), findsOneWidget);
      expect(find.text('Catatan Model'), findsOneWidget);

      // Pastikan UI TIDAK menampilkan indikator atau teks persentase confidence
      expect(find.byType(ConfidenceIndicator), findsNothing);
      expect(find.textContaining('Tingkat Kepercayaan'), findsNothing);
      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('Akurasi'), findsNothing);

      // Pastikan data internal HistoryRecord tetap menyimpan akurasi
      expect(HistoryData.records.length, 1);
      expect(HistoryData.records.first.accuracy, 88);
      expect(HistoryData.records.first.diseaseName, 'Bacterial Spot');
      expect(HistoryData.records.first.isHealthy, isFalse);
    },
  );

  testWidgets(
    'halaman hasil deteksi untuk kelas sehat tetap mempertahankan nama dan panduan',
    (tester) async {
      final selection = InspectionPhotoSelection(
        draft: InspectionDraft(
          plant: const InspectionPlant(
            name: 'Tomat Hidroponik',
            id: 'TMT-005',
            location: 'Greenhouse',
          ),
          inspectionDate: DateTime(2026, 10, 10),
          note: 'Daun hijau segar.',
        ),
        source: 'Kamera',
        predictionResult: const PredictionResult(
          label: 'healthy',
          confidence: 0.95,
          allScores: {
            'Bacterial_spot': 0.01,
            'Late_blight': 0.01,
            'Leaf_Mold': 0.01,
            'Tomato_Yellow_Leaf_Curl_Virus': 0.02,
            'healthy': 0.95,
          },
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: DetectionResultPage(selection: selection)),
        ),
      );
      await tester.pumpAndSettle();

      // Pastikan tampilan daun sehat
      expect(find.text('Daun Sehat'), findsOneWidget);
      expect(find.text('Daun Tomat Sehat'), findsOneWidget);
      expect(find.text('Lihat Panduan Perawatan ›'), findsOneWidget);

      // Pastikan UI TIDAK menampilkan persentase confidence
      expect(find.byType(ConfidenceIndicator), findsNothing);
      expect(find.textContaining('Tingkat Kepercayaan'), findsNothing);
      expect(find.textContaining('%'), findsNothing);

      // Pastikan data internal HistoryRecord tetap menyimpan akurasi
      expect(HistoryData.records.length, 1);
      expect(HistoryData.records.first.accuracy, 95);
      expect(HistoryData.records.first.isHealthy, isTrue);
    },
  );

  testWidgets('menyegarkan riwayat tanaman setelah scan disimpan', (
    tester,
  ) async {
    final scanRepository = _MemoryScanRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWith(_TestUserIdNotifier.new),
        scanRepositoryProvider.overrideWithValue(scanRepository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(plantScanHistoryProvider('TMT-002').future);
    expect(scanRepository.plantHistoryReadCount, 1);

    final selection = InspectionPhotoSelection(
      draft: InspectionDraft(
        plant: const InspectionPlant(
          name: 'Tomat Kebun Belakang',
          id: 'TMT-002',
          location: 'Kebun belakang',
        ),
        inspectionDate: DateTime(2026, 10, 10),
        note: '',
      ),
      source: 'Kamera',
      predictionResult: const PredictionResult(
        label: 'Leaf_Mold',
        confidence: 0.9,
        allScores: {'Leaf_Mold': 0.9},
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: DetectionResultPage(selection: selection)),
      ),
    );
    await tester.pumpAndSettle();

    final scans = await container.read(
      plantScanHistoryProvider('TMT-002').future,
    );
    expect(scanRepository.plantHistoryReadCount, 2);
    expect(scans.single.diseaseName, 'Leaf Mold');
  });
}

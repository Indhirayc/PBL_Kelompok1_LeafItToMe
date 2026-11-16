import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/tflite_service.dart';
import 'package:mobile_app/features/detection/presentation/pages/data_inspection_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/detection_result_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/photo_preview_page.dart';
import 'package:mobile_app/features/detection/presentation/widgets/confidence_indicator.dart';
import 'package:mobile_app/features/history/data/history_data.dart';

void main() {
  setUp(() {
    HistoryData.records.clear();
  });

  tearDown(() {
    HistoryData.records.clear();
  });

  testWidgets('halaman hasil deteksi tidak menampilkan persentase akurasi atau confidence indicator', (
    tester,
  ) async {
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
      MaterialApp(
        home: DetectionResultPage(selection: selection),
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
    expect(HistoryData.records.first.diseaseName, 'Bacterial_spot');
    expect(HistoryData.records.first.isHealthy, isFalse);
  });

  testWidgets('halaman hasil deteksi untuk kelas sehat tetap mempertahankan nama dan panduan', (
    tester,
  ) async {
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
      MaterialApp(
        home: DetectionResultPage(selection: selection),
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
  });
}

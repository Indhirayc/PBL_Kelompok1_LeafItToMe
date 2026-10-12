import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/history/views/treatment_recommendation_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/data_inspection_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/detection_result_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/photo_preview_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/photo_source_page.dart';

void main() {
  testWidgets('alur sumber foto menuju preview dan hasil contoh', (
    tester,
  ) async {
    final draft = InspectionDraft(
      plant: const InspectionPlant(
        name: 'Tomat Kebun Belakang',
        id: 'TMT-002',
        location: 'Kebun belakang',
      ),
      inspectionDate: DateTime(2026, 10, 10),
      note: 'Ada bercak pada daun.',
    );
    final router = GoRouter(
      initialLocation: '/source',
      routes: [
        GoRoute(
          path: '/source',
          builder: (context, state) => PhotoSourcePage(draft: draft),
        ),
        GoRoute(
          path: '/preview',
          name: 'photo-preview',
          builder: (context, state) => PhotoPreviewPage(
            selection: state.extra! as InspectionPhotoSelection,
          ),
        ),
        GoRoute(
          path: '/result',
          name: 'detection-result',
          builder: (context, state) => DetectionResultPage(
            selection: state.extra! as InspectionPhotoSelection,
          ),
        ),
        GoRoute(
          path: '/treatment',
          name: 'treatment-recommendation',
          builder: (context, state) => TreatmentRecommendationPage(
            record: state.extra! as HistoryRecord,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Pilih sumber gambar daun'), findsOneWidget);
    expect(find.text('Buka Kamera'), findsOneWidget);
    expect(find.text('Pilih dari Galeri'), findsOneWidget);
    expect(find.text('Tips foto yang baik'), findsOneWidget);

    await tester.tap(find.byKey(const Key('gallerySourceButton')));
    await tester.pumpAndSettle();

    expect(find.text('Preview Foto'), findsOneWidget);
    expect(find.text('Sumber: Galeri'), findsOneWidget);
    expect(
      find.text('Pastikan daun terlihat jelas dan tidak buram.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('analyzeNowButton')));
    await tester.tap(find.byKey(const Key('analyzeNowButton')));
    await tester.pumpAndSettle();

    expect(find.text('Hasil Deteksi'), findsOneWidget);
    expect(find.text('Tomat Kebun Belakang'), findsOneWidget);
    expect(find.text('TMT-002  •  Kebun belakang'), findsOneWidget);
    expect(find.text('Contoh klasifikasi'), findsOneWidget);
    expect(find.text('Bacterial Spot'), findsOneWidget);
    expect(
      find.text(
        'Hasil contoh ditambahkan ke riwayat sementara sesi ini; '
        'belum tersimpan permanen.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('saveToHistoryButton')), findsNothing);

    final detectionRecord = HistoryData.records.last;
    expect(detectionRecord.plantId, 'TMT-002');
    expect(detectionRecord.plantName, 'Tomat Kebun Belakang');
    expect(detectionRecord.diseaseName, 'Bacterial Spot');
    expect(detectionRecord.accuracy, 94);
    expect(detectionRecord.date, DateTime(2026, 10, 10));
    expect(detectionRecord.note, 'Ada bercak pada daun.');
    expect(
      detectionRecord.photoAssetPath,
      InspectionPhotoSelection.sampleImageAsset,
    );
    expect(detectionRecord.photoSource, 'Galeri');

    await tester.ensureVisible(find.byKey(const Key('treatmentButton')));
    await tester.tap(find.byKey(const Key('treatmentButton')));
    await tester.pumpAndSettle();

    expect(find.text('Rekomendasi Penanganan'), findsOneWidget);
    expect(find.text('Bacterial Spot'), findsOneWidget);
    expect(
      find.text('Tomat Kebun Belakang  •  10 Oktober 2026'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Gunakan bakterisida berbahan aktif tembaga yang sesuai untuk tomat '
        'dan ikuti petunjuk pada label produk.',
      ),
      findsOneWidget,
    );
  });
}

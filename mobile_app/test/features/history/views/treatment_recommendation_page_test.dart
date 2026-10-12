import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/guide/data/guide_data.dart';
import 'package:mobile_app/features/guide/presentation/pages/disease_detail_page.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/history/views/treatment_recommendation_page.dart';

void main() {
  final record = HistoryData.records.firstWhere(
    (item) => item.diseaseName == 'Bacterial Spot',
  );

  HistoryRecord recordForDisease(String diseaseName) {
    return HistoryRecord(
      id: 'TEST-$diseaseName',
      plantId: record.plantId,
      diseaseName: diseaseName,
      latinName: record.latinName,
      date: record.date,
      accuracy: record.accuracy,
      isHealthy: diseaseName.toLowerCase() == 'healthy',
      note: record.note,
      plantName: record.plantName,
    );
  }

  testWidgets('menampilkan langkah penanganan dan pencegahan', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: TreatmentRecommendationPage(record: record)),
    );

    expect(find.text('Rekomendasi Penanganan'), findsOneWidget);
    expect(find.text('Langkah penanganan dan pencegahan.'), findsOneWidget);
    expect(find.text('Bacterial Spot'), findsOneWidget);
    expect(find.text('Penanganan Awal'), findsOneWidget);
    expect(
      find.text(
        'Pangkas bagian daun yang menunjukkan gejala, lalu buang dengan aman '
        'dan jangan dijadikan kompos.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Lihat di Marketplace'), 300.0);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Pencegahan'), findsOneWidget);
    expect(
      find.text(
        'Siram langsung ke media tanam dan hindari membasahi daun, '
        'terutama pada sore atau malam hari.',
      ),
      findsOneWidget,
    );
    expect(find.text('Lihat Detail Penyakit'), findsOneWidget);
    expect(find.text('Lihat di Marketplace'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('marketplaceButton'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('diseaseDetailButton'))).dy,
      ),
    );
  });

  testWidgets('menampilkan konteks tanaman dan tanggal pemeriksaan', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TreatmentRecommendationPage(record: record)),
    );

    expect(find.text('Tomat Pot Depan  •  18 September 2026'), findsOneWidget);
  });

  for (final diseaseName in [
    'Bacterial Spot',
    'Leaf Mold',
    'Late Blight',
    'Tomato Yellow Leaf Curl Virus',
    ' tomato_yellow-leaf curl virus ',
  ]) {
    testWidgets('membuka detail penyakit $diseaseName yang sesuai', (
      tester,
    ) async {
      final diseaseRecord = recordForDisease(diseaseName);
      final router = GoRouter(
        initialLocation: '/recommendation',
        routes: [
          GoRoute(
            path: '/recommendation',
            builder: (context, state) =>
                TreatmentRecommendationPage(record: diseaseRecord),
          ),
          GoRoute(
            path: '/disease-detail',
            name: 'disease-detail',
            builder: (context, state) =>
                DiseaseDetailPage(disease: state.extra! as DiseaseModel),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('diseaseDetailButton')));
      await tester.tap(find.byKey(const Key('diseaseDetailButton')));
      await tester.pumpAndSettle();

      expect(find.text('Detail Penyakit'), findsOneWidget);
      final normalizedName = diseaseName.trim().toLowerCase();
      final expectedDisease = GuideData.diseases.firstWhere(
        (disease) =>
            disease.name.toLowerCase() == normalizedName ||
            disease.name
                    .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
                    .toLowerCase() ==
                normalizedName.replaceAll('_', ' ').replaceAll('-', ' '),
      );
      expect(
        tester
            .widget<DiseaseDetailPage>(find.byType(DiseaseDetailPage))
            .disease,
        same(expectedDisease),
      );
    });
  }

  testWidgets('menampilkan pesan untuk penyakit yang tidak dikenal', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TreatmentRecommendationPage(
          record: recordForDisease('Unknown Disease'),
        ),
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('diseaseDetailButton')));
    await tester.tap(find.byKey(const Key('diseaseDetailButton')));
    await tester.pump();

    expect(find.text('Detail penyakit belum tersedia.'), findsOneWidget);
    expect(find.text('Rekomendasi Penanganan'), findsOneWidget);
  });

  testWidgets('menampilkan pesan untuk hasil sehat tanpa membuka detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TreatmentRecommendationPage(record: recordForDisease('Healthy')),
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('diseaseDetailButton')));
    await tester.tap(find.byKey(const Key('diseaseDetailButton')));
    await tester.pump();

    expect(find.text('Daun sehat. Tidak ada detail penyakit.'), findsOneWidget);
    expect(find.text('Rekomendasi Penanganan'), findsOneWidget);
  });
}

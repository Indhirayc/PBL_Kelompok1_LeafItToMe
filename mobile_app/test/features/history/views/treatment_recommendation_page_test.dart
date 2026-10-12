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

  testWidgets('menampilkan langkah penanganan dan pencegahan', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: TreatmentRecommendationPage(record: record)),
    );

    expect(find.text('Rekomendasi Penanganan'), findsOneWidget);
    expect(find.text('Langkah penanganan dan pencegahan.'), findsOneWidget);
    expect(find.text('Bacterial Spot'), findsOneWidget);
    expect(find.text('Penanganan Awal'), findsOneWidget);
    expect(find.text('Pangkas dan buang daun yang terinfeksi'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Lihat di Marketplace'), 300.0);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Pencegahan'), findsOneWidget);
    expect(find.text('Hindari menyiram bagian daun'), findsOneWidget);
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

  for (final diseaseName in ['Bacterial Spot', 'Leaf Mold', 'Late Blight']) {
    testWidgets('membuka detail penyakit $diseaseName yang sesuai', (
      tester,
    ) async {
      final diseaseRecord = HistoryData.records.firstWhere(
        (item) => item.diseaseName == diseaseName,
      );
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
      expect(find.text(diseaseName), findsOneWidget);
    });
  }
}

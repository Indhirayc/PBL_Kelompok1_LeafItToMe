import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    await tester.scrollUntilVisible(find.text('Cari Produk Penanganan'), 300.0);

    expect(find.text('Pencegahan'), findsOneWidget);
    expect(find.text('Hindari menyiram bagian daun'), findsOneWidget);
    expect(find.text('Lihat Detail Penyakit'), findsOneWidget);
    expect(find.text('Cari Produk Penanganan'), findsOneWidget);
  });

  testWidgets('menampilkan konteks tanaman dan tanggal pemeriksaan', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TreatmentRecommendationPage(record: record)),
    );

    expect(find.text('Tomat Pot Depan  •  18 September 2026'), findsOneWidget);
  });
}

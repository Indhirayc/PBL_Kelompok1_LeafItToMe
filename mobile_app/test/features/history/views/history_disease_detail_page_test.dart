import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/history/views/disease_detail_page.dart';

void main() {
  final record = HistoryData.records.firstWhere(
    (item) => item.diseaseName == 'Bacterial Spot',
  );

  testWidgets('menampilkan detail penyakit beserta kategori dan risiko', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HistoryDiseaseDetailPage(record: record)),
    );

    expect(find.text('Detail Penyakit'), findsOneWidget);
    expect(find.text('Gejala dan cara pencegahan.'), findsOneWidget);
    expect(find.text('Bacterial Spot'), findsOneWidget);
    expect(find.text('Xanthomonas spp.'), findsOneWidget);
    expect(find.text('Bakteri'), findsOneWidget);
    expect(find.text('Risiko Sedang'), findsWidgets);
    expect(find.text('Gejala'), findsOneWidget);
    expect(find.text('Bercak cokelat kehitaman pada daun'), findsOneWidget);
  });

  testWidgets('menampilkan pencegahan dan tombol marketplace', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HistoryDiseaseDetailPage(record: record)),
    );

    await tester.scrollUntilVisible(find.text('Lihat di Marketplace'), 300.0);

    expect(find.text('Pencegahan'), findsOneWidget);
    expect(find.text('Gunakan benih bebas penyakit'), findsOneWidget);
    expect(find.text('Lihat di Marketplace'), findsOneWidget);
  });
}

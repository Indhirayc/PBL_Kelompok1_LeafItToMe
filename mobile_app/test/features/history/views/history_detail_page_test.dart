import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/history/views/history_detail_page.dart';

void main() {
  testWidgets('menampilkan rincian riwayat tanaman sehat', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HistoryDetailPage(record: HistoryData.records.first)),
    );

    expect(find.text('Detail Riwayat'), findsOneWidget);
    expect(find.text('Rincian hasil pemeriksaan tanaman.'), findsOneWidget);
    expect(find.text('Hasil Deteksi'), findsOneWidget);
    expect(find.text('Healthy'), findsOneWidget);
    expect(find.text('Solanum lycopersicum'), findsOneWidget);
    expect(find.text('Tingkat keyakinan 96%'), findsOneWidget);
    expect(find.text('Kondisi Sehat'), findsOneWidget);
    expect(find.text('Tomat Pot Depan'), findsOneWidget);
    expect(find.text('TMT-001'), findsWidgets);
    expect(find.text('Teras depan'), findsOneWidget);
    expect(find.text('28 September 2026'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Lihat Rekomendasi Penanganan'),
      300.0,
    );
    expect(find.text('Lihat Rekomendasi Penanganan'), findsOneWidget);
  });

  testWidgets('menampilkan status risiko untuk riwayat penyakit', (
    tester,
  ) async {
    final diseased = HistoryData.records.firstWhere(
      (record) => record.diseaseName == 'Bacterial Spot',
    );

    await tester.pumpWidget(
      MaterialApp(home: HistoryDetailPage(record: diseased)),
    );

    expect(find.text('Bacterial Spot'), findsOneWidget);
    expect(find.text('Xanthomonas spp.'), findsOneWidget);
    expect(find.text('Risiko Sedang'), findsOneWidget);
    expect(find.text('Tingkat keyakinan 89%'), findsOneWidget);
  });
}

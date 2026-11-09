import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/sync/views/sync_result_page.dart';

void main() {
  const testPlant = HistoryPlant(
    id: 'TMT-002',
    name: 'Tomat Kebun Belakang',
    location: 'Kebun belakang',
  );

  testWidgets('menampilkan hasil sinkronisasi berhasil', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SyncResultPage(plant: testPlant, isFailure: false),
      ),
    );

    expect(find.text('Sinkronisasi Data'), findsOneWidget);
    expect(find.text('Hasil proses sinkronisasi data.'), findsOneWidget);
    expect(find.text('Sinkronisasi Berhasil'), findsOneWidget);
    expect(
      find.text(
        '3 data pemeriksaan berhasil disinkronkan ke penyimpanan cloud.',
      ),
      findsOneWidget,
    );
    expect(find.text('Kembali ke Riwayat'), findsOneWidget);
  });

  testWidgets('menampilkan hasil gagal beserta tombol coba lagi', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SyncResultPage(plant: testPlant, isFailure: true),
      ),
    );

    expect(find.text('Sinkronisasi Gagal'), findsOneWidget);
    expect(
      find.text(
        'Koneksi terputus saat mengunggah data. '
        'Periksa internet lalu coba lagi.',
      ),
      findsOneWidget,
    );
    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);
  });
}

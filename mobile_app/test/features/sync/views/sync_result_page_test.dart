import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/sync/sync_manager.dart';
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
        home: SyncResultPage(
          plant: testPlant,
          userId: 'user-local',
          result: SyncBatchResult(
            syncedIds: ['S-001', 'S-002', 'S-003'],
            failedIds: [],
          ),
        ),
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
        home: SyncResultPage(
          plant: testPlant,
          userId: 'user-local',
          result: SyncBatchResult(
            syncedIds: [],
            failedIds: ['S-001'],
            errors: ['S-001: offline'],
          ),
        ),
      ),
    );

    expect(find.text('Sinkronisasi Gagal'), findsOneWidget);
    expect(
      find.text(
        '1 data masih menunggu sinkronisasi. Lihat detail kegagalan di bawah.',
      ),
      findsOneWidget,
    );
    expect(find.text('Detail kegagalan'), findsOneWidget);
    expect(find.text('S-001: offline'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);
  });
}

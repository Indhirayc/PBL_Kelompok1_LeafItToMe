import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/providers/database_providers.dart';
import 'package:mobile_app/data/models/scan_record_model.dart';
import 'package:mobile_app/features/sync/views/sync_status_page.dart';

import '../fake_scan_repository.dart';

void main() {
  final scanRepository = FakeScanRepository(
    pendingScans: [
      ScanRecordModel(
        id: 'S-001',
        userId: 'user-local',
        plantName: 'Tomat Pot Depan',
        diseaseName: 'Bacterial Spot',
        confidence: 0.9,
        localImagePath: '',
        scannedAt: DateTime(2026, 9, 18),
      ),
      ScanRecordModel(
        id: 'S-002',
        userId: 'user-local',
        plantName: 'Tomat Kebun Belakang',
        diseaseName: 'Leaf Mold',
        confidence: 0.9,
        localImagePath: '',
        scannedAt: DateTime(2026, 9, 26),
      ),
      ScanRecordModel(
        id: 'S-003',
        userId: 'user-local',
        plantName: 'Tomat Kebun Belakang',
        diseaseName: 'Late Blight',
        confidence: 0.9,
        localImagePath: '',
        scannedAt: DateTime(2026, 9, 12),
      ),
    ],
  );

  testWidgets('menampilkan status offline dan daftar data belum tersinkron', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [scanRepositoryProvider.overrideWithValue(scanRepository)],
        child: const MaterialApp(home: SyncStatusPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sinkronisasi Data'), findsOneWidget);
    expect(
      find.text('Kelola data pemeriksaan yang belum tersinkron.'),
      findsOneWidget,
    );
    expect(find.text('Mode Offline Aktif'), findsOneWidget);
    expect(find.text('Mode offline'), findsOneWidget);
    expect(find.text('3 data belum disinkronkan'), findsOneWidget);
    expect(find.text('Tomat Pot Depan'), findsOneWidget);
    expect(find.text('Bacterial Spot  •  18 Sep 2026'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Simulasikan sinkronisasi gagal'),
      300.0,
    );
    expect(find.text('Simulasikan sinkronisasi gagal'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Sinkronkan Sekarang'), 300.0);
    expect(find.text('Sinkronkan Sekarang'), findsOneWidget);
  });

  testWidgets('mengubah mode offline menjadi online', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [scanRepositoryProvider.overrideWithValue(scanRepository)],
        child: const MaterialApp(home: SyncStatusPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mode Offline Aktif'), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('Mode Online Aktif'), findsOneWidget);
    expect(find.text('Mode Offline Aktif'), findsNothing);
  });
}

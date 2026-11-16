import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/providers/database_providers.dart';
import 'package:mobile_app/core/sync/sync_manager.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/sync/data/sync_data.dart';
import 'package:mobile_app/features/sync/views/sync_process_page.dart';
import 'package:mobile_app/features/sync/views/sync_result_page.dart';

import '../fake_scan_repository.dart';

void main() {
  const testPlant = HistoryPlant(
    id: 'TMT-002',
    name: 'Tomat Kebun Belakang',
    location: 'Kebun belakang',
  );
  final pendingItem = SyncItem(
    id: 'scan-1',
    plantName: 'Tomat Kebun Belakang',
    diseaseName: 'Late Blight',
    date: DateTime(2026, 11, 16),
  );
  final scanRepository = FakeScanRepository(
    syncResult: const SyncBatchResult(syncedIds: ['scan-1'], failedIds: []),
  );

  testWidgets('menampilkan progres lalu lanjut ke hasil sinkronisasi', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/sync-process',
      routes: [
        GoRoute(
          path: '/sync-process',
          name: 'sync-process',
          builder: (context, state) {
            return SyncProcessPage(
              plant: testPlant,
              userId: 'user-local',
              items: [pendingItem],
            );
          },
        ),
        GoRoute(
          path: '/sync-result',
          name: 'sync-result',
          builder: (context, state) {
            final extra = state.extra;

            HistoryPlant plant = testPlant;
            var userId = 'user-local';
            var result = const SyncBatchResult(syncedIds: [], failedIds: []);

            if (extra is Map<String, dynamic>) {
              final plantData = extra['plant'];
              final userIdData = extra['userId'];
              final resultData = extra['result'];

              if (plantData is HistoryPlant) {
                plant = plantData;
              }
              if (userIdData is String) {
                userId = userIdData;
              }
              if (resultData is SyncBatchResult) {
                result = resultData;
              }
            }

            return SyncResultPage(plant: plant, userId: userId, result: result);
          },
        ),
        GoRoute(
          path: '/history',
          name: 'history',
          builder: (context, state) {
            return const Scaffold(body: Center(child: Text('Halaman Riwayat')));
          },
        ),
      ],
    );

    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [scanRepositoryProvider.overrideWithValue(scanRepository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Menyinkronkan Data'), findsOneWidget);
    expect(find.text('Sedang mengunggah data pemeriksaan.'), findsOneWidget);
    expect(find.text('Mengirim data ke penyimpanan cloud...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);

    // Menyelesaikan animasi sinkronisasi selama 6 detik.
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();

    expect(find.text('Sinkronisasi Berhasil'), findsOneWidget);
    expect(find.text('Kembali ke Riwayat'), findsOneWidget);
    expect(
      find.text(
        '1 data pemeriksaan berhasil disinkronkan ke penyimpanan cloud.',
      ),
      findsOneWidget,
    );
    expect(scanRepository.syncCallCount, 1);
  });
}

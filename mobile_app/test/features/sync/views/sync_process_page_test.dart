import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/sync/views/sync_process_page.dart';
import 'package:mobile_app/features/sync/views/sync_result_page.dart';

void main() {
  const testPlant = HistoryPlant(
    id: 'TMT-002',
    name: 'Tomat Kebun Belakang',
    location: 'Kebun belakang',
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
            return const SyncProcessPage(plant: testPlant, isFailure: false);
          },
        ),
        GoRoute(
          path: '/sync-result',
          name: 'sync-result',
          builder: (context, state) {
            final extra = state.extra;

            HistoryPlant plant = testPlant;
            bool isFailure = false;

            if (extra is Map<String, dynamic>) {
              final plantData = extra['plant'];
              final failureData = extra['isFailure'];

              if (plantData is HistoryPlant) {
                plant = plantData;
              }

              if (failureData is bool) {
                isFailure = failureData;
              }
            }

            return SyncResultPage(plant: plant, isFailure: isFailure);
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

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Menyinkronkan Data'), findsOneWidget);
    expect(find.text('Sedang mengunggah data pemeriksaan.'), findsOneWidget);
    expect(find.text('Mengunggah data pemeriksaan...'), findsOneWidget);
    expect(find.textContaining('%'), findsOneWidget);

    // Menyelesaikan animasi sinkronisasi selama 6 detik.
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();

    expect(find.text('Sinkronisasi Berhasil'), findsOneWidget);
    expect(find.text('Kembali ke Riwayat'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/sync/views/sync_process_page.dart';
import 'package:mobile_app/features/sync/views/sync_result_page.dart';

void main() {
  testWidgets('menampilkan progres lalu lanjut ke hasil sinkronisasi', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/sync-process',
      routes: [
        GoRoute(
          path: '/sync-process',
          builder: (context, state) => const SyncProcessPage(),
        ),
        GoRoute(
          path: '/sync-result',
          name: 'sync-result',
          builder: (context, state) =>
              SyncResultPage(isFailure: state.extra as bool? ?? false),
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

    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();

    expect(find.text('Sinkronisasi Berhasil'), findsOneWidget);
    expect(find.text('Kembali ke Riwayat'), findsOneWidget);
  });
}
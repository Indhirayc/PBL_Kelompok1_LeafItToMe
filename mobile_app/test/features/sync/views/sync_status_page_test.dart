import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/sync/views/sync_status_page.dart';

void main() {
  testWidgets('menampilkan status offline dan daftar data belum tersinkron', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SyncStatusPage()));

    expect(find.text('Sinkronisasi Data'), findsOneWidget);
    expect(
      find.text('Kelola data pemeriksaan yang belum tersinkron.'),
      findsOneWidget,
    );
    expect(find.text('Anda Sedang Offline'), findsOneWidget);
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
    await tester.pumpWidget(const MaterialApp(home: SyncStatusPage()));

    expect(find.text('Anda Sedang Offline'), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('Anda Sudah Online'), findsOneWidget);
    expect(find.text('Anda Sedang Offline'), findsNothing);
  });
}

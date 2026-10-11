import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/sync/views/sync_process_page.dart';

void main() {
  testWidgets('menampilkan progres dan data yang sedang diunggah', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SyncProcessPage()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Menyinkronkan Data'), findsOneWidget);
    expect(find.text('Sedang mengunggah data pemeriksaan.'), findsOneWidget);
    expect(find.text('Mengunggah data pemeriksaan...'), findsOneWidget);
    expect(
      find.text('Jangan tutup aplikasi selama proses berlangsung.'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('%'), findsOneWidget);

    await tester.pump(const Duration(seconds: 7));
    expect(find.text('100%'), findsOneWidget);
  });
}
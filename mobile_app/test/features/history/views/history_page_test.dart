import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/history/views/history_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('menampilkan riwayat untuk tanaman yang dipilih', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistedHistoryProvider('user-local').overrideWith((ref) async {}),
        ],
        child: const MaterialApp(home: HistoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Pemeriksaan'), findsOneWidget);
    expect(find.text('Hasil pemeriksaan untuk tanaman ini.'), findsOneWidget);
    expect(find.text('Tomat Pot Depan'), findsOneWidget);
    expect(find.text('Teras depan'), findsOneWidget);
    expect(find.text('Healthy'), findsNWidgets(2));
    expect(find.text('Bacterial Spot'), findsOneWidget);
  });

  testWidgets('menyaring riwayat sesuai tanaman yang dikirim', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistedHistoryProvider('user-local').overrideWith((ref) async {}),
        ],
        child: MaterialApp(home: HistoryPage(plant: HistoryData.plants[1])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tomat Kebun Belakang'), findsOneWidget);
    expect(find.text('Healthy'), findsOneWidget);
    expect(find.text('Leaf Mold'), findsOneWidget);
    expect(find.text('Late Blight'), findsOneWidget);
    expect(find.text('Bacterial Spot'), findsNothing);
  });
}

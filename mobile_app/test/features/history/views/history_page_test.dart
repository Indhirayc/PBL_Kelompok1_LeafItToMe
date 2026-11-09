import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/history/views/history_page.dart';

void main() {
  testWidgets('menampilkan riwayat untuk tanaman yang dipilih', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HistoryPage()));

    expect(find.text('Riwayat Pemeriksaan'), findsOneWidget);
    expect(find.text('Hasil pemeriksaan untuk tanaman ini.'), findsOneWidget);
    expect(find.text('Tomat Pot Depan'), findsOneWidget);
    expect(find.text('TMT-001  •  Teras depan'), findsOneWidget);
    expect(find.text('Healthy'), findsNWidgets(2));
    expect(find.text('Bacterial Spot'), findsOneWidget);
  });

  testWidgets('menyaring riwayat sesuai tanaman yang dikirim', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HistoryPage(plant: HistoryData.plants[1])),
    );

    expect(find.text('Tomat Kebun Belakang'), findsOneWidget);
    expect(find.text('Healthy'), findsOneWidget);
    expect(find.text('Leaf Mold'), findsOneWidget);
    expect(find.text('Late Blight'), findsOneWidget);
    expect(find.text('Bacterial Spot'), findsNothing);
  });
}

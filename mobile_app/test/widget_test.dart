import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets(
    'Splash screen menampilkan identitas LeafItToMe',
    (WidgetTester tester) async {
      // Menjalankan aplikasi.
      await tester.pumpWidget(const LeafItToMeApp());

      // Menjalankan frame pertama tanpa menunggu timer selesai.
      await tester.pump();

      // Memastikan identitas aplikasi tampil.
      expect(find.text('LeafItToMe'), findsOneWidget);
      expect(
        find.text('Kenali Daunnya, Jaga Tanamannya'),
        findsOneWidget,
      );
      expect(find.text('Memuat...'), findsOneWidget);

      // Memastikan halaman counter bawaan sudah tidak tampil.
      expect(find.text('Flutter Demo Home Page'), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);

      // Menghapus widget agar Timer dan AnimationController dihentikan.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
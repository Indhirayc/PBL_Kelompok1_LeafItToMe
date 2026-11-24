import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/profile/presentation/pages/personal_information_page.dart';
import 'package:mobile_app/features/profile/presentation/pages/profile_page.dart';

void main() {
  testWidgets('PersonalInformationPage menampilkan avatar profil dan opsi ganti foto', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: PersonalInformationPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.byKey(const Key('profilePhotoAvatar')), findsOneWidget);
    expect(find.byKey(const Key('editProfilePhotoButton')), findsOneWidget);

    // Buka modal bottom sheet foto
    await tester.tap(find.byKey(const Key('editProfilePhotoButton')));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Foto Profil'), findsNWidgets(2));
    expect(find.text('Ambil dari kamera'), findsOneWidget);
    expect(find.text('Pilih dari galeri'), findsOneWidget);
  });

  testWidgets('ProfilePage menampilkan overview card dan tombol navigasi Edit Profil', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Profil')), findsOneWidget);
    expect(find.byKey(const Key('profileOverviewCard')), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
  });

  testWidgets('PersonalInformationPage mengizinkan nomor telepon kosong (opsional)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: PersonalInformationPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Isi nama dan email valid, kosongkan nomor telepon
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(3));

    await tester.enterText(textFields.at(0), 'Budi Santoso');
    await tester.enterText(textFields.at(1), 'budi@example.com');
    await tester.enterText(textFields.at(2), ''); // Phone empty

    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    // Tidak ada pesan error 'Nomor telepon wajib diisi'
    expect(find.text('Nomor telepon wajib diisi.'), findsNothing);
  });
}

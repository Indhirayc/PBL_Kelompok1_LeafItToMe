import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/detection/presentation/pages/data_inspection_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/photo_source_page.dart';

void main() {
  testWidgets('memilih kamera atau galeri menandai sumber pilihan', (
    tester,
  ) async {
    final draft = InspectionDraft(
      plant: const InspectionPlant(
        name: 'Tomat Uji',
        id: 'TMT-123',
        location: 'Kebun',
      ),
      inspectionDate: DateTime(2026, 10, 10),
      note: 'Ada bercak pada daun.',
    );

    await tester.pumpWidget(MaterialApp(home: PhotoSourcePage(draft: draft)));

    expect(find.text('Deteksi Daun Tomat'), findsOneWidget);
    expect(find.text('Pilih sumber gambar daun'), findsOneWidget);
    expect(find.text('Buka Kamera'), findsOneWidget);
    expect(find.text('Pilih dari Galeri'), findsOneWidget);
    expect(find.text('Tips foto yang baik'), findsOneWidget);
    expect(find.byKey(const Key('selectedPhotoSourceLabel')), findsNothing);

    await tester.tap(find.byKey(const Key('gallerySourceButton')));
    await tester.pumpAndSettle();

    expect(find.text('Pilih sumber gambar daun'), findsOneWidget);
    expect(find.text('Sumber dipilih: Galeri'), findsOneWidget);
    expect(find.byKey(const Key('cameraSourceButton')), findsOneWidget);
  });
}

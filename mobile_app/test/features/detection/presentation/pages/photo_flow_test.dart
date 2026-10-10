import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/detection/presentation/pages/data_inspection_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/detection_result_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/photo_preview_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/photo_source_page.dart';

void main() {
  testWidgets('alur sumber foto menuju preview dan hasil contoh', (
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
    final router = GoRouter(
      initialLocation: '/source',
      routes: [
        GoRoute(
          path: '/source',
          builder: (context, state) => PhotoSourcePage(draft: draft),
        ),
        GoRoute(
          path: '/preview',
          name: 'photo-preview',
          builder: (context, state) => PhotoPreviewPage(
            selection: state.extra! as InspectionPhotoSelection,
          ),
        ),
        GoRoute(
          path: '/result',
          name: 'detection-result',
          builder: (context, state) => DetectionResultPage(
            selection: state.extra! as InspectionPhotoSelection,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Pilih sumber gambar daun'), findsOneWidget);
    expect(find.text('Buka Kamera'), findsOneWidget);
    expect(find.text('Pilih dari Galeri'), findsOneWidget);
    expect(find.text('Tips foto yang baik'), findsOneWidget);

    await tester.tap(find.byKey(const Key('gallerySourceButton')));
    await tester.pumpAndSettle();

    expect(find.text('Preview Foto'), findsOneWidget);
    expect(find.text('Sumber: Galeri'), findsOneWidget);
    expect(
      find.text('Pastikan daun terlihat jelas dan tidak buram.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('analyzeNowButton')));
    await tester.tap(find.byKey(const Key('analyzeNowButton')));
    await tester.pumpAndSettle();

    expect(find.text('Hasil Deteksi'), findsOneWidget);
    expect(find.text('Tomat Uji'), findsOneWidget);
    expect(find.text('TMT-123  •  Kebun'), findsOneWidget);
    expect(find.text('Contoh klasifikasi'), findsOneWidget);
    expect(find.text('Bacterial Spot'), findsOneWidget);
    expect(
      find.text(
        'Hasil di atas hanya contoh tampilan, bukan hasil analisis foto.',
      ),
      findsOneWidget,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/detection/presentation/pages/data_inspection_page.dart';
import 'package:mobile_app/features/plants/views/plant_detail_page.dart';
import 'package:mobile_app/features/plants/views/plant_list_page.dart';

void main() {
  testWidgets('menampilkan data tanaman, tanggal, dan catatan saja', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DataInspectionPage(
          plant: InspectionPlant(
            name: 'Tomat Uji',
            id: 'TMT-123',
            location: 'Kebun',
          ),
        ),
      ),
    );

    expect(find.text('Data Pemeriksaan'), findsOneWidget);
    expect(find.text('Tomat Uji'), findsOneWidget);
    expect(find.text('TMT-123  •  Kebun'), findsOneWidget);
    expect(find.text('Tanggal pemeriksaan'), findsOneWidget);
    expect(find.text('Catatan tambahan (opsional)'), findsOneWidget);
    expect(find.byKey(const Key('inspectionNoteField')), findsOneWidget);
    expect(find.text('Bagian yang diperiksa'), findsNothing);
    expect(find.text('Gejala yang terlihat'), findsNothing);
  });

  testWidgets('tanggal pemeriksaan membuka date picker', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DataInspectionPage()));

    await tester.tap(find.byKey(const Key('inspectionDateField')));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('tombol lanjut meneruskan draft pemeriksaan', (tester) async {
    InspectionDraft? receivedDraft;
    final router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(
          path: '/form',
          builder: (context, state) => const DataInspectionPage(
            plant: InspectionPlant(
              name: 'Tomat Uji',
              id: 'TMT-123',
              location: 'Kebun',
            ),
          ),
        ),
        GoRoute(
          path: '/photo-source',
          name: 'photo-source',
          builder: (context, state) {
            receivedDraft = state.extra! as InspectionDraft;
            return const Scaffold(body: Text('Draft diterima'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.enterText(
      find.byKey(const Key('inspectionNoteField')),
      'Ada bercak pada daun.',
    );
    await tester.tap(find.byKey(const Key('continueToPhotoButton')));
    await tester.pumpAndSettle();

    expect(find.text('Draft diterima'), findsOneWidget);
    expect(receivedDraft?.plant.id, 'TMT-123');
    expect(receivedDraft?.note, 'Ada bercak pada daun.');
  });

  testWidgets('tombol Scan Daun membawa tanaman terpilih ke form', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/plant-detail',
      routes: [
        GoRoute(
          path: '/plant-detail',
          builder: (context, state) => PlantDetailPage(
            plant: Plant(
              id: 'TMT-456',
              name: 'Tomat Balkon',
              location: 'Balkon',
              plantDate: '1 Okt 2026',
              status: 'Sehat',
            ),
          ),
        ),
        GoRoute(
          path: '/data-inspection',
          name: 'data-inspection',
          builder: (context, state) =>
              DataInspectionPage(plant: state.extra! as InspectionPlant),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.byKey(const Key('scanPlantButton')));
    await tester.pumpAndSettle();

    expect(find.text('Data Pemeriksaan'), findsOneWidget);
    expect(find.text('Tomat Balkon'), findsOneWidget);
    expect(find.text('TMT-456  •  Balkon'), findsOneWidget);
  });
}

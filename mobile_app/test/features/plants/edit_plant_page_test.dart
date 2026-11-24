import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/providers/database_providers.dart';
import 'package:mobile_app/data/repositories/plant_repository.dart';
import 'package:mobile_app/features/plants/models/plant.dart';
import 'package:mobile_app/features/plants/views/edit_plant_page.dart';

class _FakePlantRepository extends PlantRepository {
  _FakePlantRepository(this.plants);

  final List<Plant> plants;

  @override
  Future<List<Plant>> getAll({String userId = 'user-local'}) async =>
      List.of(plants.where((p) => p.userId == userId));

  @override
  Future<int> update(Plant plant) async {
    final index = plants.indexWhere((p) => p.id == plant.id);
    if (index < 0) return 0;
    plants[index] = plant;
    return 1;
  }
}

class _TestUserIdNotifier extends CurrentUserIdNotifier {
  @override
  String build() => 'user-local';
}

void main() {
  const initialPlant = Plant(
    id: 'TMT-001',
    name: 'Tomat Mawar',
    location: 'Teras Belakang',
    plantedDate: '15 Oktober 2026',
    lastInspectionDate: 'Belum ada pemeriksaan',
    status: 'Sehat',
    note: 'Media tanam subur',
  );

  testWidgets('menampilkan data awal tanaman pada form edit', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final plants = [initialPlant];
    final repo = _FakePlantRepository(plants);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plantRepositoryProvider.overrideWithValue(repo),
          currentUserIdProvider.overrideWith(() => _TestUserIdNotifier()),
        ],
        child: const MaterialApp(
          home: EditPlantPage(plantId: 'TMT-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Profil Tanaman'), findsOneWidget);
    expect(find.text('Tomat Mawar'), findsOneWidget);
    expect(find.text('Teras Belakang'), findsOneWidget);
    expect(find.text('15 Oktober 2026'), findsOneWidget);
    expect(find.text('Media tanam subur'), findsOneWidget);
  });

  testWidgets('validasi form jika nama tanaman dikosongkan', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final plants = [initialPlant];
    final repo = _FakePlantRepository(plants);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plantRepositoryProvider.overrideWithValue(repo),
          currentUserIdProvider.overrideWith(() => _TestUserIdNotifier()),
        ],
        child: const MaterialApp(
          home: EditPlantPage(plantId: 'TMT-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Kosongkan nama tanaman
    final nameFinder = find.widgetWithText(TextFormField, 'Tomat Mawar');
    await tester.enterText(nameFinder, '');
    await tester.pumpAndSettle();

    // Klik simpan
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveEditPlantButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveEditPlantButton')));
    await tester.pumpAndSettle();

    expect(find.text('Nama wajib diisi'), findsOneWidget);
  });

  testWidgets('berhasil memperbarui data profil tanaman', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final plants = [initialPlant];
    final repo = _FakePlantRepository(plants);

    final router = GoRouter(
      initialLocation: '/plants/TMT-001/edit',
      routes: [
        GoRoute(
          path: '/plants/:plantId/edit',
          name: 'edit-plant',
          builder: (context, state) =>
              EditPlantPage(plantId: state.pathParameters['plantId']!),
        ),
        GoRoute(
          path: '/plants/:plantId',
          name: 'plant-detail',
          builder: (context, state) =>
              Scaffold(body: Text('Detail ${state.pathParameters['plantId']}')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plantRepositoryProvider.overrideWithValue(repo),
          currentUserIdProvider.overrideWith(() => _TestUserIdNotifier()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Edit nama dan lokasi
    final nameFinder = find.widgetWithText(TextFormField, 'Tomat Mawar');
    await tester.enterText(nameFinder, 'Tomat Ceri Super');

    final locationFinder = find.widgetWithText(TextFormField, 'Teras Belakang');
    await tester.enterText(locationFinder, 'Greenhouse 2');

    await tester.pumpAndSettle();

    // Simpan perubahan
    await tester.scrollUntilVisible(
      find.byKey(const Key('saveEditPlantButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveEditPlantButton')));
    await tester.pumpAndSettle();

    // Verifikasi data di repository terupdate
    expect(repo.plants.first.name, 'Tomat Ceri Super');
    expect(repo.plants.first.location, 'Greenhouse 2');
    expect(find.text('Profil tanaman berhasil diperbarui.'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/plants/models/plant.dart';
import 'package:mobile_app/features/plants/providers/plant_provider.dart';
import 'package:mobile_app/features/plants/views/add_plant_page.dart';
import 'package:mobile_app/features/plants/views/plant_detail_page.dart';
import 'package:mobile_app/features/plants/views/plant_list_page.dart';

class _ConfiguredPlantNotifier extends PlantNotifier {
  _ConfiguredPlantNotifier(this.plants);

  final List<Plant> plants;

  @override
  Future<List<Plant>> build() async => plants;
}

class _FailingPlantNotifier extends PlantNotifier {
  @override
  Future<List<Plant>> build() async {
    throw StateError('Plant provider test error');
  }
}

Plant _plant({String id = 'TMT-010', String name = 'Tomat Uji'}) {
  return Plant(
    id: id,
    name: name,
    location: 'Teras',
    plantedDate: '12 Okt 2026',
    lastInspectionDate: 'Belum ada pemeriksaan',
    status: 'Sehat',
  );
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/plants',
    routes: [
      GoRoute(
        path: '/plants',
        name: 'plants',
        builder: (context, state) => const PlantListPage(),
      ),
      GoRoute(
        path: '/plants/add',
        name: 'add-plant',
        builder: (context, state) => AddPlantPage(
          nextId: state.extra is String ? state.extra! as String : null,
        ),
      ),
      GoRoute(
        path: '/plants/:plantId',
        name: 'plant-detail',
        builder: (context, state) =>
            PlantDetailPage(plantId: state.pathParameters['plantId']!),
      ),
    ],
  );
}

Future<void> _pumpPlantsPage(
  WidgetTester tester, {
  required AsyncNotifierProvider<PlantNotifier, List<Plant>> provider,
  required PlantNotifier Function() notifier,
}) async {
  final router = _router();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [provider.overrideWith(notifier)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  testWidgets('menampilkan loading saat daftar tanaman dimuat', (tester) async {
    await _pumpPlantsPage(
      tester,
      provider: plantProvider,
      notifier: PlantNotifier.new,
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 450));
  });

  testWidgets('menampilkan data tanaman saat provider berhasil', (
    tester,
  ) async {
    await _pumpPlantsPage(
      tester,
      provider: plantProvider,
      notifier: () => _ConfiguredPlantNotifier([_plant()]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tomat Uji'), findsOneWidget);
    expect(find.text('Total Tanaman'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
  });

  testWidgets('menampilkan empty state saat tidak ada tanaman', (tester) async {
    await _pumpPlantsPage(
      tester,
      provider: plantProvider,
      notifier: () => _ConfiguredPlantNotifier(const []),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Belum ada data tanaman'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(3));
  });

  testWidgets('menampilkan tombol coba lagi jika provider gagal', (
    tester,
  ) async {
    await _pumpPlantsPage(
      tester,
      provider: plantProvider,
      notifier: _FailingPlantNotifier.new,
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Tanaman belum dapat dimuat. Silakan coba lagi.'),
      findsOneWidget,
    );
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('detail tanaman dan tombol kembali memakai route named', (
    tester,
  ) async {
    await _pumpPlantsPage(
      tester,
      provider: plantProvider,
      notifier: () =>
          _ConfiguredPlantNotifier([_plant(id: 'TMT-010', name: 'Tomat Uji')]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lihat Detail').first);
    await tester.pumpAndSettle();

    expect(find.text('Detail Tanaman'), findsOneWidget);
    expect(find.text('Tomat Uji'), findsOneWidget);

    await tester.tap(find.byTooltip('Kembali').first);
    await tester.pumpAndSettle();

    expect(find.text('Tanamanku'), findsAtLeastNWidgets(1));
    expect(find.text('Tomat Uji'), findsOneWidget);
  });

  testWidgets('detail tanpa ID yang cocok menampilkan state tidak ditemukan', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    router.go('/plants/TMT-404');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plantProvider.overrideWith(() => _ConfiguredPlantNotifier(const [])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Data tanaman tidak ditemukan'), findsOneWidget);
    expect(find.text('Kembali ke Tanamanku'), findsOneWidget);

    await tester.tap(find.text('Kembali ke Tanamanku'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Belum ada data tanaman'), findsOneWidget);
  });

  testWidgets('hapus dari detail menghapus tanaman dan kembali ke daftar', (
    tester,
  ) async {
    await _pumpPlantsPage(
      tester,
      provider: plantProvider,
      notifier: () =>
          _ConfiguredPlantNotifier([_plant(id: 'TMT-010', name: 'Tomat Uji')]),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Detail').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Hapus Tanaman'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Tanamanku'), findsAtLeastNWidgets(1));
    expect(find.text('Tomat Uji'), findsNothing);
    expect(find.textContaining('Belum ada data tanaman'), findsOneWidget);
  });

  testWidgets('tanaman baru tersimpan ke provider dan langsung tampil', (
    tester,
  ) async {
    await _pumpPlantsPage(
      tester,
      provider: plantProvider,
      notifier: () => _ConfiguredPlantNotifier(const []),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Tomat Baru');
    await tester.enterText(find.byType(TextFormField).at(1), 'Balkon');
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Tanaman'));
    await tester.pumpAndSettle();

    expect(find.text('Tanamanku'), findsAtLeastNWidgets(1));
    expect(find.text('Tomat Baru'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
  });
}

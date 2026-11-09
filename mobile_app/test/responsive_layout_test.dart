import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/widgets/main_bottom_navigation.dart';
import 'package:mobile_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/data_inspection_page.dart';
import 'package:mobile_app/features/guide/presentation/pages/guide_list_page.dart';
import 'package:mobile_app/features/guide/data/guide_data.dart';
import 'package:mobile_app/features/guide/presentation/pages/disease_detail_page.dart';
import 'package:mobile_app/features/guide/presentation/pages/tool_detail_page.dart';
import 'package:mobile_app/features/guide/presentation/widgets/guide_illustrations.dart';
import 'package:mobile_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_app/features/auth/presentation/pages/register_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/detection_result_page.dart';
import 'package:mobile_app/features/detection/presentation/pages/photo_preview_page.dart';
import 'package:mobile_app/features/history/views/history_page.dart';
import 'package:mobile_app/features/plants/views/plant_list_page.dart';
import 'package:mobile_app/features/plants/views/plant_detail_page.dart';
import 'package:mobile_app/features/plants/models/plant.dart';
import 'package:mobile_app/features/plants/providers/plant_provider.dart';
import 'package:mobile_app/features/plants/widgets/plant_card.dart';
import 'package:mobile_app/features/profile/presentation/pages/personal_information_page.dart';
import 'package:mobile_app/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile_app/features/splash/presentation/pages/splash_page.dart';
import 'package:mobile_app/features/sync/views/sync_status_page.dart';

class _ResponsivePlantNotifier extends PlantNotifier {
  _ResponsivePlantNotifier(this.plant);

  final Plant plant;

  @override
  Future<List<Plant>> build() async => [plant];
}

void main() {
  double contentGapAfterAppBar(WidgetTester tester, Finder content) {
    final appBarBottom = tester.getRect(find.byType(AppBar).first).bottom;
    return tester.getTopLeft(content).dy - appBarBottom;
  }

  Future<void> pumpDashboardAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DashboardPage())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard responsif dan statistik tampil pada ponsel kecil', (
    tester,
  ) async {
    await pumpDashboardAt(tester, const Size(360, 640));

    expect(tester.takeException(), isNull);
    expect(find.text('Total Tanaman'), findsOneWidget);
    expect(find.text('Kondisi Sehat'), findsOneWidget);
    expect(find.text('Perlu Perhatian'), findsOneWidget);
    final bottomNavigation = find.byType(MainBottomNavigation);
    expect(
      find.descendant(of: bottomNavigation, matching: find.text('Beranda')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNavigation, matching: find.text('Panduan')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNavigation, matching: find.text('Tanamanku')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNavigation, matching: find.text('Profil')),
      findsOneWidget,
    );
  });

  testWidgets('dashboard tidak overflow pada layar lebar', (tester) async {
    await pumpDashboardAt(tester, const Size(800, 1200));

    expect(tester.takeException(), isNull);
    expect(find.text('Total Tanaman'), findsOneWidget);
    expect(find.text('Perlu Perhatian'), findsOneWidget);
  });

  testWidgets('dashboard tidak overflow pada lebar ponsel umum', (
    tester,
  ) async {
    for (final size in [const Size(390, 844), const Size(412, 915)]) {
      await pumpDashboardAt(tester, size);

      expect(tester.takeException(), isNull);
      expect(find.text('LeafItToMe'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('daftar tanaman adaptif tanpa overflow pada HP dan tablet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PlantListPage())),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Tanamanku'), findsAtLeastNWidgets(1));
      expect(find.text('Tomat Pot Depan'), findsOneWidget);
      expect(find.text('Tomat Kebun Belakang'), findsOneWidget);
      expect(find.byType(MainBottomNavigation), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('kartu tanaman tetap ringkas dan seragam pada tablet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: PlantListPage())),
    );
    await tester.pumpAndSettle();

    final cards = find.byType(PlantCard);
    expect(cards, findsNWidgets(2));
    expect(tester.getSize(cards.at(0)).height, 200);
    expect(tester.getSize(cards.at(1)).height, 200);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail penyakit dan ilustrasinya responsif tanpa overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final disease = GuideData.diseases.first;

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(home: DiseaseDetailPage(disease: disease)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        contentGapAfterAppBar(tester, find.byType(DiseaseLeafIllustration)),
        closeTo(16, 1),
      );
      final illustrationSize = tester.getSize(
        find.byType(DiseaseLeafIllustration),
      );
      expect(illustrationSize.height, lessThanOrEqualTo(280));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('detail kebutuhan dan ilustrasinya responsif tanpa overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final tool = GuideData.tools.first;

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(MaterialApp(home: ToolDetailPage(tool: tool)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        contentGapAfterAppBar(tester, find.byType(ToolIllustration)),
        closeTo(16, 1),
      );
      final illustrationSize = tester.getSize(find.byType(ToolIllustration));
      expect(illustrationSize.height, lessThanOrEqualTo(280));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('detail tanaman satu atau dua kolom tanpa overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final plant = Plant(
      id: 'TMT-002',
      name: 'Tomat Kebun Belakang',
      location: 'Kebun belakang',
      plantedDate: '25 Sep 2026',
      lastInspectionDate: '25 Sep 2026',
      status: 'Perlu perhatian',
    );

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            plantProvider.overrideWith(() => _ResponsivePlantNotifier(plant)),
          ],
          child: MaterialApp(home: PlantDetailPage(plantId: plant.id)),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Detail Tanaman'), findsOneWidget);
      expect(find.text('Riwayat Pemeriksaan'), findsOneWidget);
      expect(
        contentGapAfterAppBar(
          tester,
          find.byKey(const Key('plantInformationCard')),
        ),
        closeTo(20, 1),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('daftar panduan adaptif tanpa overflow pada HP dan tablet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MaterialApp(home: GuideListPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Panduan Budidaya'), findsOneWidget);
      expect(find.text('Topik Panduan'), findsOneWidget);
      expect(find.byType(MainBottomNavigation), findsOneWidget);
      expect(
        contentGapAfterAppBar(
          tester,
          find.byKey(const Key('guideFeaturedCard')),
        ),
        closeTo(20, 1),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('form autentikasi tetap responsif pada HP dan tablet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      for (final page in [
        const LoginPage(),
        const RegisterPage(),
        const ForgotPasswordPage(),
      ]) {
        await tester.pumpWidget(MaterialApp(home: page));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    }
  });

  testWidgets('sinkronisasi tidak overflow pada HP dan tablet', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MaterialApp(home: SyncStatusPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Sinkronisasi Data'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('riwayat adaptif tanpa overflow pada HP dan tablet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Riwayat Pemeriksaan'), findsAtLeastNWidgets(1));
      expect(find.text('Semua Riwayat'), findsOneWidget);
      expect(find.byType(MainBottomNavigation), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('hasil deteksi responsif tanpa overflow pada HP dan tablet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final selection = InspectionPhotoSelection(
      draft: InspectionDraft(
        plant: const InspectionPlant(
          name: 'Tomat Kebun Belakang',
          id: 'TMT-002',
          location: 'Kebun belakang',
        ),
        inspectionDate: DateTime(2026, 10, 10),
        note: 'Ada bercak pada daun.',
      ),
      source: 'Galeri',
    );

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(home: DetectionResultPage(selection: selection)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Hasil Deteksi'), findsOneWidget);
      expect(find.text('Bacterial Spot'), findsOneWidget);
      expect(find.byKey(const Key('treatmentButton')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('profil adaptif tanpa overflow pada HP dan tablet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Profil'), findsAtLeastNWidgets(1));
      expect(find.text('Pemindaian'), findsOneWidget);
      expect(find.text('Informasi Pribadi'), findsOneWidget);
      expect(find.byType(MainBottomNavigation), findsOneWidget);
      expect(
        contentGapAfterAppBar(
          tester,
          find.byKey(const Key('profileOverviewCard')),
        ),
        closeTo(20, 1),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('foto profil berada dekat header di HP dan tablet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 768),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        const MaterialApp(home: PersonalInformationPage()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        contentGapAfterAppBar(
          tester,
          find.byKey(const Key('profilePhotoAvatar')),
        ),
        closeTo(24, 1),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets(
    'splash menampilkan identitas dan loading pada ponsel dan tablet',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final size in [const Size(360, 640), const Size(800, 1200)]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(const MaterialApp(home: SplashPage()));
        await tester.pump();

        expect(find.text('LeafItToMe'), findsOneWidget);
        expect(find.text('Kenali Daunnya, Jaga Tanamannya'), findsOneWidget);
        expect(find.text('Memuat...'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    },
  );

  testWidgets(
    'form pemeriksaan dapat digulir saat keyboard menyisakan ruang kecil',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: DataInspectionPage()));
      await tester.pumpAndSettle();

      final continueButton = find.byKey(const Key('continueToPhotoButton'));
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('inspectionNoteField')), findsOneWidget);
      expect(continueButton, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

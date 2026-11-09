import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';
import '../../../../features/detection/presentation/pages/data_inspection_page.dart'
    show InspectionPlant;
import '../../../../features/history/data/history_data.dart' show HistoryData;
import '../../../../features/plants/models/plant.dart';
import '../../../../features/plants/providers/plant_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  // Flag untuk mendemonstrasikan 2 kondisi:
  // true = sudah memiliki tanaman
  // false = belum memiliki tanaman
  bool _hasPlants = true;

  static const Color primaryGreen = Color(0xFF2F7D4A);
  static const Color darkGreen = Color(0xFF183E2D);
  static const Color backgroundColor = Color(0xFFF8FAF5);
  static const Color secondaryText = Color(0xFF75857B);
  static const Color borderColor = Color(0xFFE3EAE4);
  static const Color accentGreen = Color(0xFFE8F5E9);

  void _showNavigationError(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Data tanaman tidak ditemukan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openPlantDetail(BuildContext context, String id) {
    context.pushNamed('plant-detail', pathParameters: {'plantId': id});
  }

  void _openPlantHistory(BuildContext context, String plantId) {
    final plant = HistoryData.plantById(plantId);
    if (plant == null) {
      _showNavigationError(context);
      return;
    }

    context.pushNamed('history', extra: plant);
  }

  void _openLatestHistoryDetail(BuildContext context, String plantId) {
    final records = HistoryData.recordsByPlantId(plantId);
    if (records.isEmpty) {
      _showNavigationError(context);
      return;
    }

    context.pushNamed('history-detail', extra: records.first);
  }

  void _openInspection(BuildContext context, Plant plant) {
    context.pushNamed(
      'data-inspection',
      extra: InspectionPlant(
        id: plant.id,
        name: plant.name,
        location: plant.location,
      ),
    );
  }

  String _nextPlantId(List<Plant> plants) {
    var maxNumber = 0;
    for (final plant in plants) {
      final parts = plant.id.split('-');
      if (parts.length < 2) {
        continue;
      }

      final number = int.tryParse(parts.last);
      if (number != null && number > maxNumber) {
        maxNumber = number;
      }
    }

    return 'TMT-${(maxNumber + 1).toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isNarrowScreen = MediaQuery.sizeOf(context).width < 380;
    final plantsAsync = ref.watch(plantProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isNarrowScreen) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco, color: primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LeafItToMe',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF1F3826),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isNarrowScreen) ...[
                      const SizedBox(height: 1),
                      const Text(
                        'Beranda',
                        style: TextStyle(
                          color: Color(0xFF75857B),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Toggle Switch untuk memudahkan pengujian 2 kondisi (Sudah vs Belum memiliki tanaman)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, right: 20.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isNarrowScreen)
                      Text(
                        _hasPlants ? 'Ada Tanaman' : 'Belum Ada',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                    if (!isNarrowScreen) const SizedBox(width: 6),
                    Semantics(
                      label: 'Tampilkan status tanaman pada beranda',
                      value: _hasPlants ? 'Ada tanaman' : 'Belum ada tanaman',
                      child: Transform.scale(
                        scale: 0.72,
                        child: Switch(
                          value: _hasPlants,
                          activeTrackColor: primaryGreen,
                          onChanged: (val) {
                            setState(() {
                              _hasPlants = val;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: AppContentLayout(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Banner Salam & Perkenalan
                  _buildGreetingHeader(),
                  const SizedBox(height: 20),

                  // Tampilan Kondisi (Sudah vs Belum Memiliki Tanaman)
                  if (_hasPlants)
                    plantsAsync.when(
                      data: (plants) => plants.isEmpty
                          ? _buildEmptyDashboard(context, plants)
                          : _buildActivePlantsDashboard(context, plants),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2F7D4A),
                        ),
                      ),
                      error: (error, stackTrace) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Data tanaman belum dapat dimuat.'),
                            TextButton(
                              onPressed: () => ref
                                  .read(plantProvider.notifier)
                                  .refreshPlants(),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _buildEmptyDashboard(
                      context,
                      plantsAsync.value ?? initialPlants,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildGreetingHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(
              Icons.energy_savings_leaf_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang, Petani Muda! 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _hasPlants
                    ? 'Pantau kesehatan tanamanmu & ikuti panduan perawatan harian.'
                    : 'Mulai petualangan berkebunmu dengan menambah tanaman pertamamu.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- KONDISI 1: BELUM MEMILIKI TANAMAN (EMPTY STATE) ---
  Widget _buildEmptyDashboard(BuildContext context, List<Plant> plants) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.yard_outlined,
              size: 56,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Memiliki Tanaman',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kamu belum merawat tanaman apapun saat ini.\nTambah tanaman baru atau pelajari panduan budidaya!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: secondaryText, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () =>
                context.pushNamed('add-plant', extra: _nextPlantId(plants)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text(
              'Tambah Tanaman Pertama',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // --- KONDISI 2: SUDAH MEMILIKI TANAMAN (ACTIVE STATE) ---
  Widget _buildActivePlantsDashboard(BuildContext context, List<Plant> plants) {
    final healthyCount = plants
        .where((plant) => plant.status.toLowerCase() == 'sehat')
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ringkasan Status Tanaman (Stat Cards)
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Tanaman',
                value: '${plants.length}',
                color: primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Kondisi Sehat',
                value: '$healthyCount',
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Perlu Perhatian',
                value: '${plants.length - healthyCount}',
                color: const Color(0xFFED6C02),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Daftar Tanaman Aktif
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.goNamed('plants'),
              child: const Text(
                'Tanamanku',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= AppBreakpoints.tablet;
            final cardWidth = isTablet
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final plant in plants)
                  SizedBox(
                    width: cardWidth,
                    child: _buildPlantItemCard(
                      name: plant.name,
                      code: plant.id,
                      location: plant.location,
                      lastCheck: plant.lastInspectionDate,
                      status: plant.status,
                      isHealthy: plant.status.toLowerCase() == 'sehat',
                      onTap: () => _openPlantDetail(context, plant.id),
                      onOpenSummary: () => _showPlantDetailModal(
                        context,
                        plant.name,
                        plant.id,
                        plant.status,
                      ),
                      onOpenHistory: () => _openPlantHistory(context, plant.id),
                      onOpenLatestHistory: () =>
                          _openLatestHistoryDetail(context, plant.id),
                      onInspect: () => _openInspection(context, plant),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantItemCard({
    required String name,
    required String code,
    required String location,
    required String lastCheck,
    required String status,
    required bool isHealthy,
    required VoidCallback onTap,
    required VoidCallback onOpenSummary,
    required VoidCallback onOpenHistory,
    required VoidCallback onOpenLatestHistory,
    required VoidCallback onInspect,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isHealthy
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.eco_rounded,
                    color: isHealthy
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFED6C02),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onOpenSummary,
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$code • $location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onInspect,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isHealthy
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isHealthy
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFED6C02),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onOpenHistory,
                      child: const Text(
                        'Pemeriksaan terakhir',
                        style: TextStyle(fontSize: 11, color: secondaryText),
                      ),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: onOpenLatestHistory,
                      child: Text(
                        lastCheck,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                  side: const BorderSide(color: primaryGreen, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPlantDetailModal(
    BuildContext context,
    String name,
    String code,
    String status,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              Text(
                'ID Tanaman: $code',
                style: const TextStyle(fontSize: 13, color: secondaryText),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: primaryGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Status Tanaman: $status.\nKondisi terpantau baik dan dalam masa pertumbuhan.',
                        style: const TextStyle(fontSize: 13, color: darkGreen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: AppButton(
                  label: 'Tutup',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

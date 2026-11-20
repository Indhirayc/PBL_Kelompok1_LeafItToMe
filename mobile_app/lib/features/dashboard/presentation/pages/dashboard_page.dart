import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';
import '../../../../features/detection/presentation/pages/data_inspection_page.dart'
    show InspectionPlant;
import '../../../../features/history/data/history_data.dart'
    show HistoryData, HistoryPlant;
import '../../../../features/plants/models/plant.dart';
import '../../../../features/plants/providers/plant_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

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

  void _openPlantHistory(BuildContext context, WidgetRef ref, String plantId) {
    final plant = ref.read(plantByIdProvider(plantId));
    if (plant == null) {
      _showNavigationError(context);
      return;
    }

    context.pushNamed(
      'history',
      extra: HistoryPlant(
        id: plant.id,
        name: plant.name,
        location: plant.location,
        userId: plant.userId,
      ),
    );
  }

  void _openLatestHistoryDetail(
    BuildContext context,
    String plantId,
    String userId,
  ) {
    final records = HistoryData.recordsByPlantId(plantId, userId: userId);
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

  Future<void> _openAddPlant(BuildContext context, WidgetRef ref) async {
    try {
      final nextId = await ref.read(plantProvider.notifier).nextPlantId();
      if (context.mounted) {
        context.pushNamed('add-plant', extra: nextId);
      }
    } catch (error, stackTrace) {
      debugPrint('Gagal menyiapkan ID tanaman: $error\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form tambah tanaman belum dapat dibuka.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/splash/leafittome_logo.png',
                width: 38,
                height: 38,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.eco_rounded,
                  color: primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LeafItToMe',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF1F3826),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Beranda',
                    style: TextStyle(
                      color: Color(0xFF75857B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: AppContentLayout(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Salam & Perkenalan
                  _buildGreetingHeader(
                    hasPlants: plantsAsync.value?.isNotEmpty ?? false,
                  ),
                  const SizedBox(height: 20),

                  plantsAsync.when(
                    data: (plants) => plants.isEmpty
                        ? _buildEmptyDashboard(context, ref)
                        : _buildActivePlantsDashboard(context, plants, ref),
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

  Widget _buildGreetingHeader({required bool hasPlants}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: const DecorationImage(
          image: AssetImage('assets/images/banner_beranda.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3622).withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.35),
              Colors.black.withValues(alpha: 0.15),
              Colors.transparent,
            ],
            stops: const [0.0, 0.65, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang, Petani Muda! 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasPlants
                    ? 'Pantau kesehatan tanamanmu & ikuti panduan perawatan harian.'
                    : 'Mulai petualangan berkebunmu dengan menambah tanaman pertamamu.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 13,
                  height: 1.45,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- KONDISI 1: BELUM MEMILIKI TANAMAN (EMPTY STATE) ---
  Widget _buildEmptyDashboard(BuildContext context, WidgetRef ref) {
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
            onPressed: () => _openAddPlant(context, ref),
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
  Widget _buildActivePlantsDashboard(
    BuildContext context,
    List<Plant> plants,
    WidgetRef ref,
  ) {
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
                color: const Color(0xFF2E7D32),
                bgColor: const Color(0xFFF6FAF7),
                borderColor: const Color(0xFFD8EADC),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Kondisi Sehat',
                value: '$healthyCount',
                color: const Color(0xFF2E7D32),
                bgColor: const Color(0xFFF1F9F3),
                borderColor: const Color(0xFFC7E6CD),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Perlu Perhatian',
                value: '${plants.length - healthyCount}',
                color: const Color(0xFFED6C02),
                bgColor: const Color(0xFFFFF7ED),
                borderColor: const Color(0xFFFFDEC0),
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
                      imagePath: plant.imagePath,
                      onTap: () => _openPlantDetail(context, plant.id),
                      onOpenSummary: () => _showPlantDetailModal(
                        context,
                        plant.name,
                        plant.id,
                        plant.status,
                      ),
                      onOpenHistory: () =>
                          _openPlantHistory(context, ref, plant.id),
                      onOpenLatestHistory: () => _openLatestHistoryDetail(
                        context,
                        plant.id,
                        plant.userId,
                      ),
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
    Color bgColor = Colors.white,
    Color borderColor = const Color(0xFFE3EAE4),
  }) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
    String? imagePath,
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
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: isHealthy
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: imagePath != null && File(imagePath).existsSync()
                    ? Image.file(
                        File(imagePath),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.eco_rounded,
                            color: isHealthy
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFED6C02),
                            size: 26,
                          ),
                        ),
                      )
                    : Center(
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
                      location,
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

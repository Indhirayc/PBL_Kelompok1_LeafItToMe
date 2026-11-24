import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_breakpoints.dart';
import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';
import '../../detection/presentation/pages/data_inspection_page.dart';
import '../../history/data/history_data.dart' hide HistoryRecord;
import '../../history/widgets/scanned_leaf_image.dart';
import '../../../../data/models/scan_record_model.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';
import 'history_detail_page.dart';

class _HistoryPreview {
  const _HistoryPreview({
    required this.id,
    required this.disease,
    required this.scannedAt,
    required this.formattedDate,
    required this.note,
    required this.isHealthy,
    this.photoAssetPath,
    this.cloudImageUrl,
  });

  final String id;
  final String disease;
  final DateTime scannedAt;
  final String formattedDate;
  final String note;
  final bool isHealthy;
  final String? photoAssetPath;
  final String? cloudImageUrl;
}

class PlantDetailPage extends ConsumerWidget {
  const PlantDetailPage({super.key, required this.plantId});

  final String plantId;

  List<_HistoryPreview> _historiesFor(List<ScanRecordModel> scans) {
    final sortedScans = List<ScanRecordModel>.from(scans)
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

    return sortedScans
        .map(
          (scan) => _HistoryPreview(
            id: scan.id,
            disease: scan.diseaseName,
            scannedAt: scan.scannedAt,
            formattedDate: formatHistoryDateTime(scan.scannedAt),
            note: scan.notes ?? 'Tidak ada catatan tambahan.',
            isHealthy: HistoryData.isHealthyName(scan.diseaseName),
            photoAssetPath: scan.localImagePath,
            cloudImageUrl: scan.cloudImageUrl,
          ),
        )
        .toList();
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Plant plant) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hapus Tanaman',
            style: TextStyle(
              color: Color(0xFF1F3826),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus '${plant.name}'?",
            style: const TextStyle(
              color: Color(0xFF65756A),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            AppButton(
              label: 'Batal',
              width: null,
              height: 50,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            AppButton(
              label: 'Hapus',
              width: null,
              height: 50,
              variant: AppButtonVariant.destructive,
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ref.read(plantProvider.notifier).deletePlant(plant.id);
                if (context.mounted) {
                  context.goNamed('plants');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlantAvatar(Plant plant, {double size = 58}) {
    if (plant.imagePath != null && File(plant.imagePath!).existsSync()) {
      return Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Image.file(
          File(plant.imagePath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultPlantAvatar(size: size),
        ),
      );
    }
    return _buildDefaultPlantAvatar(size: size);
  }

  Widget _buildDefaultPlantAvatar({double size = 58}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFDCEFD9),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.eco_rounded,
            color: const Color(0xFF2E7D32),
            size: size * 0.55,
          ),
          Positioned(
            right: size * 0.28,
            bottom: size * 0.25,
            child: Container(
              width: size * 0.18,
              height: size * 0.18,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String date,
    required bool isHealthy,
    required VoidCallback onTap,
    String? photoAssetPath,
    String? cloudImageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF1B5E20).withValues(alpha: 0.08),
          highlightColor: const Color(0xFF1B5E20).withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3EAE3)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: ScannedLeafImage(
                      cloudImageUrl: cloudImageUrl,
                      localPath: photoAssetPath,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      isHealthy: isHealthy,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3826),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF75857B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9BAAA0),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAE3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, color: Color(0xFF91A096), size: 38),
          SizedBox(height: 10),
          Text(
            'Belum ada riwayat pemeriksaan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1F3826),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Lakukan scan daun untuk menambahkan riwayat pemeriksaan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF75857B),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _openHistoryDetail(
    BuildContext context, {
    required Plant plant,
    required _HistoryPreview history,
  }) {
    context.pushNamed(
      'history-detail',
      extra: HistoryRecord(
        plantId: plant.id,
        plantName: plant.name,
        disease: history.disease,
        date: history.formattedDate,
        accuracy: '',
        note: history.note,
        userId: plant.userId,
        photoAssetPath: history.photoAssetPath,
        cloudImageUrl: history.cloudImageUrl,
      ),
    );
  }

  void _openAllHistory(BuildContext context, Plant plant) {
    context.pushNamed(
      'history',
      extra: HistoryPlant(
        id: plant.id,
        name: plant.name,
        location: plant.location,
        userId: plant.userId,
        imagePath: plant.imagePath,
      ),
    );
  }

  void _openInspectionForm(BuildContext context, Plant plant) {
    context.pushNamed(
      'data-inspection',
      extra: InspectionPlant(
        name: plant.name,
        id: plant.id,
        location: plant.location,
      ),
    );
  }

  Widget _buildPlantInformationCard(BuildContext context, Plant plant) {
    return Container(
      key: const Key('plantInformationCard'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlantAvatar(plant, size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3826),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      plant.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF65756A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        plant.status,
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  key: const Key('editProfileCardButton'),
                  onTap: () {
                    context.pushNamed(
                      'edit-plant',
                      pathParameters: {'plantId': plant.id},
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: Color(0xFF2E7D32),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ditanam ${plant.plantedDate}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF65756A)),
          ),
          const SizedBox(height: 12),
          AppButton(
            key: const Key('scanPlantButton'),
            label: 'Scan Daun',
            height: 48,
            onPressed: () => _openInspectionForm(context, plant),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context, {
    required WidgetRef ref,
    required Plant plant,
    required AsyncValue<List<_HistoryPreview>> historiesAsync,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Riwayat Pemeriksaan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3826),
                ),
              ),
            ),
            if (historiesAsync.value?.isNotEmpty ?? false)
              TextButton(
                key: const Key('viewAllHistoryButton'),
                onPressed: () => _openAllHistory(context, plant),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2F7D4A),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        historiesAsync.when(
          data: (histories) {
            final recentHistories = histories.take(3);
            if (histories.isEmpty) {
              return _buildEmptyHistory();
            }
            return Column(
              children: recentHistories.map((history) {
                return _buildHistoryItem(
                  title: history.disease,
                  date: history.formattedDate,
                  isHealthy: history.isHealthy,
                  photoAssetPath: history.photoAssetPath,
                  cloudImageUrl: history.cloudImageUrl,
                  onTap: () => _openHistoryDetail(
                    context,
                    plant: plant,
                    history: history,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Column(
            children: [
              const Text('Riwayat pemeriksaan belum dapat dimuat.'),
              TextButton(
                onPressed: () =>
                    ref.invalidate(plantScanHistoryProvider(plant.id)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantProvider);
    return plantsAsync.when(
      loading: () => _buildUnavailablePage(
        context,
        message: 'Memuat data tanaman...',
        loading: true,
      ),
      error: (error, stackTrace) => _buildUnavailablePage(
        context,
        message: 'Data tanaman belum dapat dimuat.',
        onRetry: () => ref.read(plantProvider.notifier).refreshPlants(),
      ),
      data: (plants) {
        final plant = ref.watch(plantByIdProvider(plantId));
        if (plant == null) {
          return _buildUnavailablePage(
            context,
            message: 'Data tanaman tidak ditemukan',
            onBack: () => context.goNamed('plants'),
          );
        }

        final historiesAsync = ref
            .watch(plantScanHistoryProvider(plant.id))
            .whenData(_historiesFor);
        return _buildPlantDetail(context, ref, plant, historiesAsync);
      },
    );
  }

  Widget _buildUnavailablePage(
    BuildContext context, {
    required String message,
    bool loading = false,
    VoidCallback? onRetry,
    VoidCallback? onBack,
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('plants');
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F3826),
            size: 20,
          ),
        ),
        title: const Text(
          'Detail Tanaman',
          style: TextStyle(
            color: Color(0xFF1F3826),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const CircularProgressIndicator(color: Color(0xFF2F7D4A))
              else
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF75857B),
                    fontSize: 14,
                  ),
                ),
              if (loading) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF75857B),
                    fontSize: 14,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
              ],
              if (onBack != null) ...[
                const SizedBox(height: 16),
                AppButton(
                  label: 'Kembali ke Tanamanku',
                  onPressed: onBack,
                  width: 220,
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildPlantDetail(
    BuildContext context,
    WidgetRef ref,
    Plant plant,
    AsyncValue<List<_HistoryPreview>> historiesAsync,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('plants');
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F3826),
            size: 20,
          ),
        ),
        title: const Text(
          'Detail Tanaman',
          style: TextStyle(
            color: Color(0xFF1F3826),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            key: const Key('editPlantButton'),
            tooltip: 'Edit Profil Tanaman',
            onPressed: () {
              context.pushNamed(
                'edit-plant',
                pathParameters: {'plantId': plant.id},
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            splashRadius: 22,
            color: const Color(0xFF2F7D4A),
            icon: const Icon(Icons.edit_outlined, size: 22),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              tooltip: 'Hapus Tanaman',
              onPressed: () {
                _showDeleteDialog(context, ref, plant);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              splashRadius: 22,
              color: const Color(0xFFD32F2F),
              icon: const Icon(Icons.delete_outline_rounded, size: 22),
            ),
          ),
        ],
      ),
      body: AppContentLayout(
        alignment: Alignment.topCenter,
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= AppBreakpoints.tablet;
              final plantInformation = _buildPlantInformationCard(
                context,
                plant,
              );
              final historySection = _buildHistorySection(
                context,
                ref: ref,
                plant: plant,
                historiesAsync: historiesAsync,
              );

              if (isTablet) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: (constraints.maxWidth - 64) / 2,
                        child: plantInformation,
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: (constraints.maxWidth - 64) / 2,
                        child: historySection,
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  plantInformation,
                  const SizedBox(height: 24),
                  historySection,
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }
}

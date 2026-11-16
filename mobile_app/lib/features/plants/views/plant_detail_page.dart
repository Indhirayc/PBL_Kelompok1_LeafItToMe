import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_breakpoints.dart';
import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';
import '../../detection/presentation/pages/data_inspection_page.dart';
import '../../history/data/history_data.dart' hide HistoryRecord;
import '../../../../data/models/scan_record_model.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';
import 'history_detail_page.dart';

class _HistoryPreview {
  const _HistoryPreview({
    required this.disease,
    required this.date,
    required this.accuracy,
    required this.note,
    required this.isHealthy,
  });

  final String disease;
  final String date;
  final String accuracy;
  final String note;
  final bool isHealthy;
}

class PlantDetailPage extends ConsumerWidget {
  const PlantDetailPage({super.key, required this.plantId});

  final String plantId;

  List<_HistoryPreview> _historiesFor(List<ScanRecordModel> scans) {
    return scans
        .map(
          (scan) => _HistoryPreview(
            disease: scan.diseaseName,
            date: formatHistoryDate(scan.scannedAt),
            accuracy: '${(scan.confidence * 100).round().clamp(0, 100)}%',
            note: scan.notes ?? 'Tidak ada catatan tambahan.',
            isHealthy: HistoryData.isHealthyName(scan.diseaseName),
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

  Widget _buildPlantAvatar({double size = 58}) {
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
    required String accuracy,
    required Color avatarColor,
    required bool isHealthy,
    required VoidCallback onTap,
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
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isHealthy
                        ? Icons.check_circle_outline_rounded
                        : Icons.warning_amber_rounded,
                    color: isHealthy
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFD7442D),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3826),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF75857B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accuracy,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
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
        date: history.date,
        accuracy: history.accuracy,
        note: history.note,
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
              _buildPlantAvatar(size: 60),
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
                      '${plant.id} • ${plant.location}',
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
            height: 50,
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
                  date: history.date,
                  accuracy: 'Akurasi ${history.accuracy}',
                  avatarColor: history.isHealthy
                      ? const Color(0xFFE2F1E4)
                      : const Color(0xFFFFE0D6),
                  isHealthy: history.isHealthy,
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
          Padding(
            padding: const EdgeInsets.only(right: 20),
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

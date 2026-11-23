import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';
import '../data/history_data.dart';
import '../widgets/history_page_header.dart';
import '../widgets/scanned_leaf_image.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key, required this.record});

  final HistoryRecord record;

  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _border = Color(0xFFE3EAE4);
  static const Color _bannerGreen = Color(0xFF183E2D);
  static const Color _healthyGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final HistoryPlant? plant =
        HistoryData.plantById(record.plantId, userId: record.userId) ??
        (record.plantName != null || record.plantLocation != null
            ? HistoryPlant(
                id: record.plantId,
                name: record.plantName ?? record.plantId,
                location: record.plantLocation ?? '',
                userId: record.userId,
              )
            : null);
    final HistoryDisease? disease = HistoryData.byDisease(record.diseaseName);

    return Scaffold(
      backgroundColor: _background,
      body: AppContentLayout(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              HistoryPageHeader(
                title: 'Detail Riwayat',
                subtitle: 'Rincian hasil pemeriksaan tanaman.',
                fallbackRoute: 'history',
                fallbackExtra: HistoryData.plantById(
                  record.plantId,
                  userId: record.userId,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _buildPhotoCard(plant),
                    const SizedBox(height: 16),
                    _buildResultCard(disease),
                    const SizedBox(height: 20),
                    AppButton(
                      key: const Key('recommendationButton'),
                      label: 'Lihat Rekomendasi Penanganan',
                      onPressed: () => context.pushNamed(
                        'treatment-recommendation',
                        extra: record,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildResultCard(HistoryDisease? disease) {
    final bool healthy = record.isHealthy;
    final Color statusColor = healthy
        ? _healthyGreen
        : (disease?.severityColor ?? const Color(0xFFD32F2F));
    final String statusText = healthy
        ? 'Kondisi Sehat'
        : (disease?.severity ?? 'Perlu Penanganan');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hasil Deteksi',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            record.diseaseName,
            style: const TextStyle(
              color: _darkGreen,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            record.latinName,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(HistoryPlant? plant) {
    final plantName = plant?.name ?? record.plantName ?? 'Tanaman Tomat';
    final formattedDate = formatHistoryDateTime(record.date);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _bannerGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ScannedLeafImage(
                cloudImageUrl: record.cloudImageUrl,
                localPath: record.photoAssetPath,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                isHealthy: record.isHealthy,
                fallbackWidget: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/tomato_plant.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF6FA98A),
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.90),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

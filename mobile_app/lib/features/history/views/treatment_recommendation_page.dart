import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/marketplace_card.dart';
import '../../../core/utils/disease_label_mapper.dart';
import '../../guide/data/guide_data.dart';
import '../data/history_data.dart';
import '../widgets/history_page_header.dart';
import '../widgets/scanned_leaf_image.dart';

class TreatmentRecommendationPage extends StatelessWidget {
  const TreatmentRecommendationPage({super.key, required this.record});

  final HistoryRecord record;

  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _border = Color(0xFFE3EAE4);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  static const Color _accentGreen = Color(0xFFE8F5E9);
  static const Color _dangerRed = Color(0xFFD32F2F);

  Future<void> _openMarketplace(BuildContext context, String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword);
    final url = Uri.parse(
      'https://shopee.co.id/search?keyword=$encodedKeyword',
    );

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showMarketplaceFallback(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showMarketplaceFallback(context);
      }
    }
  }

  void _showMarketplaceFallback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tautan marketplace produk penanganan tidak dapat dibuka.',
        ),
        backgroundColor: _primaryGreen,
      ),
    );
  }

  DiseaseModel? _guideDiseaseFor(String detectedDisease) {
    for (final guideDisease in GuideData.diseases) {
      if (DiseaseLabelMapper.matches(detectedDisease, guideDisease.name)) {
        return guideDisease;
      }
    }

    return null;
  }

  void _openDiseaseDetails(BuildContext context) {
    if (HistoryData.isHealthyName(record.diseaseName)) {
      context.pushNamed('guide-detail', extra: 2);
      return;
    }

    final guideDisease = _guideDiseaseFor(record.diseaseName);

    if (guideDisease == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Detail penyakit belum tersedia.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    context.pushNamed('disease-detail', extra: guideDisease);
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.viewPaddingOf(context).bottom;
    final HistoryPlant? plant = HistoryData.plantById(
      record.plantId,
      userId: record.userId,
    );

    final selectedPlant =
        plant ??
        HistoryPlant(
          id: record.plantId,
          name: record.plantName ?? record.plantId,
          location: record.plantLocation ?? '',
          userId: record.userId,
        );

    // byDisease sekarang menerima label ML seperti Leaf_Mold.
    final HistoryDisease? disease = HistoryData.byDisease(record.diseaseName);

    final bool isHealthy =
        record.isHealthy || HistoryData.isHealthyName(record.diseaseName);

    final List<String> treatments = disease?.treatments ?? const [];

    final List<String> preventions = disease?.preventions ?? const [];

    final String plantLabel = record.plantName ?? plant?.name ?? record.plantId;

    final String displayName = HistoryData.displayDiseaseName(
      record.diseaseName,
    );

    final String treatmentEmptyMessage = isHealthy
        ? 'Daun terdeteksi sehat. Lanjutkan perawatan rutin.'
        : 'Rekomendasi penanganan untuk penyakit ini belum tersedia.';

    final String preventionEmptyMessage = isHealthy
        ? 'Pertahankan perawatan rutin dan pantau kondisi daun.'
        : 'Rekomendasi pencegahan untuk penyakit ini belum tersedia.';

    return Scaffold(
      backgroundColor: _background,
      body: AppContentLayout(
        child: SafeArea(
          child: Column(
            children: [
              HistoryPageHeader(
                title: 'Rekomendasi Penanganan',
                subtitle: 'Langkah penanganan dan pencegahan.',
                fallbackRoute: 'history',
                fallbackExtra: selectedPlant,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, bottomSafeArea + 24),
                  children: [
                    _buildImageHeader(
                      plantLabel,
                      disease,
                      isHealthy,
                    ),
                    const SizedBox(height: 16),
                    _buildContextCard(
                      plantLabel,
                      displayName,
                      disease,
                      isHealthy,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      isHealthy ? 'Perawatan Harian' : 'Penanganan Awal',
                      style: const TextStyle(
                        color: _darkGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNumberedCard(
                      treatments,
                      emptyMessage: treatmentEmptyMessage,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      isHealthy ? 'Pencegahan Rutin' : 'Pencegahan',
                      style: const TextStyle(
                        color: _darkGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBulletCard(
                      preventions,
                      emptyMessage: preventionEmptyMessage,
                    ),
                    if (!isHealthy) ...[
                      const SizedBox(height: 22),
                      MarketplaceCard(
                        key: const Key('marketplaceButton'),
                        description:
                            'Temukan produk untuk penanganan tanaman melalui '
                            'marketplace. Periksa kembali informasi dan '
                            'petunjuk penggunaan produk sebelum membeli.',
                        onPressed: () => _openMarketplace(
                          context,
                          disease?.searchKeyword ?? 'perawatan tanaman tomat',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (isHealthy)
                      AppButton(
                        key: const Key('dailyCareButton'),
                        icon: Icons.eco_rounded,
                        label: 'Lihat Perawatan Harian ›',
                        variant: AppButtonVariant.secondary,
                        onPressed: () =>
                            context.pushNamed('guide-detail', extra: 2),
                      )
                    else
                      AppButton(
                        key: const Key('diseaseDetailButton'),
                        icon: Icons.arrow_forward_rounded,
                        label: 'Lihat Detail Penyakit',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _openDiseaseDetails(context),
                      ),
                    const SizedBox(height: 12),
                    AppButton(
                      key: const Key('finishAndViewHistoryButton'),
                      icon: Icons.history_rounded,
                      label: 'Selesai & Lihat Riwayat',
                      onPressed: () =>
                          context.pushNamed('history', extra: selectedPlant),
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

  Widget _buildImageHeader(
    String plantLabel,
    HistoryDisease? disease,
    bool isHealthy,
  ) {
    final imageAsset = disease?.imageAssetPath ??
        (isHealthy ? 'assets/images/tomato_plant.png' : null);

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _accentGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: ScannedLeafImage(
                cloudImageUrl: record.cloudImageUrl,
                localPath: record.photoAssetPath,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                isHealthy: isHealthy,
                fallbackWidget: imageAsset != null
                    ? Image.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/tomato_plant.png',
                          fit: BoxFit.contain,
                        ),
                      )
                    : Image.asset(
                        'assets/images/tomato_plant.png',
                        fit: BoxFit.contain,
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
                    plantLabel,
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
                    formatHistoryDate(record.date),
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

  Widget _buildContextCard(
    String plantLabel,
    String displayName,
    HistoryDisease? disease,
    bool isHealthy,
  ) {
    final statusColor = isHealthy ? _primaryGreen : _dangerRed;
    final statusBg =
        isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHealthy
                      ? Icons.check_circle_outline_rounded
                      : Icons.warning_amber_rounded,
                  color: statusColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isHealthy ? 'Kondisi Sehat' : 'Terdeteksi Penyakit',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            displayName,
            style: const TextStyle(
              color: _darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (disease?.latinName != null && disease!.latinName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              disease.latinName,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            '$plantLabel  •  ${formatHistoryDate(record.date)}',
            style: const TextStyle(color: _secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedCard(
    List<String> items, {
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return _buildEmptyCard(emptyMessage);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        color: _darkGreen,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (i != items.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletCard(List<String> items, {required String emptyMessage}) {
    if (items.isEmpty) {
      return _buildEmptyCard(emptyMessage);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 14,
                  child: Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle, size: 5, color: _primaryGreen),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    items[i],
                    style: const TextStyle(
                      color: _darkGreen,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            if (i != items.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Text(
        message,
        style: const TextStyle(color: _secondaryText, fontSize: 13),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    );
  }
}

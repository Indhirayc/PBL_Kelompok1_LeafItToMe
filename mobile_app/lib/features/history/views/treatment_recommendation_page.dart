
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/marketplace_card.dart';
import '../../guide/data/guide_data.dart';
import '../data/history_data.dart';
import '../widgets/history_page_header.dart';

class TreatmentRecommendationPage extends StatelessWidget {
  const TreatmentRecommendationPage({super.key, required this.record});

  final HistoryRecord record;

  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _border = Color(0xFFE3EAE4);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  static const Color _accentGreen = Color(0xFFE8F5E9);
  static const Color _avatarGreen = Color(0xFFDCEFD9);
  static const Color _dangerRed = Color(0xFFD32F2F);

  Future<void> _openMarketplace(
    BuildContext context,
    String keyword,
  ) async {
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

  String _normalizeDiseaseName(String value) {
    return HistoryData.normalizeDiseaseName(value);
  }

  DiseaseModel? _guideDiseaseFor(String detectedDisease) {
    final normalizedResult = _normalizeDiseaseName(detectedDisease);

    for (final guideDisease in GuideData.diseases) {
      final normalizedName = _normalizeDiseaseName(guideDisease.name);
      final normalizedNameWithoutAlias = _normalizeDiseaseName(
        guideDisease.name.replaceAll(RegExp(r'\s*\([^)]*\)'), ''),
      );

      if (normalizedName == normalizedResult ||
          normalizedNameWithoutAlias == normalizedResult) {
        return guideDisease;
      }
    }

    return null;
  }

  void _openDiseaseDetails(BuildContext context) {
    if (HistoryData.isHealthyName(record.diseaseName)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Daun sehat. Tidak ada detail penyakit.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
    final HistoryPlant? plant = HistoryData.plantById(record.plantId);

    final selectedPlant = plant ??
        HistoryPlant(
          id: record.plantId,
          name: record.plantName ?? record.plantId,
          location: record.plantLocation ?? '',
        );

    // byDisease sekarang menerima label ML seperti Leaf_Mold.
    final HistoryDisease? disease =
        HistoryData.byDisease(record.diseaseName);

    final bool isHealthy =
        record.isHealthy || HistoryData.isHealthyName(record.diseaseName);


    final List<String> treatments =
        disease?.treatments ?? const [];

    final List<String> preventions =
        disease?.preventions ?? const [];

    final String plantLabel =
        record.plantName ?? plant?.name ?? record.plantId;

    final String displayName =
        HistoryData.displayDiseaseName(record.diseaseName);

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
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    bottomSafeArea + 24,
                  ),
                  children: [
                    _buildContextCard(
                      plantLabel,
                      displayName,
                      disease,
                      isHealthy,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Penanganan Awal',
                      style: TextStyle(
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
                    const Text(
                      'Pencegahan',
                      style: TextStyle(
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
                    const SizedBox(height: 22),
                    MarketplaceCard(
                      key: const Key('marketplaceButton'),
                      description:
                          'Temukan produk untuk penanganan tanaman melalui '
                          'marketplace. Periksa kembali informasi dan '
                          'petunjuk penggunaan produk sebelum membeli.',
                      onPressed: () => _openMarketplace(
                        context,
                        disease?.searchKeyword ??
                            'perawatan tanaman tomat',
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      onPressed: () => context.pushNamed(
                        'history',
                        extra: selectedPlant,
                      ),
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

  Widget _buildContextCard(
    String plantLabel,
    String displayName,
    HistoryDisease? disease,
    bool isHealthy,
  ) {
    final bool hasDiseaseData = disease != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _accentGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: _avatarGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHealthy
                  ? Icons.check_circle_outline_rounded
                  : Icons.coronavirus_rounded,
              color: isHealthy || !hasDiseaseData
                  ? _primaryGreen
                  : _dangerRed,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$plantLabel  •  ${formatHistoryDate(record.date)}',
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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
            if (i != items.length - 1)
              const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletCard(
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
                const SizedBox(
                  width: 14,
                  child: Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: _primaryGreen,
                    ),
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
            if (i != items.length - 1)
              const SizedBox(height: 14),
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
        style: const TextStyle(
          color: _secondaryText,
          fontSize: 13,
        ),
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

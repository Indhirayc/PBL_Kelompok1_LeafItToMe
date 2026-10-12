import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/marketplace_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final HistoryPlant? plant = HistoryData.plantById(record.plantId);
    final HistoryDisease? disease = HistoryData.byDisease(record.diseaseName);
    final List<String> treatments = disease?.treatments ?? const [];
    final List<String> preventions = disease?.preventions ?? const [];
    final String plantLabel = plant?.name ?? record.plantId;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HistoryPageHeader(
              title: 'Rekomendasi Penanganan',
              subtitle: 'Langkah penanganan dan pencegahan.',
              fallbackRoute: 'history',
              fallbackExtra: plant,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _buildContextCard(plantLabel, disease),
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
                  _buildNumberedCard(treatments),
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
                  _buildBulletCard(preventions),
                  const SizedBox(height: 22),
                  AppButton(
                    key: const Key('diseaseDetailButton'),
                    icon: Icons.arrow_forward_rounded,
                    label: 'Lihat Detail Penyakit',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.pushNamed(
                      'history-disease-detail',
                      extra: record,
                    ),
                  ),
                  const SizedBox(height: 12),
                  MarketplaceButton(
                    key: const Key('marketplaceButton'),
                    onPressed: () => _openMarketplace(
                      context,
                      disease?.searchKeyword ?? 'perawatan tanaman tomat',
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

  Widget _buildContextCard(String plantLabel, HistoryDisease? disease) {
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
              disease == null
                  ? Icons.check_circle_outline_rounded
                  : Icons.coronavirus_rounded,
              color: disease == null ? _primaryGreen : _dangerRed,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.diseaseName,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$plantLabel  •  ${formatHistoryDate(record.date)}',
                  style: const TextStyle(color: _secondaryText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedCard(List<String> items) {
    if (items.isEmpty) {
      return _buildEmptyCard(
        'Tidak ada penanganan khusus. Lanjutkan perawatan rutin.',
      );
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

  Widget _buildBulletCard(List<String> items) {
    if (items.isEmpty) {
      return _buildEmptyCard('Belum ada tips pencegahan tambahan.');
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
                const Padding(
                  padding: EdgeInsets.only(top: 7),
                  child: Text(
                    '•',
                    style: TextStyle(
                      color: _primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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

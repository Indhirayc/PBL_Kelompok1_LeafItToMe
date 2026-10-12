import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/marketplace_button.dart';
import '../data/history_data.dart';
import '../widgets/history_page_header.dart';

class HistoryDiseaseDetailPage extends StatelessWidget {
  const HistoryDiseaseDetailPage({super.key, required this.record});

  final HistoryRecord record;

  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _border = Color(0xFFE3EAE4);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  static const Color _accentGreen = Color(0xFFE8F5E9);
  static const Color _categoryBg = Color(0xFFE2F1E4);
  static const Color _categoryFg = Color(0xFF2E7D32);
  static const Color _severityBg = Color(0xFFFBE7D6);
  static const Color _dangerRed = Color(0xFFD32F2F);
  static const Color _pillBg = Color(0xFF4A5B50);

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
    final HistoryDisease? disease = HistoryData.byDisease(record.diseaseName);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HistoryPageHeader(
              title: 'Detail Penyakit',
              subtitle: 'Gejala dan cara pencegahan.',
              fallbackRoute: 'history',
              fallbackExtra: HistoryData.plantById(record.plantId),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _buildBanner(disease),
                  const SizedBox(height: 18),
                  _buildTitleCard(disease),
                  const SizedBox(height: 22),
                  const Text(
                    'Gejala',
                    style: TextStyle(
                      color: _darkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletCard(disease?.symptoms ?? const []),
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
                  _buildBulletCard(disease?.preventions ?? const []),
                  const SizedBox(height: 22),
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

  Widget _buildBanner(HistoryDisease? disease) {
    final String severity = disease?.severity ?? 'Risiko Sedang';

    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _darkGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _accentGreen,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _pillBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  severity,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.coronavirus_rounded,
                color: _dangerRed,
                size: 56,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleCard(HistoryDisease? disease) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildChip(
                disease?.category ?? 'Penyakit Tanaman',
                _categoryBg,
                _categoryFg,
              ),
              _buildChip(
                disease?.severity ?? 'Risiko Sedang',
                _severityBg,
                disease?.severityColor ?? const Color(0xFFE65100),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBulletCard(List<String> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: const Text(
          'Belum ada informasi.',
          style: TextStyle(color: _secondaryText, fontSize: 13),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
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
}

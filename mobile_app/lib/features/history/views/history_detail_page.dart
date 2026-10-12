import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';
import '../data/history_data.dart';
import '../widgets/history_page_header.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key, required this.record});

  final HistoryRecord record;

  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _border = Color(0xFFE3EAE4);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  static const Color _paleGreen = Color(0xFFE8F5E9);
  static const Color _bannerGreen = Color(0xFF183E2D);
  static const Color _healthyGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final HistoryPlant? plant = HistoryData.plantById(record.plantId);
    final HistoryDisease? disease = HistoryData.byDisease(record.diseaseName);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HistoryPageHeader(
              title: 'Detail Riwayat',
              subtitle: 'Rincian hasil pemeriksaan tanaman.',
              fallbackRoute: 'history',
              fallbackExtra: HistoryData.plantById(record.plantId),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _buildBanner(disease),
                  const SizedBox(height: 18),
                  _buildResultCard(),
                  const SizedBox(height: 16),
                  _buildInfoCard(plant),
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
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildBanner(HistoryDisease? disease) {
    final bool healthy = record.isHealthy;
    final Color statusColor = healthy
        ? _healthyGreen
        : (disease?.severityColor ?? const Color(0xFFD32F2F));
    final String statusText = healthy
        ? 'Kondisi Sehat'
        : (disease?.severity ?? 'Perlu Penanganan');

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 200,
        width: double.infinity,
        color: _bannerGreen,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
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
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hasil Deteksi',
            style: TextStyle(
              color: _secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _paleGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Tingkat keyakinan ${record.accuracy}%',
              style: const TextStyle(
                color: _primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(HistoryPlant? plant) {
    final List<_InfoRow> rows = [
      _InfoRow(
        icon: Icons.calendar_today_outlined,
        label: 'Tanggal pemeriksaan',
        value: formatHistoryDate(record.date),
      ),
      _InfoRow(
        icon: Icons.eco_outlined,
        label: 'Tanaman',
        value: plant?.name ?? '-',
      ),
      _InfoRow(
        icon: Icons.qr_code_2_outlined,
        label: 'ID tanaman',
        value: plant?.id ?? record.plantId,
      ),
      _InfoRow(
        icon: Icons.place_outlined,
        label: 'Lokasi',
        value: plant?.location ?? '-',
      ),
      _InfoRow(
        icon: Icons.notes_outlined,
        label: 'Catatan',
        value: record.note,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _buildInfoRow(rows[i]),
            if (i != rows.length - 1) const Divider(height: 1, color: _border),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(row.icon, color: _primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.label,
                  style: const TextStyle(color: _secondaryText, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  row.value,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _InfoRow {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

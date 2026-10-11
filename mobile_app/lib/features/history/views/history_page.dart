import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/main_bottom_navigation.dart';
import '../data/history_data.dart';
import '../widgets/history_card.dart';
import '../widgets/history_page_header.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, this.plant});

  final HistoryPlant? plant;

  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _bannerGreen = Color(0xFFE8F5E9);
  static const Color _avatarGreen = Color(0xFFDCEFD9);
  static const Color _primaryGreen = Color(0xFF2F7D4A);

  void _showSyncPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Sinkronisasi data segera hadir.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final HistoryPlant selected = plant ?? HistoryData.plants.first;
    final List<HistoryRecord> records = HistoryData.records
        .where((record) => record.plantId == selected.id)
        .toList();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HistoryPageHeader(
              title: 'Riwayat Pemeriksaan',
              subtitle: 'Hasil pemeriksaan untuk tanaman ini.',
              action: IconButton(
                onPressed: () => _showSyncPlaceholder(context),
                tooltip: 'Sinkronisasi data',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                splashRadius: 22,
                icon: const Icon(
                  Icons.sync_rounded,
                  color: _darkGreen,
                  size: 22,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _buildPlantBanner(selected),
                  const SizedBox(height: 16),
                  if (records.isEmpty)
                    _buildEmptyState()
                  else
                    ...records.map(
                      (record) => HistoryCard(
                        record: record,
                        onTap: () => context.pushNamed(
                          'history-detail',
                          extra: record,
                        ),
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

  Widget _buildPlantBanner(HistoryPlant selected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bannerGreen,
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
            child: const Icon(
              Icons.eco_rounded,
              color: _primaryGreen,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected.name,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${selected.id}  •  ${selected.location}',
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

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 48, color: _secondaryText),
          SizedBox(height: 12),
          Text(
            'Belum ada riwayat pemeriksaan.',
            style: TextStyle(color: _secondaryText, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
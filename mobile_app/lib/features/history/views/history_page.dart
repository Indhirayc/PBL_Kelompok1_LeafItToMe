import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/database_providers.dart';
import '../../../core/widgets/app_content_layout.dart';

import '../../../../core/widgets/main_bottom_navigation.dart';
import '../data/history_data.dart';
import '../widgets/history_card.dart';
import '../widgets/history_page_header.dart';

final persistedHistoryProvider = FutureProvider.family<void, String>((
  ref,
  userId,
) async {
  await HistoryData.loadPersistedRecords(userId: userId);
});

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key, this.plant});

  final HistoryPlant? plant;

  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _bannerGreen = Color(0xFFE8F5E9);
  static const Color _avatarGreen = Color(0xFFDCEFD9);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  static const Color _borderColor = Color(0xFFDDE7DE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    return ref
        .watch(persistedHistoryProvider(userId))
        .when(
          data: (_) {
            final selected = plant?.userId == userId
                ? plant
                : plant == null
                ? _firstPlantForUser(userId)
                : null;
            if (selected == null) {
              return _buildNoPlantsPage(context);
            }

            final records = HistoryData.recordsByPlantId(
              selected.id,
              userId: userId,
            );
            return _buildHistoryPage(context, selected, records);
          },
          loading: _buildLoadingPage,
          error: (error, stackTrace) => _buildErrorPage(),
        );
  }

  HistoryPlant? _firstPlantForUser(String userId) {
    for (final plant in HistoryData.plantsForUser(userId)) {
      return plant;
    }
    return null;
  }

  Widget _buildLoadingPage() => const Scaffold(
    backgroundColor: _background,
    body: Center(child: CircularProgressIndicator()),
    bottomNavigationBar: MainBottomNavigation(currentIndex: 2),
  );

  Widget _buildErrorPage() => const Scaffold(
    backgroundColor: _background,
    body: Center(child: Text('Riwayat belum dapat dimuat.')),
    bottomNavigationBar: MainBottomNavigation(currentIndex: 2),
  );

  Widget _buildNoPlantsPage(BuildContext context) => Scaffold(
    backgroundColor: _background,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Belum ada tanaman di akun ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _darkGreen, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.goNamed('plants'),
              child: const Text('Buka Tanamanku'),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
  );

  Widget _buildHistoryPage(
    BuildContext context,
    HistoryPlant selected,
    List<HistoryRecord> records,
  ) {
    return Scaffold(
      backgroundColor: _background,
      body: AppContentLayout(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              HistoryPageHeader(
                title: 'Riwayat Pemeriksaan',
                subtitle: 'Hasil pemeriksaan untuk tanaman ini.',
                fallbackRoute: 'plants',
                action: IconButton(
                  tooltip: 'Sinkronisasi Data',
                  onPressed: () {
                    context.pushNamed('sync-status', extra: selected);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  splashRadius: 22,
                  color: const Color(0xFF2F7D4A),
                  icon: const Icon(Icons.sync_rounded, size: 22),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _buildPlantBanner(selected, historyCount: records.length),
                    const SizedBox(height: 22),
                    _buildSectionHeader(records.length),
                    const SizedBox(height: 12),
                    if (records.isEmpty)
                      _buildEmptyState()
                    else
                      ...records.map(
                        (record) => HistoryCard(
                          record: record,
                          onTap: () {
                            context.pushNamed('history-detail', extra: record);
                          },
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

  Widget _buildPlantBanner(HistoryPlant selected, {required int historyCount}) {
    return Container(
      width: double.infinity,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${selected.id}  •  ${selected.location}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _secondaryText, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '$historyCount hasil pemeriksaan',
                  style: const TextStyle(
                    color: _primaryGreen,
                    fontSize: 11,
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

  Widget _buildSectionHeader(int historyCount) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Semua Riwayat',
            style: TextStyle(
              color: _darkGreen,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor),
          ),
          child: Text(
            '$historyCount scan',
            style: const TextStyle(
              color: _primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, size: 48, color: _secondaryText),
          SizedBox(height: 12),
          Text(
            'Belum ada riwayat pemeriksaan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _darkGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Lakukan scan daun untuk menambahkan riwayat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

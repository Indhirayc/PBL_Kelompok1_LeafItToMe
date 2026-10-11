import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../history/widgets/history_page_header.dart';
import '../data/sync_data.dart';

class SyncStatusPage extends StatefulWidget {
  const SyncStatusPage({super.key});

  @override
  State<SyncStatusPage> createState() => _SyncStatusPageState();
}

class _SyncStatusPageState extends State<SyncStatusPage> {
  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _border = Color(0xFFE3EAE4);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  static const Color _accentGreen = Color(0xFFE8F5E9);
  static const Color _avatarGreen = Color(0xFFDCEFD9);
  static const Color _offlineBg = Color(0xFFFBE9E7);
  static const Color _offlineIconBg = Color(0xFFF6D5D1);
  static const Color _offlineRed = Color(0xFFD32F2F);

  bool _offlineMode = true;
  bool _simulateFailure = false;

  @override
  Widget build(BuildContext context) {
    final List<SyncItem> items = SyncData.items;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HistoryPageHeader(
              title: 'Sinkronisasi Data',
              subtitle: 'Kelola data pemeriksaan yang belum tersinkron.',
              fallbackRoute: 'history',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _buildConnectionBanner(),
                  const SizedBox(height: 16),
                  _buildOfflineToggleCard(),
                  const SizedBox(height: 14),
                  _buildPendingCard(items),
                  const SizedBox(height: 14),
                  _buildSimulateFailureCard(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      key: const Key('syncNowButton'),
                      onPressed: () => context.pushNamed(
                        'sync-process',
                        extra: _simulateFailure,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 19),
                          SizedBox(width: 8),
                          Text('Sinkronkan Sekarang'),
                        ],
                      ),
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

  Widget _buildConnectionBanner() {
    final bool offline = _offlineMode;
    final Color background = offline ? _offlineBg : _accentGreen;
    final Color iconBg = offline ? _offlineIconBg : _avatarGreen;
    final Color iconColor = offline ? _offlineRed : _primaryGreen;
    final String title = offline ? 'Anda Sedang Offline' : 'Anda Sudah Online';
    final String subtitle = offline
        ? 'Data pemeriksaan akan disinkronkan saat kembali online.'
        : 'Data pemeriksaan siap disinkronkan ke penyimpanan cloud.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(
              offline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
              color: iconColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: iconColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: _primaryGreen, size: 22),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode offline',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Simulasi perangkat tanpa koneksi',
                  style: TextStyle(color: _secondaryText, fontSize: 12),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _offlineMode,
              activeTrackColor: _primaryGreen,
              onChanged: (value) => setState(() => _offlineMode = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(List<SyncItem> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync_rounded, color: _primaryGreen, size: 20),
              const SizedBox(width: 10),
              Text(
                '${items.length} data belum disinkronkan',
                style: const TextStyle(
                  color: _darkGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < items.length; i++) ...[
            _buildPendingItem(items[i]),
            if (i != items.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingItem(SyncItem item) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: _avatarGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.eco_rounded, color: _primaryGreen, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.plantName,
                style: const TextStyle(
                  color: _darkGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.diseaseName}  •  ${formatSyncDate(item.date)}',
                style: const TextStyle(color: _secondaryText, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimulateFailureCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: _secondaryText,
            size: 22,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulasikan sinkronisasi gagal',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Untuk menguji tampilan kegagalan',
                  style: TextStyle(color: _secondaryText, fontSize: 12),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _simulateFailure,
              activeTrackColor: _primaryGreen,
              onChanged: (value) => setState(() => _simulateFailure = value),
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
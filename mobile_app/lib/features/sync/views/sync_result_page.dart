import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../history/widgets/history_page_header.dart';
import '../../history/data/history_data.dart';
import '../data/sync_data.dart';

class SyncResultPage extends StatelessWidget {
  const SyncResultPage({
    super.key,
    required this.plant,
    required this.isFailure,
  });

  final HistoryPlant plant;
  final bool isFailure;

  static const Color _background = Color(0xFFF8FAF5);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  static const Color _accentGreen = Color(0xFFE8F5E9);
  static const Color _dangerRed = Color(0xFFD32F2F);
  static const Color _dangerBg = Color(0xFFFBE9E7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HistoryPageHeader(
              title: 'Sinkronisasi Data',
              subtitle: 'Hasil proses sinkronisasi data.',
              fallbackRoute: 'history',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusIcon(),
                    const SizedBox(height: 26),
                    Text(
                      isFailure
                          ? 'Sinkronisasi Gagal'
                          : 'Sinkronisasi Berhasil',
                      style: TextStyle(
                        color: isFailure ? _dangerRed : _primaryGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isFailure
                          ? 'Koneksi terputus saat mengunggah data. Periksa internet lalu coba lagi.'
                          : '${SyncData.items.length} data pemeriksaan berhasil disinkronkan ke penyimpanan cloud.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 34),
                    if (isFailure) ...[
                      _buildPrimaryButton(
                        key: const Key('retrySyncButton'),
                        icon: Icons.refresh_rounded,
                        label: 'Coba Lagi',
                        onPressed: () => context.pushReplacementNamed(
                          'sync-status',
                          extra: plant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        key: const Key('backFromFailureButton'),
                        label: 'Kembali',
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          context.goNamed('history', extra: plant);
                        },
                      ),
                    ] else
                      _buildPrimaryButton(
                        key: const Key('backToHistoryButton'),
                        icon: Icons.history_rounded,
                        label: 'Kembali ke Riwayat',
                        onPressed: () {
                          context.goNamed('history', extra: plant);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isFailure ? _dangerBg : _accentGreen,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isFailure ? _dangerRed : _primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFailure ? Icons.priority_high_rounded : Icons.check_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return AppButton(key: key, icon: icon, label: label, onPressed: onPressed);
  }
}

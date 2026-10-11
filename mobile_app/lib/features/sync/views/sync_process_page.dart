import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../history/widgets/history_page_header.dart';
import '../../history/data/history_data.dart';
import '../data/sync_data.dart';

class SyncProcessPage extends StatefulWidget {
  const SyncProcessPage({
    super.key,
    required this.plant,
    this.isFailure = false,
  });

  final HistoryPlant plant;
  final bool isFailure;

  @override
  State<SyncProcessPage> createState() => _SyncProcessPageState();
}

class _SyncProcessPageState extends State<SyncProcessPage>
    with SingleTickerProviderStateMixin {
  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _border = Color(0xFFE3EAE4);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  static const Color _track = Color(0xFFDFE7E0);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _controller.addStatusListener(_onStatusChanged);
    _controller.forward();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      context.pushReplacementNamed(
        'sync-result',
        extra: <String, dynamic>{
          'plant': widget.plant,
          'isFailure': widget.isFailure,
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              title: 'Menyinkronkan Data',
              subtitle: 'Sedang mengunggah data pemeriksaan.',
              fallbackRoute: 'history',
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final double progress = _controller.value;
                  final int percent = (progress * 100).round();
                  final int index = (progress * items.length).floor().clamp(
                    0,
                    items.length - 1,
                  );
                  final SyncItem current = items[index];

                  return Column(
                    children: [
                      const Spacer(flex: 2),
                      _buildProgressRing(percent, progress),
                      const SizedBox(height: 28),
                      const Text(
                        'Mengunggah data pemeriksaan...',
                        style: TextStyle(
                          color: _darkGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Jangan tutup aplikasi selama proses berlangsung.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildCurrentItemCard(current),
                      ),
                      const Spacer(flex: 3),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing(int percent, double progress) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 9,
              backgroundColor: _track,
              strokeCap: StrokeCap.round,
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              color: _darkGreen,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentItemCard(SyncItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_rounded, color: _primaryGreen, size: 24),
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
      ),
    );
  }
}

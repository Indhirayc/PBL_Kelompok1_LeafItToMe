import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../history/widgets/history_page_header.dart';
import '../../history/data/history_data.dart';
import '../data/sync_data.dart';

class SyncProcessPage extends ConsumerStatefulWidget {
  const SyncProcessPage({
    super.key,
    required this.plant,
    required this.userId,
    required this.items,
    this.isOffline = false,
    this.isFailure = false,
  });

  final HistoryPlant? plant;
  final String userId;
  final List<SyncItem> items;
  final bool isOffline;
  final bool isFailure;

  @override
  ConsumerState<SyncProcessPage> createState() => _SyncProcessPageState();
}

class _SyncProcessPageState extends ConsumerState<SyncProcessPage> {
  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _border = Color(0xFFE3EAE4);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  late final Future<SyncBatchResult> _syncFuture;

  @override
  void initState() {
    super.initState();
    _syncFuture = _syncPendingScans();
    unawaited(_showResultWhenReady());
  }

  Future<SyncBatchResult> _syncPendingScans() async {
    final pendingIds = widget.items.map((item) => item.id);
    if (widget.isFailure) {
      return SyncBatchResult.failed(
        pendingIds,
        StateError('Sinkronisasi gagal sesuai simulasi.'),
      );
    }
    if (widget.isOffline) {
      return SyncBatchResult.offline(pendingIds);
    }

    try {
      return await ref.read(scanRepositoryProvider).triggerSync(widget.userId);
    } catch (error, stackTrace) {
      debugPrint('Sinkronisasi manual gagal: $error\n$stackTrace');
      return SyncBatchResult.failed(pendingIds, error);
    }
  }

  Future<void> _showResultWhenReady() async {
    final result = await _syncFuture;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    HistoryData.markScansSynced(
      userId: widget.userId,
      scanIds: result.syncedIds,
    );
    if (!mounted) return;

    context.pushReplacementNamed(
      'sync-result',
      extra: <String, dynamic>{
        'plant': widget.plant,
        'userId': widget.userId,
        'result': result,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HistoryPageHeader(
              title: 'Menyinkronkan Data',
              subtitle: 'Sedang mengunggah data pemeriksaan.',
              fallbackRoute: 'history',
              fallbackExtra: widget.plant,
            ),
            Expanded(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildProgressIndicator(),
                  const SizedBox(height: 28),
                  const Text(
                    'Mengirim data ke penyimpanan cloud...',
                    style: TextStyle(
                      color: _darkGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Menunggu konfirmasi. Hasil ditampilkan setelah '
                    'penyimpanan merespons.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryText,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (items.isEmpty)
                    const Text('Tidak ada data yang menunggu sinkronisasi.')
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildCurrentItemCard(items.first),
                    ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
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
              value: null,
              strokeWidth: 9,
              strokeCap: StrokeCap.round,
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
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

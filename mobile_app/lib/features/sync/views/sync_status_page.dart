import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../history/data/history_data.dart';
import '../../history/widgets/history_page_header.dart';
import '../data/sync_data.dart';

class SyncStatusPage extends ConsumerStatefulWidget {
  const SyncStatusPage({super.key, this.plant});

  final HistoryPlant? plant;

  @override
  ConsumerState<SyncStatusPage> createState() => _SyncStatusPageState();
}

class _SyncStatusPageState extends ConsumerState<SyncStatusPage> {
  static const Color _background = Color(0xFFF8FAF5);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _border = Color(0xFFE3EAE4);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  static const Color _accentGreen = Color(0xFFE8F5E9);
  static const Color _avatarGreen = Color(0xFFDCEFD9);
  static const Color _errorRed = Color(0xFFD32F2F);
  static const Color _errorBackground = Color(0xFFFBE9E7);

  bool _isLoading = true;
  bool _isSyncing = false;
  String? _loadError;
  String _userId = 'user-local';
  List<SyncItem> _items = const [];
  SyncBatchResult? _lastSyncResult;

  @override
  void initState() {
    super.initState();
    _loadUnsyncedItems();
  }

  Future<void> _loadUnsyncedItems() async {
    try {
      final userId = ref.read(currentUserIdProvider);
      final unsynced = await ref
          .read(scanRepositoryProvider)
          .getUnsyncedScans(userId);
      if (!mounted) return;

      setState(() {
        _userId = userId;
        _items = unsynced.map((scan) {
          final plant = scan.plantId == null
              ? null
              : HistoryData.plantById(scan.plantId!, userId: userId);
          return SyncItem(
            id: scan.id,
            plantName:
                scan.plantName ??
                plant?.name ??
                'Tanaman ${scan.plantId ?? ''}',
            diseaseName: scan.diseaseName,
            date: scan.scannedAt,
          );
        }).toList();
        _loadError = null;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Gagal memuat scan yang menunggu sinkronisasi: $error\n$stackTrace',
      );
      if (mounted) {
        setState(() {
          _loadError = 'Data sinkronisasi belum dapat dimuat.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _syncPendingScans() async {
    final pendingIds = _items.map((item) => item.id).toList();
    setState(() {
      _isSyncing = true;
      _lastSyncResult = null;
    });

    SyncBatchResult result;
    try {
      result = await ref.read(scanRepositoryProvider).triggerSync(_userId);
    } catch (error, stackTrace) {
      debugPrint('Sinkronisasi manual gagal: $error\n$stackTrace');
      result = SyncBatchResult.failed(pendingIds, error);
    }

    HistoryData.markScansSynced(userId: _userId, scanIds: result.syncedIds);
    if (!mounted) return;

    await _loadUnsyncedItems();
    if (!mounted) return;

    setState(() {
      _lastSyncResult = result;
      _isSyncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<SyncItem> items = _items;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: AppContentLayout(
          child: Column(
            children: [
              HistoryPageHeader(
                title: 'Sinkronisasi Data',
                subtitle: 'Kelola data pemeriksaan yang belum tersinkron.',
                fallbackRoute: 'history',
                fallbackExtra: widget.plant,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _buildCloudInfoCard(),
                    const SizedBox(height: 14),
                    _buildPendingCard(items),
                    if (_lastSyncResult != null) ...[
                      const SizedBox(height: 14),
                      _buildSyncResultCard(_lastSyncResult!),
                    ],
                    if (_isSyncing) ...[
                      const SizedBox(height: 18),
                      const LinearProgressIndicator(
                        color: _primaryGreen,
                        backgroundColor: _border,
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Sinkronisasi sedang berlangsung...',
                          style: TextStyle(color: _secondaryText, fontSize: 12),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    AppButton(
                      key: const Key('syncNowButton'),
                      label: _isSyncing
                          ? 'Menyinkronkan...'
                          : 'Sinkronkan Sekarang',
                      onPressed:
                          _isLoading ||
                              _isSyncing ||
                              _loadError != null ||
                              items.isEmpty
                          ? null
                          : _syncPendingScans,
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

  Widget _buildCloudInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_upload_outlined, color: _primaryGreen, size: 26),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sinkronisasi Cloud',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Data tersimpan di perangkat sampai berhasil dikirim.',
            style: TextStyle(color: _secondaryText, fontSize: 12, height: 1.4),
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
              Expanded(
                child: Text(
                  '${items.length} data belum disinkronkan',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_loadError != null)
            Text(
              _loadError!,
              style: const TextStyle(color: _errorRed, fontSize: 13),
            )
          else if (items.isEmpty)
            const Text(
              'Tidak ada data yang menunggu sinkronisasi.',
              style: TextStyle(color: _secondaryText, fontSize: 13),
            )
          else
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

  Widget _buildSyncResultCard(SyncBatchResult result) {
    final hasFailures = result.hasFailures;
    final background = hasFailures ? _errorBackground : _accentGreen;
    final statusColor = hasFailures ? _errorRed : _primaryGreen;
    final title = hasFailures
        ? result.syncedCount == 0
              ? 'Sinkronisasi Gagal'
              : 'Sinkronisasi Sebagian Berhasil'
        : 'Sinkronisasi Berhasil';
    final message = hasFailures
        ? '${result.syncedCount} berhasil, ${result.failedCount} masih tertunda.'
        : result.syncedCount == 0
        ? 'Tidak ada data baru yang perlu disinkronkan.'
        : '${result.syncedCount} data berhasil disinkronkan.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasFailures
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline_rounded,
                color: statusColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (hasFailures && result.errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Detail kegagalan',
              style: TextStyle(
                color: _errorRed,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final error in result.errors)
                      SelectableText(
                        error,
                        style: const TextStyle(
                          color: _secondaryText,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
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

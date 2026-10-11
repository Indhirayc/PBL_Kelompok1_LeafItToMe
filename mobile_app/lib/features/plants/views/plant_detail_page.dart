import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/main_bottom_navigation.dart';
import '../../detection/presentation/pages/data_inspection_page.dart';
import '../../history/data/history_data.dart' hide HistoryRecord;
import 'history_detail_page.dart';
import 'plant_list_page.dart';

class _HistoryPreview {
  const _HistoryPreview({
    required this.disease,
    required this.date,
    required this.accuracy,
    required this.note,
    required this.isHealthy,
  });

  final String disease;
  final String date;
  final String accuracy;
  final String note;
  final bool isHealthy;
}

class PlantDetailPage extends StatelessWidget {
  const PlantDetailPage({super.key, required this.plant});

  final Plant plant;

  List<_HistoryPreview> get _histories {
    // Tanaman pertama mempunyai lima riwayat pemeriksaan.
    if (plant.id == 'TMT-001') {
      return const [
        _HistoryPreview(
          disease: 'Healthy',
          date: '28 Sep 2026',
          accuracy: '96%',
          note: 'Kondisi daun terlihat sehat dan tidak ditemukan gejala penyakit.',
          isHealthy: true,
        ),
        _HistoryPreview(
          disease: 'Bacterial Spot',
          date: '18 Sep 2026',
          accuracy: '89%',
          note: 'Ditemukan bercak gelap berukuran kecil pada permukaan daun.',
          isHealthy: false,
        ),
        _HistoryPreview(
          disease: 'Healthy',
          date: '02 Sep 2026',
          accuracy: '94%',
          note: 'Tanaman berada dalam kondisi sehat berdasarkan hasil pemeriksaan.',
          isHealthy: true,
        ),
        _HistoryPreview(
          disease: 'Leaf Mold',
          date: '24 Agu 2026',
          accuracy: '91%',
          note:
              'Terlihat bercak kekuningan dan lapisan seperti jamur pada daun.',
          isHealthy: false,
        ),
        _HistoryPreview(
          disease: 'Late Blight',
          date: '12 Agu 2026',
          accuracy: '87%',
          note:
              'Ditemukan bercak berwarna cokelat gelap pada bagian tepi daun.',
          isHealthy: false,
        ),
      ];
    }

    // Tanaman kedua mempunyai tiga riwayat pemeriksaan.
    if (plant.id == 'TMT-002') {
      return const [
        _HistoryPreview(
          disease: 'Healthy',
          date: '25 Sep 2026',
          accuracy: '95%',
          note: 'Kondisi tanaman sehat dan daun tidak menunjukkan gejala penyakit.',
          isHealthy: true,
        ),
        _HistoryPreview(
          disease: 'Tomato Yellow Leaf Curl Virus',
          date: '10 Sep 2026',
          accuracy: '90%',
          note: 'Daun terlihat menguning, mengecil, dan melengkung ke bagian atas.',
          isHealthy: false,
        ),
        _HistoryPreview(
          disease: 'Leaf Mold',
          date: '22 Agu 2026',
          accuracy: '88%',
          note: 'Ditemukan bercak kekuningan pada permukaan bagian atas daun.',
          isHealthy: false,
        ),
      ];
    }

    // Tanaman yang baru ditambahkan belum memiliki riwayat.
    return const [];
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hapus Tanaman',
            style: TextStyle(
              color: Color(0xFF1F3826),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus '${plant.name}'?",
            style: const TextStyle(
              color: Color(0xFF65756A),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF65756A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, true);
              },
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlantAvatar({double size = 58}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFDCEFD9),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.eco_rounded,
            color: const Color(0xFF2E7D32),
            size: size * 0.55,
          ),
          Positioned(
            right: size * 0.28,
            bottom: size * 0.25,
            child: Container(
              width: size * 0.18,
              height: size * 0.18,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String date,
    required String accuracy,
    required Color avatarColor,
    required bool isHealthy,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF1B5E20).withValues(alpha: 0.08),
          highlightColor: const Color(0xFF1B5E20).withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3EAE3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isHealthy
                        ? Icons.check_circle_outline_rounded
                        : Icons.warning_amber_rounded,
                    color: isHealthy
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFD7442D),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3826),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF75857B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accuracy,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9BAAA0),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAE3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, color: Color(0xFF91A096), size: 38),
          SizedBox(height: 10),
          Text(
            'Belum ada riwayat pemeriksaan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1F3826),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Lakukan scan daun untuk menambahkan riwayat pemeriksaan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF75857B),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _openHistoryDetail(
    BuildContext context, {
    required _HistoryPreview history,
  }) {
    context.pushNamed(
      'history-detail',
      extra: HistoryRecord(
        plantId: plant.id,
        plantName: plant.name,
        disease: history.disease,
        date: history.date,
        accuracy: history.accuracy,
        note: history.note,
      ),
    );
  }

  void _openAllHistory(BuildContext context) {
    context.pushNamed(
      'history',
      extra: HistoryPlant(
        id: plant.id,
        name: plant.name,
        location: plant.location,
      ),
    );
  }

  void _openInspectionForm(BuildContext context) {
    context.pushNamed(
      'data-inspection',
      extra: InspectionPlant(
        name: plant.name,
        id: plant.id,
        location: plant.location,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_HistoryPreview> recentHistories = _histories.take(3).toList();

    final bool showViewAllButton = _histories.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F3826),
            size: 20,
          ),
        ),
        title: const Text(
          'Detail Tanaman',
          style: TextStyle(
            color: Color(0xFF1F3826),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            tooltip: 'Hapus tanaman',
            onPressed: () {
              _showDeleteDialog(context);
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFE53935),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            // Informasi tanaman.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlantAvatar(size: 60),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F3826),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${plant.id} • ${plant.location}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF65756A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                plant.status,
                                style: const TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ditanam ${plant.plantDate}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF65756A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        key: const Key('scanPlantButton'),
                        onPressed: () {
                          _openInspectionForm(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Scan Daun',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Judul dan tombol Lihat Semua.
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Riwayat Pemeriksaan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3826),
                    ),
                  ),
                ),
                if (showViewAllButton)
                  TextButton(
                    key: const Key('viewAllHistoryButton'),
                    onPressed: () {
                      _openAllHistory(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Kondisi daftar riwayat.
            if (_histories.isEmpty)
              _buildEmptyHistory()
            else
              ...recentHistories.map((history) {
                return _buildHistoryItem(
                  title: history.disease,
                  date: history.date,
                  accuracy: 'Akurasi ${history.accuracy}',
                  avatarColor: history.isHealthy
                      ? const Color(0xFFE2F1E4)
                      : const Color(0xFFFFE0D6),
                  isHealthy: history.isHealthy,
                  onTap: () {
                    _openHistoryDetail(context, history: history);
                  },
                );
              }),

            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }
}

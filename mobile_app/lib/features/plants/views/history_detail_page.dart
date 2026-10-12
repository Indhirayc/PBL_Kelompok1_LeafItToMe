import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/marketplace_button.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';

class HistoryRecord {
  const HistoryRecord({
    required this.plantId,
    required this.plantName,
    required this.disease,
    required this.date,
    required this.accuracy,
    this.plantVariety = 'Solanum lycopersicum',
    this.diseaseScientificName = 'Early Blight • Alternaria solani',
    this.note = 'Tidak ada catatan tambahan.',
  });

  final String plantId;
  final String plantName;
  final String disease;
  final String date;
  final String accuracy;
  final String plantVariety;
  final String diseaseScientificName;
  final String note;
}

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key, required this.record});

  final HistoryRecord record;

  static const Color _backgroundColor = Color(0xFFFAFCF8);
  static const Color _darkGreen = Color(0xFF193B28);
  static const Color _primaryGreen = Color(0xFF2E7D45);
  static const Color _lightGreen = Color(0xFFEAF6E7);
  static const Color _secondaryText = Color(0xFF748079);
  static const Color _borderColor = Color(0xFFE0E9E1);
  static const Color _diseaseRed = Color(0xFFE94B3C);
  static const Color _lightRed = Color(0xFFFFE8E4);

  bool get _isHealthy {
    final diseaseName = record.disease.toLowerCase();

    return diseaseName == 'healthy' || diseaseName == 'sehat';
  }

  Future<void> _openMarketplace(BuildContext context) async {
    final Uri marketplaceUrl = Uri.parse(
      'https://www.tokopedia.com/search'
      '?st=product&q=bakterisida%20tembaga',
    );

    try {
      final bool launched = await launchUrl(
        marketplaceUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showMarketplaceError(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showMarketplaceError(context);
      }
    }
  }

  void _showMarketplaceError(BuildContext context) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Tautan marketplace tidak dapat dibuka.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F3826),
            size: 20,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Detail Riwayat',
          style: TextStyle(
            color: _darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: AppContentLayout(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _PlantInformationCard(record: record),
              const SizedBox(height: 12),
              _DetectionResultCard(record: record, isHealthy: _isHealthy),
              const SizedBox(height: 12),
              _TreatmentCard(isHealthy: _isHealthy),
              const SizedBox(height: 12),
              if (!_isHealthy) ...[
                _MarketplaceSection(
                  onMarketplacePressed: () {
                    _openMarketplace(context);
                  },
                ),
                const SizedBox(height: 12),
              ],
              if (record.note.isNotEmpty &&
                  record.note != 'Tidak ada catatan tambahan.')
                _NoteCard(note: record.note),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }
}

class _PlantInformationCard extends StatelessWidget {
  const _PlantInformationCard({required this.record});

  final HistoryRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HistoryDetailPage._lightGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFD7EFD4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(
              'assets/images/tomato_plant.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.eco_rounded,
                  color: HistoryDetailPage._primaryGreen,
                  size: 42,
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ID ${record.plantId}',
                    style: const TextStyle(
                      color: HistoryDetailPage._primaryGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  record.plantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HistoryDetailPage._darkGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.plantVariety,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HistoryDetailPage._secondaryText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: HistoryDetailPage._primaryGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        record.date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: HistoryDetailPage._secondaryText,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectionResultCard extends StatelessWidget {
  const _DetectionResultCard({required this.record, required this.isHealthy});

  final HistoryRecord record;
  final bool isHealthy;

  double get _confidenceValue {
    final String normalizedValue = record.accuracy.replaceAll('%', '');

    final double parsedValue = double.tryParse(normalizedValue) ?? 0;

    return (parsedValue / 100).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final Color resultColor = isHealthy
        ? HistoryDetailPage._primaryGreen
        : HistoryDetailPage._diseaseRed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HistoryDetailPage._borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Hasil Deteksi',
                  style: TextStyle(
                    color: HistoryDetailPage._darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isHealthy
                      ? HistoryDetailPage._lightGreen
                      : HistoryDetailPage._lightRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: resultColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isHealthy ? 'SEHAT' : 'PERLU PERAWATAN',
                      style: TextStyle(
                        color: resultColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            record.disease,
            style: TextStyle(
              color: resultColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            isHealthy
                ? 'Tidak ditemukan indikasi penyakit'
                : record.diseaseScientificName,
            style: const TextStyle(
              color: HistoryDetailPage._secondaryText,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tingkat keyakinan model',
                  style: TextStyle(
                    color: HistoryDetailPage._secondaryText,
                    fontSize: 10,
                  ),
                ),
              ),
              Text(
                record.accuracy,
                style: const TextStyle(
                  color: HistoryDetailPage._darkGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _confidenceValue,
              minHeight: 6,
              backgroundColor: const Color(0xFFEAF0EA),
              valueColor: AlwaysStoppedAnimation<Color>(resultColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.isHealthy});

  final bool isHealthy;

  @override
  Widget build(BuildContext context) {
    final List<String> treatments = isHealthy
        ? const [
            'Lanjutkan penyiraman tanaman secara teratur.',
            'Pastikan tanaman mendapatkan sinar matahari yang cukup.',
            'Lakukan pemeriksaan daun secara berkala.',
          ]
        : const [
            'Pangkas daun yang menunjukkan bercak.',
            'Hindari menyiram langsung ke permukaan daun.',
            'Periksa kembali kondisi tanaman dalam 3 hari.',
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HistoryDetailPage._borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saran Penanganan',
            style: TextStyle(
              color: HistoryDetailPage._darkGreen,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (int index = 0; index < treatments.length; index++)
            _TreatmentItem(
              number: index + 1,
              text: treatments[index],
              showBottomSpacing: index != treatments.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TreatmentItem extends StatelessWidget {
  const _TreatmentItem({
    required this.number,
    required this.text,
    required this.showBottomSpacing,
  });

  final int number;
  final String text;
  final bool showBottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: showBottomSpacing ? 12 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFDCEFD9),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: HistoryDetailPage._primaryGreen,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: const TextStyle(
                  color: HistoryDetailPage._darkGreen,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketplaceSection extends StatelessWidget {
  const _MarketplaceSection({required this.onMarketplacePressed});

  final VoidCallback onMarketplacePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6, bottom: 7),
          child: Text(
            'Produk Pendukung',
            style: TextStyle(
              color: HistoryDetailPage._darkGreen,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD5E5D6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5F1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD8E0D8)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.local_drink_outlined,
                      color: Color(0xFF8EA08F),
                      size: 34,
                    ),
                    Positioned(
                      bottom: 10,
                      child: Container(
                        width: 21,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: HistoryDetailPage._primaryGreen,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bakterisida Tembaga',
                      style: TextStyle(
                        color: HistoryDetailPage._darkGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Referensi produk pendukung untuk membantu '
                      'mengendalikan bakteri.',
                      style: TextStyle(
                        color: HistoryDetailPage._secondaryText,
                        fontSize: 9,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MarketplaceButton(onPressed: onMarketplacePressed),
                    const SizedBox(height: 5),
                    const Text(
                      'Produk hanya sebagai referensi. '
                      'Transaksi dilakukan di luar aplikasi.',
                      style: TextStyle(
                        color: HistoryDetailPage._secondaryText,
                        fontSize: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HistoryDetailPage._borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notes_rounded,
                color: HistoryDetailPage._primaryGreen,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Catatan Pemeriksaan',
                style: TextStyle(
                  color: HistoryDetailPage._darkGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            note,
            style: const TextStyle(
              color: HistoryDetailPage._secondaryText,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

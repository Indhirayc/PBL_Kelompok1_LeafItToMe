
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_page_header.dart';
import 'photo_preview_page.dart';
import '../../../history/data/history_data.dart';
import '../widgets/confidence_indicator.dart';
import '../widgets/plant_context_card.dart';

class DetectionResultPage extends StatefulWidget {
  const DetectionResultPage({
    super.key,
    required this.selection,
  });

  final InspectionPhotoSelection selection;

  @override
  State<DetectionResultPage> createState() => _DetectionResultPageState();
}

class _DetectionResultPageState extends State<DetectionResultPage> {
  static const Color _background = Color(0xFFFBFCF9);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF718478);
  static const Color _border = Color(0xFFE4EBE5);
  static const Color _paleGreen = Color(0xFFEEF6E8);

  HistoryRecord? _detectionRecord;

  bool get _hasPrediction =>
      widget.selection.predictionResult != null;

  @override
  void initState() {
    super.initState();

    // Jangan membuat riwayat atau hasil palsu jika prediksi tidak tersedia.
    final prediction = widget.selection.predictionResult;

    if (prediction == null) {
      return;
    }

    final draft = widget.selection.draft;
    final diseaseLabel = prediction.label;
    final isHealthyClass =
        diseaseLabel.trim().toLowerCase() == 'healthy';

    final confidenceScore =
        prediction.confidencePercentage.round().clamp(0, 100);

    _detectionRecord = HistoryRecord(
      id: 'DET-${DateTime.now().microsecondsSinceEpoch}',
      plantId: draft.plant.id,
      diseaseName: diseaseLabel,
      latinName:
          isHealthyClass ? 'Solanum lycopersicum' : 'Pathogen spp.',
      date: draft.inspectionDate,
      accuracy: confidenceScore,
      isHealthy: isHealthyClass,
      note: draft.note,
      isSynced: false,
      plantName: draft.plant.name,
      plantLocation: draft.plant.location,
      photoAssetPath: widget.selection.imageFile?.path ??
          InspectionPhotoSelection.sampleImageAsset,
      photoSource: widget.selection.source,
    );

    // Hindari menambahkan record ketika prediksi tidak tersedia.
    HistoryData.records.add(_detectionRecord!);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPrediction || _detectionRecord == null) {
      return _buildMissingPredictionPage(context);
    }

    final prediction = widget.selection.predictionResult!;
    final diseaseLabel = prediction.label;
    final confidenceScore =
        prediction.confidencePercentage.round().clamp(0, 100);

    final isHealthyClass =
        diseaseLabel.trim().toLowerCase() == 'healthy';

    return Scaffold(
      backgroundColor: _background,
      body: AppContentLayout(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      _buildResultPhoto(confidenceScore),
                      const SizedBox(height: 20),
                      InspectionPlantContextCard(
                        name: widget.selection.draft.plant.name,
                        id: widget.selection.draft.plant.id,
                        location: widget.selection.draft.plant.location,
                      ),
                      const SizedBox(height: 18),
                      _buildDiseaseCard(
                        diseaseLabel,
                        confidenceScore,
                        isHealthyClass,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        key: const Key('treatmentButton'),
                        label: isHealthyClass
                            ? 'Lihat Panduan Perawatan ›'
                            : 'Lihat Penanganan ›',
                        onPressed: () => context.pushNamed(
                          'treatment-recommendation',
                          extra: _detectionRecord!,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Prediksi diproses secara lokal menggunakan '
                        'TensorFlow Lite. Hasil merupakan estimasi model, '
                        'bukan diagnosis profesional.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Halaman pengaman jika hasil model belum tersedia.
  Widget _buildMissingPredictionPage(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: AppContentLayout(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 56,
                          color: Color(0xFFB7791F),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Hasil prediksi belum tersedia',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _darkGreen,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Silakan kembali dan jalankan deteksi '
                          'pada gambar daun tomat terlebih dahulu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _secondaryText,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'Kembali',
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppPageHeader(
      title: 'Hasil Deteksi',
      showBackButton: true,
      onBack: () => context.pop(),
    );
  }

  Widget _buildResultPhoto(int confidence) {
    final imageFile = widget.selection.imageFile;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageFile != null
              ? Image.file(
                  imageFile,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageError();
                  },
                )
              : Image.asset(
                  InspectionPhotoSelection.sampleImageAsset,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageError();
                  },
                ),
        ),
        Positioned(
          bottom: -12,
          child: ConfidenceIndicator(
            percentage: confidence,
            isExample: imageFile == null,
          ),
        ),
      ],
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 280,
      width: double.infinity,
      color: _paleGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 48,
        color: _secondaryText,
      ),
    );
  }

  Widget _buildDiseaseCard(
    String diseaseName,
    int confidence,
    bool isHealthy,
  ) {
    final displayName = _getDisplayName(diseaseName);

    final statusColor = isHealthy
        ? const Color(0xFF2F7D46)
        : const Color(0xFFB94135);

    final statusBackground = isHealthy
        ? _paleGreen
        : const Color(0xFFFFE6E2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHealthy
                      ? Icons.check_circle_outline
                      : Icons.fact_check_outlined,
                  color: statusColor,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  isHealthy ? 'Daun Sehat' : 'Klasifikasi TFLite',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: const TextStyle(
              color: _darkGreen,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Tingkat Kepercayaan: $confidence%',
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _paleGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan Model',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                _SymptomItem(
                  text: isHealthy
                      ? 'Model mengklasifikasikan gambar sebagai daun sehat.'
                      : 'Model mengklasifikasikan gambar sebagai $displayName.',
                ),
                const SizedBox(height: 4),
                const _SymptomItem(
                  text: 'Hasil merupakan prediksi model dan perlu '
                      'diperiksa kembali jika gejala tidak sesuai.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayName(String label) {
    switch (label.trim()) {
      case 'Bacterial_spot':
        return 'Bacterial Spot (Bercak Bakteri)';
      case 'Late_blight':
        return 'Late Blight (Busuk Daun)';
      case 'Leaf_Mold':
        return 'Leaf Mold (Kapang Daun)';
      case 'Tomato_Yellow_Leaf_Curl_Virus':
        return 'Tomato Yellow Leaf Curl Virus';
      case 'healthy':
        return 'Daun Tomat Sehat';
      default:
        return label.replaceAll('_', ' ');
    }
  }
}

class _SymptomItem extends StatelessWidget {
  const _SymptomItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: Color(0xFF477254),
            fontSize: 11,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF477254),
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_page_header.dart';
import 'photo_preview_page.dart';
import '../../../history/data/history_data.dart';
import '../widgets/confidence_indicator.dart';
import '../widgets/image_preview.dart';
import '../widgets/plant_context_card.dart';

class DetectionResultPage extends StatefulWidget {
  const DetectionResultPage({super.key, required this.selection});

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

  late final HistoryRecord _detectionRecord;

  @override
  void initState() {
    super.initState();
    final draft = widget.selection.draft;
    _detectionRecord = HistoryRecord(
      id: 'DET-${DateTime.now().microsecondsSinceEpoch}',
      plantId: draft.plant.id,
      diseaseName: 'Bacterial Spot',
      latinName: 'Xanthomonas spp.',
      date: draft.inspectionDate,
      accuracy: 94,
      isHealthy: false,
      note: draft.note,
      plantName: draft.plant.name,
      plantLocation: draft.plant.location,
      photoAssetPath: InspectionPhotoSelection.sampleImageAsset,
      photoSource: widget.selection.source,
    );
    HistoryData.records.add(_detectionRecord);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    _buildResultPhoto(),
                    const SizedBox(height: 20),
                    InspectionPlantContextCard(
                      name: widget.selection.draft.plant.name,
                      id: widget.selection.draft.plant.id,
                      location: widget.selection.draft.plant.location,
                    ),
                    const SizedBox(height: 18),
                    _buildDiseaseCard(),
                    const SizedBox(height: 12),
                    AppButton(
                      key: const Key('treatmentButton'),
                      label: 'Lihat Penanganan  ›',
                      onPressed: () => context.pushNamed(
                        'treatment-recommendation',
                        extra: _detectionRecord,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Hasil contoh ditambahkan ke riwayat sementara sesi ini; '
                      'belum tersimpan permanen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 10,
                        height: 1.4,
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return AppPageHeader(
      title: 'Hasil Deteksi',
      showBackButton: true,
      onBack: () => context.pop(),
    );
  }

  Widget _buildResultPhoto() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        ImagePreview(
          imageAsset: InspectionPhotoSelection.sampleImageAsset,
          semanticLabel: 'Contoh foto daun tomat untuk hasil deteksi',
          aspectRatio: 1.08,
          showFrameCorners: false,
          padding: 10,
        ),
        Positioned(
          bottom: -12,
          child: const ConfidenceIndicator(percentage: 94, isExample: true),
        ),
      ],
    );
  }

  Widget _buildDiseaseCard() {
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6E2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  color: Color(0xFFB94135),
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  'Contoh klasifikasi',
                  style: TextStyle(
                    color: Color(0xFFB94135),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bacterial Spot',
            style: TextStyle(
              color: _darkGreen,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Contoh hasil pada tanaman tomat',
            style: TextStyle(color: _secondaryText, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _paleGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contoh gejala',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                _SymptomItem(text: 'Bercak cokelat kehitaman pada daun'),
                SizedBox(height: 4),
                _SymptomItem(text: 'Daun mulai menguning'),
              ],
            ),
          ),
        ],
      ),
    );
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
          '•  ',
          style: TextStyle(color: Color(0xFF477254), fontSize: 11),
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

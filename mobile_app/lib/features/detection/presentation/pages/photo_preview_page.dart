import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_page_header.dart';
import 'data_inspection_page.dart';
import '../widgets/image_preview.dart';

class InspectionPhotoSelection {
  const InspectionPhotoSelection({required this.draft, required this.source});

  final InspectionDraft draft;
  final String source;

  static const String sampleImageAsset = 'assets/images/leaf_mold.jpg';
}

class PhotoPreviewPage extends StatelessWidget {
  const PhotoPreviewPage({super.key, required this.selection});

  final InspectionPhotoSelection selection;

  static const Color _background = Color(0xFFFBFCF9);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _primaryGreen = Color(0xFF1F7338);
  static const Color _secondaryText = Color(0xFF718478);
  static const Color _paleGreen = Color(0xFFEEF6E8);

  void _analyzeSample(BuildContext context) {
    context.pushNamed('detection-result', extra: selection);
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
                    ImagePreview(
                      imageAsset: InspectionPhotoSelection.sampleImageAsset,
                      semanticLabel: 'Contoh foto daun tomat',
                      source: selection.source,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pastikan daun terlihat jelas dan tidak buram.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _secondaryText, fontSize: 11),
                    ),
                    const SizedBox(height: 14),
                    _buildSampleNotice(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        key: const Key('retakePhotoButton'),
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Ambil Ulang'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryGreen,
                          side: const BorderSide(color: _primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        key: const Key('analyzeNowButton'),
                        onPressed: () => _analyzeSample(context),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text('Analisis Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPrivacyNotice(),
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
      title: 'Preview Foto',
      showBackButton: true,
      onBack: () => context.pop(),
    );
  }

  Widget _buildSampleNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2C4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF94701A), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Foto ini hanya contoh tampilan. Kamera dan galeri belum terhubung.',
              style: TextStyle(
                color: Color(0xFF715815),
                fontSize: 10,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _paleGreen,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        children: [
          Icon(Icons.phone_android_rounded, color: _darkGreen, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contoh alur analisis',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Belum menjalankan pemrosesan foto.',
                  style: TextStyle(color: _secondaryText, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

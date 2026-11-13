
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/tflite_service.dart';
import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_page_header.dart';
import 'data_inspection_page.dart';

class InspectionPhotoSelection {
  const InspectionPhotoSelection({
    required this.draft,
    required this.source,
    this.imageFile,
    this.predictionResult,
  });

  final InspectionDraft draft;
  final String source;
  final File? imageFile;
  final PredictionResult? predictionResult;

  static const String sampleImageAsset = 'assets/images/leaf_mold.jpg';
}

class PhotoPreviewPage extends StatefulWidget {
  const PhotoPreviewPage({
    super.key,
    required this.selection,
  });

  final InspectionPhotoSelection selection;

  @override
  State<PhotoPreviewPage> createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends State<PhotoPreviewPage> {
  static const Color _background = Color(0xFFFBFCF9);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _primaryGreen = Color(0xFF1F7338);
  static const Color _secondaryText = Color(0xFF718478);
  static const Color _paleGreen = Color(0xFFEEF6E8);

  bool _isAnalyzing = false;

  Future<void> _analyzeImage() async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final imageFile = widget.selection.imageFile;

      // Muat gambar contoh sebelum operasi asynchronous lainnya
      // agar tidak menggunakan context setelah await.
      Uint8List? sampleBytes;

      if (imageFile == null) {
        final byteData = await rootBundle.load(
          InspectionPhotoSelection.sampleImageAsset,
        );

        sampleBytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
      }

      if (!mounted) return;

      final tfliteService = TfliteService.instance;
      await tfliteService.initModel();

      if (!mounted) return;

      late final PredictionResult result;

      if (imageFile != null) {
        if (!await imageFile.exists()) {
          throw Exception(
            'File foto tidak ditemukan. Silakan pilih foto kembali.',
          );
        }

        if (!mounted) return;

        result = await tfliteService.predictImageFile(imageFile);
      } else {
        result = await tfliteService.predictImageBytes(sampleBytes!);
      }

      if (!mounted) return;

      final updatedSelection = InspectionPhotoSelection(
        draft: widget.selection.draft,
        source: widget.selection.source,
        imageFile: widget.selection.imageFile,
        predictionResult: result,
      );

      context.pushNamed(
        'detection-result',
        extra: updatedSelection,
      );
    } on InvalidPlantImageException catch (e) {
      if (kDebugMode) {
        debugPrint('Gambar ditolak: ${e.message}');
      }

      if (!mounted) return;

      _showMessage(
        e.message,
        backgroundColor: Colors.orange.shade800,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error saat inferensi TFLite: $e');
        debugPrint('$stackTrace');
      }

      if (!mounted) return;

      _showMessage(
        'Analisis gagal. Periksa foto dan konfigurasi model, '
        'lalu coba kembali.',
        backgroundColor: Colors.red.shade700,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    required Color backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = widget.selection.imageFile;

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
                      const SizedBox(height: 12),
                      const Text(
                        'Pastikan daun terlihat jelas dan tidak buram.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSampleNotice(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          key: const Key('retakePhotoButton'),
                          onPressed: _isAnalyzing
                              ? null
                              : () => context.pop(),
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 18,
                          ),
                          label: const Text('Ambil Ulang'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryGreen,
                            side: const BorderSide(
                              color: _primaryGreen,
                            ),
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
                          onPressed: _isAnalyzing
                              ? null
                              : _analyzeImage,
                          iconAlignment: IconAlignment.end,
                          icon: _isAnalyzing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                          label: Text(
                            _isAnalyzing
                                ? 'Menganalisis...'
                                : 'Analisis Sekarang',
                          ),
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

  Widget _buildImageError() {
    return Container(
      height: 280,
      width: double.infinity,
      color: _paleGreen,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 42,
            color: _secondaryText,
          ),
          SizedBox(height: 8),
          Text(
            'Foto tidak dapat ditampilkan',
            style: TextStyle(
              color: _secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF94701A),
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gunakan foto daun tomat yang jelas untuk '
              'mendapatkan hasil prediksi yang lebih baik.',
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
          Icon(
            Icons.phone_android_rounded,
            color: _darkGreen,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'On-Device Inference',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Prediksi diproses secara lokal tanpa internet.',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

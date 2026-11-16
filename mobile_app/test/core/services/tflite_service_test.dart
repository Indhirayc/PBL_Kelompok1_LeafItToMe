import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/tflite_service.dart';

void main() {
  group('TfliteService & Two-Stage Validation Tests', () {
    test('PredictionResult memformat displayLabel dan confidencePercentage dengan benar', () {
      const result = PredictionResult(
        label: 'Bacterial_spot',
        confidence: 0.954,
        allScores: {
          'Bacterial_spot': 0.954,
          'Late_blight': 0.02,
          'Leaf_Mold': 0.01,
          'Tomato_Yellow_Leaf_Curl_Virus': 0.006,
          'healthy': 0.01,
        },
        leafConfidence: 0.99,
      );

      expect(result.displayLabel, 'Bacterial Spot');
      expect(result.confidencePercentage, closeTo(95.4, 0.01));
      expect(result.leafConfidence, 0.99);
    });

    test('displayLabel memetakan seluruh 5 kelas daun tomat secara tepat', () {
      final mapping = {
        'Bacterial_spot': 'Bacterial Spot',
        'Late_blight': 'Late Blight',
        'Leaf_Mold': 'Leaf Mold',
        'Tomato_Yellow_Leaf_Curl_Virus': 'Tomato Yellow Leaf Curl Virus',
        'healthy': 'Sehat',
      };

      for (final entry in mapping.entries) {
        final res = PredictionResult(
          label: entry.key,
          confidence: 0.9,
          allScores: {entry.key: 0.9},
        );
        expect(res.displayLabel, entry.value);
      }
    });

    test('InvalidPlantImageException menyimpan pesan penolakan gambar dengan benar', () {
      const msg = 'Gambar tidak terdeteksi sebagai daun tomat. '
          'Silakan ambil atau pilih foto daun tomat yang jelas.';
      const exception = InvalidPlantImageException(msg);

      expect(exception.message, msg);
      expect(exception.toString(), msg);
    });

    test('Konfigurasi ambang batas validasi Stage 1 dan keyakinan Stage 2 sesuai spesifikasi', () {
      expect(TfliteService.leafValidationThreshold, 0.70);
      expect(TfliteService.confidenceThreshold, 0.60);
      expect(TfliteService.enableValidationStage, isTrue);
      expect(TfliteService.normalizationMode, NormalizationMode.rawZeroTo255);
    });
  });
}

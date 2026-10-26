
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Menyimpan hasil prediksi model daun tomat.
class PredictionResult {
  final String label;
  final double confidence;
  final Map<String, double> allScores;

  const PredictionResult({
    required this.label,
    required this.confidence,
    required this.allScores,
  });

  double get confidencePercentage => confidence * 100;

  /// Nama kelas untuk ditampilkan di UI.
  /// Label asli tetap dipertahankan untuk pencocokan data.
  String get displayLabel {
    const displayNames = <String, String>{
      'Bacterial_spot': 'Bacterial Spot',
      'Late_blight': 'Late Blight',
      'Leaf_Mold': 'Leaf Mold',
      'Tomato_Yellow_Leaf_Curl_Virus':
          'Tomato Yellow Leaf Curl Virus',
      'healthy': 'Sehat',
    };

    return displayNames[label] ?? label.replaceAll('_', ' ');
  }
}

/// Mode normalisasi input.
enum NormalizationMode {
  zeroToOne,
  minusOneToOne,
  rawZeroTo255,
}

/// Error untuk gambar yang tidak lolos pemeriksaan confidence.
/// Confidence rendah bukan detektor objek non-daun yang pasti.
class InvalidPlantImageException implements Exception {
  final String message;

  const InvalidPlantImageException(this.message);

  @override
  String toString() => message;
}

class TfliteService {
  TfliteService._internal();

  static final TfliteService instance = TfliteService._internal();

  static const String _modelPath =
      'assets/models/leafittome_mobilenetv2.tflite';

  static const String _labelsPath = 'assets/models/labels.txt';
  static const int _inputSize = 224;

  /// Ambang awal untuk pengujian.
  /// Nilai lebih rendah dapat meningkatkan penerimaan prediksi
  /// yang kurang yakin, tetapi tidak menjamin gambar adalah daun tomat.
  static const double confidenceThreshold = 0.60;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  /// Model memiliki preprocess_input di dalam arsitekturnya.
  /// Karena itu input diberikan sebagai RGB float32 0–255.
  static const NormalizationMode normalizationMode =
      NormalizationMode.rawZeroTo255;

  bool get isInitialized => _isInitialized;

  List<String> get labels => List.unmodifiable(_labels);

  Future<void> initModel() async {
    if (_isInitialized && _interpreter != null) return;

    Interpreter? loadedInterpreter;

    try {
      loadedInterpreter = await Interpreter.fromAsset(_modelPath);

      final rawLabels = await rootBundle.loadString(_labelsPath);

      final labels = rawLabels
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (labels.isEmpty) {
        throw Exception('File labels.txt tidak berisi label kelas.');
      }

      final inputTensor = loadedInterpreter.getInputTensor(0);
      final outputTensor = loadedInterpreter.getOutputTensor(0);

      final inputShape = inputTensor.shape;
      final outputShape = outputTensor.shape;

      if (inputTensor.type != TensorType.float32) {
        throw Exception(
          'Tipe input model ${inputTensor.type} tidak sesuai '
          'dengan preprocessing float32 pada service ini.',
        );
      }

      if (outputTensor.type != TensorType.float32) {
        throw Exception(
          'Tipe output model ${outputTensor.type} tidak didukung '
          'oleh service ini.',
        );
      }

      if (inputShape.length != 4 ||
          inputShape[0] != 1 ||
          inputShape[1] != _inputSize ||
          inputShape[2] != _inputSize ||
          inputShape[3] != 3) {
        throw Exception(
          'Bentuk input yang diharapkan [1, 224, 224, 3], '
          'tetapi didapat $inputShape.',
        );
      }

      if (outputShape.length != 2 ||
          outputShape[0] != 1 ||
          outputShape[1] <= 0) {
        throw Exception(
          'Bentuk output model tidak didukung: $outputShape.',
        );
      }

      if (labels.length != outputShape[1]) {
        throw Exception(
          'Jumlah label (${labels.length}) tidak sesuai '
          'dengan jumlah kelas output (${outputShape[1]}).',
        );
      }

      _interpreter = loadedInterpreter;
      _labels = labels;
      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('=== Model LeafItToMe berhasil dimuat ===');
        debugPrint('Input shape: $inputShape');
        debugPrint('Input type: ${inputTensor.type}');
        debugPrint('Output shape: $outputShape');
        debugPrint('Output type: ${outputTensor.type}');
        debugPrint('Normalisasi input: $normalizationMode');
        debugPrint('Confidence threshold: $confidenceThreshold');
        debugPrint('Labels: $_labels');
      }
    } catch (e, stackTrace) {
      loadedInterpreter?.close();
      _interpreter?.close();

      _interpreter = null;
      _labels = [];
      _isInitialized = false;

      if (kDebugMode) {
        debugPrint('Gagal memuat model TFLite: $e');
        debugPrint('$stackTrace');
      }

      rethrow;
    }
  }

  Future<PredictionResult> predictImageFile(File imageFile) async {
    if (!await imageFile.exists()) {
      throw Exception('File gambar tidak ditemukan.');
    }

    final bytes = await imageFile.readAsBytes();
    return predictImageBytes(bytes);
  }

  Future<PredictionResult> predictImageBytes(
    Uint8List imageBytes,
  ) async {
    if (imageBytes.isEmpty) {
      throw Exception('File gambar kosong.');
    }

    if (!_isInitialized || _interpreter == null) {
      await initModel();
    }

    final interpreter = _interpreter!;

    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception(
        'Gagal membaca gambar. Gunakan format gambar yang valid.',
      );
    }

    final orientedImage = img.bakeOrientation(decodedImage);

    final resizedImage = img.copyResize(
      orientedImage,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    final inputTensor = _buildInputTensor(resizedImage);

    final outputShape = interpreter.getOutputTensor(0).shape;
    final numClasses = outputShape[1];

    final outputTensor = <List<double>>[
      List<double>.filled(numClasses, 0.0),
    ];

    interpreter.run(inputTensor, outputTensor);

    final scores = outputTensor[0];

    if (scores.isEmpty || scores.any((score) => !score.isFinite)) {
      throw Exception(
        'Model menghasilkan skor prediksi yang tidak valid.',
      );
    }

    if (scores.any((score) => score < 0.0 || score > 1.0)) {
      throw Exception(
        'Output model berada di luar rentang probabilitas 0–1. '
        'Periksa kembali output model TFLite.',
      );
    }

    if (scores.length != _labels.length) {
      throw Exception(
        'Jumlah skor prediksi tidak sesuai dengan jumlah label.',
      );
    }

    // Output softmax digunakan langsung tanpa softmax kedua.
    final totalProbability = scores.fold<double>(
      0.0,
      (sum, score) => sum + score,
    );

    if (totalProbability < 0.98 || totalProbability > 1.02) {
      throw Exception(
        'Output model tidak menyerupai distribusi softmax '
        '(jumlah skor: $totalProbability).',
      );
    }

    var bestIndex = 0;
    var maxScore = scores[0];

    final allScores = <String, double>{};

    for (var i = 0; i < scores.length; i++) {
      allScores[_labels[i]] = scores[i];

      if (scores[i] > maxScore) {
        maxScore = scores[i];
        bestIndex = i;
      }
    }

    if (kDebugMode) {
      debugPrint('=== Prediksi LeafItToMe ===');
      debugPrint('Skor mentah output: $scores');
      debugPrint('Semua skor: $allScores');
      debugPrint('Label asli: ${_labels[bestIndex]}');
      debugPrint(
        'Nama tampilan: '
        '${PredictionResult(
          label: _labels[bestIndex],
          confidence: maxScore,
          allScores: allScores,
        ).displayLabel}',
      );
      debugPrint(
        'Confidence: ${(maxScore * 100).toStringAsFixed(2)}%',
      );
    }

    if (maxScore < confidenceThreshold) {
      throw const InvalidPlantImageException(
        'Hasil prediksi kurang meyakinkan. '
        'Silakan gunakan foto daun tomat yang lebih jelas.',
      );
    }

    return PredictionResult(
      label: _labels[bestIndex],
      confidence: maxScore,
      allScores: allScores,
    );
  }

  /// Membentuk tensor RGB float32 dengan bentuk [1, 224, 224, 3].
  List<List<List<List<double>>>> _buildInputTensor(img.Image image) {
    return [
      List.generate(_inputSize, (y) {
        return List.generate(_inputSize, (x) {
          final pixel = image.getPixel(x, y);

          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();

          switch (normalizationMode) {
            case NormalizationMode.zeroToOne:
              return [r / 255.0, g / 255.0, b / 255.0];

            case NormalizationMode.minusOneToOne:
              return [
                (r / 127.5) - 1.0,
                (g / 127.5) - 1.0,
                (b / 127.5) - 1.0,
              ];

            case NormalizationMode.rawZeroTo255:
              return [r, g, b];
          }
        });
      }),
    ];
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = [];
    _isInitialized = false;
  }
}

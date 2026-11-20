class DiseaseLabel {
  const DiseaseLabel({
    required this.documentId,
    required this.labelCode,
    required this.canonicalName,
    required this.displayName,
    required this.detectionDisplayName,
    required this.modelLabel,
    required this.aliases,
    required this.latinName,
  });

  final String documentId;
  final String labelCode;
  final String canonicalName;
  final String displayName;
  final String detectionDisplayName;
  final String modelLabel;
  final List<String> aliases;
  final String latinName;
}

abstract final class DiseaseLabelMapper {
  static const List<DiseaseLabel> labels = [
    DiseaseLabel(
      documentId: 'P001',
      labelCode: 'Bacterial_Spot',
      canonicalName: 'Bacterial Spot',
      displayName: 'Bacterial Spot',
      detectionDisplayName: 'Bacterial Spot (Bercak Bakteri)',
      modelLabel: 'Bacterial_spot',
      aliases: ['bacterial-spot', 'Bacterial Spot (Bercak Bakteri)'],
      latinName: 'Xanthomonas spp.',
    ),
    DiseaseLabel(
      documentId: 'P002',
      labelCode: 'Late_Blight',
      canonicalName: 'Late Blight',
      displayName: 'Late Blight',
      detectionDisplayName: 'Late Blight (Busuk Daun)',
      modelLabel: 'Late_blight',
      aliases: ['late-blight', 'Late Blight (Busuk Daun)'],
      latinName: 'Phytophthora infestans',
    ),
    DiseaseLabel(
      documentId: 'P003',
      labelCode: 'Leaf_Mold',
      canonicalName: 'Leaf Mold',
      displayName: 'Leaf Mold',
      detectionDisplayName: 'Leaf Mold (Kapang Daun)',
      modelLabel: 'Leaf_Mold',
      aliases: ['leaf-mold', 'Leaf Mold (Kapang Daun)'],
      latinName: 'Passalora fulva',
    ),
    DiseaseLabel(
      documentId: 'P004',
      labelCode: 'TYLCV',
      canonicalName: 'Tomato Yellow Leaf Curl Virus (TYLCV)',
      displayName: 'Tomato Yellow Leaf Curl Virus',
      detectionDisplayName: 'Tomato Yellow Leaf Curl Virus',
      modelLabel: 'Tomato_Yellow_Leaf_Curl_Virus',
      aliases: [
        'tylcv',
        'Tomato Yellow Leaf Curl Virus',
        'tomato-yellow-leaf-curl-virus',
      ],
      latinName: 'Begomovirus',
    ),
    DiseaseLabel(
      documentId: 'P005',
      labelCode: 'Healthy',
      canonicalName: 'Healthy',
      displayName: 'Sehat',
      detectionDisplayName: 'Daun Tomat Sehat',
      modelLabel: 'healthy',
      aliases: ['sehat', 'Daun Tomat Sehat'],
      latinName: 'Solanum lycopersicum',
    ),
  ];

  static DiseaseLabel? resolve(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final normalized = _normalizeKey(value);
    for (final label in labels) {
      final candidates = [
        label.documentId,
        label.labelCode,
        label.canonicalName,
        label.displayName,
        label.detectionDisplayName,
        label.modelLabel,
        ...label.aliases,
      ];
      if (candidates.any(
        (candidate) => _normalizeKey(candidate) == normalized,
      )) {
        return label;
      }
    }
    return null;
  }

  static String canonicalName(String? value) {
    final label = resolve(value);
    if (label != null) return label.canonicalName;
    return _fallbackName(value);
  }

  static String displayName(String? value) {
    final label = resolve(value);
    if (label != null) return label.displayName;
    return _fallbackName(value);
  }

  static String detectionDisplayName(String? value) {
    final label = resolve(value);
    if (label != null) return label.detectionDisplayName;
    return _fallbackName(value);
  }

  static String latinName(String? value) {
    final label = resolve(value);
    if (label != null) return label.latinName;
    return isHealthy(value) ? 'Solanum lycopersicum' : 'Xanthomonas spp.';
  }

  static String? documentId(String? value) => resolve(value)?.documentId;

  static String normalizeName(String value) {
    final label = resolve(value);
    return _normalizeKey(label?.canonicalName ?? value);
  }

  static bool isHealthy(String? value) => resolve(value)?.documentId == 'P005';

  static bool matches(String? first, String? second) {
    final firstLabel = resolve(first);
    final secondLabel = resolve(second);
    if (firstLabel != null && secondLabel != null) {
      return firstLabel.documentId == secondLabel.documentId;
    }
    return normalizeName(first ?? '') == normalizeName(second ?? '');
  }

  static String _fallbackName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Penyakit tidak diketahui';
    }
    return value.replaceAll('_', ' ').replaceAll('-', ' ').trim();
  }

  static String _normalizeKey(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

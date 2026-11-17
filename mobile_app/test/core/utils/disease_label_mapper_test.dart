import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/utils/disease_label_mapper.dart';

void main() {
  test('maps all TFLite labels to their Firestore disease IDs', () {
    const modelLabels = {
      'Bacterial_spot': 'P001',
      'Late_blight': 'P002',
      'Leaf_Mold': 'P003',
      'Tomato_Yellow_Leaf_Curl_Virus': 'P004',
      'healthy': 'P005',
    };

    for (final entry in modelLabels.entries) {
      expect(
        DiseaseLabelMapper.documentId(entry.key),
        entry.value,
        reason: entry.key,
      );
    }
  });

  test('resolves model, master-data, display, and document-ID aliases', () {
    const aliases = {
      'Bacterial_Spot': 'P001',
      'Tomato Yellow Leaf Curl Virus (TYLCV)': 'P004',
      'TYLCV': 'P004',
      'P005': 'P005',
      'Sehat': 'P005',
    };

    for (final entry in aliases.entries) {
      expect(
        DiseaseLabelMapper.documentId(entry.key),
        entry.value,
        reason: entry.key,
      );
    }
  });

  test('uses the canonical and display labels for each known disease', () {
    expect(
      DiseaseLabelMapper.canonicalName('Tomato_Yellow_Leaf_Curl_Virus'),
      'Tomato Yellow Leaf Curl Virus (TYLCV)',
    );
    expect(DiseaseLabelMapper.displayName('healthy'), 'Sehat');
    expect(
      DiseaseLabelMapper.detectionDisplayName('Bacterial_spot'),
      'Bacterial Spot (Bercak Bakteri)',
    );
    expect(
      DiseaseLabelMapper.matches('Tomato_Yellow_Leaf_Curl_Virus', 'TYLCV'),
      isTrue,
    );
  });

  test('preserves readable names for unknown model labels', () {
    expect(
      DiseaseLabelMapper.displayName('Unmapped_Disease'),
      'Unmapped Disease',
    );
    expect(DiseaseLabelMapper.documentId('Unmapped_Disease'), isNull);
  });
}

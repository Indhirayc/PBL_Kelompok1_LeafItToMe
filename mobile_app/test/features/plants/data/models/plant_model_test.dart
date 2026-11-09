import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/plants/data/models/plant_model.dart';
import 'package:mobile_app/features/plants/models/plant.dart';

void main() {
  group('PlantModel', () {
    const plant = Plant(
      id: 'plant-1',
      name: 'Tomat Pot Depan',
      location: 'Teras',
      plantedDate: '28 Sep 2026',
      lastInspectionDate: '12 Okt 2026',
      status: 'Sehat',
      note: 'Tanaman tumbuh baik',
    );

    test('round-trips the existing Plant entity and all fields', () {
      final model = PlantModel.fromEntity(plant);

      expect(model.toEntity().id, plant.id);
      expect(model.toEntity().name, plant.name);
      expect(model.toEntity().location, plant.location);
      expect(model.toEntity().plantedDate, plant.plantedDate);
      expect(model.toEntity().lastInspectionDate, plant.lastInspectionDate);
      expect(model.toEntity().status, plant.status);
      expect(model.toEntity().note, plant.note);
    });

    test('serializes and deserializes API JSON fields', () {
      final model = PlantModel.fromJson({
        'id': 'plant-1',
        'name': 'Tomat Pot Depan',
        'location': 'Teras',
        'planted_date': '28 Sep 2026',
        'last_inspection_date': '12 Okt 2026',
        'status': 'Sehat',
        'note': 'Tanaman tumbuh baik',
      });

      expect(PlantModel.fromJson(model.toJson()).toEntity().note, plant.note);
      expect(model.toEntity().plantedDate, plant.plantedDate);
      expect(model.toEntity().lastInspectionDate, plant.lastInspectionDate);
    });

    test('uses safe empty values for missing or malformed fields', () {
      final model = PlantModel.fromJson({
        'id': 12,
        'name': null,
        'planted_date': 123,
      });

      expect(model.id, isEmpty);
      expect(model.name, isEmpty);
      expect(model.plantedDate, isEmpty);
      expect(model.lastInspectionDate, isEmpty);
      expect(model.note, isNull);
    });
  });
}

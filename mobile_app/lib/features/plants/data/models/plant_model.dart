import '../../models/plant.dart';

class PlantModel {
  const PlantModel({
    required this.id,
    required this.name,
    required this.location,
    required this.plantedDate,
    required this.status,
    required this.lastInspectionDate,
    this.note,
  });

  final String id;
  final String name;
  final String location;
  final String plantedDate;
  final String status;
  final String lastInspectionDate;
  final String? note;

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    final note = json['note'];
    return PlantModel(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      location: _readString(json, 'location'),
      plantedDate: _readDate(json, 'planted_date', 'plantedDate'),
      status: _readString(json, 'status'),
      lastInspectionDate: _readDate(
        json,
        'last_inspection_date',
        'lastInspectionDate',
      ),
      note: note is String ? note : null,
    );
  }

  factory PlantModel.fromEntity(Plant plant) {
    return PlantModel(
      id: plant.id,
      name: plant.name,
      location: plant.location,
      plantedDate: plant.plantedDate,
      status: plant.status,
      lastInspectionDate: plant.lastInspectionDate,
      note: plant.note,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'planted_date': plantedDate,
    'status': status,
    'last_inspection_date': lastInspectionDate,
    'note': note,
  };

  Plant toEntity() => Plant(
    id: id,
    name: name,
    location: location,
    plantedDate: plantedDate,
    status: status,
    lastInspectionDate: lastInspectionDate,
    note: note,
  );

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String ? value : '';
  }

  static String _readDate(
    Map<String, dynamic> json,
    String snakeCaseKey,
    String camelCaseKey,
  ) {
    final value = json[snakeCaseKey] ?? json[camelCaseKey];
    // Entity dates are display-ready strings; keeping them as strings preserves
    // existing UI formatting while safely accepting missing/invalid values.
    return value is String ? value : '';
  }
}

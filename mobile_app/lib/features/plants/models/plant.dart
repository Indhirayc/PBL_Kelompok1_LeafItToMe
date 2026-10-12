class Plant {
  const Plant({
    required this.id,
    required this.name,
    required this.location,
    required this.plantedDate,
    required this.lastInspectionDate,
    required this.status,
    this.note,
  });

  final String id;
  final String name;
  final String location;
  final String plantedDate;
  final String lastInspectionDate;
  final String status;
  final String? note;

  Plant copyWith({
    String? id,
    String? name,
    String? location,
    String? plantedDate,
    String? lastInspectionDate,
    String? status,
    String? note,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      plantedDate: plantedDate ?? this.plantedDate,
      lastInspectionDate: lastInspectionDate ?? this.lastInspectionDate,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}

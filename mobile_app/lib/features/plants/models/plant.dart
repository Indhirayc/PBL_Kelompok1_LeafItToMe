class Plant {
  const Plant({
    required this.id,
    required this.name,
    required this.location,
    required this.plantedDate,
    required this.lastInspectionDate,
    required this.status,
    this.note,
    this.userId = 'user-local',
    this.imagePath,
  });

  final String id;
  final String name;
  final String location;
  final String plantedDate;
  final String lastInspectionDate;
  final String status;
  final String? note;
  final String userId;
  final String? imagePath;

  Plant copyWith({
    String? id,
    String? name,
    String? location,
    String? plantedDate,
    String? lastInspectionDate,
    String? status,
    String? note,
    String? userId,
    String? imagePath,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      plantedDate: plantedDate ?? this.plantedDate,
      lastInspectionDate: lastInspectionDate ?? this.lastInspectionDate,
      status: status ?? this.status,
      note: note ?? this.note,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

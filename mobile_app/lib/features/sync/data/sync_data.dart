const List<String> _syncMonthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String formatSyncDate(DateTime date) =>
    '${date.day} ${_syncMonthNames[date.month - 1]} ${date.year}';

class SyncItem {
  final String id;
  final String plantName;
  final String diseaseName;
  final DateTime date;

  const SyncItem({
    required this.id,
    required this.plantName,
    required this.diseaseName,
    required this.date,
  });
}

abstract final class SyncData {
  static final List<SyncItem> items = [
    SyncItem(
      id: 'S-001',
      plantName: 'Tomat Pot Depan',
      diseaseName: 'Bacterial Spot',
      date: DateTime(2026, 9, 18),
    ),
    SyncItem(
      id: 'S-002',
      plantName: 'Tomat Kebun Belakang',
      diseaseName: 'Leaf Mold',
      date: DateTime(2026, 9, 26),
    ),
    SyncItem(
      id: 'S-003',
      plantName: 'Tomat Kebun Belakang',
      diseaseName: 'Late Blight',
      date: DateTime(2026, 9, 12),
    ),
  ];
}
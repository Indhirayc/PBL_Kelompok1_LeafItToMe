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

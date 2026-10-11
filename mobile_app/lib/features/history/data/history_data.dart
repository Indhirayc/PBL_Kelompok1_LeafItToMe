import 'package:flutter/material.dart';

const List<String> _historyMonthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String formatHistoryDate(DateTime date) =>
    '${date.day} ${_historyMonthNames[date.month - 1]} ${date.year}';

class HistoryPlant {
  final String id;
  final String name;
  final String location;

  const HistoryPlant({
    required this.id,
    required this.name,
    required this.location,
  });
}

class HistoryDisease {
  final String name;
  final String latinName;
  final String category;
  final String severity;
  final Color severityColor;
  final List<String> symptoms;
  final List<String> preventions;
  final List<String> treatments;
  final String searchKeyword;

  const HistoryDisease({
    required this.name,
    required this.latinName,
    required this.category,
    required this.severity,
    required this.severityColor,
    required this.symptoms,
    required this.preventions,
    required this.treatments,
    required this.searchKeyword,
  });
}

class HistoryRecord {
  final String id;
  final String plantId;
  final String diseaseName;
  final String latinName;
  final DateTime date;
  final int accuracy;
  final bool isHealthy;
  final String note;

  const HistoryRecord({
    required this.id,
    required this.plantId,
    required this.diseaseName,
    required this.latinName,
    required this.date,
    required this.accuracy,
    required this.isHealthy,
    required this.note,
  });
}

abstract final class HistoryData {
  static const List<HistoryPlant> plants = [
    HistoryPlant(id: 'TMT-001', name: 'Tomat Pot Depan', location: 'Teras depan'),
    HistoryPlant(
      id: 'TMT-002',
      name: 'Tomat Kebun Belakang',
      location: 'Kebun belakang',
    ),
  ];

  static final List<HistoryRecord> records = [
    HistoryRecord(
      id: 'H-001',
      plantId: 'TMT-001',
      diseaseName: 'Healthy',
      latinName: 'Solanum lycopersicum',
      date: DateTime(2026, 9, 28),
      accuracy: 96,
      isHealthy: true,
      note: 'Daun tampak hijau segar, tidak ditemukan bercak.',
    ),
    HistoryRecord(
      id: 'H-002',
      plantId: 'TMT-001',
      diseaseName: 'Bacterial Spot',
      latinName: 'Xanthomonas spp.',
      date: DateTime(2026, 9, 18),
      accuracy: 89,
      isHealthy: false,
      note: 'Terdapat bercak cokelat pada beberapa daun.',
    ),
    HistoryRecord(
      id: 'H-003',
      plantId: 'TMT-001',
      diseaseName: 'Healthy',
      latinName: 'Solanum lycopersicum',
      date: DateTime(2026, 9, 2),
      accuracy: 94,
      isHealthy: true,
      note: 'Tanaman dalam kondisi sehat.',
    ),
    HistoryRecord(
      id: 'H-004',
      plantId: 'TMT-002',
      diseaseName: 'Leaf Mold',
      latinName: 'Passalora fulva',
      date: DateTime(2026, 9, 26),
      accuracy: 87,
      isHealthy: false,
      note: 'Bercak kuning pada daun bagian bawah.',
    ),
    HistoryRecord(
      id: 'H-005',
      plantId: 'TMT-002',
      diseaseName: 'Late Blight',
      latinName: 'Phytophthora infestans',
      date: DateTime(2026, 9, 12),
      accuracy: 91,
      isHealthy: false,
      note: 'Bercak basah kehitaman di tepi daun.',
    ),
  ];

  static const HistoryDisease bacterialSpot = HistoryDisease(
    name: 'Bacterial Spot',
    latinName: 'Xanthomonas spp.',
    category: 'Bakteri',
    severity: 'Risiko Sedang',
    severityColor: Color(0xFFE65100),
    symptoms: [
      'Bercak cokelat kehitaman pada daun',
      'Daun menguning dan mengering',
      'Bercak dapat menyebar ke buah',
    ],
    preventions: [
      'Hindari menyiram bagian daun',
      'Jaga jarak antar tanaman',
      'Gunakan benih bebas penyakit',
    ],
    treatments: [
      'Pangkas dan buang daun yang terinfeksi',
      'Aplikasikan bakterisida berbahan tembaga',
      'Kurangi kelembapan berlebih di sekitar tanaman',
    ],
    searchKeyword: 'bakterisida tembaga bacterial spot tomat',
  );

  static const HistoryDisease leafMold = HistoryDisease(
    name: 'Leaf Mold',
    latinName: 'Passalora fulva',
    category: 'Jamur Daun',
    severity: 'Perlu Perawatan',
    severityColor: Color(0xFFE65100),
    symptoms: [
      'Bercak kuning pucat pada permukaan atas daun',
      'Lapisan beludru abu-abu di bawah daun',
      'Daun mengering dan gugur',
    ],
    preventions: [
      'Tingkatkan sirkulasi udara di sekitar tanaman',
      'Pangkas daun tua bagian bawah',
      'Jaga permukaan daun tetap kering',
    ],
    treatments: [
      'Pangkas daun yang terinfeksi',
      'Aplikasikan fungisida berbahan mankozeb',
      'Kurangi kelembapan kandang tanaman',
    ],
    searchKeyword: 'fungisida mancozeb obat jamur daun tomat',
  );

  static const HistoryDisease lateBlight = HistoryDisease(
    name: 'Late Blight',
    latinName: 'Phytophthora infestans',
    category: 'Jamur (Oomycete)',
    severity: 'Risiko Tinggi',
    severityColor: Color(0xFFD32F2F),
    symptoms: [
      'Bercak kehitaman basah pada daun dan batang',
      'Lapisan putih seperti kapas di balik daun',
      'Daun cepat layu dan membusuk',
    ],
    preventions: [
      'Musnahkan bagian tanaman yang bergejala',
      'Hindari menyiram dari atas daun',
      'Beri jarak antar pot agar sirkulasi lancar',
    ],
    treatments: [
      'Buang dan musnahkan daun terinfeksi',
      'Aplikasikan fungisida berbasis tembaga',
      'Perbaiki drainase dan sirkulasi udara',
    ],
    searchKeyword: 'fungisida tembaga busuk daun late blight',
  );

  static const Map<String, HistoryDisease> _diseasesByName = {
    'Bacterial Spot': bacterialSpot,
    'Leaf Mold': leafMold,
    'Late Blight': lateBlight,
  };

  static HistoryDisease? byDisease(String? name) {
    if (name == null) {
      return null;
    }
    return _diseasesByName[name];
  }

  static HistoryPlant? plantById(String id) {
    for (final plant in plants) {
      if (plant.id == id) {
        return plant;
      }
    }
    return null;
  }
}
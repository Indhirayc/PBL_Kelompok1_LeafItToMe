import 'package:flutter/material.dart';

import '../../../../core/utils/disease_label_mapper.dart';
import '../../../../data/models/scan_record_model.dart';
import '../../../../data/repositories/plant_repository.dart';
import '../../../../data/repositories/scan_repository.dart';

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
  final String userId;

  const HistoryPlant({
    required this.id,
    required this.name,
    required this.location,
    this.userId = 'user-local',
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
  final bool isSynced;
  final String? plantName;
  final String? plantLocation;
  final String? photoAssetPath;
  final String? photoSource;
  final String userId;

  const HistoryRecord({
    required this.id,
    required this.plantId,
    required this.diseaseName,
    required this.latinName,
    required this.date,
    required this.accuracy,
    required this.isHealthy,
    required this.note,
    this.isSynced = true,
    this.plantName,
    this.plantLocation,
    this.photoAssetPath,
    this.photoSource,
    this.userId = 'user-local',
  });

  HistoryRecord copyWith({bool? isSynced}) {
    return HistoryRecord(
      id: id,
      plantId: plantId,
      diseaseName: diseaseName,
      latinName: latinName,
      date: date,
      accuracy: accuracy,
      isHealthy: isHealthy,
      note: note,
      isSynced: isSynced ?? this.isSynced,
      plantName: plantName,
      plantLocation: plantLocation,
      photoAssetPath: photoAssetPath,
      photoSource: photoSource,
      userId: userId,
    );
  }
}

abstract final class HistoryData {
  static final List<HistoryPlant> plants = [
    HistoryPlant(
      id: 'TMT-001',
      name: 'Tomat Pot Depan',
      location: 'Teras depan',
    ),
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
      plantId: 'TMT-001',
      diseaseName: 'Leaf Mold',
      latinName: 'Passalora fulva',
      date: DateTime(2026, 8, 24),
      accuracy: 91,
      isHealthy: false,
      note: 'Terlihat bercak kekuningan dan lapisan seperti jamur pada daun.',
    ),
    HistoryRecord(
      id: 'H-005',
      plantId: 'TMT-001',
      diseaseName: 'Late Blight',
      latinName: 'Phytophthora infestans',
      date: DateTime(2026, 8, 12),
      accuracy: 87,
      isHealthy: false,
      note: 'Ditemukan bercak berwarna cokelat gelap pada bagian tepi daun.',
    ),
    HistoryRecord(
      id: 'H-006',
      plantId: 'TMT-002',
      diseaseName: 'Healthy',
      latinName: 'Solanum lycopersicum',
      date: DateTime(2026, 9, 25),
      accuracy: 95,
      isHealthy: true,
      note: 'Kondisi tanaman sehat dan daun tidak menunjukkan gejala penyakit.',
    ),
    HistoryRecord(
      id: 'H-007',
      plantId: 'TMT-002',
      diseaseName: 'Leaf Mold',
      latinName: 'Passalora fulva',
      date: DateTime(2026, 9, 10),
      accuracy: 88,
      isHealthy: false,
      note: 'Ditemukan bercak kekuningan pada permukaan bagian atas daun.',
    ),
    HistoryRecord(
      id: 'H-008',
      plantId: 'TMT-002',
      diseaseName: 'Late Blight',
      latinName: 'Phytophthora infestans',
      date: DateTime(2026, 8, 22),
      accuracy: 90,
      isHealthy: false,
      note: 'Ditemukan bercak basah kehitaman pada bagian tepi daun.',
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
      'Siram langsung ke media tanam dan hindari membasahi daun, terutama pada sore atau malam hari.',
      'Beri jarak tanam yang cukup agar sirkulasi udara baik dan daun cepat kering setelah terkena air.',
      'Gunakan benih atau bibit sehat bersertifikat, serta bersihkan alat pemangkasan sebelum digunakan kembali.',
    ],
    treatments: [
      'Pangkas bagian daun yang menunjukkan gejala, lalu buang dengan aman dan jangan dijadikan kompos.',
      'Gunakan bakterisida berbahan aktif tembaga yang sesuai untuk tomat dan ikuti petunjuk pada label produk.',
      'Kurangi kelembapan di sekitar tanaman dengan memperbaiki sirkulasi udara dan menghindari penyiraman berlebih.',
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

  static const Map<String, HistoryDisease> _diseasesById = {
    'P001': bacterialSpot,
    'P002': lateBlight,
    'P003': leafMold,
  };

  static String normalizeDiseaseName(String value) =>
      DiseaseLabelMapper.normalizeName(value);

  /// Nama penyakit yang digunakan untuk ditampilkan di UI.
  static String displayDiseaseName(String? name) =>
      DiseaseLabelMapper.displayName(name);

  static bool isHealthyName(String? name) => DiseaseLabelMapper.isHealthy(name);

  static HistoryDisease? byDisease(String? name) {
    final documentId = DiseaseLabelMapper.documentId(name);
    return documentId == null ? null : _diseasesById[documentId];
  }

  static HistoryPlant? plantById(String id, {String userId = 'user-local'}) {
    for (final plant in plants) {
      if (plant.id == id && plant.userId == userId) {
        return plant;
      }
    }

    return null;
  }

  static List<HistoryPlant> plantsForUser(String userId) =>
      plants.where((plant) => plant.userId == userId).toList();

  static Future<void> loadPersistedPlants({
    PlantRepository? repository,
    String userId = 'user-local',
  }) async {
    final persistedPlants = await (repository ?? PlantRepository()).getAll(
      userId: userId,
    );
    for (final plant in persistedPlants) {
      final historyPlant = HistoryPlant(
        id: plant.id,
        name: plant.name,
        location: plant.location,
        userId: plant.userId,
      );
      final index = plants.indexWhere(
        (item) => item.id == plant.id && item.userId == plant.userId,
      );
      if (index == -1) {
        plants.add(historyPlant);
      } else {
        plants[index] = historyPlant;
      }
    }
  }

  static List<HistoryRecord> recordsByPlantId(
    String plantId, {
    String userId = 'user-local',
  }) {
    final recordsForPlant = records
        .where((record) => record.plantId == plantId && record.userId == userId)
        .toList();

    recordsForPlant.sort((first, second) => second.date.compareTo(first.date));

    return recordsForPlant;
  }

  static void markScansSynced({
    required String userId,
    required Iterable<String> scanIds,
  }) {
    final syncedIds = scanIds.toSet();
    for (var index = 0; index < records.length; index++) {
      final record = records[index];
      if (record.userId == userId && syncedIds.contains(record.id)) {
        records[index] = record.copyWith(isSynced: true);
      }
    }
  }

  /// Memuat riwayat yang tersimpan di SQLite (milik user yang sedang login)
  /// lalu menggabungkannya ke [records] berdasarkan ID.
  /// Data contoh di atas tetap dipakai bila database kosong/gagal dimuat.
  static final Set<String> _persistedLoadedUserIds = {};

  static Future<void> loadPersistedRecords({
    String userId = 'user-local',
  }) async {
    if (_persistedLoadedUserIds.contains(userId)) return;
    try {
      await loadPersistedPlants(userId: userId);
      if (userId == 'user-local') {
        _persistedLoadedUserIds.add(userId);
        return;
      }

      final scans = await ScanRepository().getUserHistory(userId);
      final existingIds = records
          .where((record) => record.userId == userId)
          .map((record) => record.id)
          .toSet();
      for (final scan in scans) {
        if (existingIds.contains(scan.id)) continue;
        records.add(recordFromScan(scan));
      }
      _persistedLoadedUserIds.add(userId);
    } catch (e) {
      debugPrint('Gagal memuat riwayat tersimpan: $e');
    }
  }

  static HistoryRecord recordFromScan(ScanRecordModel scan) {
    final disease = byDisease(scan.diseaseName);
    return HistoryRecord(
      id: scan.id,
      plantId: scan.plantId ?? '',
      diseaseName: DiseaseLabelMapper.canonicalName(scan.diseaseName),
      latinName: disease?.latinName ?? '',
      date: scan.scannedAt,
      accuracy: (scan.confidence * 100).round().clamp(0, 100).toInt(),
      isHealthy: isHealthyName(scan.diseaseName),
      note: scan.notes ?? '',
      isSynced: scan.isSynced,
      plantName: scan.plantName,
      plantLocation: scan.plantLocation,
      userId: scan.userId,
      photoAssetPath: scan.localImagePath,
    );
  }
}

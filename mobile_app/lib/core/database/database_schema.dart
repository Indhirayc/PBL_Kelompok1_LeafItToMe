/// Cetak biru (DDL) database SQLite LeafItToMe — versi 2 (ringkas).
///
/// Berbasis tabel `scan_history` milik layer data (branch `develop`): menyimpan
/// riwayat scan offline, **PATH** foto tanaman (`local_image_path`, bukan isi
/// gambarnya), serta antrian sinkronisasi (`is_synced`/`synced_at`).
///
/// Versi 2 menambahkan kolom `synced_at` agar antrian tercatat lengkap
/// (kapan tepatnya sebuah baris berhasil diunggah), melengkapi `is_synced`.
library;

const int kLeafItToMeDatabaseVersion = 2;

/// Urutan pembuatan tabel. Dipakai `AppDatabase` saat membuat database baru.
const List<String> kLeafItToMeSchema = <String>[
  '''
CREATE TABLE scan_history (
  id               TEXT PRIMARY KEY,
  user_id          TEXT NOT NULL,
  disease_name     TEXT NOT NULL,
  confidence       REAL NOT NULL,
  local_image_path TEXT NOT NULL,
  cloud_image_url  TEXT,
  notes            TEXT,
  scanned_at       TEXT NOT NULL,
  is_synced        INTEGER NOT NULL DEFAULT 0,
  synced_at        TEXT
)''',
];

/// Nama tabel yang dikelola skema ini (untuk keperluan perawatan/migrasi).
const List<String> kLeafItToMeTables = <String>[
  'scan_history',
];
/// Cetak biru (DDL) database SQLite LeafItToMe — versi 2.
///
/// Bersumber dari `leafittome_schema.sql` (log kerja offline-first). Intinya:
/// riwayat scan (`detections`) sebagai pusat, antrian sinkronisasi lewat
/// `is_synced`/`synced_at`, gambar tanaman disimpan sebagai PATH (`images`),
/// serta foto profil pengguna sebagai BLOB di dalam `users`.
///
/// Catatan: bagian TRIGGER dari file `.sql` sengaja tidak disertakan karena
/// berisi titik-koma internal yang membingungkan saat dieksekusi per-statement.
/// Kolom waktu (`updated_at`) diisi oleh kode aplikasi.
const int kLeafItToMeDatabaseVersion = 2;

/// Nama view yang dibuat skema ini (dibutuhkan saat membangun ulang DB).
const List<String> kLeafItToMeViews = <String>[
  'v_detection_details',
];

/// Urutan pembuatan tabel (tabel induk lebih dulu agar foreign key valid).
const List<String> kLeafItToMeSchema = <String>[
  '''
CREATE TABLE severity_levels (
  id        INTEGER PRIMARY KEY,
  label     TEXT NOT NULL UNIQUE,
  color_hex TEXT NOT NULL
)''',
  '''
CREATE TABLE images (
  id         INTEGER PRIMARY KEY,
  file_path  TEXT NOT NULL UNIQUE,
  source     TEXT CHECK (source IN ('camera', 'gallery')),
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
)''',
  '''
CREATE TABLE users (
  id                 INTEGER PRIMARY KEY,
  email              TEXT NOT NULL UNIQUE,
  full_name          TEXT NOT NULL,
  phone              TEXT,
  profile_photo      BLOB,
  profile_photo_mime TEXT,
  created_at         TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at         TEXT NOT NULL DEFAULT (datetime('now'))
)''',
  '''
CREATE TABLE diseases (
  id             INTEGER PRIMARY KEY,
  name           TEXT NOT NULL UNIQUE,
  latin_name     TEXT,
  category       TEXT,
  severity_id    INTEGER REFERENCES severity_levels(id) ON DELETE SET NULL,
  search_keyword TEXT
)''',
  '''
CREATE TABLE disease_symptoms (
  disease_id INTEGER NOT NULL REFERENCES diseases(id) ON DELETE CASCADE,
  position   INTEGER NOT NULL,
  text       TEXT NOT NULL,
  PRIMARY KEY (disease_id, position)
)''',
  '''
CREATE TABLE disease_preventions (
  disease_id INTEGER NOT NULL REFERENCES diseases(id) ON DELETE CASCADE,
  position   INTEGER NOT NULL,
  text       TEXT NOT NULL,
  PRIMARY KEY (disease_id, position)
)''',
  '''
CREATE TABLE disease_treatments (
  disease_id INTEGER NOT NULL REFERENCES diseases(id) ON DELETE CASCADE,
  position   INTEGER NOT NULL,
  text       TEXT NOT NULL,
  PRIMARY KEY (disease_id, position)
)''',
  '''
CREATE TABLE plants (
  id                   INTEGER PRIMARY KEY,
  code                 TEXT NOT NULL UNIQUE,
  user_id              INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name                 TEXT NOT NULL,
  location             TEXT,
  planted_date         TEXT,
  status               TEXT CHECK (status IN ('Sehat', 'Perlu perhatian', 'Perlu perawatan')),
  last_inspection_date TEXT,
  note                 TEXT,
  created_at           TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at           TEXT NOT NULL DEFAULT (datetime('now'))
)''',
  '''
CREATE TABLE detections (
  id           INTEGER PRIMARY KEY,
  code         TEXT UNIQUE,
  user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plant_id     INTEGER NOT NULL REFERENCES plants(id) ON DELETE CASCADE,
  image_id     INTEGER REFERENCES images(id) ON DELETE SET NULL,
  disease_id   INTEGER REFERENCES diseases(id) ON DELETE SET NULL,
  is_healthy   INTEGER NOT NULL CHECK (is_healthy IN (0, 1)),
  accuracy     INTEGER NOT NULL CHECK (accuracy BETWEEN 0 AND 100),
  note         TEXT,
  inspected_at TEXT NOT NULL,
  is_synced    INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
  synced_at    TEXT,
  created_at   TEXT NOT NULL DEFAULT (datetime('now')),
  CHECK (is_healthy = 0 OR disease_id IS NULL)
)''',
  'CREATE INDEX idx_plants_user ON plants(user_id)',
  'CREATE INDEX idx_plants_status ON plants(status)',
  'CREATE INDEX idx_detections_plant ON detections(plant_id)',
  'CREATE INDEX idx_detections_user ON detections(user_id)',
  'CREATE INDEX idx_detections_disease ON detections(disease_id)',
  'CREATE INDEX idx_detections_image ON detections(image_id)',
  'CREATE INDEX idx_detections_inspected ON detections(inspected_at)',
  'CREATE INDEX idx_detections_sync ON detections(is_synced)',
  'CREATE INDEX idx_diseases_severity ON diseases(severity_id)',
  '''
CREATE VIEW v_detection_details AS
SELECT
  d.id           AS detection_id,
  d.code         AS detection_code,
  u.full_name    AS user_name,
  p.code         AS plant_code,
  p.name         AS plant_name,
  p.location     AS plant_location,
  dz.name        AS disease_name,
  dz.latin_name  AS latin_name,
  sev.label      AS severity,
  sev.color_hex  AS severity_color,
  d.accuracy     AS accuracy,
  d.is_healthy   AS is_healthy,
  d.note         AS note,
  d.inspected_at AS inspected_at,
  d.is_synced    AS is_synced,
  d.synced_at    AS synced_at,
  im.file_path   AS photo_path,
  im.source      AS photo_source
FROM detections d
JOIN plants  p   ON p.id  = d.plant_id
JOIN users   u   ON u.id  = d.user_id
LEFT JOIN diseases        dz  ON dz.id  = d.disease_id
LEFT JOIN severity_levels sev ON sev.id = dz.severity_id
LEFT JOIN images          im  ON im.id  = d.image_id''',
];

/// Urutan penghapusan tabel (anak lebih dulu) untuk membangun ulang DB.
const List<String> kLeafItToMeTables = <String>[
  'detections',
  'disease_symptoms',
  'disease_preventions',
  'disease_treatments',
  'plants',
  'diseases',
  'images',
  'users',
  'severity_levels',
];
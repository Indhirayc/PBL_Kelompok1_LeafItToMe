# Handoff Tugas — Implementasi Database SQLite LeafItToMe

Dokumen ini untuk teman yang mengerjakan **layer database SQLite**. Batasannya jelas: **hanya SQLite**, belum Firebase, belum Cloudinary, belum UI.

- Tanggal: 2026-11-09
- Branch kerja: `feature/sqlite-v2`
- Estimasi: 1–2 hari kerja
- Fokus: schema, migrasi, model, repository, test

---

## 1. Konteks singkat

Aplikasi Flutter LeafItToMe memakai:

```text
Flutter UI -> SQLite (cache + antrian sync) -> Firestore -> Cloudinary
```

SQLite adalah **source of truth untuk UI** dan **antrian sinkronisasi**. Firestore hanya tujuan sync. Jadi pekerjaan ini tidak boleh bergantung pada Firebase.

Kondisi saat ini:

- `main` belum punya `sqflite`, `path`, `uuid`.
- `app_database.dart` hanya ada di branch `features` (versi 1, satu tabel `scan_history`).
- `scan_record_model.dart` masih meng-import `cloud_firestore`.
- `sync_manager.dart` meng-import file remote yang tidak ada di `main`.

---

## 2. Batas pekerjaan

### Boleh diubah

```text
mobile_app/pubspec.yaml
mobile_app/lib/data/datasources/local/
mobile_app/lib/data/models/
mobile_app/lib/data/repositories/
mobile_app/test/data/
```

### Jangan diubah

```text
mobile_app/lib/features/          <- UI
mobile_app/lib/core/router/       <- navigasi
mobile_app/lib/core/sync/         <- ditunda sampai fase Firebase
firestore.rules
firestore.indexes.json
```

### Jangan dipakai

- Firebase / Firestore / Cloudinary
- MySQL / Laravel
- State management UI

---

## 3. Langkah 1 — Setup branch dan dependency

```powershell
cd 'D:\Semester 5\PBL\PBL_Kelompok1_LeafItToMe'
git switch main
git pull
git switch -c feature/sqlite-v2

# Ambil implementasi SQLite v1 dari branch features
git checkout features -- mobile_app/lib/data/datasources/local/app_database.dart
```

Tambahkan ke `mobile_app/pubspec.yaml`:

```yaml
dependencies:
  sqflite: ^2.4.1
  path: ^1.9.0
  uuid: ^4.5.1

dev_dependencies:
  sqflite_common_ffi: ^2.3.4
```

Lalu:

```powershell
cd mobile_app
flutter pub get
```

Catatan: `sqflite_common_ffi` hanya untuk unit test di Windows/CI. Di Android tetap memakai `sqflite`.

---

## 4. Langkah 2 — Struktur folder

```text
lib/data/
├── datasources/
│   └── local/
│       ├── app_database.dart
│       ├── plant_dao.dart
│       ├── scan_dao.dart
│       ├── master_data_dao.dart
│       └── sync_queue_dao.dart
├── models/
│   ├── plant_model.dart
│   ├── scan_record_model.dart
│   ├── disease_model.dart
│   ├── guide_model.dart
│   ├── tool_model.dart
│   └── product_model.dart
└── repositories/
    ├── plant_repository.dart
    ├── scan_repository.dart
    └── master_data_repository.dart
```

`AppDatabase` hanya bertanggung jawab membuka database dan membuat/migrasi tabel. Query taruh di DAO.

---

## 5. Langkah 3 — Schema SQLite v2

Buat 8 tabel. Semua tanggal disimpan sebagai **TEXT ISO 8601 UTC**. Boolean disimpan sebagai **INTEGER 0/1**.

```sql
PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- Tanaman milik user
-- ---------------------------------------------------------------------------
CREATE TABLE plants (
  id                 TEXT PRIMARY KEY,
  user_id            TEXT NOT NULL,
  kode_tanaman       TEXT,
  name               TEXT NOT NULL,
  location           TEXT,
  planted_date       TEXT,                 -- YYYY-MM-DD
  health_status      TEXT NOT NULL DEFAULT 'sehat',
  last_inspection_at TEXT,                 -- ISO 8601
  note               TEXT,
  created_at         TEXT NOT NULL,
  updated_at         TEXT NOT NULL,
  deleted_at         TEXT,                 -- soft delete
  sync_status        TEXT NOT NULL DEFAULT 'pending'
);

-- ---------------------------------------------------------------------------
-- Riwayat scan
-- ---------------------------------------------------------------------------
CREATE TABLE scans (
  id                  TEXT PRIMARY KEY,
  user_id             TEXT NOT NULL,
  plant_id            TEXT,
  disease_id          TEXT,
  disease_label       TEXT,
  confidence          REAL NOT NULL DEFAULT 0,  -- 0.0 - 1.0
  local_image_path    TEXT,
  cloud_image_url     TEXT,
  cloud_public_id     TEXT,
  notes               TEXT,
  photo_source        TEXT,                     -- kamera | galeri
  model_version       TEXT,
  scanned_at          TEXT NOT NULL,
  created_at          TEXT NOT NULL,
  updated_at          TEXT NOT NULL,
  deleted_at          TEXT,
  image_upload_status TEXT NOT NULL DEFAULT 'pending',
  sync_status         TEXT NOT NULL DEFAULT 'pending',
  synced_at           TEXT,
  sync_error          TEXT,
  FOREIGN KEY (plant_id) REFERENCES plants(id) ON DELETE SET NULL
);

-- ---------------------------------------------------------------------------
-- Master data (cache offline)
-- ---------------------------------------------------------------------------
CREATE TABLE diseases (
  id                TEXT PRIMARY KEY,
  label_code        TEXT UNIQUE,
  name              TEXT,
  latin_name        TEXT,
  description       TEXT,
  category          TEXT,
  risk_level        TEXT,
  image_path        TEXT,
  search_keyword    TEXT,
  symptoms_json     TEXT,
  preventions_json  TEXT,
  treatments_json   TEXT,
  updated_at        TEXT
);

CREATE TABLE guides (
  id           TEXT PRIMARY KEY,
  slug         TEXT UNIQUE,
  category     TEXT,
  title        TEXT,
  description  TEXT,
  steps_json   TEXT,
  image_path   TEXT,
  video_url    TEXT,
  urutan       INTEGER DEFAULT 0,
  updated_at   TEXT
);

CREATE TABLE tools (
  id                   TEXT PRIMARY KEY,
  slug                 TEXT UNIQUE,
  name                 TEXT,
  tag                  TEXT,
  short_description    TEXT,
  full_description     TEXT,
  specifications_json  TEXT,
  tip                  TEXT,
  icon                 TEXT,
  image_path           TEXT,
  search_keyword       TEXT,
  urutan               INTEGER DEFAULT 0,
  updated_at           TEXT
);

CREATE TABLE products (
  id                TEXT PRIMARY KEY,
  disease_ids_json  TEXT,
  guide_id          TEXT,
  name              TEXT,
  description       TEXT,
  link              TEXT,
  category          TEXT,
  search_keyword    TEXT,
  image_path        TEXT,
  is_active         INTEGER NOT NULL DEFAULT 1,
  updated_at        TEXT
);

-- ---------------------------------------------------------------------------
-- Antrian sinkronisasi
-- ---------------------------------------------------------------------------
CREATE TABLE sync_queue (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_type  TEXT NOT NULL,   -- plant | scan | profile | ...
  entity_id    TEXT NOT NULL,
  operation    TEXT NOT NULL,   -- create | update | delete
  payload      TEXT,
  retry_count  INTEGER NOT NULL DEFAULT 0,
  last_error   TEXT,
  created_at   TEXT NOT NULL
);

-- ---------------------------------------------------------------------------
-- Metadata aplikasi
-- ---------------------------------------------------------------------------
CREATE TABLE app_meta (
  key    TEXT PRIMARY KEY,
  value  TEXT NOT NULL
);

-- ---------------------------------------------------------------------------
-- Index
-- ---------------------------------------------------------------------------
CREATE INDEX idx_plants_user_updated
  ON plants(user_id, updated_at DESC);

CREATE INDEX idx_scans_plant_date
  ON scans(plant_id, scanned_at DESC);

CREATE INDEX idx_scans_user_date
  ON scans(user_id, scanned_at DESC);

CREATE INDEX idx_scans_sync
  ON scans(sync_status, updated_at);

CREATE INDEX idx_queue_entity
  ON sync_queue(entity_type, entity_id);

CREATE UNIQUE INDEX idx_queue_unique
  ON sync_queue(entity_type, entity_id, operation);
```

### Nilai status yang disepakati

| Kolom | Nilai |
|---|---|
| `sync_status` | `pending`, `synced`, `error` |
| `image_upload_status` | `pending`, `uploaded`, `failed` |
| `health_status` | `sehat`, `perlu_perhatian`, `kritis` |
| `operation` | `create`, `update`, `delete` |
| `entity_type` | `plant`, `scan`, `profile` |

Jangan memakai nilai lain tanpa mencatat di dokumen ini.

---

## 6. Langkah 4 — `AppDatabase`

File: `lib/data/datasources/local/app_database.dart`

Persyaratan:

1. Singleton `AppDatabase.instance`.
2. Bisa di-inject `DatabaseFactory` dan path untuk test.
3. `version: 2`.
4. `onConfigure`: aktifkan foreign key.
5. `onCreate`: jalankan semua `CREATE TABLE` + index.
6. `onUpgrade`: migrasi dari v1.
7. `onDowngrade`: lempar error yang jelas.
8. `close()` mereset `_database = null`.
9. Tidak boleh ada query domain di `AppDatabase`.

Contoh kerangka:

```dart
class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._({DatabaseFactory? factory, String? path})
      : _factory = factory ?? databaseFactory,
        _customPath = path;

  final DatabaseFactory _factory;
  final String? _customPath;
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = _customPath ?? join(await getDatabasesPath(), 'leafittome.db');
    _database = await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    // jalankan semua CREATE TABLE dan CREATE INDEX di sini
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _migrateV1ToV2(db);
  }
}
```

---

## 7. Langkah 5 — Migrasi v1 → v2

Tabel v1:

```text
scan_history(
  id, user_id, disease_name, confidence,
  local_image_path, cloud_image_url, notes,
  scanned_at, is_synced
)
```

Langkah migrasi, semuanya dalam satu transaksi:

1. Rename `scan_history` menjadi `scan_history_legacy`.
2. Buat tabel `scans` dan index-nya.
3. Copy data:

```sql
INSERT INTO scans (
  id, user_id, plant_id, disease_label, confidence,
  local_image_path, cloud_image_url, notes,
  scanned_at, created_at, updated_at,
  image_upload_status, sync_status, synced_at
)
SELECT
  id,
  user_id,
  NULL,                         -- plant_id belum ada di v1
  disease_name,
  confidence,
  local_image_path,
  cloud_image_url,
  notes,
  scanned_at,
  scanned_at,
  scanned_at,
  CASE WHEN cloud_image_url IS NULL THEN 'pending' ELSE 'uploaded' END,
  CASE WHEN is_synced = 1 THEN 'synced' ELSE 'pending' END,
  CASE WHEN is_synced = 1 THEN scanned_at ELSE NULL END
FROM scan_history_legacy;
```

4. Jangan drop `scan_history_legacy` dulu. Drop setelah data diverifikasi.
5. Set `app_meta('schema_version', '2')`.

`plant_id` sengaja **nullable** karena data v1 tidak punya relasi tanaman.

---

## 8. Langkah 6 — Model

### 8.1 `ScanRecordModel`

Field wajib:

```text
id                String
userId            String
plantId           String?
diseaseId         String?
diseaseLabel      String?
confidence        double      (0.0 - 1.0)
localImagePath    String?
cloudImageUrl     String?
cloudPublicId     String?
notes             String?
photoSource       String?
modelVersion      String?
scannedAt         DateTime
createdAt         DateTime
updatedAt         DateTime
deletedAt         DateTime?
imageUploadStatus String
syncStatus        String
syncedAt          DateTime?
syncError         String?
```

Method:

- `toSqliteMap()`
- `factory fromSqliteMap(Map<String, dynamic>)`
- `copyWith(...)`

**Penting:** hapus import `cloud_firestore` dari model. Mapping Firestore dipindahkan ke data source remote pada fase berikutnya.

### 8.2 `PlantModel`

```text
id, userId, kodeTanaman, name, location, plantedDate,
healthStatus, lastInspectionAt, note,
createdAt, updatedAt, deletedAt, syncStatus
```

### 8.3 Model master data

`DiseaseModel`, `GuideModel`, `ToolModel`, `ProductModel`: field mengikuti tabel, array/map disimpan sebagai JSON string dan di-decode di DAO.

---

## 9. Langkah 7 — DAO dan Repository

### `PlantRepository`

```dart
Future<void> createPlant(PlantModel plant);
Future<void> updatePlant(PlantModel plant);
Future<void> softDeletePlant(String id);
Future<List<PlantModel>> getPlantsByUser(String userId);
Future<PlantModel?> getPlantById(String id);
```

Aturan:

- ID memakai `Uuid().v4()`.
- `created_at` dan `updated_at` diisi UTC.
- Setiap create/update/delete juga `enqueue` ke `sync_queue`.
- `getPlantsByUser` memfilter `deleted_at IS NULL`.

### `ScanRepository`

```dart
Future<void> saveScanResult(ScanRecordModel scan);
Future<List<ScanRecordModel>> getUserHistory(String userId, {int limit = 50});
Future<void> softDeleteScan(String id);
```

`saveScanResult` wajib memakai **transaksi**:

```text
BEGIN
  INSERT INTO scans ...
  UPDATE plants SET last_inspection_at = ?, health_status = ? WHERE id = ?
  INSERT INTO sync_queue ...
COMMIT
```

Jangan memakai `catchError((_) {})`. Error harus disimpan ke `sync_error`.

### `MasterDataRepository`

```dart
Future<void> replaceDiseases(List<DiseaseModel> items);
Future<void> replaceGuides(List<GuideModel> items);
Future<void> replaceTools(List<ToolModel> items);
Future<void> replaceProducts(List<ProductModel> items);
Future<List<DiseaseModel>> getDiseases();
Future<List<GuideModel>> getGuides();
Future<List<ToolModel>> getTools();
Future<List<ProductModel>> getProducts();
Future<String?> getMeta(String key);
Future<void> setMeta(String key, String value);
```

`replace*` harus menghapus data lama dan memasukkan data baru dalam satu transaksi.

### `SyncQueueDao`

```dart
Future<void> enqueue(String entityType, String entityId, String operation, String payload);
Future<List<SyncQueueItem>> peekPending({int limit = 20});
Future<void> markDone(int queueId);
Future<void> markFailed(int queueId, String error);
Future<void> removeByEntity(String entityType, String entityId);
```

Untuk enqueue berulang pada entity yang sama, gunakan upsert:

```sql
INSERT INTO sync_queue (entity_type, entity_id, operation, payload, created_at)
VALUES (?, ?, ?, ?, ?)
ON CONFLICT(entity_type, entity_id, operation) DO UPDATE SET
  payload = excluded.payload,
  retry_count = 0,
  last_error = NULL,
  created_at = excluded.created_at;
```

---

## 10. Langkah 8 — Test

Buat `test/data/`:

```text
app_database_test.dart
plant_repository_test.dart
scan_repository_test.dart
master_data_repository_test.dart
sync_queue_test.dart
```

Setup:

```dart
setUpAll(() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
});

setUp(() async {
  db = AppDatabase(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
});
```

Test wajib:

- [ ] Schema v2 membuat 8 tabel.
- [ ] Fresh install tidak error.
- [ ] Migrasi v1 → v2 mempertahankan jumlah baris.
- [ ] `is_synced = 1` menjadi `sync_status = 'synced'`.
- [ ] Create + read tanaman.
- [ ] Soft delete tidak muncul di `getPlantsByUser`.
- [ ] `saveScanResult` menulis scan + update plant + queue.
- [ ] Enqueue dua kali tidak membuat duplikat.
- [ ] `markFailed` menaikkan `retry_count`.
- [ ] Round-trip `toSqliteMap` / `fromSqliteMap`.
- [ ] Foreign key menolak `plant_id` yang tidak ada.
- [ ] `replaceDiseases` tidak menyisakan data lama.

Jalankan:

```powershell
flutter test test/data
flutter analyze
```

---

## 11. Langkah 9 — Verifikasi manual

```powershell
flutter run
```

Lalu cek database:

```powershell
adb shell run-as <applicationId> ls databases
adb shell run-as <applicationId> sqlite3 databases/leafittome.db ".tables"
```

Atau Android Studio:

```text
View -> Tool Windows -> App Inspection -> Database Inspector
```

Yang harus terlihat:

```text
plants
scans
diseases
guides
tools
products
sync_queue
app_meta
```

---

## 12. Checklist serah terima

- [ ] `flutter pub get` berhasil.
- [ ] `flutter analyze` tidak error di folder `lib/data` dan `test/data`.
- [ ] `flutter test test/data` lulus semua.
- [ ] 8 tabel + 6 index dibuat.
- [ ] Migrasi v1 → v2 terbukti mempertahankan data.
- [ ] Tidak ada import Firebase/Cloudinary di layer SQLite.
- [ ] Tidak ada perubahan di `lib/features/`.
- [ ] Tidak ada query domain di `AppDatabase`.
- [ ] Semua tanggal UTC ISO 8601.
- [ ] Semua ID baru memakai UUID v4.
- [ ] Soft delete memakai `deleted_at`.
- [ ] `sync_queue` unik per `(entity_type, entity_id, operation)`.
- [ ] Commit terpisah dan pesan jelas.

---

## 13. Urutan commit yang disarankan

```text
1. chore: add sqflite, path, and uuid dependencies
2. feat(sqlite): add v2 schema and migration from scan_history
3. feat(model): extend scan model and add plant model
4. feat(sqlite): add plant and scan repositories with transaction
5. feat(sqlite): add master data cache and app_meta
6. feat(sqlite): add sync queue dao with upsert
7. test(sqlite): add migration, repository, and queue tests
```

---

## 14. Yang tidak boleh dilakukan

- Jangan memakai Firebase Storage; foto nanti ke Cloudinary.
- Jangan memakai MySQL atau phpMyAdmin untuk SQLite.
- Jangan menyimpan `confidence` 0–100; gunakan 0.0–1.0.
- Jangan memakai `TMT-001` sebagai primary key lintas perangkat.
- Jangan hard delete data yang belum tersinkron.
- Jangan memakai dua antrian offline sekaligus.
- Jangan menaruh logika UI di repository.

---

## 15. Pertanyaan yang harus dikonfirmasi sebelum mulai

1. `plant_id` pada `scans` tetap nullable? **(Rekomendasi: ya, untuk migrasi.)**
2. `scan_history_legacy` dihapus setelah verifikasi atau disimpan permanen?
3. `MasterDataRepository` mengisi cache dari data statis `GuideData` dulu, atau menunggu Firestore?
4. Apakah `health_status` boleh dihitung otomatis dari scan, atau diisi manual?

Jika ragu, ikuti rekomendasi di dokumen ini dan catat keputusan di PR.

# PBL_Kelompok1_LeafItToMe

Aplikasi deteksi penyakit daun tanaman tomat berbasis **Flutter** dan **Machine Learning**.

---

## 1. Stack yang dipakai & Fungsinya

| Lapisan / Komponen | Teknologi | Peran & Fungsi Utama |
|---|---|---|
| **Mobile UI & Logika Aplikasi** | Flutter & Dart | Antarmuka pengguna (Login, Register, Dashboard, Scan Daun, Riwayat, Panduan). Menggunakan arsitektur repository dan widget modular. |
| **Penyimpanan Lokal (Offline-First)** | SQLite (`sqflite` + `path`) | Cache lokal di dalam perangkat. Hasil scan tersimpan langsung secara instan tanpa menunggu koneksi internet, dilengkapi penanda status sinkronisasi (`is_synced`). |
| **Autentikasi Pengguna** | Firebase Authentication | Mengelola registrasi pengguna baru, enkripsi kata sandi, verifikasi login, logout, dan pemantauan sesi pengguna (`authStateChanges`). |
| **Database Cloud NoSQL** | Cloud Firestore | Menyimpan data terstruktur dan metadata: profil pengguna (`users/{uid}`), riwayat deteksi (`users/{uid}/scans`), serta master data (penyakit, panduan, dsb). |
| **Penyimpanan Foto Cloud** | Cloudinary (`dio`) | Mengunggah foto fisik daun hasil kamera/galeri secara *unsigned*, mengembalikan tautan URL publik yang aman, dan menghemat kuota Firebase Storage. |
| **Sinkronisasi Latar Belakang** | `SyncManager` | Mekanisme background sync: mendeteksi data scan offline yang belum terunggah (`is_synced = 0`), mengunggah gambar ke Cloudinary, menyimpan metadata ke Firestore, dan memperbarui status lokal. |
| **Tooling Admin & Seed Data** | Node.js + Firebase Admin SDK | Script backend command-line (`seed-firestore.js` & `list-firestore.js`) untuk inisialisasi master data dan inspeksi database cloud langsung dari terminal. |

MySQL/Laravel **tidak dipakai** pada aplikasi ini. File SQL MySQL hanya disimpan sebagai referensi desain.

Alur data:

```text
Flutter UI (Login / Register / Scan)
   │
   ├── Auth & Profil ──────────────► Firebase Auth & Firestore (users/{uid})
   │
   └── Hasil Scan Daun (Offline) ──► SQLite Lokal (AppDatabase, is_synced: 0)
                                           │
                                           ▼ (Background Sync)
                                      SyncManager
                                     ├── Foto Daun  ──► Cloudinary (Upload Foto)
                                     ├── Metadata   ──► Firestore (users/{uid}/scans)
                                     └── Status DB  ──► SQLite (is_synced: 1)
```

---

## 2. Struktur project

```text
PBL_Kelompok1_LeafItToMe/
├── README.md                     <- dokumen ini
└── mobile_app/
    ├── lib/                      <- kode Flutter
    ├── firebase.json             <- konfigurasi Firebase CLI
    ├── .firebaserc               <- project default
    ├── firestore.rules           <- security rules
    ├── firestore.indexes.json    <- composite index
    ├── serviceAccountKey.json    <- kredensial admin (JANGAN di-commit)
    ├── package.json              <- script Node.js
    └── scripts/
        ├── seed-firestore.js     <- isi master data
        ├── list-firestore.js     <- lihat data tanpa Console
        └── README.md             <- panduan detail script
```

---

## 3. Status pekerjaan

| Bagian | Status | Keterangan |
|---|---|---|
| UI Autentikasi | **Selesai & Terhubung** | Halaman Login & Register terhubung penuh ke Firebase Auth dengan validasi form & SnackBar |
| Profil User Firestore | **Selesai** | Dibuat otomatis saat registrasi dengan model `UserModel` (fleksibel Timestamp/String) |
| Database Lokal SQLite | **Selesai (Offline-First)** | `AppDatabase` singleton siap menyimpan riwayat scan dan status sinkronisasi (`is_synced`) |
| Cloudinary Upload | **Selesai** | `CloudinarySource` & `ImageUploadRepository` siap mengunggah foto daun |
| Firestore Scan Source | **Selesai** | `FirestoreScanSource` menyimpan riwayat diagnosa ke Firestore (`users/{uid}/scans`) |
| Sync Manager | **Selesai & Terintegrasi** | Menghubungkan SQLite lokal -> Cloudinary -> Firestore |
| Firestore master data | **Sudah terisi** (21 dokumen) | Terverifikasi di project `leafittome-e91ed` |
| Script seed & viewer | **Selesai** | `npm run seed` dan `npm run list` berfungsi penuh |
| UI Deteksi Daun & Kamera | Prototype | Perlu dihubungkan dengan `AppDatabase` dan `SyncManager` |

Data yang sudah ada di Firestore project `leafittome-e91ed`:

```text
diseases : 5
guides   : 4
tools    : 6
products : 5
meta     : 1
-----------
total    : 21 dokumen
```

---

## 4. Perubahan yang sudah dikerjakan

### 2026-11-10

| File | Jenis | Perubahan |
|---|---|---|
| `mobile_app/lib/data/datasources/remote/cloudinary_source.dart` | Baru | Integrasi upload foto daun tanpa server backend (*unsigned*) ke Cloudinary menggunakan Dio |
| `mobile_app/lib/data/repositories/image_upload_repository.dart` | Baru | Repository untuk abstraksi upload gambar hasil scan |
| `mobile_app/lib/data/datasources/local/app_database.dart` | Baru | Database lokal SQLite offline-first (tabel `scans`, insert scan, query un-synced, mark synced) |
| `mobile_app/lib/data/datasources/remote/firestore_scan_source.dart` | Baru | Data source untuk menyimpan hasil deteksi ke subkoleksi `users/{uid}/scans` di Firestore |
| `mobile_app/lib/core/sync/sync_manager.dart` | Diubah | Integrasi alur offline-to-cloud: SQLite -> upload foto Cloudinary -> simpan metadata Firestore |
| `mobile_app/lib/features/auth/presentation/pages/login_page.dart` | Diubah | Penghubungan form login ke `UserRepository`, validasi input, state loading, dan error handling SnackBar |
| `mobile_app/lib/features/auth/presentation/pages/register_page.dart` | Diubah | Penghubungan form register ke `UserRepository`, validasi syarat & ketentuan, dan feedback visual SnackBar |
| `mobile_app/pubspec.yaml` | Diubah | Menambahkan dependensi `sqflite: ^2.4.1`, `path: ^1.9.1`, dan merapikan versi `cloud_firestore: ^5.6.5` |
| `mobile_app/README.md` | Diubah | Dokumentasi changelog dan arsitektur data flow aplikasi mobile |

### 2026-11-09

| File | Jenis | Perubahan |
|---|---|---|
| `mobile_app/lib/data/models/user_model.dart` | Baru | Model data user dengan parser fleksibel (`toFirestore` & `fromFirestore`) untuk tipe Timestamp/String |
| `mobile_app/lib/data/datasources/remote/firebase_auth_source.dart` | Baru | Data source Firebase Authentication (login, register + buat profil Firestore, logout, stream auth) |
| `mobile_app/lib/data/repositories/user_repository.dart` | Baru | Abstraksi repository user untuk konsumsi antarmuka UI |
| `mobile_app/firestore.rules` | Diubah | Security rules granular untuk `users/{uid}`, `plants`, `scans`, dan pembatasan master data |
| `mobile_app/firestore.indexes.json` | Diubah | Konfigurasi composite index Firestore untuk query multi-field |
| `mobile_app/pubspec.yaml` | Diubah | Menambahkan dependensi awal `firebase_core`, `firebase_auth`, `cloud_firestore` |

### 2026-11-08

| File | Jenis | Perubahan |
|---|---|---|
| `mobile_app/scripts/seed-firestore.js` | Baru | Seed master data Firestore dari data statis aplikasi |
| `mobile_app/scripts/list-firestore.js` | Baru | Viewer Firestore read-only untuk terminal |
| `mobile_app/scripts/README.md` | Baru | Panduan lengkap kedua script |
| `mobile_app/package.json` | Diubah | Menambah script `seed`, `seed:dry`, `list` |
| `mobile_app/.gitignore` | Diubah | Mengabaikan `node_modules/`, `.firebase/`, `firebase-debug.log`, `serviceAccountKey.json` |
| `README.md` | Diubah | Dokumentasi setup, cara menjalankan, dan changelog |

Tidak ada perubahan pada kode Flutter (`lib/`) dan tidak ada perubahan pada security rules.

### Detail `seed-firestore.js`

- Mengisi koleksi:
  - `diseases` (5 dokumen: `P001`–`P005`, termasuk `Healthy`)
  - `guides` (4 dokumen: `GD-001`–`GD-004`)
  - `tools` (6 dokumen)
  - `products` (5 dokumen: `PRD-001`–`PRD-005`)
  - `meta/app` (`schema_version`, `master_data_version`)
- Memakai `set(..., { merge: true })` sehingga **idempotent** dan aman dijalankan berulang.
- Document ID stabil (`P001`, `GD-001`, dst), bukan auto-ID.
- `updated_at` memakai `FieldValue.serverTimestamp()`.
- Batch dipecah per 400 dokumen (batas Firestore 500).
- Mendukung `--dry-run` dan `--version=N`.

### Detail `list-firestore.js`

- **Read-only** — tidak pernah menulis, mengubah, atau menghapus data.
- Perintah: ringkasan, per-koleksi, per-dokumen, per-user, semua koleksi, JSON.
- `count()` memakai aggregation query agar hemat read.
- `Timestamp` dikonversi ke ISO 8601 agar mudah dibaca.
- Mendukung Firebase Emulator melalui `FIRESTORE_EMULATOR_HOST`.
- Seluruh logika diberi komentar Bahasa Indonesia di dalam file.

### Temuan saat verifikasi

- Master data sudah masuk sesuai target (21 dokumen).
- Terdapat 3 dokumen di koleksi `users`.
- Dokumen user yang diperiksa masih memakai **camelCase**:

  ```text
  displayName, phoneNumber, updatedAt
  ```

  Padahal kontrak yang direncanakan memakai **snake_case**:

  ```text
  nama_lengkap, email, no_telepon, foto_profil, role, created_at, updated_at
  ```

- Subkoleksi `plants` dan `scans` user tersebut masih kosong.

Artinya, saat integrasi Auth + profil user, model `UserModel` dan penulisan dokumen `users/{uid}` perlu diselaraskan lebih dulu.

---

## 5. Cara menjalankan

Semua perintah script dijalankan dari folder `mobile_app`.

### 5.1 Prasyarat

1. Node.js dan npm terpasang.

   ```powershell
   node -v
   npm -v
   ```

2. Dependency terpasang.

   ```powershell
   cd 'D:\Semester 5\PBL\PBL_Kelompok1_LeafItToMe\mobile_app'
   npm install
   ```

3. `serviceAccountKey.json` tersedia di folder `mobile_app/`.

   File ini didapat dari:
   Firebase Console -> Project Settings -> Service Accounts -> Generate new private key.

   Alternatif, set environment variable:

   ```powershell
   $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\service-account.json"
   ```

4. Firebase CLI (hanya jika ingin deploy rules/indexes).

   ```powershell
   npm install -g firebase-tools
   firebase login
   firebase use leafittome-e91ed
   ```

### 5.2 Melihat data Firestore

```powershell
cd 'D:\Semester 5\PBL\PBL_Kelompok1_LeafItToMe\mobile_app'

# Ringkasan jumlah dokumen
npm run list

# Contoh isi koleksi (default 5 dokumen)
npm run list -- --collection=diseases
npm run list -- --collection=guides --limit=10

# Satu dokumen
npm run list -- --doc=meta/app
npm run list -- --doc=diseases/P001

# Data satu user (profil + plants + scans)
npm run list -- --uid=<UID>

# Semua koleksi root
npm run list -- --all

# Output JSON
npm run list -- --collection=tools --json

# Bantuan
npm run list -- --help
```

Contoh output:

```text
======================================================================
LeafItToMe - Firestore Viewer
Project : leafittome-e91ed
Mode    : ringkasan
======================================================================

Jumlah dokumen:
  diseases     : 5
  guides       : 4
  tools        : 6
  products     : 5
  meta         : 1

  Total        : 21 dokumen
```

### 5.3 Mengisi / memperbarui master data

```powershell
# Cek tanpa menulis
npm run seed:dry

# Tulis ke Firestore
npm run seed

# Naikkan versi master data (memaksa aplikasi menarik ulang cache)
npm run seed -- --version=2
```

### 5.4 Deploy rules dan indexes

```powershell
cd 'D:\Semester 5\PBL\PBL_Kelompok1_LeafItToMe\mobile_app'
firebase deploy --only firestore:rules,firestore:indexes
```

### 5.5 Menjalankan dengan Emulator (opsional)

```powershell
# Terminal 1
firebase emulators:start --only firestore,auth

# Terminal 2
$env:FIRESTORE_EMULATOR_HOST="127.0.0.1:8080"
npm run seed
npm run list
```

Emulator UI: `http://localhost:4000`.

### 5.6 Menjalankan aplikasi Flutter

```powershell
cd 'D:\Semester 5\PBL\PBL_Kelompok1_LeafItToMe\mobile_app'
flutter pub get
flutter run
```

---

## 6. Melihat SQLite

SQLite adalah file lokal di perangkat, **bukan** MySQL, sehingga **tidak bisa dibuka di phpMyAdmin**.

| Kebutuhan | Tool |
|---|---|
| Lihat SQLite saat app berjalan | Android Studio -> App Inspection -> Database Inspector |
| Ambil file database | `adb exec-out run-as <applicationId> cat databases/<nama>.db > db.sqlite` |
| Buka file database | DB Browser for SQLite |
| Lihat data cloud | `npm run list` atau Firebase Console |
| Lihat foto | Cloudinary Media Library |

---

## 7. Keamanan

- `serviceAccountKey.json` memberi akses admin penuh. **Jangan commit** dan jangan bagikan.
- Jangan menaruh `api_secret` Cloudinary di kode Flutter.
- Jangan biarkan Firestore dalam test mode.
- Gunakan unsigned upload preset Cloudinary yang dibatasi format, ukuran, dan folder.
- Jangan memakai document ID seperti `TMT-001` lintas perangkat; gunakan UUID.

---

## 8. Troubleshooting

| Masalah | Penyebab | Solusi |
|---|---|---|
| `Could not load the default credentials` | Service account tidak ada | Letakkan `serviceAccountKey.json` di `mobile_app/` |
| `The database (default) does not exist` | Firestore belum dibuat | Buat database di project Firebase |
| `PERMISSION_DENIED` | Role service account kurang | Beri role *Cloud Datastore User* |
| `Missing script: "list"` | Salah folder | `cd mobile_app` dulu |
| Hasil kosong padahal seed jalan | Beda project | Cek baris `Project:` pada output |
| `The credentials option is deprecated` | Warning internal library | Aman diabaikan |

---

## 9. Dokumentasi lanjutan

- Panduan detail script: [`mobile_app/scripts/README.md`](mobile_app/scripts/README.md)
- Firebase Console: https://console.firebase.google.com/project/leafittome-e91ed
- Cloudinary Media Library: https://console.cloudinary.com

---

## 10. Rencana berikutnya

- [x] 1. Selaraskan `UserModel` ke `snake_case` dan otomatis buat `users/{uid}` saat registrasi.
- [x] 2. Implementasi `FirebaseAuthSource` & `UserRepository` pada halaman login dan register.
- [x] 3. Implementasi `CloudinarySource` & `ImageUploadRepository` untuk upload foto scan daun secara unsigned.
- [x] 4. Implementasi `AppDatabase` (SQLite lokal offline-first) dengan penanda status `is_synced`.
- [x] 5. Sambungkan `SyncManager` untuk background sync lokal -> Cloudinary -> Firestore.
- [ ] 6. Sambungkan alur kamera/deteksi daun (`detection_result_page.dart`) ke `ScanRepository` & `SyncManager`.
- [ ] 7. Ganti data statis (`initialPlants`, `history_data`, `guide_data`) dengan repository dari Firestore/SQLite.
- [ ] 8. Uji security rules dan alur offline-online secara komprehensif.

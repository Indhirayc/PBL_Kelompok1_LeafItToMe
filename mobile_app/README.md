# 📱 LeafItToMe Mobile App (Flutter)

Aplikasi mobile berbasis **Flutter** untuk deteksi penyakit daun tanaman tomat, manajemen tanaman, dan panduan perawatan berbasis Machine Learning dan arsitektur Offline-First.

Untuk dokumentasi lengkap arsitektur backend, instalasi dependensi, dan panduan pengujian, silakan lihat file dokumentasi utama:
👉 **[Root README.md](../README.md)**

---

## ⚡ Panduan Cepat Menjalankan Modul Mobile

### 1. Install Dependensi
```bash
cd mobile_app
flutter pub get
```

### 2. Jalankan Static Analysis & Testing
```bash
flutter analyze
flutter test
```

### 3. Jalankan Aplikasi
```bash
flutter run
```

---

## Log Perubahan Terbaru (Changelog)

### 📅 Selasa, 10 November 2026

1. **Integrasi Cloudinary untuk Unggah Foto Daun (`CloudinarySource`)**:
   - Menambahkan `CloudinarySource` (`lib/data/datasources/remote/cloudinary_source.dart`) berbasis `dio` untuk unsigned upload foto scan daun ke Cloudinary (`folder: leafittome/scans/{userId}`).
   - Menambahkan `ImageUploadRepository` (`lib/data/repositories/image_upload_repository.dart`) sebagai abstraksi upload gambar scan.

2. **Implementasi Database Lokal SQLite Offline-First (`AppDatabase`)**:
   - Membuat `AppDatabase` (`lib/data/datasources/local/app_database.dart`) menggunakan `sqflite` dan `path` dengan pola Singleton.
   - Mengimplementasikan migrasi skema tabel relasional dan pelacakan status sinkronisasi (`is_synced`).
   - Menyediakan fungsi CRUD lokal: `insertScan`, `getScansByUser`, `getUnsyncedScans`, `markAsSynced`, dan `deleteScan`.

3. **Remote Source & Sinkronisasi Scan (`FirestoreScanSource` & `SyncManager`)**:
   - Membuat `FirestoreScanSource` (`lib/data/datasources/remote/firestore_scan_source.dart`) untuk menyimpan hasil scan ke subkoleksi `users/{uid}/scans/{scanId}` di Cloud Firestore.
   - Memperbarui `SyncManager` (`lib/core/sync/sync_manager.dart`) untuk otomatis menjalankan sinkronisasi offline ke cloud.

4. **Penyempurnaan Integrasi Form Login & Register**:
   - Menghubungkan form `login_page.dart` dan `register_page.dart` ke `UserRepository` dan Firebase Auth.
   - Memperbaiki alur validasi form, penanganan error `FirebaseAuthException`, dan feedback visual `SnackBar`.

---

### 📅 Senin, 09 November 2026

1. **Pemodelan Data Pengguna (`UserModel`)**:
   - Membuat `UserModel` (`lib/data/models/user_model.dart`) untuk representasi entitas user pada Firebase Authentication dan Cloud Firestore.
2. **Data Source & Repository Autentikasi Pengguna**:
   - Membuat `FirebaseAuthSource` (`lib/data/datasources/remote/firebase_auth_source.dart`) dan `UserRepository` (`lib/data/repositories/user_repository.dart`).
3. **Inisialisasi Konfigurasi Firebase**:
   - Menambahkan dependensi Firebase ke `pubspec.yaml`.
   - Mengonfigurasi `firestore.rules` dan `firestore.indexes.json`.

---

## Arsitektur Aliran Data (Data Flow)

```text
[ Flutter UI (Pages / Widgets) ]
               │
               ▼
   [ Repositories ]
   ├── UserRepository
   ├── ScanRepository
   └── ImageUploadRepository
         │               │                │
         ▼               ▼                ▼
   [ SQLite Local ]  [ Cloudinary ]  [ Cloud Firestore / API ]
   (AppDatabase)     (Upload Foto)   (Metadata & User Data)
         │                                ▲
         └──────────► [ SyncManager ] ────┘
                      (Background Sync)
```

# LeafItToMe Mobile App

Aplikasi mobile berbasis **Flutter** untuk deteksi penyakit daun tanaman tomat, manajemen tanaman, dan panduan perawatan berbasis Machine Learning dan Cloud.

---

## Log Perubahan Terbaru (Changelog)

### 📅 Selasa, 10 November 2026 (Hari Ini)

1. **Integrasi Cloudinary untuk Unggah Foto Daun (`CloudinarySource`)**:
   - Menambahkan `CloudinarySource` (`lib/data/datasources/remote/cloudinary_source.dart`) berbasis `dio` untuk unsigned upload foto scan daun ke Cloudinary (`folder: leafittome/scans/{userId}`).
   - Menambahkan `ImageUploadRepository` (`lib/data/repositories/image_upload_repository.dart`) sebagai abstraksi upload gambar scan.

2. **Implementasi Database Lokal SQLite Offline-First (`AppDatabase`)**:
   - Membuat `AppDatabase` (`lib/data/datasources/local/app_database.dart`) menggunakan `sqflite` dan `path` dengan pola Singleton.
   - Membuat tabel SQLite `scans` lokal dengan kolom pelacakan status sinkronisasi (`is_synced`).
   - Menyediakan fungsi CRUD lokal:
     - `insertScan(record)`: Menyimpan hasil deteksi langsung ke storage internal perangkat.
     - `getScansByUser(userId)`: Menampilkan riwayat scan user secara offline diurutkan dari terbaru.
     - `getUnsyncedScans(userId)`: Mengambil daftar scan yang belum terunggah (`is_synced = 0`).
     - `markAsSynced(scanId, cloudImageUrl)`: Menandai data telah tersinkronisasi (`is_synced = 1`) beserta URL gambar dari Cloudinary.

3. **Remote Source & Sinkronisasi Scan (`FirestoreScanSource` & `SyncManager`)**:
   - Membuat `FirestoreScanSource` (`lib/data/datasources/remote/firestore_scan_source.dart`) untuk menyimpan hasil scan ke subkoleksi `users/{uid}/scans/{scanId}` di Cloud Firestore.
   - Memperbarui `SyncManager` (`lib/core/sync/sync_manager.dart`) untuk otomatis menjalankan sinkronisasi:
     - Mengunggah foto daun lokal ke **Cloudinary**.
     - Menyimpan metadata hasil diagnosa ke **Cloud Firestore**.
     - Memperbarui status scan lokal di **SQLite** menjadi tersinkronisasi.

4. **Penyempurnaan Integrasi Form Login & Register**:
   - Menghubungkan fungsi submit pada `login_page.dart` dan `register_page.dart` ke `UserRepository`.
   - Memperbaiki pemanggilan nama private controller (`_emailController`, `_passwordController`, `_nameController`).
   - Memperbaiki alur validasi form (`_formKey.currentState?.validate()`) dan persetujuan syarat & ketentuan agar dievaluasi sebelum request ke Firebase.
   - Menambahkan penanganan error `try - catch` (`FirebaseAuthException`) serta feedback visual `SnackBar` (sukses dan gagal).
   - Menambahkan pengelolaan state `_isLoading` yang reaktif untuk menampilkan indikator loading pada tombol aksi.

5. **Resolusi Merge Conflict & Perbaikan Dependensi `pubspec.yaml`**:
   - Menyelesaikan konflik merge Git pada branch `anval`.
   - Memperbaiki format dan versi library di `pubspec.yaml` (`sqflite: ^2.4.1`, `path: ^1.9.1`, `cloud_firestore: ^5.6.5`).
   - Berhasil mengeksekusi `flutter pub get` dan membersihkan seluruh dependensi merah pada project.

---

### 📅 Senin, 09 November 2026 (Kemarin)

1. **Pemodelan Data Pengguna (`UserModel`)**:
   - Membuat `UserModel` (`lib/data/models/user_model.dart`) untuk merepresentasikan entitas user pada Firebase Authentication dan Cloud Firestore.
   - Mengimplementasikan `toFirestore()` dan parser `fromFirestore()` yang fleksibel terhadap format data `Timestamp` Firestore maupun `String` ISO 8601, serta kompatibel dengan penamaan field *snake_case* dan *camelCase*.

2. **Data Source & Repository Autentikasi Pengguna**:
   - Membuat `FirebaseAuthSource` (`lib/data/datasources/remote/firebase_auth_source.dart`) untuk mengelola operasi:
     - `login(email, password)`
     - `register(email, password, namaLengkap)` dan otomatis membuat dokumen `users/{uid}` di Firestore
     - `logout()`
     - Stream `authStateChanges` dan getter `currentUser`.
   - Membuat `UserRepository` (`lib/data/repositories/user_repository.dart`) sebagai abstraction layer antara UI dengan data source autentikasi.

3. **Inisialisasi Konfigurasi Firebase**:
   - Menambahkan dependensi Firebase ke `pubspec.yaml` (`firebase_core`, `firebase_auth`, `cloud_firestore`).
   - Mengonfigurasi Firebase CLI dan rules database:
     - `firestore.rules`: Aturan keamanan untuk `users/{uid}`, `plants`, `scans`, serta master data (`diseases`, `guides`, `tools`, `products`).
     - `firestore.indexes.json`: Definisi composite indexes untuk query Firestore.

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
   [ SQLite Local ]  [ Cloudinary ]  [ Cloud Firestore ]
   (AppDatabase)     (Upload Foto)   (Metadata & User Data)
         │                                ▲
         └──────────► [ SyncManager ] ────┘
                      (Background Sync)
```

---

## Panduan Menjalankan Aplikasi

1. Pastikan dependensi sudah terunduh:
   ```bash
   cd mobile_app
   flutter pub get
   ```
2. Jalankan aplikasi pada perangkat atau emulator:
   ```bash
   flutter run
   ```

# Script Firestore LeafItToMe

Folder ini berisi script terminal untuk mengelola Firestore **tanpa membuka Firebase Console**.

| File | Fungsi | Menulis data? |
|---|---|---|
| `seed-firestore.js` | Mengisi master data (`diseases`, `guides`, `tools`, `products`, `meta`) | Ya |
| `list-firestore.js` | Melihat isi Firestore | Tidak (read-only) |

---

## 1. Persiapan

Semua perintah dijalankan dari folder `mobile_app`:

```powershell
cd 'D:\Semester 5\PBL\PBL_Kelompok1_LeafItToMe\mobile_app'
```

Yang dibutuhkan:

1. `npm install` (sudah ada `firebase-admin` di `package.json`).
2. `serviceAccountKey.json` di folder `mobile_app/`.
   File ini **jangan di-commit** — sudah masuk `.gitignore`.
3. Project Firestore aktif (`leafittome-e91ed`).

Kalau tidak memakai `serviceAccountKey.json`, set environment variable:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\service-account.json"
```

---

## 2. Langkah 8 — Lihat data tanpa Firebase Console

### 2.1 Ringkasan jumlah dokumen

```powershell
npm run list
```

Contoh output:

```text
Project : leafittome-e91ed
Mode    : ringkasan

Jumlah dokumen:
  diseases     : 5
  guides       : 4
  tools        : 6
  products     : 5
  meta         : 1

  Total        : 21 dokumen
```

Gunakan ini untuk menjawab: **"seed sudah masuk atau belum?"**

> `count()` memakai aggregation query, jadi lebih murah daripada membaca semua dokumen.

---

### 2.2 Lihat contoh isi koleksi

```powershell
npm run list -- --collection=diseases
npm run list -- --collection=guides --limit=10
```

Arti tiap bagian output:

```text
[doc] diseases/P001          <- koleksi/document ID
      id: P001
      label_code     : Bacterial_Spot
      nama_penyakit  : Bacterial Spot
      updated_at     : 2026-11-08T14:49:09.429Z
```

- `[doc]` = dokumen yang sedang dibaca.
- `id` = document ID (bukan field di dalam data).
- `updated_at` = Firestore `Timestamp` yang diubah menjadi ISO 8601.

Default hanya menampilkan **5 dokumen**. Selalu pakai `--limit` agar tidak boros read.

---

### 2.3 Lihat satu dokumen

```powershell
npm run list -- --doc=meta/app
npm run list -- --doc=diseases/P001
```

Format `--doc` harus `koleksi/documentId`.

---

### 2.4 Lihat data satu user

```powershell
npm run list -- --uid=UID_DARI_FIREBASE_AUTH
```

UID bisa didapat dari:

- Firebase Console → Authentication, atau
- `firebase auth:export users.json`, atau
- log aplikasi saat register.

Perintah ini menampilkan:

```text
users/{uid}                 -> profil
users/{uid}/plants          -> tanaman milik user
users/{uid}/scans           -> riwayat scan milik user
```

---

### 2.5 Lihat semua koleksi root

```powershell
npm run list -- --all
```

Berguna kalau ada koleksi baru yang tidak tercantum di `DEFAULT_COLLECTIONS`.

---

### 2.6 Output JSON

```powershell
npm run list -- --collection=tools --json
```

Output JSON memudahkan pengolahan lanjutan, misalnya disimpan ke file:

```powershell
npm run list -- --collection=tools --json > tools.json
```

---

### 2.7 Jangan potong teks panjang

Secara default string/array panjang dipotong agar terminal tetap nyaman dibaca.

```powershell
npm run list -- --collection=guides --full
```

---

## 3. Seed data

```powershell
# cek tanpa menulis
npm run seed:dry

# tulis / perbarui data
npm run seed

# naikkan versi master data
npm run seed -- --version=2
```

Seed bersifat **idempotent** (`set` dengan `merge: true`), jadi aman dijalankan berulang.

---

## 4. Memakai Emulator

Jika ingin melihat data lokal tanpa menyentuh Firestore cloud:

```powershell
firebase emulators:start --only firestore,auth
```

Lalu di terminal lain:

```powershell
$env:FIRESTORE_EMULATOR_HOST="127.0.0.1:8080"
npm run seed
npm run list
```

Saat env tersebut aktif, Admin SDK otomatis terhubung ke emulator. Header output akan menampilkan baris `Emulator:`.

Emulator UI bisa dibuka di `http://localhost:4000` — ini juga cara melihat data tanpa Console.

---

## 5. Troubleshooting

| Pesan | Penyebab | Solusi |
|---|---|---|
| `Could not load the default credentials` | Service account tidak ditemukan | Letakkan `serviceAccountKey.json` di `mobile_app/` |
| `The database (default) does not exist` | Firestore belum dibuat | Buat database di project |
| `PERMISSION_DENIED` | Role service account kurang | Beri role *Cloud Datastore User* |
| Hasil kosong padahal seed jalan | Beda project | Cek baris `Project:` di output |
| `The credentials option is deprecated` | Warning internal `google-auth-library` | Aman, bisa diabaikan |
| `Missing script: "list"` | Menjalankan dari folder salah | `cd mobile_app` dulu |

---

## 6. Biaya read

| Aksi | Perkiraan read |
|---|---|
| `npm run list` | 5 aggregation read |
| `--collection=X --limit=5` | maksimal 5 read |
| `--doc=meta/app` | 1 read |
| `--uid=UID --limit=5` | 1 + 5 + 5 read |

Jangan jalankan `--limit=1000` berulang kali hanya untuk melihat data. Gunakan `--limit` kecil dan tambah hanya bila perlu.

---

## 7. Hubungan dengan aplikasi Flutter

Script ini untuk **development dan verifikasi**, bukan bagian dari aplikasi.

Alur data tetap:

```text
Flutter -> SQLite -> sync queue -> Firestore
                                -> Cloudinary (foto)
```

Aplikasi membaca master data dari Firestore (dan cache SQLite), sedangkan script ini memastikan data di Firestore sudah benar sebelum aplikasi diuji.

---

## 8. Catatan perubahan

### 2026-11-08

| File | Jenis | Perubahan |
|---|---|---|
| `scripts/seed-firestore.js` | Baru | Seed 21 dokumen master data ke Firestore |
| `scripts/list-firestore.js` | Baru | Viewer Firestore read-only |
| `scripts/README.md` | Baru | Panduan penggunaan kedua script |
| `package.json` | Diubah | Menambah `seed`, `seed:dry`, `list` |
| `.gitignore` | Diubah | Mengabaikan kredensial dan artefak Node.js |

#### `seed-firestore.js`

- Koleksi: `diseases` (5), `guides` (4), `tools` (6), `products` (5), `meta/app` (1).
- Idempotent: `set(..., { merge: true })`.
- Batch per 400 dokumen.
- Opsi: `--dry-run`, `--version=N`.
- Sumber data: `guide_data.dart`, `history_data.dart`, dan seed MySQL sebagai referensi.

#### `list-firestore.js`

- Read-only.
- Opsi: `--collection`, `--doc`, `--uid`, `--limit`, `--all`, `--json`, `--full`, `--help`.
- `count()` untuk ringkasan yang hemat read.
- Konversi `Timestamp` ke ISO 8601.
- Deteksi otomatis `DocumentReference` dan `GeoPoint`.
- Mendukung `FIRESTORE_EMULATOR_HOST`.

#### Hasil verifikasi

```text
Project : leafittome-e91ed
diseases : 5
guides   : 4
tools    : 6
products : 5
meta     : 1
users    : 3
```

Catatan: dokumen `users/{uid}` yang ada masih memakai camelCase (`displayName`, `phoneNumber`, `updatedAt`) dan subkoleksi `plants`/`scans` masih kosong. Perlu diselaraskan saat integrasi Auth.

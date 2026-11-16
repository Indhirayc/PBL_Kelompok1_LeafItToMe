# Backend API LeafItToMe (PHP + MySQL)

API sederhana untuk menghubungkan aplikasi Flutter ke database MySQL `leafittome`
(skema di `D:\Kuliah\Semester 5\PBL\proto2`).

## 1. Prasyarat

1. XAMPP terpasang (PHP 8+ dan MySQL/MariaDB).
2. Database `leafittome` sudah dibuat:
   - Buka phpMyAdmin → Import → `proto2/leafittome_mysql_schema.sql`.
   - Opsional: import `proto2/leafittome_mysql_seed.sql` untuk data contoh.
3. Jalankan MySQL dari XAMPP Control Panel.

## 2. Konfigurasi Database

API membaca environment variable berikut (default cocok untuk XAMPP):

| Variable | Default |
|---|---|
| `DB_HOST` | `127.0.0.1` |
| `DB_PORT` | `3306` |
| `DB_NAME` | `leafittome` |
| `DB_USER` | `root` |
| `DB_PASS` | *(kosong)* |

Contoh di PowerShell:

```powershell
$env:DB_HOST="127.0.0.1"
$env:DB_PORT="3306"
$env:DB_NAME="leafittome"
$env:DB_USER="root"
$env:DB_PASS=""
```

## 3. Menjalankan Server

Dari folder `backend`:

```powershell
C:\xampp\php\php.exe -S 0.0.0.0:8000 -t public public/router.php
```

Cek kesehatan API:

```powershell
Invoke-RestMethod http://localhost:8000/api/health
```

Hasil yang diharapkan:

```json
{"status":"ok","database":"connected"}
```

> `0.0.0.0` membuat server bisa diakses dari HP di jaringan yang sama.
> Cari IP LAN laptop dengan `ipconfig` (contoh `192.168.1.10`).

## 4. Endpoint

| Method | Path | Fungsi |
|---|---|---|
| GET | `/api/health` | Cek server + koneksi database |
| POST | `/api/scans` | Simpan/upsert hasil scan |
| POST | `/api/scans/{id}/image` | Upload foto (multipart, field `image`) |
| GET | `/api/scans?id_pengguna=...` | Daftar riwayat milik pengguna |
| DELETE | `/api/scans/{id}` | Hapus satu riwayat |

Contoh `POST /api/scans`:

```json
{
  "id_riwayat": "scan-123",
  "id_pengguna": "user-001",
  "id_tanaman": "TMT-001",
  "nama_tanaman": "Tomat Pot Depan",
  "lokasi": "Teras depan",
  "nama_penyakit": "Late_Blight",
  "confidence_score": 0.95,
  "tanggal_pemeriksaan": "2026-10-23T12:00:00",
  "catatan": "Bercak pada daun bagian bawah",
  "foto_daun": "scans/scan-123.jpg"
}
```

## 5. Menjalankan Aplikasi Flutter

Gunakan IP LAN laptop (bukan `localhost`):

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

Jika memakai emulator Android, `10.0.2.2` menggantikan `localhost`:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

## 6. Alur Data

```text
DetectionResultPage
  -> ScanRepository.saveScanResult
  -> SQLite (status pending)
  -> SyncManager
  -> POST /api/scans (+ upload gambar)
  -> MySQL (status synced, cloud_image_url terisi)
  -> phpMyAdmin
```

Jika offline atau API mati, data tetap `pending` di SQLite dan dicoba lagi
saat sinkronisasi berikutnya.

## 7. Catatan Keamanan

- Ini API demo untuk PBL. `id_pengguna` masih dipercaya dari aplikasi.
- Untuk produksi: tambahkan verifikasi token Firebase, rate limit, HTTPS, dan
  jangan tampilkan detail error database.
- Jangan commit file `.env` atau kredensial database.
- Folder upload ada di `public/uploads/scans` dan tidak masuk Git.
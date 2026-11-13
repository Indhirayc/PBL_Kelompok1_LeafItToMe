# PBL_Kelompok1_LeafItToMe
Aplikasi deteksi penyakit pada daun tanaman tomat berbasis Flutter dan Machine Learning

## Backend (mobile_app)

Backend saat ini memakai **Firebase** (Auth + Firestore) dan **Cloudinary** untuk
penyimpanan gambar. Riwayat scan disimpan offline-first di SQLite lalu disinkronkan.

### Deploy Firestore Rules & Indexes

```bash
cd mobile_app
firebase deploy --only firestore:rules,firestore:indexes
```

### Master Data (diseases / guides / tools)

Aplikasi membaca koleksi `diseases`, `guides`, dan `tools` dari Firestore
(read-only, write hanya untuk admin). Seed dilakukan manual dari Firebase Console.
Urutan muat: Firestore (online) → cache SQLite → data bawaan aplikasi.

Contoh dokumen koleksi `diseases`:

```json
{
  "id": "bacterial-spot",
  "name": "Bacterial Spot",
  "latin_name": "Xanthomonas spp.",
  "category": "Bakteri",
  "severity": "RISIKO SEDANG",
  "severity_color": 15124680,
  "short_description": "Bercak bakteri pada daun tomat.",
  "symptoms": ["Bercak cokelat kehitaman pada daun", "Daun menguning dan mengering"],
  "preventions": ["Hindari menyiram daun pada sore hari"],
  "image_asset_path": "assets/images/bacterial_spot.jpg",
  "search_keyword": "bakterisida tembaga bacterial spot tomat"
}
```

### Backend REST (plants) — belum dipakai

Fitur plants memiliki data source REST (`lib/features/plants/data/...`) yang
membaca `API_BASE_URL` dari `--dart-define`, tetapi **belum dikonfigurasi dan
belum dipakai** — UI plants masih memakai data lokal. Untuk mengaktifkannya
(setelah server REST tersedia):

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

/// Cetak biru (DDL) database SQLite LeafItToMe — versi 3.
///
/// Versi 3 menyelaraskan database aplikasi (`sqflite`) dengan **ERD proposal**:
/// tujuh tabel ternormalisasi (`pengguna`, `tanaman`, `penyakit`,
/// `riwayat_pemindaian`, `penanganan`, `panduan_menanam`, `rekomendasi_produk`).
///
/// Perbedaan penting dari v2:
/// - `scan_history` (denormalized) diganti `riwayat_pemindaian` + foreign key.
/// - Nama penyakit tidak lagi disimpan sebagai teks di riwayat; dipakai
///   `penyakit.nama_penyakit` lewat `id_penyakit`.
/// - `id_pengguna` memakai **Firebase UID (TEXT)**, bukan angka.
/// - `cloud_image_url` tetap disimpan di riwayat sebagai kolom pendukung sync.
library;

const int kLeafItToMeDatabaseVersion = 3;

/// Urutan pembuatan tabel. Dipakai `AppDatabase` saat membuat database baru.
const List<String> kLeafItToMeSchema = <String>[
  '''
CREATE TABLE pengguna (
  id_pengguna  TEXT PRIMARY KEY,
  nama_lengkap TEXT NOT NULL,
  email        TEXT NOT NULL UNIQUE,
  foto_profil  TEXT,
  created_at   TEXT NOT NULL
)''',
  '''
CREATE TABLE tanaman (
  id_tanaman           TEXT PRIMARY KEY,
  id_pengguna          TEXT NOT NULL,
  nama_tanaman         TEXT NOT NULL,
  lokasi               TEXT,
  tanggal_tanam        TEXT,
  status_sinkronisasi  TEXT NOT NULL DEFAULT 'pending'
                       CHECK (status_sinkronisasi IN ('pending', 'synced')),
  created_at           TEXT NOT NULL,
  FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna)
    ON UPDATE CASCADE ON DELETE CASCADE
)''',
  '''
CREATE TABLE penyakit (
  id_penyakit    TEXT PRIMARY KEY,
  label_code     TEXT NOT NULL UNIQUE,
  nama_penyakit  TEXT NOT NULL,
  nama_latin     TEXT,
  deskripsi      TEXT,
  kategori       TEXT,
  tingkat_risiko TEXT NOT NULL DEFAULT 'sedang'
                 CHECK (tingkat_risiko IN ('rendah', 'sedang', 'tinggi', 'sangat_tinggi', 'sehat'))
)''',
  '''
CREATE TABLE riwayat_pemindaian (
  id_riwayat           TEXT PRIMARY KEY,
  id_tanaman           TEXT NOT NULL,
  id_penyakit          TEXT NOT NULL,
  foto_daun            TEXT,
  cloud_image_url      TEXT,
  confidence_score     REAL NOT NULL DEFAULT 0
                       CHECK (confidence_score >= 0 AND confidence_score <= 1),
  tanggal_pemeriksaan  TEXT NOT NULL,
  catatan              TEXT,
  status_sinkronisasi  TEXT NOT NULL DEFAULT 'pending'
                       CHECK (status_sinkronisasi IN ('pending', 'synced')),
  synced_at            TEXT,
  created_at           TEXT NOT NULL,
  FOREIGN KEY (id_tanaman) REFERENCES tanaman (id_tanaman)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (id_penyakit) REFERENCES penyakit (id_penyakit)
    ON UPDATE CASCADE ON DELETE RESTRICT
)''',
  '''
CREATE TABLE penanganan (
  id_penangan  TEXT PRIMARY KEY,
  id_penyakit  TEXT NOT NULL,
  jenis        TEXT NOT NULL CHECK (jenis IN ('gejala', 'pencegahan', 'penanganan')),
  urutan       INTEGER NOT NULL DEFAULT 1,
  instruksi    TEXT NOT NULL,
  created_at   TEXT NOT NULL,
  UNIQUE (id_penyakit, jenis, urutan),
  FOREIGN KEY (id_penyakit) REFERENCES penyakit (id_penyakit)
    ON UPDATE CASCADE ON DELETE CASCADE
)''',
  '''
CREATE TABLE panduan_menanam (
  id_panduan      TEXT PRIMARY KEY,
  kategori        TEXT NOT NULL,
  judul           TEXT NOT NULL,
  deskripsi       TEXT,
  langkah_langkah TEXT,
  gambar          TEXT,
  created_at      TEXT NOT NULL
)''',
  '''
CREATE TABLE rekomendasi_produk (
  id_produk      TEXT PRIMARY KEY,
  id_penyakit    TEXT,
  id_panduan     TEXT,
  nama_produk    TEXT NOT NULL,
  deskripsi      TEXT,
  link_penjualan TEXT,
  kategori       TEXT,
  created_at     TEXT NOT NULL,
  FOREIGN KEY (id_penyakit) REFERENCES penyakit (id_penyakit)
    ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (id_panduan) REFERENCES panduan_menanam (id_panduan)
    ON UPDATE CASCADE ON DELETE SET NULL
)''',
  'CREATE INDEX idx_tanaman_pengguna ON tanaman (id_pengguna)',
  'CREATE INDEX idx_tanaman_status ON tanaman (status_sinkronisasi)',
  'CREATE INDEX idx_riwayat_tanaman ON riwayat_pemindaian (id_tanaman)',
  'CREATE INDEX idx_riwayat_penyakit ON riwayat_pemindaian (id_penyakit)',
  'CREATE INDEX idx_riwayat_tanggal ON riwayat_pemindaian (tanggal_pemeriksaan)',
  'CREATE INDEX idx_riwayat_status ON riwayat_pemindaian (status_sinkronisasi)',
  'CREATE INDEX idx_penanganan_penyakit ON penanganan (id_penyakit)',
  'CREATE INDEX idx_panduan_kategori ON panduan_menanam (kategori)',
  'CREATE INDEX idx_produk_penyakit ON rekomendasi_produk (id_penyakit)',
  'CREATE INDEX idx_produk_panduan ON rekomendasi_produk (id_panduan)',
];

/// Referensi 5 kelas penyakit yang dipakai model ML.
///
/// Baris ini adalah **data referensi**, bukan data demo. Tujuannya agar hasil
/// scan (yang menyimpan `id_penyakit`) selalu punya pasangan nama/label yang
/// konsisten, termasuk saat aplikasi baru pertama kali dibuka.
const List<Map<String, Object?>>
kLeafItToMeSeedPenyakit = <Map<String, Object?>>[
  {
    'id_penyakit': 'P001',
    'label_code': 'Bacterial_Spot',
    'nama_penyakit': 'Bacterial Spot',
    'nama_latin': 'Xanthomonas spp.',
    'deskripsi': 'Penyakit bakteri yang menimbulkan bercak kecil cokelat kehitaman pada daun dan dapat meluas hingga daun menguning.',
    'kategori': 'Bakteri',
    'tingkat_risiko': 'sedang',
  },
  {
    'id_penyakit': 'P002',
    'label_code': 'Late_Blight',
    'nama_penyakit': 'Late Blight',
    'nama_latin': 'Phytophthora infestans',
    'deskripsi': 'Penyakit jamur yang menimbulkan bercak kehitaman dan basah pada daun serta batang, dan dapat menyebar cepat.',
    'kategori': 'Jamur (Oomycete)',
    'tingkat_risiko': 'tinggi',
  },
  {
    'id_penyakit': 'P003',
    'label_code': 'Leaf_Mold',
    'nama_penyakit': 'Leaf Mold',
    'nama_latin': 'Passalora fulva',
    'deskripsi': 'Penyakit jamur daun dengan bercak kuning pada permukaan atas dan lapisan beludru pada permukaan bawah daun.',
    'kategori': 'Jamur Daun',
    'tingkat_risiko': 'sedang',
  },
  {
    'id_penyakit': 'P004',
    'label_code': 'TYLCV',
    'nama_penyakit': 'Tomato Yellow Leaf Curl Virus (TYLCV)',
    'nama_latin': 'Begomovirus',
    'deskripsi': 'Penyakit virus yang menyebabkan daun menguning, keriting melengkung, dan pertumbuhan tanaman terhambat.',
    'kategori': 'Virus Tanaman',
    'tingkat_risiko': 'sangat_tinggi',
  },
  {
    'id_penyakit': 'P005',
    'label_code': 'Healthy',
    'nama_penyakit': 'Healthy',
    'nama_latin': 'Solanum lycopersicum',
    'deskripsi':
        'Daun sehat tanpa gejala penyakit yang terlihat pada permukaan daun.',
    'kategori': 'Sehat',
    'tingkat_risiko': 'sehat',
  },
];

/// Nama tabel yang dikelola skema ini (untuk keperluan perawatan/migrasi).
const List<String> kLeafItToMeTables = <String>[
  'pengguna',
  'tanaman',
  'penyakit',
  'riwayat_pemindaian',
  'penanganan',
  'panduan_menanam',
  'rekomendasi_produk',
];

/// Cetak biru (DDL) database SQLite LeafItToMe — versi 7.
///
/// Menyajikan skema tabel database offline-first aplikasi (`sqflite`):
/// 8 tabel ternormalisasi: `plants`, `scans`, `diseases`, `guides`, `tools`,
/// `products`, `sync_queue`, dan `app_meta`.
///
/// Skema ini adalah Single Source of Truth yang dieksekusi oleh `AppDatabase`.
library;

const int kLeafItToMeDatabaseVersion = 7;

/// Daftar nama tabel yang dikelola oleh database aplikasi.
const List<String> kLeafItToMeTables = <String>[
  'plants',
  'scans',
  'diseases',
  'guides',
  'tools',
  'products',
  'sync_queue',
  'app_meta',
];

/// Urutan pembuatan tabel & indeks. Dipakai `AppDatabase` saat inisialisasi database baru.
const List<String> kLeafItToMeSchema = <String>[
  '''
  CREATE TABLE plants (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL DEFAULT 'user-local',
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    planted_at TEXT NOT NULL,
    last_inspection_at TEXT,
    status TEXT NOT NULL,
    note TEXT,
    image_path TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )
  ''',
  '''
  CREATE TABLE scans (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    plant_id TEXT,
    disease_label TEXT NOT NULL,
    confidence REAL NOT NULL,
    local_image_path TEXT NOT NULL,
    cloud_image_url TEXT,
    notes TEXT,
    scanned_at TEXT NOT NULL,
    sync_status TEXT NOT NULL DEFAULT 'pending'
      CHECK (sync_status IN ('pending', 'synced')),
    FOREIGN KEY (plant_id) REFERENCES plants(id) ON DELETE SET NULL
  )
  ''',
  '''
  CREATE TABLE diseases (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    symptoms TEXT,
    treatment TEXT,
    image_url TEXT,
    updated_at TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE guides (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    content TEXT NOT NULL,
    category TEXT,
    video_url TEXT,
    updated_at TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE tools (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    updated_at TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    price REAL,
    product_url TEXT,
    updated_at TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE sync_queue (
    id TEXT PRIMARY KEY,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    operation TEXT NOT NULL,
    payload TEXT NOT NULL,
    created_at TEXT NOT NULL,
    attempts INTEGER NOT NULL DEFAULT 0,
    last_error TEXT,
    UNIQUE (entity_type, entity_id, operation)
  )
  ''',
  '''
  CREATE TABLE app_meta (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )
  ''',
  'CREATE INDEX IF NOT EXISTS idx_scans_user ON scans (user_id)',
  'CREATE INDEX IF NOT EXISTS idx_scans_plant ON scans (plant_id)',
  'CREATE INDEX IF NOT EXISTS idx_scans_sync ON scans (sync_status)',
  'CREATE INDEX IF NOT EXISTS idx_plants_status ON plants (status)',
  'CREATE INDEX IF NOT EXISTS idx_plants_deleted ON plants (deleted_at)',
  'CREATE INDEX IF NOT EXISTS idx_plants_user ON plants (user_id)',
];

/// Referensi 5 kelas penyakit yang dipakai model ML & master data awal.
const List<Map<String, Object?>> kLeafItToMeSeedDiseases = <Map<String, Object?>>[
  {
    'id': 'P001',
    'id_penyakit': 'P001',
    'label_code': 'Bacterial_Spot',
    'name': 'Bacterial Spot',
    'nama_penyakit': 'Bacterial Spot',
    'nama_latin': 'Xanthomonas spp.',
    'description':
        'Penyakit bakteri yang menimbulkan bercak kecil cokelat kehitaman pada daun dan dapat meluas hingga daun menguning.',
    'deskripsi':
        'Penyakit bakteri yang menimbulkan bercak kecil cokelat kehitaman pada daun dan dapat meluas hingga daun menguning.',
    'symptoms': 'Bercak kecil cokelat kehitaman, daun menguning dan rontok',
    'treatment':
        'Semprot bakterisida tembaga, buang daun yang terinfeksi, hindari penyiraman daun langsung.',
    'kategori': 'Bakteri',
    'tingkat_risiko': 'sedang',
    'image_url': 'assets/images/bacterial_spot.jpg',
  },
  {
    'id': 'P002',
    'id_penyakit': 'P002',
    'label_code': 'Late_Blight',
    'name': 'Late Blight',
    'nama_penyakit': 'Late Blight',
    'nama_latin': 'Phytophthora infestans',
    'description':
        'Penyakit jamur yang menimbulkan bercak kehitaman dan basah pada daun serta batang, dan dapat menyebar cepat.',
    'deskripsi':
        'Penyakit jamur yang menimbulkan bercak kehitaman dan basah pada daun serta batang, dan dapat menyebar cepat.',
    'symptoms': 'Bercak basah kehitaman berminyak pada daun dan batang',
    'treatment':
        'Gunakan fungisida sistemik tembaga, potong bagian terinfeksi, jaga sirkulasi udara kebun.',
    'kategori': 'Jamur (Oomycete)',
    'tingkat_risiko': 'tinggi',
    'image_url': 'assets/images/late_blight.jpg',
  },
  {
    'id': 'P003',
    'id_penyakit': 'P003',
    'label_code': 'Leaf_Mold',
    'name': 'Leaf Mold',
    'nama_penyakit': 'Leaf Mold',
    'nama_latin': 'Passalora fulva',
    'description':
        'Penyakit jamur daun dengan bercak kuning pada permukaan atas dan lapisan beludru pada permukaan bawah daun.',
    'deskripsi':
        'Penyakit jamur daun dengan bercak kuning pada permukaan atas dan lapisan beludru pada permukaan bawah daun.',
    'symptoms':
        'Bercak pucat/kuning di atas daun dan lapisan jamur cokelat di bawah daun',
    'treatment':
        'Kurangi kelembapan ruangan/greenhouse, aplikasikan fungisida organik, pangkas daun bawah.',
    'kategori': 'Jamur Daun',
    'tingkat_risiko': 'sedang',
    'image_url': 'assets/images/leaf_mold.jpg',
  },
  {
    'id': 'P004',
    'id_penyakit': 'P004',
    'label_code': 'TYLCV',
    'name': 'Tomato Yellow Leaf Curl Virus (TYLCV)',
    'nama_penyakit': 'Tomato Yellow Leaf Curl Virus (TYLCV)',
    'nama_latin': 'Begomovirus',
    'description':
        'Penyakit virus yang menyebabkan daun menguning, keriting melengkung, dan pertumbuhan tanaman terhambat.',
    'deskripsi':
        'Penyakit virus yang menyebabkan daun menguning, keriting melengkung, dan pertumbuhan tanaman terhambat.',
    'symptoms':
        'Daun mengecil, melengkung ke atas seperti mangkuk, tepi menguning, kerdil',
    'treatment':
        'Kendalikan vektor kutu kebul (whitefly) dengan insektisida/minyak mimba, cabut tanaman terinfeksi parah.',
    'kategori': 'Virus Tanaman',
    'tingkat_risiko': 'sangat_tinggi',
    'image_url': 'assets/images/tylcv.jpg',
  },
  {
    'id': 'P005',
    'id_penyakit': 'P005',
    'label_code': 'Healthy',
    'name': 'Healthy',
    'nama_penyakit': 'Healthy',
    'nama_latin': 'Solanum lycopersicum',
    'description':
        'Daun sehat tanpa gejala penyakit yang terlihat pada permukaan daun.',
    'deskripsi':
        'Daun sehat tanpa gejala penyakit yang terlihat pada permukaan daun.',
    'symptoms': 'Tidak ada gejala penyakit',
    'treatment': 'Pertahankan rutinitas penyiraman, pemupukan, dan sinar matahari yang cukup.',
    'kategori': 'Sehat',
    'tingkat_risiko': 'sehat',
    'image_url': 'assets/images/tomato_plant.png',
  },
];

/// Materi panduan bawaan beserta URL video berbahasa Indonesia.
///
/// Video disimpan di database (`guides.video_url`), bukan di UI.
const List<Map<String, Object?>> kLeafItToMeSeedGuides = <Map<String, Object?>>[
  {
    'id_panduan': 'GD-001',
    'kategori': 'Persiapan',
    'judul': 'Persiapan Alat dan Bahan',
    'deskripsi':
        'Siapkan wadah tanam, media, benih, dan alat perawatan sebelum mulai menanam tomat.',
    'langkah_langkah':
        '1. Pilih pot atau polybag berdiameter minimal 30-40 cm dengan lubang drainase.\n'
        '2. Siapkan media tanam dari campuran tanah, kompos, dan sekam.\n'
        '3. Pilih benih tomat unggul bersertifikat.\n'
        '4. Siapkan sprayer, ajir, dan pupuk organik atau NPK.',
    'gambar': 'assets/images/pot_tanam.jpg',
    'video_url': 'https://www.youtube.com/watch?v=6fr7OFcITBk',
    'created_at': '2026-07-01T08:00:00',
  },
  {
    'id_panduan': 'GD-002',
    'kategori': 'Penanaman',
    'judul': 'Cara Menanam Tomat',
    'deskripsi':
        'Langkah dasar menyemai benih dan memindahkan bibit ke media tanam.',
    'langkah_langkah':
        '1. Rendam benih selama beberapa jam lalu semai di wadah kecil.\n'
        '2. Jaga media semai tetap lembap dan tempatkan di area terang.\n'
        '3. Pindahkan bibit ke pot utama setelah memiliki 4-5 helai daun.\n'
        '4. Pasang ajir sebagai penyangga batang tanaman.',
    'gambar': 'assets/images/tomato_plant.png',
    'video_url': 'https://www.youtube.com/watch?v=LgZysH3ggp8',
    'created_at': '2026-07-02T08:00:00',
  },
  {
    'id_panduan': 'GD-003',
    'kategori': 'Perawatan',
    'judul': 'Perawatan Harian',
    'deskripsi':
        'Rutinitas penyiraman, pemupukan, dan pemangkasan agar tanaman tumbuh sehat.',
    'langkah_langkah':
        '1. Siram tanaman pada pagi atau sore hari sesuai kondisi media.\n'
        '2. Beri pupuk organik atau NPK secara berkala sesuai dosis.\n'
        '3. Pangkas tunas air dan daun tua yang tidak produktif.\n'
        '4. Periksa daun secara rutin untuk mendeteksi gejala penyakit.',
    'gambar': 'assets/images/tomato_plant.png',
    'video_url': 'https://www.youtube.com/watch?v=cLBXqZ0VtOA',
    'created_at': '2026-07-03T08:00:00',
  },
  {
    'id_panduan': 'GD-004',
    'kategori': 'Pencegahan',
    'judul': 'Mencegah Penyakit',
    'deskripsi':
        'Langkah dasar menjaga sanitasi dan sirkulasi udara untuk mencegah penyakit daun.',
    'langkah_langkah':
        '1. Hindari menyiram daun dan arahkan air ke media tanam.\n'
        '2. Jaga jarak antar tanaman agar sirkulasi udara lancar.\n'
        '3. Bersihkan gulma dan daun gugur di sekitar pot.\n'
        '4. Gunakan benih sehat dan bersihkan alat sebelum digunakan.',
    'gambar': 'assets/images/late_blight.jpg',
    'video_url': 'https://www.youtube.com/watch?v=0kRmIf_I3lc',
    'created_at': '2026-07-04T08:00:00',
  },
];

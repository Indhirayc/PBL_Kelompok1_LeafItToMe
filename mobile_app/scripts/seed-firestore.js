/**
 * LeafItToMe - Seed Firestore (master data)
 * =========================================
 *
 * Mengisi koleksi master data Firestore dari data statis aplikasi Flutter:
 *   - diseases/{diseaseId}
 *   - guides/{guideId}
 *   - tools/{toolId}
 *   - products/{productId}
 *   - meta/app
 *
 * Data user (users/{uid}, plants, scans) TIDAK di-seed di sini.
 * Data tersebut dibuat oleh aplikasi saat register / menyimpan tanaman / scan.
 *
 * Pemakaian (dari folder mobile_app):
 *   node scripts/seed-firestore.js
 *   node scripts/seed-firestore.js --dry-run
 *   node scripts/seed-firestore.js --version=2
 *
 * Autentikasi (urutan prioritas):
 *   1. GOOGLE_APPLICATION_CREDENTIALS
 *   2. mobile_app/serviceAccountKey.json
 *   3. Application Default Credentials (firebase login / gcloud auth)
 *
 * Catatan:
 *   - Semua penulisan memakai set(..., { merge: true }) agar idempotent.
 *   - Document ID sengaja memakai ID stabil (P001, GD-001, dst), bukan auto-ID.
 *   - Jalankan di project dev lebih dulu, jangan langsung ke produksi.
 */

'use strict';

const fs = require('fs');
const path = require('path');
const {
  initializeApp,
  getApps,
  cert,
  applicationDefault,
} = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

// ---------------------------------------------------------------------------
// Konfigurasi & argumen
// ---------------------------------------------------------------------------

const args = process.argv.slice(2);
const isDryRun = args.includes('--dry-run');

const versionArg = args.find((arg) => arg.startsWith('--version='));
const masterDataVersion = versionArg
  ? Number(versionArg.split('=')[1])
  : 1;

if (!Number.isFinite(masterDataVersion) || masterDataVersion < 1) {
  console.error('Nilai --version harus angka >= 1.');
  process.exit(1);
}

const projectRoot = path.resolve(__dirname, '..');
const serviceAccountPath = path.join(projectRoot, 'serviceAccountKey.json');

// ---------------------------------------------------------------------------
// Inisialisasi Firebase Admin
// ---------------------------------------------------------------------------

function initializeAdmin() {
  const existing = getApps();
  if (existing.length > 0) {
    return existing[0];
  }

  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.log(
      'Auth: GOOGLE_APPLICATION_CREDENTIALS =',
      process.env.GOOGLE_APPLICATION_CREDENTIALS,
    );
    return initializeApp({ credential: applicationDefault() });
  }

  if (fs.existsSync(serviceAccountPath)) {
    console.log('Auth: service account =', serviceAccountPath);
    const serviceAccount = require(serviceAccountPath);
    return initializeApp({
      credential: cert(serviceAccount),
      projectId: serviceAccount.project_id,
    });
  }

  console.log('Auth: Application Default Credentials (ADC)');
  return initializeApp({ credential: applicationDefault() });
}

// ---------------------------------------------------------------------------
// Master data
// ---------------------------------------------------------------------------

/**
 * diseases/{id}
 * Field mengikuti kontrak snake_case:
 *   label_code, nama_penyakit, nama_latin, deskripsi, kategori,
 *   tingkat_risiko, gambar, search_keyword, gejala[], pencegahan[], penanganan[]
 */
const diseases = [
  {
    id: 'P001',
    label_code: 'Bacterial_Spot',
    nama_penyakit: 'Bacterial Spot',
    nama_latin: 'Xanthomonas spp.',
    deskripsi:
      'Penyakit bakteri yang menimbulkan bercak kecil cokelat kehitaman pada daun dan dapat meluas hingga daun menguning.',
    kategori: 'Bakteri',
    tingkat_risiko: 'sedang',
    gambar: 'assets/images/bacterial_spot.jpg',
    search_keyword: 'bakterisida tembaga bacterial spot tomat',
    gejala: [
      'Muncul bercak kecil berwarna cokelat kehitaman, terkadang tampak basah, pada permukaan daun.',
      'Bercak dapat membesar dan menyatu, sementara jaringan di sekitarnya menguning lalu mengering.',
      'Pada serangan berat, daun dapat gugur dan bercak kasar juga bisa muncul pada batang atau buah.',
    ],
    pencegahan: [
      'Siram langsung ke media tanam dan hindari membasahi daun, terutama pada sore atau malam hari.',
      'Beri jarak tanam yang cukup agar sirkulasi udara baik dan daun cepat kering setelah terkena air.',
      'Gunakan benih atau bibit sehat bersertifikat, serta bersihkan alat pemangkasan sebelum digunakan kembali.',
    ],
    penanganan: [
      'Pangkas bagian daun yang menunjukkan gejala, lalu buang dengan aman dan jangan dijadikan kompos.',
      'Gunakan bakterisida berbahan aktif tembaga yang sesuai untuk tomat dan ikuti petunjuk pada label produk.',
      'Kurangi kelembapan di sekitar tanaman dengan memperbaiki sirkulasi udara dan menghindari penyiraman berlebih.',
    ],
  },
  {
    id: 'P002',
    label_code: 'Late_Blight',
    nama_penyakit: 'Late Blight',
    nama_latin: 'Phytophthora infestans',
    deskripsi:
      'Penyakit jamur yang menimbulkan bercak kehitaman dan basah pada daun serta batang, dan dapat menyebar cepat.',
    kategori: 'Jamur (Oomycete)',
    tingkat_risiko: 'tinggi',
    gambar: 'assets/images/late_blight.jpg',
    search_keyword: 'fungisida tembaga busuk daun late blight',
    gejala: [
      'Bercak kehitaman atau cokelat basah tak beraturan di ujung atau tepi daun.',
      'Terdapat lapisan seperti kapas atau bulu halus keperakan di balik daun saat lembap.',
      'Daun dengan cepat layu, mengering, membusuk, dan menggulung kecokelatan.',
      'Batang dan buah membentuk lesi bercak cokelat gelap bertekstur kasar.',
    ],
    pencegahan: [
      'Potong dan segera musnahkan daun atau bagian tanaman yang menunjukkan gejala awal.',
      'Hindari menyiram dari atas daun; siramlah langsung ke media tanah di pagi hari.',
      'Beri jarak antar pot minimal 50-60 cm untuk menjaga sirkulasi udara yang lancar.',
      'Semprotkan fungisida berbasis tembaga atau bahan organik secara berkala.',
    ],
    penanganan: [
      'Buang dan musnahkan daun terinfeksi agar tidak menulari tanaman lain.',
      'Aplikasikan fungisida berbasis tembaga sesuai dosis pada label produk.',
      'Perbaiki drainase dan sirkulasi udara di sekitar tanaman.',
    ],
  },
  {
    id: 'P003',
    label_code: 'Leaf_Mold',
    nama_penyakit: 'Leaf Mold',
    nama_latin: 'Passalora fulva',
    deskripsi:
      'Penyakit jamur daun dengan bercak kuning pada permukaan atas dan lapisan beludru pada permukaan bawah daun.',
    kategori: 'Jamur Daun',
    tingkat_risiko: 'sedang',
    gambar: 'assets/images/leaf_mold.jpg',
    search_keyword: 'fungisida mancozeb obat jamur daun tomat',
    gejala: [
      'Muncul bercak kuning pucat tak beraturan pada permukaan atas daun bagian bawah.',
      'Tumbuh lapisan beludru abu-abu kecokelatan di permukaan bawah daun.',
      'Daun yang terinfeksi berat akan berubah menjadi cokelat keriput dan gugur.',
      'Perkembangan penyakit sangat pesat saat kelembapan udara tinggi di atas 85 persen.',
    ],
    pencegahan: [
      'Tingkatkan ventilasi dan tempatkan tanaman di area yang terkena sinar matahari penuh.',
      'Lakukan pemangkasan pada daun-daun tua di bagian bawah tanaman.',
      'Jaga permukaan daun tetap kering dan bersihkan guguran daun di sekitar pot.',
      'Aplikasikan fungisida berbahan aktif mankozeb atau pembasmi jamur organik.',
    ],
    penanganan: [
      'Pangkas daun yang terinfeksi dan buang jauh dari area tanam.',
      'Aplikasikan fungisida berbahan mankozeb sesuai petunjuk produk.',
      'Kurangi kelembapan di sekitar tanaman dan tingkatkan aliran udara.',
    ],
  },
  {
    id: 'P004',
    label_code: 'TYLCV',
    nama_penyakit: 'Tomato Yellow Leaf Curl Virus (TYLCV)',
    nama_latin: 'Begomovirus',
    deskripsi:
      'Penyakit virus yang menyebabkan daun menguning, keriting melengkung, dan pertumbuhan tanaman terhambat.',
    kategori: 'Virus Tanaman',
    tingkat_risiko: 'sangat_tinggi',
    gambar: 'assets/images/tylcv.jpg',
    search_keyword: 'insektisida minyak mimba neem oil kutu kebul',
    gejala: [
      'Helaian daun menguning cerah di tepi dan sela tulang daun.',
      'Tepi daun melengkung ke atas seperti cangkir dan mengerut kaku.',
      'Pertumbuhan tanaman terhenti, kerdil, dan pembentukan bunga atau buah terhambat.',
      'Penyakit disebarkan secara cepat oleh serangga kutu kebul.',
    ],
    pencegahan: [
      'Kendalikan serangga vektor kutu kebul dengan minyak mimba atau perangkap kuning.',
      'Pasang kassa atau jaring pembatas jika menanam di greenhouse.',
      'Cabut dan musnahkan segera tanaman yang terinfeksi parah agar tidak menular.',
      'Pilih dan tanam varietas benih tomat yang resisten terhadap virus keriting.',
    ],
    penanganan: [
      'Kendalikan kutu kebul sebagai vektor virus dengan minyak mimba atau perangkap kuning.',
      'Cabut dan musnahkan tanaman yang terinfeksi berat agar tidak menular ke tanaman lain.',
      'Gunakan varietas benih tomat yang resisten dan jaga sanitasi area tanam.',
    ],
  },
  {
    id: 'P005',
    label_code: 'Healthy',
    nama_penyakit: 'Healthy',
    nama_latin: 'Solanum lycopersicum',
    deskripsi:
      'Daun sehat tanpa gejala penyakit yang terlihat pada permukaan daun.',
    kategori: 'Sehat',
    tingkat_risiko: 'sehat',
    gambar: 'assets/images/tomato_plant.png',
    search_keyword: 'daun tomat sehat',
    gejala: [],
    pencegahan: [],
    penanganan: [],
  },
];

/**
 * guides/{id}
 * langkah[] berupa objek { urutan, judul, deskripsi } agar cocok dengan
 * tampilan GuideDetailPage (judul + deskripsi per langkah).
 */
const guides = [
  {
    id: 'GD-001',
    slug: 'persiapan-alat-dan-bahan',
    kategori: 'Persiapan',
    judul: 'Persiapan Alat dan Bahan',
    deskripsi:
      'Siapkan wadah tanam, media, benih, dan alat perawatan sebelum mulai menanam tomat.',
    langkah: [
      {
        urutan: 1,
        judul: 'Pilih Pot',
        deskripsi:
          'Pilih pot atau polybag berdiameter minimal 30-40 cm dengan lubang drainase.',
      },
      {
        urutan: 2,
        judul: 'Siapkan Media Tanam',
        deskripsi:
          'Campurkan tanah topsoil, kompos matang, dan sekam bakar dengan perbandingan 1:1:1.',
      },
      {
        urutan: 3,
        judul: 'Pilih Benih',
        deskripsi:
          'Gunakan benih tomat unggul atau hibrida (F1) bersertifikat dengan daya kecambah tinggi.',
      },
      {
        urutan: 4,
        judul: 'Siapkan Alat Perawatan',
        deskripsi:
          'Siapkan sprayer, ajir, dan pupuk organik atau NPK sesuai kebutuhan.',
      },
    ],
    gambar: 'assets/images/pot_tanam.jpg',
    video_url: 'https://www.youtube.com/watch?v=6fr7OFcITBk',
    urutan: 1,
  },
  {
    id: 'GD-002',
    slug: 'cara-menanam-tomat',
    kategori: 'Penanaman',
    judul: 'Cara Menanam Tomat',
    deskripsi:
      'Langkah dasar menyemai benih dan memindahkan bibit ke media tanam.',
    langkah: [
      {
        urutan: 1,
        judul: 'Siapkan Media Tanam',
        deskripsi:
          'Campurkan tanah humus/topsoil, kompos matang, dan sekam bakar (1:1:1). Masukkan ke pot berdiameter minimal 30-40 cm dengan drainase baik.',
      },
      {
        urutan: 2,
        judul: 'Tanam Benih atau Bibit',
        deskripsi:
          'Buat lubang tanam sedalam 1-2 cm di bagian tengah media. Letakkan benih atau pindahkan bibit muda tanpa merusak perakaran.',
      },
      {
        urutan: 3,
        judul: 'Siram Perlahan',
        deskripsi:
          'Semprotkan air merata dengan sprayer halus agar media lembap tanpa memadatkan atau menggeser bibit.',
      },
      {
        urutan: 4,
        judul: 'Pencahayaan & Penempatan',
        deskripsi:
          'Letakkan pot di tempat teduh 2-3 hari pertama, lalu pindahkan ke area dengan 6-8 jam sinar matahari penuh per hari.',
      },
    ],
    gambar: 'assets/images/tomato_plant.png',
    video_url: 'https://www.youtube.com/watch?v=LgZysH3ggp8',
    urutan: 2,
  },
  {
    id: 'GD-003',
    slug: 'perawatan-harian',
    kategori: 'Perawatan',
    judul: 'Perawatan Harian',
    deskripsi:
      'Rutinitas penyiraman, pemupukan, dan pemangkasan agar tanaman tumbuh sehat.',
    langkah: [
      {
        urutan: 1,
        judul: 'Cek Kelembapan Media',
        deskripsi:
          'Tekan tanah sedalam 2 cm. Jika mulai kering, lakukan penyiraman secukupnya.',
      },
      {
        urutan: 2,
        judul: 'Penyiraman Pangkal Batang',
        deskripsi:
          'Siram langsung ke media tanah di sekitar pangkal tanaman, hindari membasahi daun.',
      },
      {
        urutan: 3,
        judul: 'Pemangkasan Tunas Air (Wiwil)',
        deskripsi:
          'Buang tunas air di ketiak daun agar nutrisi terfokus pada batang utama dan pembungaan.',
      },
      {
        urutan: 4,
        judul: 'Pemasangan Tiang Ajir',
        deskripsi:
          'Ikat batang tomat dengan tali rami longgar ke bambu ajir agar tidak rebah saat berbuah.',
      },
    ],
    gambar: 'assets/images/tomato_plant.png',
    video_url: 'https://www.youtube.com/watch?v=cLBXqZ0VtOA',
    urutan: 3,
  },
  {
    id: 'GD-004',
    slug: 'mencegah-penyakit',
    kategori: 'Pencegahan',
    judul: 'Mencegah Penyakit',
    deskripsi:
      'Langkah dasar menjaga sanitasi dan sirkulasi udara untuk mencegah penyakit daun.',
    langkah: [
      {
        urutan: 1,
        judul: 'Hindari Menyiram Daun',
        deskripsi:
          'Arahkan air ke media tanam, jangan membasahi daun, terutama pada sore atau malam hari.',
      },
      {
        urutan: 2,
        judul: 'Jaga Sirkulasi Udara',
        deskripsi:
          'Beri jarak antar tanaman agar udara mengalir dan daun cepat kering setelah terkena air.',
      },
      {
        urutan: 3,
        judul: 'Bersihkan Area Tanam',
        deskripsi:
          'Bersihkan gulma dan daun gugur di sekitar pot untuk mengurangi sumber infeksi.',
      },
      {
        urutan: 4,
        judul: 'Gunakan Benih Sehat',
        deskripsi:
          'Gunakan benih sehat dan bersihkan alat pemangkasan sebelum digunakan kembali.',
      },
    ],
    gambar: 'assets/images/late_blight.jpg',
    video_url: 'https://www.youtube.com/watch?v=0kRmIf_I3lc',
    urutan: 4,
  },
];

/**
 * tools/{id}
 * spesifikasi berupa map string -> string.
 */
const tools = [
  {
    id: 'pot-tanam',
    slug: 'pot-tanam',
    nama: 'Pot Tanam / Polybag',
    tag: 'Wajib',
    deskripsi_singkat: 'Diameter minimal 30-40 cm',
    deskripsi_lengkap:
      'Wadah utama untuk pertumbuhan akar tomat. Sistem drainase yang baik sangat krusial agar air siraman tidak menggenang di dasar pot.',
    spesifikasi: {
      Ukuran: 'Diameter 30-40 cm',
      Bahan: 'Tanah liat, keramik, atau plastik tebal',
      Drainase: 'Minimal 4-6 lubang di dasar pot',
    },
    tips: 'Pastikan air tidak menggenang di dasar pot untuk mencegah busuk akar.',
    ikon: 'inventory_2_outlined',
    gambar: 'assets/images/pot_tanam.jpg',
    search_keyword: 'pot tanaman diameter 30cm',
    urutan: 1,
  },
  {
    id: 'benih-tomat',
    slug: 'benih-tomat',
    nama: 'Benih Tomat Unggul',
    tag: 'Wajib',
    deskripsi_singkat: 'Pilih benih bersertifikat',
    deskripsi_lengkap:
      'Benih tomat unggul atau hibrida (F1) berkualitas tinggi dengan tingkat daya berkecambah di atas 85% dan daya tahan lebih baik terhadap serangan hama dan penyakit.',
    spesifikasi: {
      Varietas: 'Tomat Buah / Tomat Cherry',
      Sertifikasi: 'Label Resmi Kementan / Benih F1',
      Kemasan: 'Aluminium foil kedap udara',
    },
    tips: 'Simpan sisa benih di wadah kedap udara dan tempat yang sejuk.',
    ikon: 'eco_outlined',
    gambar: '',
    search_keyword: 'benih tomat hibrida unggul',
    urutan: 2,
  },
  {
    id: 'media-tanam',
    slug: 'media-tanam',
    nama: 'Media Tanam Subur',
    tag: 'Wajib',
    deskripsi_singkat: 'Tanah, kompos, dan sekam',
    deskripsi_lengkap:
      'Kombinasi media tanam gembur yang kaya nutrisi organik, memiliki porositas tinggi, dan dapat menahan kelembapan tanah secara stabil.',
    spesifikasi: {
      Komposisi: 'Tanah topsoil : Kompos : Sekam bakar (1:1:1)',
      'pH Ideal': '6.0 - 6.8 (Agak Asam - Netral)',
      Tekstur: 'Gembur, porus & kaya humus',
    },
    tips: 'Sterilkan media tanam di bawah sinar matahari sebelum digunakan.',
    ikon: 'landscape_outlined',
    gambar: '',
    search_keyword: 'media tanam organik gembur',
    urutan: 3,
  },
  {
    id: 'penyiram-sprayer',
    slug: 'penyiram-sprayer',
    nama: 'Sprayer & Alat Penyiram',
    tag: 'Opsional',
    deskripsi_singkat: 'Gunakan aliran air lembut',
    deskripsi_lengkap:
      'Sprayer misting halus untuk membasahi benih pada tahap awal penyemaian, serta gembor berlubang halus untuk menyiram tanaman dewasa tanpa merusak struktur tanah.',
    spesifikasi: {
      Kapasitas: '1.5 - 2 Liter Sprayer',
      Nozzle: 'Dapat diatur (kabut halus s/d semprotan)',
      Bahan: 'Plastik HDPE tahan bocor & korosi',
    },
    tips: 'Siramlah langsung di sekeliling pangkal batang, hindari menyiram daun.',
    ikon: 'water_drop_outlined',
    gambar: '',
    search_keyword: 'sprayer semprotan tanaman 2 liter',
    urutan: 4,
  },
  {
    id: 'ajir-tanaman',
    slug: 'ajir-tanaman',
    nama: 'Ajir Tanaman (Penyangga)',
    tag: 'Opsional',
    deskripsi_singkat: 'Penyangga batang tomat',
    deskripsi_lengkap:
      'Tiang penyangga berbahan bambu atau pipa PVC setinggi 1.5-2 meter untuk menopang batang tomat yang berbuah lebat agar tidak rebah atau patah.',
    spesifikasi: {
      Tinggi: '1.5 - 2.0 Meter',
      Bahan: 'Bambu tebal / Pipa PVC / Kayu',
      Pengikat: 'Tali rami atau tali kain lembut',
    },
    tips: 'Pasang ajir seawal mungkin saat penanaman bibit agar akar tidak rusak.',
    ikon: 'straighten_outlined',
    gambar: '',
    search_keyword: 'ajir bambu penyangga tanaman',
    urutan: 5,
  },
  {
    id: 'pupuk-organik',
    slug: 'pupuk-organik',
    nama: 'Pupuk Organik & NPK',
    tag: 'Opsional',
    deskripsi_singkat: 'Nutrisi lengkap tanaman',
    deskripsi_lengkap:
      'Pupuk dasar kompos/kandang yang telah terfermentasi matang, serta pupuk NPK dan Kalsium untuk merangsang pertumbuhan bunga dan memperkuat dinding sel buah.',
    spesifikasi: {
      'Pupuk Dasar': 'Kompos matang / Pupuk kandang kambing',
      'Pupuk Susulan': 'NPK 16-16-16 & Kalsium Nitrat',
      Dosis: '1-2 sendok makan per tanaman',
    },
    tips: 'Berikan pupuk kalsium untuk mencegah pembusukan pada ujung buah.',
    ikon: 'science_outlined',
    gambar: '',
    search_keyword: 'pupuk npk 16 16 16 tanaman tomat',
    urutan: 6,
  },
];

/**
 * products/{id}
 * disease_ids[] agar satu produk bisa terkait beberapa penyakit.
 */
const products = [
  {
    id: 'PRD-001',
    disease_ids: ['P001'],
    id_panduan: 'GD-004',
    nama_produk: 'Bakterisida Tembaga',
    deskripsi:
      'Bakterisida berbahan aktif tembaga untuk membantu mengendalikan penyakit bakteri pada daun tomat.',
    link_penjualan:
      'https://shopee.co.id/search?keyword=bakterisida%20tembaga%20bacterial%20spot%20tomat',
    kategori: 'Obat',
    search_keyword: 'bakterisida tembaga bacterial spot tomat',
    gambar: '',
    is_active: true,
  },
  {
    id: 'PRD-002',
    disease_ids: ['P002'],
    id_panduan: 'GD-004',
    nama_produk: 'Fungisida Tembaga',
    deskripsi:
      'Fungisida berbasis tembaga untuk membantu mengendalikan penyakit jamur seperti late blight.',
    link_penjualan:
      'https://shopee.co.id/search?keyword=fungisida%20tembaga%20busuk%20daun%20late%20blight',
    kategori: 'Obat',
    search_keyword: 'fungisida tembaga busuk daun late blight',
    gambar: '',
    is_active: true,
  },
  {
    id: 'PRD-003',
    disease_ids: ['P003'],
    id_panduan: 'GD-004',
    nama_produk: 'Fungisida Mankozeb',
    deskripsi:
      'Fungisida berbahan aktif mankozeb untuk membantu mengendalikan jamur daun.',
    link_penjualan:
      'https://shopee.co.id/search?keyword=fungisida%20mancozeb%20obat%20jamur%20daun%20tomat',
    kategori: 'Obat',
    search_keyword: 'fungisida mancozeb obat jamur daun tomat',
    gambar: '',
    is_active: true,
  },
  {
    id: 'PRD-004',
    disease_ids: ['P004'],
    id_panduan: 'GD-004',
    nama_produk: 'Minyak Mimba (Neem Oil)',
    deskripsi:
      'Minyak mimba untuk membantu mengendalikan kutu kebul sebagai vektor virus TYLCV.',
    link_penjualan:
      'https://shopee.co.id/search?keyword=insektisida%20minyak%20mimba%20neem%20oil%20kutu%20kebul',
    kategori: 'Obat',
    search_keyword: 'insektisida minyak mimba neem oil kutu kebul',
    gambar: '',
    is_active: true,
  },
  {
    id: 'PRD-005',
    disease_ids: [],
    id_panduan: 'GD-003',
    nama_produk: 'Pupuk NPK 16-16-16',
    deskripsi:
      'Pupuk majemuk untuk membantu memenuhi kebutuhan nutrisi tanaman tomat.',
    link_penjualan:
      'https://shopee.co.id/search?keyword=pupuk%20npk%2016%2016%2016%20tanaman%20tomat',
    kategori: 'Pupuk',
    search_keyword: 'pupuk npk 16 16 16 tanaman tomat',
    gambar: '',
    is_active: true,
  },
];

// ---------------------------------------------------------------------------
// Penulisan
// ---------------------------------------------------------------------------

function buildDocuments() {
  const timestamp = FieldValue.serverTimestamp();

  return [
    ...diseases.map(({ id, ...data }) => ({
      collection: 'diseases',
      id,
      data: { ...data, updated_at: timestamp },
    })),
    ...guides.map(({ id, ...data }) => ({
      collection: 'guides',
      id,
      data: { ...data, updated_at: timestamp },
    })),
    ...tools.map(({ id, ...data }) => ({
      collection: 'tools',
      id,
      data: { ...data, updated_at: timestamp },
    })),
    ...products.map(({ id, ...data }) => ({
      collection: 'products',
      id,
      data: { ...data, updated_at: timestamp },
    })),
    {
      collection: 'meta',
      id: 'app',
      data: {
        schema_version: 1,
        master_data_version: masterDataVersion,
        updated_at: timestamp,
      },
    },
  ];
}

/**
 * Firestore membatasi 500 operasi per batch.
 */
async function commitInChunks(db, documents, chunkSize = 400) {
  let written = 0;

  for (let start = 0; start < documents.length; start += chunkSize) {
    const chunk = documents.slice(start, start + chunkSize);
    const batch = db.batch();

    for (const doc of chunk) {
      batch.set(
        db.collection(doc.collection).doc(doc.id),
        doc.data,
        { merge: true },
      );
    }

    await batch.commit();
    written += chunk.length;
    console.log(`  -> ${written}/${documents.length} dokumen tertulis`);
  }

  return written;
}

async function main() {
  const app = initializeAdmin();
  const db = getFirestore(app);
  const documents = buildDocuments();

  const summary = documents.reduce((acc, doc) => {
    acc[doc.collection] = (acc[doc.collection] || 0) + 1;
    return acc;
  }, {});

  console.log('\nRingkasan seed:');
  for (const [collection, count] of Object.entries(summary)) {
    console.log(`  ${collection}: ${count} dokumen`);
  }
  console.log(`  master_data_version: ${masterDataVersion}`);

  if (isDryRun) {
    console.log('\n[dry-run] Tidak ada data yang ditulis ke Firestore.');
    return;
  }

  console.log('\nMenulis ke Firestore...');
  await commitInChunks(db, documents);
  console.log('\nSeed selesai.');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('\nSeed gagal:', error);
    process.exit(1);
  });

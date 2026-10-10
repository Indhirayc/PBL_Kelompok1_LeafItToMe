import 'package:flutter/material.dart';

class ToolModel {
  final String id;
  final String name;
  final String tag; // 'Wajib' or 'Opsional'
  final String shortDescription;
  final String fullDescription;
  final Map<String, String> specifications;
  final String tip;
  final IconData icon;
  final String? imageAssetPath;
  final String searchKeyword;

  const ToolModel({
    required this.id,
    required this.name,
    required this.tag,
    required this.shortDescription,
    required this.fullDescription,
    required this.specifications,
    required this.tip,
    required this.icon,
    this.imageAssetPath,
    required this.searchKeyword,
  });
}

class DiseaseModel {
  final String id;
  final String name;
  final String latinName;
  final String category;
  final String severity;
  final Color severityColor;
  final String shortDescription;
  final List<String> symptoms;
  final List<String> preventions;
  final String imageAssetPath;
  final String searchKeyword;

  const DiseaseModel({
    required this.id,
    required this.name,
    required this.latinName,
    required this.category,
    required this.severity,
    required this.severityColor,
    required this.shortDescription,
    required this.symptoms,
    required this.preventions,
    required this.imageAssetPath,
    required this.searchKeyword,
  });
}

abstract final class GuideData {
  static const List<ToolModel> tools = [
    ToolModel(
      id: 'pot-tanam',
      name: 'Pot Tanam / Polybag',
      tag: 'Wajib',
      shortDescription: 'Diameter minimal 30-40 cm',
      fullDescription:
          'Wadah utama untuk pertumbuhan akar tomat. Memiliki sistem drainase yang baik sangat krusial agar air siraman tidak menggenang di dasar pot.',
      specifications: {
        'Ukuran': 'Diameter 30–40 cm',
        'Bahan': 'Tanah liat, keramik, atau plastik tebal',
        'Drainase': 'Minimal 4–6 lubang di dasar pot',
      },
      tip: 'Pastikan air tidak menggenang di dasar pot untuk mencegah busuk akar.',
      icon: Icons.inventory_2_outlined,
      imageAssetPath: 'assets/images/pot_tanam.jpg',
      searchKeyword: 'pot tanaman diameter 30cm',
    ),
    ToolModel(
      id: 'benih-tomat',
      name: 'Benih Tomat Unggul',
      tag: 'Wajib',
      shortDescription: 'Pilih benih bersertifikat',
      fullDescription:
          'Benih tomat unggul atau hibrida (F1) berkualitas tinggi dengan tingkat daya berkecambah di atas 85% dan daya tahan lebih baik terhadap serangan hama & penyakit.',
      specifications: {
        'Varietas': 'Tomat Buah / Tomat Cherry',
        'Sertifikasi': 'Label Resmi Kementan / Benih F1',
        'Kemasan': 'Aluminium foil kedap udara',
      },
      tip: 'Simpan sisa benih di wadah kedap udara dan tempat yang sejuk.',
      icon: Icons.eco_outlined,
      searchKeyword: 'benih tomat hibrida unggul',
    ),
    ToolModel(
      id: 'media-tanam',
      name: 'Media Tanam Subur',
      tag: 'Wajib',
      shortDescription: 'Tanah, kompos, dan sekam',
      fullDescription:
          'Kombinasi media tanam gembur yang kaya nutrisi organik, memiliki porositas tinggi, dan dapat menahan kelembapan tanah secara stabil.',
      specifications: {
        'Komposisi': 'Tanah topsoil : Kompos : Sekam bakar (1:1:1)',
        'pH Ideal': '6.0 – 6.8 (Agak Asam - Netral)',
        'Tekstur': 'Gembur, porus & kaya humus',
      },
      tip: 'Sterilkan media tanam di bawah sinar matahari sebelum digunakan.',
      icon: Icons.landscape_outlined,
      searchKeyword: 'media tanam organik gembur',
    ),
    ToolModel(
      id: 'penyiram-sprayer',
      name: 'Sprayer & Alat Penyiram',
      tag: 'Opsional',
      shortDescription: 'Gunakan aliran air lembut',
      fullDescription:
          'Sprayer misting halus untuk membasahi benih pada tahap awal penyemaian, serta gembor berlubang halus untuk menyiram tanaman dewasa tanpa merusak struktur tanah.',
      specifications: {
        'Kapasitas': '1.5 – 2 Litre Sprayer',
        'Nozzle': 'Dapat diatur (Kabut halus s/d Semprotan)',
        'Bahan': 'Plastik HDPE tahan bocor & korosi',
      },
      tip: 'Siramlah langsung di sekeliling pangkal batang, hindari menyiram daun.',
      icon: Icons.water_drop_outlined,
      searchKeyword: 'sprayer semprotan tanaman 2 liter',
    ),
    ToolModel(
      id: 'ajir-tanaman',
      name: 'Ajir Tanaman (Penyangga)',
      tag: 'Opsional',
      shortDescription: 'Penyangga batang tomat',
      fullDescription:
          'Tiang penyangga berbahan bambu atau pipa PVC setinggi 1.5–2 meter untuk menopang batang tomat yang berbuah lebat agar tidak rebah atau patah.',
      specifications: {
        'Tinggi': '1.5 – 2.0 Meter',
        'Bahan': 'Bambu tebal / Pipa PVC / Kayu',
        'Pengikat': 'Tali rami atau tali kain lembut',
      },
      tip: 'Pasang ajir seawal mungkin saat penanaman bibit agar akar tidak rusak.',
      icon: Icons.straighten_outlined,
      searchKeyword: 'ajir bambu penyangga tanaman',
    ),
    ToolModel(
      id: 'pupuk-organik',
      name: 'Pupuk Organik & NPK',
      tag: 'Opsional',
      shortDescription: 'Nutrisi lengkap tanaman',
      fullDescription:
          'Pupuk dasar kompos/kandang yang telah terfermentasi matang, serta pupuk NPK dan Kalsium untuk merangsang pertumbuhan bunga dan memperkuat dinding sel buah.',
      specifications: {
        'Pupuk Dasar': 'Kompos matang / Pupuk kandang kambing',
        'Pupuk Susulan': 'NPK 16-16-16 & Kalsium Nitrat',
        'Dosis': '1–2 sendok makan per tanaman',
      },
      tip: 'Berikan pupuk kalsium untuk mencegah pembusukan pada ujung buah.',
      icon: Icons.science_outlined,
      searchKeyword: 'pupuk npk 16 16 16 tanaman tomat',
    ),
  ];

  static const List<DiseaseModel> diseases = [
    DiseaseModel(
      id: 'late-blight',
      name: 'Late Blight',
      latinName: 'Phytophthora infestans • Penyakit Jamur',
      category: 'Jamur (Oomycete)',
      severity: 'RISIKO TINGGI',
      severityColor: Color(0xFFD32F2F),
      shortDescription: 'Bercak kehitaman & basah pada daun dan batang',
      symptoms: [
        'Bercak kehitaman atau cokelat basah tak beraturan di ujung/tepi daun.',
        'Terdapat lapisan seperti kapas/bulu halus keperakan di balik daun saat lembap.',
        'Daun dengan cepat layu, mengering, membusuk, dan menggulung kecokelatan.',
        'Batang dan buah membentuk lesi bercak cokelat gelap bertekstur kasar.',
      ],
      preventions: [
        'Potong dan segera musnahkan daun atau bagian tanaman yang menunjukkan gejala awal.',
        'Hindari menyiram dari atas daun; siramlah langsung ke media tanah di pagi hari.',
        'Beri jarak antar pot minimal 50-60 cm untuk menjaga sirkulasi udara yang lancar.',
        'Semprotkan fungisida berbasis tembaga (copper fungicide) atau bahan organik secara berkala.',
      ],
      imageAssetPath: 'assets/images/late_blight.jpg',
      searchKeyword: 'fungisida tembaga busuk daun late blight',
    ),
    DiseaseModel(
      id: 'leaf-mold',
      name: 'Leaf Mold',
      latinName: 'Passalora fulva • Penyakit Jamur Daun',
      category: 'Jamur Daun',
      severity: 'PERLU PERAWATAN',
      severityColor: Color(0xFFE65100),
      shortDescription: 'Bercak kuning atas & bulu beludru di bawah daun',
      symptoms: [
        'Muncul bercak kuning pucat tak beraturan pada permukaan atas daun bagian bawah.',
        'Tumbuh lapisan beludru abu-abu ke-cokelatan di permukaan bawah daun.',
        'Daun yang terinfeksi berat akan berubah menjadi cokelat keriput dan gugur.',
        'Perkembangan penyakit sangat pesat saat kelembapan udara tinggi (>85%).',
      ],
      preventions: [
        'Tingkatkan ventilasi dan tempatkan tanaman di area yang terkena sinar matahari penuh.',
        'Lakukan pemangkasan (pruning) pada daun-daun tua di bagian bawah tanaman.',
        'Jaga permukaan daun tetap kering dan bersihkan guguran daun di sekitar pot.',
        'Aplikasi fungisida berbahan aktif mankozeb atau larutan pembasmi jamur organik.',
      ],
      imageAssetPath: 'assets/images/leaf_mold.jpg',
      searchKeyword: 'fungisida mancozeb obat jamur daun tomat',
    ),
    DiseaseModel(
      id: 'tylcv',
      name: 'Tomato Yellow Leaf Curl Virus (TYLCV)',
      latinName: 'Begomovirus • Virus Keriting Kuning',
      category: 'Virus Tanaman',
      severity: 'SANGAT MENULAR',
      severityColor: Color(0xFFC62828),
      shortDescription: 'Daun menguning, keriting melengkung & kerdil',
      symptoms: [
        'Helaian daun menguning cerah di tepi dan sela tulang daun (klorosis).',
        'Tepi daun melengkung ke atas seperti cangkir (cupping) dan mengerut kaku.',
        'Pertumbuhan tanaman terhenti, kerdil, dan pembentukan bunga/buah terhambat.',
        'Disebarkan secara cepat oleh serangga Kutu Kebul (Bemisia tabaci).',
      ],
      preventions: [
        'Kendalikan serangga vektor Kutu Kebul dengan minyak mimba (neem oil) atau perangkap kuning.',
        'Pasang kassa/jaring pembatas (insect net) jika menanam di greenhouse.',
        'Cabut dan musnahkan segera tanaman yang terinfeksi parah agar tidak menular.',
        'Pilih dan tanam varietas benih tomat yang resisten terhadap virus keriting.',
      ],
      imageAssetPath: 'assets/images/tylcv.jpg',
      searchKeyword: 'insektisida minyak mimba neem oil kutu kebul',
    ),
  ];
}

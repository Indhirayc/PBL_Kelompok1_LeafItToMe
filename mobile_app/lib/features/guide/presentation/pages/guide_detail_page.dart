import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GuideDetailPage extends StatefulWidget {
  const GuideDetailPage({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

  static const Color primaryGreen = Color(0xFF2F7D4A);
  static const Color darkGreen = Color(0xFF183E2D);
  static const Color backgroundColor = Color(0xFFF8FAF5);
  static const Color secondaryText = Color(0xFF75857B);
  static const Color borderColor = Color(0xFFE3EAE4);
  static const Color accentGreen = Color(0xFFE8F5E9);

  @override
  State<GuideDetailPage> createState() => _GuideDetailPageState();
}

class _GuideDetailPageState extends State<GuideDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTabIndex.clamp(0, 3);
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GuideDetailPage.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: GuideDetailPage.darkGreen, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('guides');
            }
          },
        ),
        title: const Text(
          'Panduan Menanam Tomat',
          style: TextStyle(
            color: GuideDetailPage.darkGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: GuideDetailPage.primaryGreen,
          unselectedLabelColor: GuideDetailPage.secondaryText,
          indicatorColor: GuideDetailPage.primaryGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Alat & Bahan'),
            Tab(text: 'Cara Menanam'),
            Tab(text: 'Perawatan Harian'),
            Tab(text: 'Cegah Penyakit'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildToolsAndMaterialsTab(),
            _buildPlantingStepsTab(),
            _buildDailyCareTab(),
            _buildDiseasePreventionTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: ALAT DAN BAHAN ---
  Widget _buildToolsAndMaterialsTab() {
    final items = [
      {
        'title': 'Pot / Polybag (Diameter 30cm)',
        'desc': 'Memiliki lubang drainase di bagian bawah agar air tidak menggenang.',
        'icon': Icons.inventory_2_outlined,
      },
      {
        'title': 'Media Tanam Humus & Sekam',
        'desc': 'Campuran tanah subur, pupuk kandang matang, dan sekam bakar (1:1:1).',
        'icon': Icons.landscape_outlined,
      },
      {
        'title': 'Benih Tomat Unggul',
        'desc': 'Pilih benih bersertifikat atau benih hibrida yang tahan penyakit.',
        'icon': Icons.eco_outlined,
      },
      {
        'title': 'Tiang Penyangga (Ajir)',
        'desc': 'Bambu atau kayu setinggi 1.5 meter untuk menopang batang tomat.',
        'icon': Icons.straighten_outlined,
      },
      {
        'title': 'Sprayer & Alat Penyiram',
        'desc': 'Sprayer halus untuk pembibitan dan gembor air untuk tanaman dewasa.',
        'icon': Icons.water_drop_outlined,
      },
      {
        'title': 'Pupuk Organik & NPK',
        'desc': 'Pupuk kompos/kandang untuk dasar dan NPK 16-16-16 untuk susulan.',
        'icon': Icons.science_outlined,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Daftar Alat & Bahan Budidaya', 'Persiapkan semua perlengkapan sebelum memulai penanaman.'),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GuideDetailPage.borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: GuideDetailPage.accentGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: GuideDetailPage.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: GuideDetailPage.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: GuideDetailPage.secondaryText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // --- TAB 2: CARA MENANAM ---
  Widget _buildPlantingStepsTab() {
    final steps = [
      {
        'step': '1',
        'title': 'Penyemaian Benih',
        'desc': 'Rendam benih dalam air hangat selama 2-4 jam. Semai di wadah persemaian dengan media halus. Jaga kelembapan hingga berkecambah (3-7 hari).',
      },
      {
        'step': '2',
        'title': 'Penyiapan Media Tanam',
        'desc': 'Campurkan tanah, pupuk kandang, dan sekam. Masukkan ke dalam pot 30cm dan biarkan media diangin-anginkan selama 2 hari.',
      },
      {
        'step': '3',
        'title': 'Pemindahan Bibit',
        'desc': 'Pindahkan bibit yang sudah memiliki 4-5 helai daun sejati ke pot utama secara hati-hati agar perakaran tidak rusak.',
      },
      {
        'step': '4',
        'title': 'Pemasangan Ajir (Penyangga)',
        'desc': 'Tancapkan bambu penyangga dekat pangkal tanaman sejak awal agar tidak merusak perakaran saat tanaman tumbuh membesar.',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Tahapan Penanaman', 'Ikuti langkah-langkah penanaman bertahap berikut.'),
        const SizedBox(height: 16),
        ...steps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GuideDetailPage.borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: GuideDetailPage.primaryGreen,
                      child: Text(
                        step['step'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: GuideDetailPage.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step['desc'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: GuideDetailPage.secondaryText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // --- TAB 3: PERAWATAN HARIAN ---
  Widget _buildDailyCareTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Panduan Perawatan Rutin', 'Perawatan yang konsisten menghasilkan tanaman yang sehat dan berbuah lebat.'),
        const SizedBox(height: 16),

        _buildCareCategoryCard(
          icon: Icons.water_drop,
          title: 'Penyiraman',
          details: [
            'Siram 2x sehari (Pagi pukul 07:00 dan Sore pukul 16:00).',
            'Hindari menyiram daun langsung untuk mencegah jamur.',
            'Pastikan tanah lembap namun tidak becek.',
          ],
        ),
        const SizedBox(height: 14),

        _buildCareCategoryCard(
          icon: Icons.wb_sunny,
          title: 'Sinar Matahari',
          details: [
            'Tomat membutuhkan sinar matahari langsung 6-8 jam sehari.',
            'Letakkan pot di area terbuka seperti teras atau balkon selatan.',
          ],
        ),
        const SizedBox(height: 14),

        _buildCareCategoryCard(
          icon: Icons.content_cut,
          title: 'Pemangkasan (Pruning)',
          details: [
            'Potong tunas air (sucker branch) yang tumbuh di ketiak daun.',
            'Buang daun bagian bawah yang sudah kuning atau menyentuh tanah.',
          ],
        ),
        const SizedBox(height: 14),

        _buildCareCategoryCard(
          icon: Icons.bolt,
          title: 'Pemupukan Susulan',
          details: [
            'Beri pupuk NPK 16-16-16 larut air setiap 2 minggu sekali.',
            'Saat pembungaan, berikan pupuk tinggi Kalium untuk merangsang buah.',
          ],
        ),
      ],
    );
  }

  // --- TAB 4: CEGAH PENYAKIT ---
  Widget _buildDiseasePreventionTab() {
    final diseases = [
      {
        'name': 'Bercak Daun (Bacterial Spot)',
        'symptom': 'Bercak cokelat kehitaman pada daun bagian bawah yang meluas.',
        'prevention': 'Hindari penyiraman dari atas daun, berikan jarak antar pot agar sirkulasi udara lancar, dan semprot fungisida organik.',
        'severity': 'Sedang',
      },
      {
        'name': 'Busuk Ujung Buah (Blossom End Rot)',
        'symptom': 'Bagian bawah buah tomat menghitam dan membusuk.',
        'prevention': 'Jaga kelembapan tanah tetap stabil dan tambahkan kalsium/kapur dolomit pada media tanam.',
        'severity': 'Tinggi',
      },
      {
        'name': 'Hama Kutu Daun (Aphids)',
        'symptom': 'Kutu kecil bergerombol di balik daun menyebabkan daun melingkar.',
        'prevention': 'Semprotkan larutan sabun pencuci piring cair encer atau minyak mimba (neem oil) secara berkala.',
        'severity': 'Ringan',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Pencegahan & Pengendalian Penyakit', 'Kenali gejala awal dan tindakan pencegahan dini.'),
        const SizedBox(height: 16),
        ...diseases.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GuideDetailPage.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFFE5484D),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            d['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: GuideDetailPage.darkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gejala:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d['symptom']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: GuideDetailPage.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Cara Pencegahan:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: GuideDetailPage.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d['prevention']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: GuideDetailPage.darkGreen,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: GuideDetailPage.darkGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: GuideDetailPage.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildCareCategoryCard({
    required IconData icon,
    required String title,
    required List<String> details,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GuideDetailPage.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GuideDetailPage.accentGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: GuideDetailPage.primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GuideDetailPage.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...details.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: GuideDetailPage.primaryGreen)),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: GuideDetailPage.secondaryText,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

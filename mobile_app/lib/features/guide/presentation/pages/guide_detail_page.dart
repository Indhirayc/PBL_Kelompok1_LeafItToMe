import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_content_layout.dart';
import '../../data/guide_data.dart';

class GuideDetailPage extends StatefulWidget {
  const GuideDetailPage({super.key, this.initialTabIndex = 0});

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
        toolbarHeight: 56,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F3826),
            size: 20,
          ),
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
            color: Color(0xFF1F3826),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: GuideDetailPage.borderColor),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              labelColor: GuideDetailPage.primaryGreen,
              unselectedLabelColor: GuideDetailPage.secondaryText,
              indicatorColor: GuideDetailPage.primaryGreen,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
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
        ),
      ),
      body: AppContentLayout(
        child: SafeArea(
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
      ),
    );
  }

  // --- TAB 1: ALAT DAN BAHAN ---
  Widget _buildToolsAndMaterialsTab() {
    final tools = GuideData.tools;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        _buildSectionHeader(
          'Alat & Bahan',
          'Persiapkan kebutuhan berikut agar proses budidaya tomat berjalan terarah.',
        ),
        const SizedBox(height: 16),
        ...tools.map(
          (tool) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () {
                  context.pushNamed('tool-detail', extra: tool);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GuideDetailPage.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: GuideDetailPage.accentGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          tool.icon,
                          color: GuideDetailPage.primaryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tool.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: GuideDetailPage.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tool.shortDescription,
                              style: const TextStyle(
                                fontSize: 12,
                                color: GuideDetailPage.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tool.tag == 'Wajib'
                              ? GuideDetailPage.accentGreen
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tool.tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tool.tag == 'Wajib'
                                ? GuideDetailPage.primaryGreen
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: GuideDetailPage.secondaryText,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: CARA MENANAM ---
  Widget _buildPlantingStepsTab() {
    final steps = [
      {
        'step': '1',
        'title': 'Siapkan Media Tanam',
        'desc': 'Campurkan tanah humus/topsoil, kompos matang, dan sekam bakar (perbandingan 1:1:1). Masukkan ke dalam pot berdiameter minimal 30–40 cm dengan lubang drainase baik.',
      },
      {
        'step': '2',
        'title': 'Tanam Benih atau Bibit',
        'desc': 'Buat lubang tanam sedalam 1–2 cm di bagian tengah media. Letakkan benih atau pindahkan bibit muda perlahan tanpa merusak perakarannya.',
      },
      {
        'step': '3',
        'title': 'Siram Perlahan',
        'desc': 'Semprotkan air secara merata dengan sprayer halus agar media lembap tanpa memadatkan atau menggeser posisi bibit.',
      },
      {
        'step': '4',
        'title': 'Pencahayaan & Penempatan',
        'desc': 'Letakkan pot di tempat teduh selama 2–3 hari pertama, kemudian pindahkan ke area yang menerima 6–8 jam sinar matahari penuh harian.',
      },
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        _buildSectionHeader(
          'Tahapan Menanam',
          'Ikuti urutan langkah ini untuk menumbuhkan tanaman tomat yang kokoh.',
        ),
        const SizedBox(height: 16),
        ...steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GuideDetailPage.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: GuideDetailPage.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        step['step'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: GuideDetailPage.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['desc'] as String,
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
          ),
        ),
      ],
    );
  }

  // --- TAB 3: PERAWATAN HARIAN ---
  Widget _buildDailyCareTab() {
    final cares = [
      {
        'title': 'Cek Kelembapan Media',
        'subtitle': 'Pagi • 06:30 - 08:00',
        'desc': 'Tekan tanah sedalam 2 cm. Jika mulai kering, lakukan penyiraman secukupnya.',
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'title': 'Penyiraman Pangkal Batang',
        'subtitle': '1x sehari',
        'desc': 'Siram langsung ke media tanah di sekitar pangkal tanaman, hindari membasahi daun.',
        'icon': Icons.water_drop_outlined,
      },
      {
        'title': 'Pemangkasan Tunas Air (Wiwil)',
        'subtitle': 'Secara berkala',
        'desc': 'Buang tunas air di ketiak daun agar nutrisi terfokus pada batang utama dan pembungaan.',
        'icon': Icons.content_cut_outlined,
      },
      {
        'title': 'Pemasangan Tiang Ajir',
        'subtitle': 'Minggu ke-3',
        'desc': 'Ikat batang tomat dengan tali rami longgar ke bambu ajir agar tidak rebah saat berbuah.',
        'icon': Icons.straighten_outlined,
      },
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        _buildSectionHeader(
          'Perawatan Rutin',
          'Aktivitas berkala untuk menjaga kesuburan dan daya tahan tanaman.',
        ),
        const SizedBox(height: 16),
        ...cares.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GuideDetailPage.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: GuideDetailPage.accentGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      c['icon'] as IconData,
                      color: GuideDetailPage.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          c['title'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: GuideDetailPage.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c['desc'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: GuideDetailPage.secondaryText,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: GuideDetailPage.backgroundColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: GuideDetailPage.borderColor,
                            ),
                          ),
                          child: Text(
                            c['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: GuideDetailPage.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 4: CEGAH PENYAKIT ---
  Widget _buildDiseasePreventionTab() {
    final diseases = GuideData.diseases;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        _buildSectionHeader(
          'Pencegahan & Diagnosis',
          'Kenali gejala awal penyakit daun tomat dan langkah antisipasinya.',
        ),
        const SizedBox(height: 16),

        // List of Diseases
        ...diseases.map(
          (disease) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () {
                  context.pushNamed('disease-detail', extra: disease);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GuideDetailPage.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: disease.severityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.coronavirus_outlined,
                          color: disease.severityColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              disease.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: GuideDetailPage.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              disease.shortDescription,
                              style: const TextStyle(
                                fontSize: 12,
                                color: GuideDetailPage.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: GuideDetailPage.secondaryText,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
            fontWeight: FontWeight.w700,
            color: GuideDetailPage.darkGreen,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: GuideDetailPage.secondaryText,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

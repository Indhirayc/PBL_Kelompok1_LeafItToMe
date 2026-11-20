import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';
import '../../data/guide_data.dart';

class GuideListPage extends StatefulWidget {
  const GuideListPage({super.key});

  @override
  State<GuideListPage> createState() => _GuideListPageState();
}

class _GuideListPageState extends State<GuideListPage> {
  static const Color primaryGreen = Color(0xFF2F7D4A);
  static const Color darkGreen = Color(0xFF183E2D);
  static const Color backgroundColor = Color(0xFFF8FAF5);
  static const Color secondaryText = Color(0xFF75857B);
  static const Color borderColor = Color(0xFFE3EAE4);
  static const Color cardGreenBg = Color(0xFFE9F4EC);

  @override
  void initState() {
    super.initState();
    // Muat master data (Firestore → cache → data bawaan) lalu segarkan UI
    GuideData.loadFromFirestore().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Panduan Budidaya',
          style: TextStyle(
            color: Color(0xFF1F3826),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: AppContentLayout(
        alignment: Alignment.topCenter,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured Hero Card (Tappable Magazine-style)
                _buildFeaturedCard(context),
                const SizedBox(height: 24),

                // Section: Topik Panduan
                const Text(
                  'Topik Panduan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),

                // 2x2 Clean Topic Grid
                _buildTopicGrid(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.goNamed('guide-detail', extra: 0);
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          key: const Key('guideFeaturedCard'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            image: const DecorationImage(
              image: AssetImage('assets/images/banner_panduan.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
            border: Border.all(color: primaryGreen.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 100, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PANDUAN LENGKAP',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Menanam Tomat\ndari Awal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                    height: 1.22,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Langkah terstruktur dari pot & bibit hingga penanganan penyakit.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: secondaryText,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryGreen.withValues(alpha: 0.22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Mulai Baca',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primaryGreen,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: primaryGreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTopicCard(
                context,
                title: 'Alat & Bahan',
                subtitle: 'Pot, benih & media',
                iconData: Icons.build_outlined,
                initialTab: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTopicCard(
                context,
                title: 'Cara Menanam',
                subtitle: 'Langkah bertahap',
                iconData: Icons.eco_outlined,
                initialTab: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTopicCard(
                context,
                title: 'Perawatan Harian',
                subtitle: 'Penyiraman & nutrisi',
                iconData: Icons.water_drop_outlined,
                initialTab: 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTopicCard(
                context,
                title: 'Cegah Penyakit',
                subtitle: 'Gejala & antisipasi',
                iconData: Icons.shield_outlined,
                initialTab: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopicCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData iconData,
    required int initialTab,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          context.goNamed('guide-detail', extra: initialTab);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: cardGreenBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(iconData, color: primaryGreen, size: 22),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: secondaryText.withValues(alpha: 0.4),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

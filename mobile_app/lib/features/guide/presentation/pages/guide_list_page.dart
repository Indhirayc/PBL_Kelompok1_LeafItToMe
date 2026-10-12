import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/main_bottom_navigation.dart';

class GuideListPage extends StatelessWidget {
  const GuideListPage({super.key});

  static const Color primaryGreen = Color(0xFF2F7D4A);
  static const Color darkGreen = Color(0xFF183E2D);
  static const Color backgroundColor = Color(0xFFF8FAF5);
  static const Color secondaryText = Color(0xFF75857B);
  static const Color borderColor = Color(0xFFE3EAE4);
  static const Color cardGreenBg = Color(0xFFE9F4EC);

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
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
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
              const SizedBox(height: 24),
            ],
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardGreenBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryGreen.withValues(alpha: 0.15)),
          ),
          child: Stack(
            children: [
              // Plant illustration on right
              Positioned(
                right: 12,
                bottom: 8,
                top: 8,
                child: SizedBox(
                  width: 100,
                  child: Image.asset(
                    'assets/images/tomato_plant.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.eco_rounded,
                        size: 56,
                        color: primaryGreen,
                      );
                    },
                  ),
                ),
              ),

              // Editorial Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 110, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PANDUAN LENGKAP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: primaryGreen,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Menanam Tomat\ndari Awal',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: darkGreen,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Langkah terstruktur dari pemilihan pot hingga penanganan penyakit.',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryText,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ],
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
          padding: const EdgeInsets.all(16),
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cardGreenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(iconData, color: primaryGreen, size: 20),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: secondaryText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

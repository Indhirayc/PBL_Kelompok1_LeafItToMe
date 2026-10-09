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
  static const Color cardGreenBg = Color(0xFFE3F4E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Header Title
                    const Text(
                      'Panduan Budidaya',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Featured Card: Menanam Tomat dari Awal
                    _buildFeaturedBannerCard(context),
                    const SizedBox(height: 24),

                    // Section Title: Topik Panduan
                    const Text(
                      'Topik Panduan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Grid 2x2 Topik Panduan
                    _buildTopicGrid(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildFeaturedBannerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardGreenBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.15)),
      ),
      child: Stack(
        children: [
          // Graphic Illustration (Tanaman Tomat)
          Positioned(
            right: 12,
            bottom: 0,
            top: 0,
            child: SizedBox(
              width: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Stem
                  Container(
                    width: 6,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F7D4A),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Leaf Left Top
                  Positioned(
                    top: 25,
                    left: 20,
                    child: Transform.rotate(
                      angle: -0.6,
                      child: Container(
                        width: 32,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF43A047),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Leaf Right Top
                  Positioned(
                    top: 35,
                    right: 18,
                    child: Transform.rotate(
                      angle: 0.6,
                      child: Container(
                        width: 34,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Tomato Fruit Left
                  Positioned(
                    bottom: 30,
                    left: 15,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tomato Fruit Right
                  Positioned(
                    bottom: 45,
                    right: 12,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Text & Button
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 24,
              bottom: 24,
              right: 130,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menanam Tomat\ndari Awal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Panduan lengkap untuk hasil panen yang optimal.',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    context.goNamed('guide-detail', extra: 0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Baca Panduan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
                subtitle: 'Kenali kebutuhan',
                iconData: Icons.build_outlined,
                initialTab: 0,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildTopicCard(
                context,
                title: 'Cara Menanam',
                subtitle: 'Langkah demi langkah',
                iconData: Icons.eco_outlined,
                initialTab: 1,
              ),
            ),
          ],
        ),
        const SizedBox(width: 14, height: 14),
        Row(
          children: [
            Expanded(
              child: _buildTopicCard(
                context,
                title: 'Perawatan Harian',
                subtitle: 'Tips setiap hari',
                iconData: Icons.water_drop_outlined,
                initialTab: 2,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildTopicCard(
                context,
                title: 'Cegah Penyakit',
                subtitle: 'Lindungi tanaman',
                iconData: Icons.security_outlined,
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
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cardGreenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    iconData,
                    color: primaryGreen,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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

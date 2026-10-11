import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AboutColors.background,
      appBar: AppBar(
        backgroundColor: _AboutColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.pop();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const SizedBox(
                    width: 32,
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _AboutColors.darkGreen,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              const Text(
                'Tentang LeafItToMe',
                style: TextStyle(
                  color: _AboutColors.darkGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(27, 20, 27, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildApplicationIdentity(),
              const SizedBox(height: 28),

              const _SectionTitle(title: 'Tentang Aplikasi'),
              const SizedBox(height: 14),

              const _InformationCard(
                child: Text(
                  'LeafItToMe adalah aplikasi mobile yang membantu pengguna '
                  'mengenali kondisi dan penyakit pada daun tanaman tomat. '
                  'Aplikasi menggunakan teknologi machine learning untuk '
                  'melakukan klasifikasi berdasarkan foto daun yang diberikan.',
                  style: TextStyle(
                    color: _AboutColors.secondaryText,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              const _SectionTitle(title: 'Fitur Utama'),
              const SizedBox(height: 14),

              const _InformationCard(
                child: Column(
                  children: [
                    _FeatureItem(
                      icon: Icons.eco_outlined,
                      title: 'Kelola Tanaman',
                      description:
                          'Menyimpan dan mengelola data setiap tanaman tomat.',
                    ),
                    _CardDivider(),
                    _FeatureItem(
                      icon: Icons.document_scanner_outlined,
                      title: 'Deteksi Penyakit',
                      description: 'Mendeteksi kondisi daun melalui foto menggunakan model machine learning.',
                    ),
                    _CardDivider(),
                    _FeatureItem(
                      icon: Icons.history_rounded,
                      title: 'Riwayat Pemeriksaan',
                      description:
                          'Menyimpan hasil pemeriksaan berdasarkan tanaman.',
                    ),
                    _CardDivider(),
                    _FeatureItem(
                      icon: Icons.menu_book_outlined,
                      title: 'Panduan Budidaya',
                      description: 'Menyediakan informasi perawatan dan budidaya tanaman tomat.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const _SectionTitle(title: 'Informasi Pengembangan'),
              const SizedBox(height: 14),

              const _InformationCard(
                child: Column(
                  children: [
                    _InformationRow(
                      icon: Icons.school_outlined,
                      label: 'Institusi',
                      value: 'Politeknik Negeri Malang',
                    ),
                    _CardDivider(),
                    _InformationRow(
                      icon: Icons.groups_outlined,
                      label: 'Pengembang',
                      value: 'Kelompok 1 PBL',
                    ),
                    _CardDivider(),
                    _InformationRow(
                      icon: Icons.phone_android_rounded,
                      label: 'Platform',
                      value: 'Flutter',
                    ),
                    _CardDivider(),
                    _InformationRow(
                      icon: Icons.info_outline_rounded,
                      label: 'Versi',
                      value: _appVersion,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFF2E3B8)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD89116),
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hasil deteksi LeafItToMe merupakan informasi awal '
                        'dan bukan diagnosis mutlak. Lakukan pemeriksaan '
                        'lebih lanjut jika kondisi tanaman memburuk.',
                        style: TextStyle(
                          color: Color(0xFF80662C),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Dibuat untuk membantu menjaga tanaman tomat tetap sehat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _AboutColors.secondaryText,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                '© 2026 LeafItToMe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _AboutColors.darkGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationIdentity() {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F8F0),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD6E9D7), width: 1.2),
          ),
          child: Image.asset(
            'assets/images/splash/leafittome_logo.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.eco_rounded,
                color: _AboutColors.primaryGreen,
                size: 58,
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'LeafItToMe',
          style: TextStyle(
            color: _AboutColors.darkGreen,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kenali Daunnya, Jaga Tanamannya',
          textAlign: TextAlign.center,
          style: TextStyle(color: _AboutColors.secondaryText, fontSize: 13),
        ),
        const SizedBox(height: 11),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: _AboutColors.primaryGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Versi $_appVersion',
            style: TextStyle(
              color: _AboutColors.primaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _AboutColors.darkGreen,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _AboutColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AboutColors.border),
      ),
      child: child,
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _AboutColors.primaryGreen.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _AboutColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _AboutColors.darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: _AboutColors.secondaryText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: _AboutColors.primaryGreen.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _AboutColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 13),
          SizedBox(
            width: 92,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                label,
                style: const TextStyle(
                  color: _AboutColors.secondaryText,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                value,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: _AboutColors.darkGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, thickness: 1, color: _AboutColors.border),
    );
  }
}

abstract final class _AboutColors {
  static const Color background = Color(0xFFFBFCF7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryGreen = Color(0xFF2D8952);
  static const Color darkGreen = Color(0xFF123F2E);
  static const Color secondaryText = Color(0xFF74867C);
  static const Color border = Color(0xFFD7E1D9);
}

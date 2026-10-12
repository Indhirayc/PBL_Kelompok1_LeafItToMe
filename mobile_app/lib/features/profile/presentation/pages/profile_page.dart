import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../widgets/profile_menu_tile.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color primaryGreen = Color(0xFF2F7D4A);
  static const Color darkGreen = Color(0xFF183E2D);
  static const Color backgroundColor = Color(0xFFF8FAF5);
  static const Color secondaryText = Color(0xFF75857B);
  static const Color borderColor = Color(0xFFE3EAE4);
  static const Color dangerColor = Color(0xFFE5484D);

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Keluar dari akun?',
            style: TextStyle(
              color: darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun LeafItToMe?',
            style: TextStyle(color: secondaryText, fontSize: 14, height: 1.5),
          ),
          actions: [
            AppButton(
              label: 'Batal',
              width: null,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            AppButton(
              label: 'Keluar',
              width: null,
              variant: AppButtonVariant.destructive,
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      context.goNamed('login');
    }
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
          'Profil',
          style: TextStyle(
            color: darkGreen,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(context),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Aktivitas Tanaman'),
              const SizedBox(height: 10),
              const _ActivityCard(),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Pengaturan Akun'),
              const SizedBox(height: 12),
              _buildAccountMenu(context),
              const SizedBox(height: 26),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
      // Profil merupakan menu keempat, sehingga index-nya 3.
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7EE),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDCE9DC)),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/splash/leafittome_logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person_rounded,
                    color: primaryGreen,
                    size: 42,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Indhira Yuantika Christy',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'indhira@example.com',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.pushNamed('personal-information');
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryGreen,
                      side: const BorderSide(color: Color(0xFFBFD7C4)),
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileMenuTile(
            icon: Icons.person_outline_rounded,
            title: 'Informasi Pribadi',
            subtitle: 'Lihat dan ubah informasi akun',
            onTap: () {
              context.pushNamed('personal-information');
            },
          ),
          ProfileMenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Bantuan & FAQ',
            subtitle: 'Temukan jawaban dan bantuan',
            onTap: () {
              context.pushNamed('help-faq');
            },
          ),
          ProfileMenuTile(
            icon: Icons.info_outline_rounded,
            title: 'Tentang LeafItToMe',
            subtitle: 'Informasi dan versi aplikasi',
            showDivider: false,
            onTap: () {
              context.pushNamed('about');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {
          _showLogoutDialog(context);
        },
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('Keluar'),
        style: OutlinedButton.styleFrom(
          foregroundColor: dangerColor,
          side: const BorderSide(color: dangerColor),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
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
        color: ProfilePage.darkGreen,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      // Ukuran atas dan bawah diperkecil dari 20 menjadi 13.
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,

        // Sedikit diperkecil agar sesuai dengan tinggi kartu baru.
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ProfilePage.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: _ActivityItem(
              icon: Icons.document_scanner_outlined,
              value: '12',
              label: 'Pemindaian',
              color: Color(0xFF2F7D4A),
              backgroundColor: Color(0xFFEAF4EC),
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _ActivityItem(
              icon: Icons.warning_amber_rounded,
              value: '4',
              label: 'Penyakit',
              color: Color(0xFFE57E25),
              backgroundColor: Color(0xFFFFF1E5),
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _ActivityItem(
              icon: Icons.eco_outlined,
              value: '8',
              label: 'Sehat',
              color: Color(0xFF3A9D5D),
              backgroundColor: Color(0xFFE7F5EA),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          // Kotak ikon diperkecil dari 38 menjadi 32.
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: color,

            // Ikon diperkecil dari 21 menjadi 18.
            size: 18,
          ),
        ),

        // Jarak ikon dengan angka diperkecil.
        const SizedBox(height: 6),

        Text(
          value,
          style: const TextStyle(
            color: ProfilePage.darkGreen,

            // Angka diperkecil dari 19 menjadi 17.
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7A8D81),

            // Label diperkecil dari 11 menjadi 10.
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,

      // Garis mengikuti ukuran kartu yang lebih kecil.
      height: 58,
      color: ProfilePage.borderColor,
    );
  }
}

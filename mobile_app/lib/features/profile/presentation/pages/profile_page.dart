import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../core/widgets/app_content_layout.dart';
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
            color: Color(0xFF1F3826),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: AppContentLayout(
        alignment: Alignment.topCenter,
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet =
                  constraints.maxWidth >= AppBreakpoints.tablet ||
                  MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildProfileCard(context)),
                          const SizedBox(width: 24),
                          const Expanded(child: _ActivitySection()),
                        ],
                      )
                    else ...[
                      _buildProfileCard(context),
                      const SizedBox(height: 24),
                      const _ActivitySection(),
                    ],
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Pengaturan Akun'),
                    const SizedBox(height: 12),
                    _buildAccountMenu(context),
                    const SizedBox(height: 26),
                    _buildLogoutButton(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      // Profil merupakan menu keempat, sehingga index-nya 3.
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        final displayName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user?.email?.split('@').first ?? 'Pengguna');
        final email = user?.email ?? 'Email tidak tersedia';

        return Container(
          key: const Key('profileOverviewCard'),
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
                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: secondaryText, fontSize: 12),
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
      },
    );
  }

  Widget _buildAccountMenu(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;
    final items = _buildAccountMenuItems(context, isTablet: isTablet);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isTablet) {
          final itemWidth = (constraints.maxWidth - 16) / 2;
          return Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              for (final item in items)
                SizedBox(
                  width: itemWidth,
                  child: Container(
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
                    child: item,
                  ),
                ),
            ],
          );
        }

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
          child: Column(children: items),
        );
      },
    );
  }

  List<Widget> _buildAccountMenuItems(
    BuildContext context, {
    required bool isTablet,
  }) {
    return [
      ProfileMenuTile(
        icon: Icons.person_outline_rounded,
        title: 'Informasi Pribadi',
        subtitle: 'Lihat dan ubah informasi akun',
        showDivider: !isTablet,
        onTap: () {
          context.pushNamed('personal-information');
        },
      ),
      ProfileMenuTile(
        icon: Icons.help_outline_rounded,
        title: 'Bantuan & FAQ',
        subtitle: 'Temukan jawaban dan bantuan',
        showDivider: !isTablet,
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
    ];
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

class _ActivitySection extends StatelessWidget {
  const _ActivitySection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Aktivitas Tanaman'),
        SizedBox(height: 10),
        _ActivityCard(),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: const Row(
        children: [
          Expanded(
            child: _ActivityItem(
              value: '2',
              label: 'Pemindaian',
              color: Color(0xFF2F7D4A),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _ActivityItem(
              value: '1',
              label: 'Penyakit',
              color: Color(0xFFED6C02),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _ActivityItem(
              value: '1',
              label: 'Sehat',
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ProfilePage.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ProfilePage.darkGreen,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

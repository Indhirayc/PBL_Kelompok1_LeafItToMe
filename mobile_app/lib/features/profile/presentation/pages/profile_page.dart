import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/utils/disease_label_mapper.dart';
import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/repositories/user_repository.dart';
import '../widgets/profile_menu_tile.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';

FirebaseApp? _defaultFirebaseApp() {
  for (final app in Firebase.apps) {
    if (app.name == '[DEFAULT]') {
      return app;
    }
  }
  return null;
}

FirebaseAuth? _firebaseAuth() {
  final app = _defaultFirebaseApp();
  return app == null ? null : FirebaseAuth.instanceFor(app: app);
}

class PlantActivityStats {
  const PlantActivityStats({
    required this.totalScans,
    required this.diseasedScans,
    required this.healthyScans,
  });

  final int totalScans;
  final int diseasedScans;
  final int healthyScans;
}

final plantActivityStatsProvider =
    FutureProvider.autoDispose<PlantActivityStats>((ref) async {
      final userId = ref.watch(currentUserIdProvider);
      final scans = await ref
          .read(scanRepositoryProvider)
          .getUserHistory(userId);
      final healthyScans = scans
          .where((scan) => DiseaseLabelMapper.isHealthy(scan.diseaseName))
          .length;

      return PlantActivityStats(
        totalScans: scans.length,
        diseasedScans: scans.length - healthyScans,
        healthyScans: healthyScans,
      );
    });

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

    if (shouldLogout == true) {
      try {
        if (Firebase.apps.isNotEmpty) {
          await UserRepository().logout();
        }
      } catch (e) {
        debugPrint('Gagal logout: $e');
      }
      if (context.mounted) {
        context.goNamed('login');
      }
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
    final auth = _firebaseAuth();
    return StreamBuilder<User?>(
      stream: auth?.userChanges() ?? const Stream<User?>.empty(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? auth?.currentUser;
        final displayName =
            (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user?.email?.split('@').first ?? 'Pengguna');
        final email = user?.email ?? 'Email tidak tersedia';

        return Container(
          key: const Key('profileOverviewCard'),
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF7FAF7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFDCE7DF)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF183E2D).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: (user?.photoURL != null &&
                        user!.photoURL!.isNotEmpty &&
                        (File(user.photoURL!).existsSync() ||
                            (Uri.tryParse(user.photoURL!)?.hasScheme ?? false)))
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5EB),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC7E6CC), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2F7D4A).withValues(alpha: 0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildAvatarWidget(user?.photoURL),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.pushNamed('personal-information');
                        },
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Edit Profil'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryGreen,
                          side: BorderSide(
                            color: primaryGreen.withValues(alpha: 0.35),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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

  Widget _buildAvatarWidget(String? photoURL) {
    if (photoURL != null && photoURL.isNotEmpty) {
      if (File(photoURL).existsSync()) {
        return Image.file(
          File(photoURL),
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
        );
      } else if (Uri.tryParse(photoURL)?.hasScheme ?? false) {
        return Image.network(
          photoURL,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
        );
      }
    }
    return _buildFallbackLogo();
  }

  Widget _buildFallbackLogo() {
    return Image.asset(
      'assets/images/splash/leafittome_logo.png',
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.person_rounded,
          color: primaryGreen,
          size: 40,
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
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          _showLogoutDialog(context);
        },
        icon: const Icon(Icons.logout_rounded, size: 19),
        label: const Text('Keluar'),
        style: OutlinedButton.styleFrom(
          foregroundColor: dangerColor,
          side: const BorderSide(color: Color(0xFFFFCDD2)),
          backgroundColor: const Color(0xFFFFF5F5),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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

class _ActivityCard extends ConsumerWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(plantActivityStatsProvider);
    return statsAsync.when(
      data: (stats) => _buildItems(
        totalScans: '${stats.totalScans}',
        diseasedScans: '${stats.diseasedScans}',
        healthyScans: '${stats.healthyScans}',
      ),
      loading: () => _buildItems(
        totalScans: '...',
        diseasedScans: '...',
        healthyScans: '...',
      ),
      error: (error, stackTrace) => Column(
        children: [
          _buildItems(totalScans: '-', diseasedScans: '-', healthyScans: '-'),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Statistik aktivitas belum dapat dimuat.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ProfilePage.secondaryText, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(plantActivityStatsProvider),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildItems({
    required String totalScans,
    required String diseasedScans,
    required String healthyScans,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: _ActivityItem(
              value: totalScans,
              label: 'Pemindaian',
              color: const Color(0xFF2F7D4A),
              bgColor: const Color(0xFFF6FAF7),
              borderColor: const Color(0xFFD8EADC),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActivityItem(
              value: diseasedScans,
              label: 'Penyakit',
              color: const Color(0xFFED6C02),
              bgColor: const Color(0xFFFFF7ED),
              borderColor: const Color(0xFFFFDEC0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActivityItem(
              value: healthyScans,
              label: 'Sehat',
              color: const Color(0xFF2E7D32),
              bgColor: const Color(0xFFF1F9F3),
              borderColor: const Color(0xFFC7E6CD),
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
    this.bgColor = Colors.white,
    this.borderColor = ProfilePage.borderColor,
  });

  final String value;
  final String label;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
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

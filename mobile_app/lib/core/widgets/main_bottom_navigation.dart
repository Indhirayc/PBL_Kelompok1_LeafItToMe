import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MainBottomNavigation extends StatelessWidget {
  const MainBottomNavigation({
    super.key,
    required this.currentIndex,
  }) : assert(
          currentIndex >= 0 && currentIndex <= 3,
          'currentIndex harus bernilai antara 0 sampai 3',
        );

  final int currentIndex;

  static const Color _backgroundColor = Color(0xFFFFFFFF);
  static const Color _borderColor = Color(0xFFE4EBE5);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _backgroundColor,
        border: Border(
          top: BorderSide(
            color: _borderColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              Expanded(
                child: _NavigationItem(
                  label: 'Beranda',
                  iconPath: 'assets/icons/navigation/home.svg',
                  isActive: currentIndex == 0,
                  onTap: () {
                    _handleNavigation(
                      context,
                      selectedIndex: 0,
                      routeName: 'home',
                    );
                  },
                ),
              ),
              Expanded(
                child: _NavigationItem(
                  label: 'Panduan',
                  iconPath: 'assets/icons/navigation/guide.svg',
                  isActive: currentIndex == 1,
                  onTap: () {
                    _handleNavigation(
                      context,
                      selectedIndex: 1,
                      routeName: 'guides',
                    );
                  },
                ),
              ),
              Expanded(
                child: _NavigationItem(
                  label: 'Tanamanku',
                  iconPath: 'assets/icons/navigation/plant.svg',
                  isActive: currentIndex == 2,
                  onTap: () {
                    _handleNavigation(
                      context,
                      selectedIndex: 2,
                      routeName: 'plants',
                    );
                  },
                ),
              ),
              Expanded(
                child: _NavigationItem(
                  label: 'Profil',
                  iconPath: 'assets/icons/navigation/profile.svg',
                  isActive: currentIndex == 3,
                  onTap: () {
                    _handleNavigation(
                      context,
                      selectedIndex: 3,
                      routeName: 'profile',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(
    BuildContext context, {
    required int selectedIndex,
    required String routeName,
  }) {
    // Jangan membuka kembali halaman yang sedang aktif.
    if (selectedIndex == currentIndex) {
      return;
    }

    // Untuk sementara, hanya halaman Profil yang sudah tersedia.
    if (routeName == 'profile') {
      context.goNamed('profile');
      return;
    }

    // Halaman lain masih dikerjakan anggota kelompok.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Halaman ${_getPageName(selectedIndex)} sedang dikembangkan.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _getPageName(int index) {
    switch (index) {
      case 0:
        return 'Beranda';
      case 1:
        return 'Panduan';
      case 2:
        return 'Tanamanku';
      case 3:
        return 'Profil';
      default:
        return 'Tidak diketahui';
    }
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.iconPath,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool isActive;
  final VoidCallback onTap;

  static const Color _activeColor = Color(0xFF07852F);
  static const Color _inactiveColor = Color(0xFF7B9186);

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isActive
        ? _activeColor
        : _inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: _activeColor.withValues(alpha: 0.08),
        highlightColor: _activeColor.withValues(alpha: 0.04),
        child: Semantics(
          button: true,
          selected: isActive,
          label: label,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 5,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 26,
                  height: 26,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    itemColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: itemColor,
                    fontSize: 12,
                    height: 1,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
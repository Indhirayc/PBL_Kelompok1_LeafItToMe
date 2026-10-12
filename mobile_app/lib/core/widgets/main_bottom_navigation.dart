import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MainBottomNavigation extends StatelessWidget {
  const MainBottomNavigation({
    super.key,
    required this.currentIndex,
  });

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
                  activeColor: const Color(0xFF07852F),
                  onTap: () => _handleNavigation(
                    context,
                    selectedIndex: 0,
                    routeName: 'home',
                  ),
                ),
              ),
              Expanded(
                child: _NavigationItem(
                  label: 'Panduan',
                  iconPath: 'assets/icons/navigation/guide.svg',
                  isActive: currentIndex == 1,
                  activeColor: const Color(0xFF07852F),
                  onTap: () => _handleNavigation(
                    context,
                    selectedIndex: 1,
                    routeName: 'guides',
                  ),
                ),
              ),
              Expanded(
                child: _NavigationItem(
                  label: 'Tanamanku',
                  iconPath: 'assets/icons/navigation/plant.svg',
                  isActive: currentIndex == 2,

                  // Tanamanku menggunakan warna merah saat aktif.
                  activeColor: const Color(0xFFE53935),
                  onTap: () => _handleNavigation(
                    context,
                    selectedIndex: 2,
                    routeName: 'plants',
                  ),
                ),
              ),
              Expanded(
                child: _NavigationItem(
                  label: 'Profil',
                  iconPath: 'assets/icons/navigation/profile.svg',
                  isActive: currentIndex == 3,
                  activeColor: const Color(0xFF07852F),
                  onTap: () => _handleNavigation(
                    context,
                    selectedIndex: 3,
                    routeName: 'profile',
                  ),
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
    // Tidak membuka ulang halaman yang sedang aktif.
    if (selectedIndex == currentIndex) {
      return;
    }

    context.goNamed(routeName);
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.iconPath,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  static const Color _inactiveColor = Color(0xFF7B9186);

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isActive ? activeColor : _inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: activeColor.withValues(alpha: 0.08),
        highlightColor: activeColor.withValues(alpha: 0.04),
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
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    itemColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
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
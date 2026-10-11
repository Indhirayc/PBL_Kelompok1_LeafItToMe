import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MainBottomNavigation extends StatelessWidget {
  const MainBottomNavigation({super.key, required this.currentIndex})
    : assert(
        currentIndex >= 0 && currentIndex <= 3,
        'currentIndex harus bernilai antara 0 sampai 3',
      );

  final int currentIndex;

  static const Color _backgroundColor = Color(0xFFFFFFFF);
  static const Color _borderColor = Color(0xFFE3EAE4);

  static const List<_NavigationData> _items = [
    _NavigationData(
      label: 'Beranda',
      iconPath: 'assets/icons/navigation/home.svg',
      routeName: 'home',
    ),
    _NavigationData(
      label: 'Panduan',
      iconPath: 'assets/icons/navigation/guide.svg',
      routeName: 'guides',
    ),
    _NavigationData(
      label: 'Tanamanku',
      iconPath: 'assets/icons/navigation/plant.svg',
      routeName: 'plants',
    ),
    _NavigationData(
      label: 'Profil',
      iconPath: 'assets/icons/navigation/profile.svg',
      routeName: 'profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _backgroundColor,
        border: Border(top: BorderSide(color: _borderColor, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];

              return Expanded(
                child: _NavigationItem(
                  label: item.label,
                  iconPath: item.iconPath,
                  isActive: currentIndex == index,
                  onTap: () {
                    _handleNavigation(
                      context,
                      selectedIndex: index,
                      routeName: item.routeName,
                    );
                  },
                ),
              );
            }),
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
    // Mencegah halaman aktif dibuka kembali.
    if (selectedIndex == currentIndex) {
      return;
    }

    context.goNamed(routeName);
  }
}

class _NavigationData {
  const _NavigationData({
    required this.label,
    required this.iconPath,
    required this.routeName,
  });

  final String label;
  final String iconPath;
  final String routeName;
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

  static const Color _activeColor = Color(0xFF2F7D4A);
  static const Color _inactiveColor = Color(0xFF75857B);

  @override
  Widget build(BuildContext context) {
    final itemColor = isActive ? _activeColor : _inactiveColor;

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
            padding: const EdgeInsets.only(top: 8, bottom: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 25,
                  height: 25,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                  placeholderBuilder: (context) {
                    return Icon(
                      _fallbackIcon(label),
                      size: 25,
                      color: itemColor,
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: itemColor,
                    fontSize: 11,
                    height: 1,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _fallbackIcon(String label) {
    switch (label) {
      case 'Beranda':
        return Icons.home_outlined;
      case 'Panduan':
        return Icons.menu_book_outlined;
      case 'Tanamanku':
        return Icons.eco_outlined;
      case 'Profil':
        return Icons.person_outline_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}

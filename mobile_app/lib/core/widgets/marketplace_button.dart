import 'package:flutter/material.dart';

class MarketplaceButton extends StatelessWidget {
  const MarketplaceButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const Color _primaryGreen = Color(0xFF2E7D45);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.open_in_new_rounded, size: 13),
        label: const Text(
          'Lihat di Marketplace',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

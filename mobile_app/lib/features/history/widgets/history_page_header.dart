import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HistoryPageHeader extends StatelessWidget {
  const HistoryPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    this.fallbackRoute = 'plants',
  });

  final String title;
  final String subtitle;
  final Widget? action;
  final String fallbackRoute;

  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.goNamed(fallbackRoute),
            tooltip: 'Kembali',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            splashRadius: 22,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _darkGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
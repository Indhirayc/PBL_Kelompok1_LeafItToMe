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

  static const Color _titleColor = Color(0xFF1F3826);
  static const Color _secondaryText = Color(0xFF75857B);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: IconButton(
                    tooltip: 'Kembali',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(fallbackRoute);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _titleColor,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _titleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (action != null)
                  SizedBox(width: 56, height: 56, child: Center(child: action))
                else
                  const SizedBox(width: 16),
              ],
            ),
          ),
          if (subtitle.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 0, 20, 0),
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

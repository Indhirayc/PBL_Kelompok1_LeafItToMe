import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.action,
    this.fallbackRoute,
    this.fallbackExtra,
    this.onBack,
    this.backgroundColor = Colors.white,
  });

  final String title;
  final String? subtitle;
  final bool showBackButton;
  final Widget? action;
  final String? fallbackRoute;
  final Object? fallbackExtra;
  final VoidCallback? onBack;
  final Color backgroundColor;

  void _handleBack(BuildContext context) {
    final backCallback = onBack;
    final route = fallbackRoute;

    if (backCallback != null) {
      backCallback();
    } else if (context.canPop()) {
      context.pop();
    } else if (route != null) {
      context.goNamed(route, extra: fallbackExtra);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = const Color(0xFF1F3826);
    final subtitleText = subtitle?.trim();
    final actionWidget = action;

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            child: Row(
              children: [
                if (showBackButton) ...[
                  SizedBox(
                    width: 40,
                    height: 56,
                    child: IconButton(
                      tooltip: 'Kembali',
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      onPressed: () => _handleBack(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: titleColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: showBackButton ? 20 : 22,
                          fontWeight: showBackButton
                              ? FontWeight.bold
                              : FontWeight.w700,
                        ),
                      ),
                      if (subtitleText != null && subtitleText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF75857B),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (actionWidget != null) ...[
                  const SizedBox(width: 12),
                  Center(child: actionWidget),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

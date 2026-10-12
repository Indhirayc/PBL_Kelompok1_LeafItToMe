import 'package:flutter/material.dart';

import '../../../core/widgets/app_page_header.dart';

class HistoryPageHeader extends StatelessWidget {
  const HistoryPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    this.fallbackRoute,
    this.fallbackExtra,
    this.showBackButton = true,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget? action;
  final String? fallbackRoute;
  final Object? fallbackExtra;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: title,
      subtitle: subtitle,
      showBackButton: showBackButton,
      action: action,
      fallbackRoute: fallbackRoute,
      fallbackExtra: fallbackExtra,
      onBack: onBack,
    );
  }
}

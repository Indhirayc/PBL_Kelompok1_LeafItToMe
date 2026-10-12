import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width = double.infinity,
    this.height = 50,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final AppButtonVariant variant;

  Widget _buildContent(Color indicatorColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          color: indicatorColor,
          strokeWidth: 2.5,
        ),
      );
    }

    final buttonText = Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );

    if (icon == null) {
      return buttonText;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), buttonText],
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2F7D4A);
    const destructiveColor = Color(0xFFD32F2F);
    const disabledBackgroundColor = Color(0xFFA8CDB2);
    const disabledForegroundColor = Color(0xFF45624D);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(13),
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledForegroundColor: disabledForegroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: buttonShape,
        ),
        child: _buildContent(
          isLoading ? disabledForegroundColor : Colors.white,
        ),
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          disabledForegroundColor: disabledForegroundColor,
          side: const BorderSide(color: primaryColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: buttonShape,
        ),
        child: _buildContent(primaryColor),
      ),
      AppButtonVariant.destructive => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: destructiveColor,
          disabledForegroundColor: const Color(0xFF9E3A3A),
          side: const BorderSide(color: destructiveColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: buttonShape,
        ),
        child: _buildContent(destructiveColor),
      ),
    };

    return SizedBox(width: width, height: height, child: button);
  }
}

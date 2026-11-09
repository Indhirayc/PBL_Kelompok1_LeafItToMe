import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_breakpoints.dart';

class DiseaseLeafIllustration extends StatelessWidget {
  final String diseaseId;
  final String? imageAssetPath;

  const DiseaseLeafIllustration({
    super.key,
    required this.diseaseId,
    this.imageAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = imageAssetPath;
    return _ResponsiveIllustrationBanner(
      imageAssetPath: assetPath,
      overlayOpacity: 0.4,
      fallback: _buildFallbackBanner(diseaseId),
    );
  }

  Widget _buildFallbackBanner(String id) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: 70,
          color: const Color(0xFF2F7D4A).withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class ToolIllustration extends StatelessWidget {
  final String toolId;
  final IconData icon;
  final String? imageAssetPath;

  const ToolIllustration({
    super.key,
    required this.toolId,
    required this.icon,
    this.imageAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = imageAssetPath;
    return _ResponsiveIllustrationBanner(
      imageAssetPath: assetPath,
      overlayOpacity: 0.35,
      fallback: _buildFallbackToolBanner(),
    );
  }

  Widget _buildFallbackToolBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 54, color: const Color(0xFF2F7D4A)),
        ),
      ),
    );
  }
}

class _ResponsiveIllustrationBanner extends StatelessWidget {
  const _ResponsiveIllustrationBanner({
    required this.imageAssetPath,
    required this.overlayOpacity,
    required this.fallback,
  });

  final String? imageAssetPath;
  final double overlayOpacity;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= AppBreakpoints.tablet;
        final aspectRatio = isTablet
            ? math.max(16 / 7, constraints.maxWidth / 280).toDouble()
            : 16 / 9;
        final assetPath = imageAssetPath;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: assetPath == null || assetPath.isEmpty
                  ? fallback
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          assetPath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) =>
                              fallback,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0),
                                Colors.black.withValues(alpha: overlayOpacity),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

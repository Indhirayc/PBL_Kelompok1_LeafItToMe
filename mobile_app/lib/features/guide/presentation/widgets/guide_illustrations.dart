import 'package:flutter/material.dart';

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
    if (imageAssetPath != null && imageAssetPath!.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imageAssetPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackBanner(diseaseId),
              ),
              // Subtle dark gradient overlay at bottom
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildFallbackBanner(diseaseId);
  }

  Widget _buildFallbackBanner(String id) {
    return Container(
      width: double.infinity,
      height: 200,
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
    if (imageAssetPath != null && imageAssetPath!.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imageAssetPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackToolBanner(),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildFallbackToolBanner();
  }

  Widget _buildFallbackToolBanner() {
    return Container(
      width: double.infinity,
      height: 200,
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

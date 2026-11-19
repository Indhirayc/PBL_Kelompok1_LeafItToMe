import 'dart:io';

import 'package:flutter/material.dart';

/// Widget untuk menampilkan foto daun hasil pemindaian.
/// Mendukung 3 tingkat resolusi sumber foto (3-tier fallback):
/// 1. Cloud URL (Firebase Storage / Cloudinary / HTTP/HTTPS)
/// 2. Berkas lokal di memori HP (File system path)
/// 3. Aset bundel aplikasi (Asset path)
/// Jika seluruh sumber di atas tidak tersedia atau gagal dimuat,
/// widget secara anggun (gracefully) menampilkan placeholder default.
class ScannedLeafImage extends StatelessWidget {
  const ScannedLeafImage({
    super.key,
    this.cloudImageUrl,
    this.localPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isHealthy = true,
    this.fallbackAsset = 'assets/images/tomato_plant.png',
    this.fallbackWidget,
  });

  final String? cloudImageUrl;
  final String? localPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isHealthy;
  final String fallbackAsset;
  final Widget? fallbackWidget;

  Widget _buildFallback() {
    if (fallbackWidget != null) {
      return fallbackWidget!;
    }

    if (isHealthy) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            fallbackAsset,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.eco_rounded,
              color: Color(0xFF2E7D32),
              size: 28,
            ),
          ),
        ),
      );
    }

    return const Center(
      child: Icon(
        Icons.eco_rounded,
        color: Color(0xFFD32F2F),
        size: 28,
      ),
    );
  }

  Widget _buildLocalOrFallback() {
    final path = localPath?.trim();
    if (path == null || path.isEmpty) {
      return _buildFallback();
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // Berkas lokal pada penyimpanan perangkat.
    final file = File(path);
    return Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    final cloud = cloudImageUrl?.trim();

    if (cloud != null &&
        (cloud.startsWith('http://') || cloud.startsWith('https://'))) {
      content = Image.network(
        cloud,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFE8F5E9),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F7D4A)),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildLocalOrFallback(),
      );
    } else {
      content = _buildLocalOrFallback();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }
}


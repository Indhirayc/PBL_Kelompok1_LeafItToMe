import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/services/photo_cache_service.dart';

/// Widget untuk menampilkan foto daun hasil pemindaian dengan strategi
/// **Hybrid (Opsi C)**:
///
/// 1. **Lokal dulu** — berkas di memori HP dipakai apa adanya (instan dan
///    tetap tampil saat offline); aset bundel juga langsung dipakai.
/// 2. **Cache cloud** — bila berkas lokal hilang (mis. dibersihkan sistem),
///    foto ditarik dari URL cloud; hasilnya di-cache terkompresi sehingga
///    pembukaan berikutnya instan.
/// 3. **HP baru** — foto otomatis ditarik dari cloud hanya saat lokal tidak
///    ada; setelah ter-cache tetap instan dan hemat memori.
///
/// Bila seluruh sumber tidak tersedia (offline & belum ada cache), widget
/// secara anggun (gracefully) menampilkan placeholder default.
class ScannedLeafImage extends StatefulWidget {
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

  @override
  State<ScannedLeafImage> createState() => _ScannedLeafImageState();
}

class _ScannedLeafImageState extends State<ScannedLeafImage> {
  static final PhotoCacheService _photoCache = PhotoCacheService();

  String? _resolvedPath;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _resolvePhoto();
  }

  @override
  void didUpdateWidget(covariant ScannedLeafImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localPath != widget.localPath ||
        oldWidget.cloudImageUrl != widget.cloudImageUrl) {
      _resolvePhoto();
    }
  }

  Future<void> _resolvePhoto() async {
    final localPath = widget.localPath;
    final cloudImageUrl = widget.cloudImageUrl;

    setState(() {
      _isResolving = true;
      _resolvedPath = null;
    });

    final String? resolved;
    try {
      resolved = await _photoCache.resolve(
        localPath: localPath,
        cloudImageUrl: cloudImageUrl,
      );
    } catch (e) {
      debugPrint('ScannedLeafImage: resolusi foto gagal: $e');
      resolved = null;
    }

    if (!mounted) return;
    if (localPath != widget.localPath ||
        cloudImageUrl != widget.cloudImageUrl) {
      // Input berubah saat resolusi berjalan; resolusi ulang sudah dipicu
      // oleh didUpdateWidget dan hasil ini sudah usang.
      return;
    }

    setState(() {
      _resolvedPath = resolved;
      _isResolving = false;
    });
  }

  Widget _buildFallback() {
    if (widget.fallbackWidget != null) {
      return widget.fallbackWidget!;
    }

    if (widget.isHealthy) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            widget.fallbackAsset,
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
      child: Icon(Icons.eco_rounded, color: Color(0xFFD32F2F), size: 28),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: widget.width,
      height: widget.height,
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
  }

  Widget _buildResolved() {
    final path = _resolvedPath;
    if (path == null || path.isEmpty) {
      return _buildFallback();
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // Berkas lokal di HP (foto asli maupun hasil cache cloud).
    return Image.file(
      File(path),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_isResolving && _resolvedPath == null) {
      content = _buildLoading();
    } else {
      content = _buildResolved();
    }

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }

    return content;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Layanan cache foto daun dengan strategi **Hybrid (Opsi C)**:
///
/// 1. **Lokal dulu** — berkas di memori HP / aset bundel dipakai apa adanya
///    (instan & tetap tampil saat offline).
/// 2. **Cloud kemudian** — bila berkas lokal hilang, foto ditarik dari URL
///    cloud (Cloudinary) memakai transformasi terkompresi (`f_auto,q_auto`
///    lebar 800px) agar cache ringan di memori.
/// 3. **Cache permanen** — hasil unduhan disimpan di penyimpanan aplikasi
///    sehingga pembukaan berikutnya instan tanpa unduh ulang.
///
/// Return berupa path string: path aset (`assets/...`) atau path berkas
/// absolut; `null` bila seluruh sumber tidak tersedia (mis. offline dan
/// belum ada cache).
class PhotoCacheService {
  PhotoCacheService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Mencegah unduhan ganda untuk URL yang sama secara bersamaan.
  final Map<String, Future<String?>> _inFlight = {};

  static const String _cacheDirName = 'leaf_photo_cache';
  static const String _cloudinaryMarker = '/upload/';

  Future<String?> resolve({String? localPath, String? cloudImageUrl}) async {
    final local = localPath?.trim();

    // 1. Aset bundel selalu tersedia → instan, tanpa I/O berkas.
    if (local != null && local.isNotEmpty && local.startsWith('assets/')) {
      return local;
    }

    // 2. Berkas lokal yang masih ada di HP → instan & offline.
    if (local != null && local.isNotEmpty && !_isUrl(local)) {
      try {
        if (await File(local).exists()) return local;
      } catch (e) {
        debugPrint('PhotoCacheService: gagal memeriksa berkas lokal: $e');
      }
    }

    // 3. Cloud: cache lokal dulu, belum ada → unduh versi terkompresi.
    final cloud = cloudImageUrl?.trim();
    if (cloud == null || cloud.isEmpty || !_isUrl(cloud)) return null;

    final future = _inFlight.putIfAbsent(cloud, () => _resolveFromCloud(cloud));
    try {
      return await future;
    } finally {
      _inFlight.remove(cloud);
    }
  }

  Future<String?> _resolveFromCloud(String url) async {
    try {
      final cachePath = await _cacheFilePath(url);
      final cachedFile = File(cachePath);
      if (await cachedFile.exists()) return cachePath;

      await cachedFile.parent.create(recursive: true);
      await _dio.download(_compressedUrl(url), cachePath);

      if (await cachedFile.exists()) return cachePath;
      return null;
    } catch (e) {
      // Offline / URL mati → biarkan pemanggil memakai fallback.
      debugPrint('PhotoCacheService: gagal mengambil foto dari cloud: $e');
      return null;
    }
  }

  bool _isUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  /// Sisipkan transformasi Cloudinary agar versi cache terkompresi
  /// (format otomatis, kualitas otomatis, lebar maks 800px).
  /// URL non-Cloudinary dikembalikan apa adanya.
  String _compressedUrl(String url) {
    final index = url.indexOf(_cloudinaryMarker);
    if (!url.contains('res.cloudinary.com') || index == -1) return url;

    final insertAt = index + _cloudinaryMarker.length;
    return url.replaceRange(insertAt, insertAt, 'f_auto,q_auto,w_800/');
  }

  /// Nama berkas cache deterministik dari URL (aman sebagai nama berkas).
  Future<String> _cacheFilePath(String url) async {
    final dbPath = await getDatabasesPath();
    final fileName = base64Url.encode(utf8.encode(url));
    return p.join(dbPath, _cacheDirName, '$fileName.jpg');
  }
}

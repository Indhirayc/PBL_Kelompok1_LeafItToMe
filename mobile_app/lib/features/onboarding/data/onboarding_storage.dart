import 'dart:io';

import 'package:sqflite/sqflite.dart';

/// Menyimpan penanda bahwa onboarding sudah pernah ditampilkan.
///
/// Memakai folder database yang sudah disediakan `sqflite` agar tidak perlu
/// menambah dependency baru. Semua kegagalan penyimpanan diabaikan supaya
/// layar onboarding tidak pernah menahan pengguna.
class OnboardingStorage {
  const OnboardingStorage();

  static const String _markerFileName = 'leafittome_onboarding.marker';

  Future<bool> hasSeenOnboarding() async {
    try {
      final file = await _markerFile();
      return await file.exists();
    } catch (_) {
      // Fail-open: bila status tidak bisa dibaca, lewati onboarding.
      return true;
    }
  }

  Future<void> markOnboardingSeen() async {
    try {
      final file = await _markerFile();
      await file.writeAsString(
        DateTime.now().toIso8601String(),
        flush: true,
      );
    } catch (_) {
      // Diabaikan: pengguna tetap boleh melanjutkan walaupun gagal menyimpan.
    }
  }

  Future<File> _markerFile() async {
    final directory = await getDatabasesPath();
    return File('$directory${Platform.pathSeparator}$_markerFileName');
  }
}
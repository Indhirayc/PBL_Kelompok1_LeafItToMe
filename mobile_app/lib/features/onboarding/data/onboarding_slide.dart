import 'package:flutter/material.dart';

/// Satu halaman perkenalan pada layar onboarding.
class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

/// Konten onboarding singkat: kenali, rawat, lalu simpan cerita tanaman.
const List<OnboardingSlide> kOnboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    title: 'Kenali Daun Tomatmu',
    description:
        'Cukup ambil foto daun tomat. LeafItToMe akan membantu menebak '
        'kemungkinan penyakitnya, langsung dari ponselmu.',
    icon: Icons.center_focus_strong_rounded,
  ),
  OnboardingSlide(
    title: 'Rawat dengan Langkah Tepat',
    description:
        'Dapatkan panduan menanam dan menangani tanaman yang disesuaikan '
        'dengan hasil pemeriksaanmu.',
    icon: Icons.menu_book_rounded,
  ),
  OnboardingSlide(
    title: 'Simpan Cerita Tanamanmu',
    description:
        'Setiap pemeriksaan tersimpan rapi, jadi kamu bisa memantau '
        'perkembangan tanaman dari waktu ke waktu.',
    icon: Icons.history_rounded,
  ),
];
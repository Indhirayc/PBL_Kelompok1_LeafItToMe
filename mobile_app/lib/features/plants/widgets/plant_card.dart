import 'package:flutter/material.dart';

import '../models/plant.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTapDetail;
  final EdgeInsetsGeometry margin;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTapDetail,
    this.margin = const EdgeInsets.only(bottom: 14),
  });

  static const Color primaryGreen = Color(0xFF2F7D4A);
  static const Color darkGreen = Color(0xFF183E2D);
  static const Color secondaryText = Color(0xFF75857B);
  static const Color borderColor = Color(0xFFE3EAE4);

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = plant.status.toLowerCase() == 'sehat';

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── BARIS ATAS: Avatar + Nama + ID + Badge Status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Ikon Lingkaran
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isHealthy
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isHealthy
                        ? const Color(0xFFC8E6C9)
                        : const Color(0xFFFFE0B2),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.eco_rounded,
                  color: isHealthy ? primaryGreen : const Color(0xFFED6C02),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              // Detail Teks & Badge Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            plant.id,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A6854),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge Chip Status dengan indikator dot
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isHealthy
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isHealthy
                                  ? const Color(0xFFC8E6C9)
                                  : const Color(0xFFFFE0B2),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isHealthy
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFED6C02),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                plant.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isHealthy
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFED6C02),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEF3EF)),
          const SizedBox(height: 10),
          // ── BARIS BAWAH: Tanggal Pemeriksaan + Tombol 'Lihat Detail ›' ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pemeriksaan terakhir',
                      style: TextStyle(fontSize: 11, color: secondaryText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plant.lastInspectionDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol Lihat Detail Berbentuk Pill
              OutlinedButton(
                onPressed: onTapDetail,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2F7D4A),
                  side: const BorderSide(color: Color(0xFF2F7D4A), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

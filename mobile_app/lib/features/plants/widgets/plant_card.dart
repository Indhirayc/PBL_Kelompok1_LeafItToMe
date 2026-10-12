import 'package:flutter/material.dart';

import '../views/plant_list_page.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTapDetail;

  const PlantCard({super.key, required this.plant, required this.onTapDetail});

  static const Color primaryGreen = Color(0xFF2F7D4A);
  static const Color darkGreen = Color(0xFF183E2D);
  static const Color secondaryText = Color(0xFF75857B);
  static const Color borderColor = Color(0xFFE3EAE4);

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = plant.status.toLowerCase() == 'sehat';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.eco,
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plant.id,
                      style: const TextStyle(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Badge Chip Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isHealthy
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        plant.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isHealthy
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFED6C02),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),
          // ── BARIS BAWAH: Tanggal Pemeriksaan + Tombol 'Lihat Detail ›' ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pemeriksaan terakhir',
                    style: TextStyle(fontSize: 11, color: secondaryText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plant.plantDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ],
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
                    Icon(Icons.chevron_right, size: 16),
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

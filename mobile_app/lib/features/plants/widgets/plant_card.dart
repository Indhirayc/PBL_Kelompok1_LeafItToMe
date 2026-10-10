import 'package:flutter/material.dart';

import '../views/plant_list_page.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTapDetail;

  const PlantCard({super.key, required this.plant, required this.onTapDetail});

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = plant.status.toLowerCase() == 'sehat';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // ⬅️ KUNCI: Membuat SEMUA elemen rata tengah secara vertikal
          children: [
            // 1. Lingkaran Logo Daun
            CircleAvatar(
              radius: 22,
              backgroundColor: isHealthy
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              child: Icon(
                Icons.eco,
                color: isHealthy ? const Color(0xFF2E7D32) : Colors.orange,
              ),
            ),
            const SizedBox(width: 14),

            // 2. Teks Info Tanaman
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${plant.id} • ${plant.location}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Ditanam: ${plant.plantDate}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 3. Tombol Detail
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              onPressed: onTapDetail,
              child: const Text("Detail", style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

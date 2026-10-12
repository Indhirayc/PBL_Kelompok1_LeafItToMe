import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import halaman dan widget
import 'plant_detail_page.dart';
import '../widgets/plant_card.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';

class Plant {
  final String id;
  final String name;
  final String location;
  final String plantDate;
  final String status;
  final String? note;

  Plant({
    required this.id,
    required this.name,
    required this.location,
    required this.plantDate,
    required this.status,
    this.note,
  });
}

class PlantListPage extends StatefulWidget {
  const PlantListPage({super.key});
  @override
  State<PlantListPage> createState() => _PlantListPageState();
}

class _PlantListPageState extends State<PlantListPage> {
  // Simulasi data awal tanaman
  final List<Plant> _plants = [
    Plant(
      id: "TMT-001",
      name: "Tomat Pot Depan",
      location: "Teras depan",
      plantDate: "28 Sep 2026",
      status: "Sehat",
    ),
    Plant(
      id: "TMT-002",
      name: "Tomat Kebun Belakang",
      location: "Kebun belakang",
      plantDate: "25 Sep 2026",
      status: "Perlu perhatian",
    ),
  ];

  String _generateNextPlantId() {
    int maxNum = 0;
    for (var plant in _plants) {
      final parts = plant.id.split('-');
      if (parts.length > 1) {
        final num = int.tryParse(parts[1]);
        if (num != null && num > maxNum) {
          maxNum = num;
        }
      }
    }
    return "TMT-${(maxNum + 1).toString().padLeft(3, '0')}";
  }

  Widget _buildStatItem(
    String count,
    String label,
    Color countColor,
    Color labelColor,
  ) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: countColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalCount = _plants.length;
    int healthyCount = _plants
        .where((p) => p.status.toLowerCase() == 'sehat')
        .length;
    int attentionCount = totalCount - healthyCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Bagian Header & Tombol Tambah
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tanamanku",
                          style: TextStyle(
                            color: Color(0xFF1F3826),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          "Pantau setiap tanaman berdasarkan ID.",
                          style: TextStyle(
                            color: Color(0xFF75857B),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F7D4A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          final newPlant = await context.pushNamed<Plant>(
                            'add-plant',
                            extra: _generateNextPlantId(),
                          );
                          if (newPlant != null) {
                            setState(() {
                              _plants.add(newPlant);
                            });
                          }
                        },
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text(
                          "Tambah",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Card Ringkasan Statistik
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '$totalCount',
                      'Tanaman',
                      const Color(0xFF2E7D32),
                      const Color(0xFF75857B),
                    ),
                    _buildStatItem(
                      '$healthyCount',
                      'Sehat',
                      const Color(0xFF2E7D32),
                      const Color(0xFF2E7D32),
                    ),
                    _buildStatItem(
                      '$attentionCount',
                      'Perlu Perhatian',
                      const Color(0xFFED6C02),
                      const Color(0xFFED6C02),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // List Data / Kondisi Kosong
              Expanded(
                child: _plants.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada data tanaman.\nTekan tombol Tambah untuk membuat baru.",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _plants.length,
                        itemBuilder: (context, index) {
                          final plant = _plants[index];
                          return PlantCard(
                            plant: plant,
                            onTapDetail: () async {
                              // Navigasi ke detail sambil menunggu opsi hapus
                              final bool? shouldDelete = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PlantDetailPage(plant: plant),
                                ),
                              );
                              if (shouldDelete == true) {
                                setState(() {
                                  _plants.removeAt(index);
                                });
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // ✅ GANTI MENJADI:
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }
}

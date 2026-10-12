import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_breakpoints.dart';
// Import halaman dan widget
import 'plant_detail_page.dart';
import '../widgets/plant_card.dart';
import '../../../../core/widgets/app_content_layout.dart';
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

  Widget _buildStatItem(String count, String label, Color countColor) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAE4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            count,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: countColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF183E2D),
            ),
          ),
        ],
      ),
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
      body: AppContentLayout(
        child: SafeArea(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tanamanku",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF1F3826),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Text(
                              "Pantau setiap tanaman berdasarkan ID.",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF75857B),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
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
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '$totalCount',
                        'Total Tanaman',
                        const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        '$healthyCount',
                        'Kondisi Sehat',
                        const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        '$attentionCount',
                        'Perlu Perhatian',
                        const Color(0xFFED6C02),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // List Data / Kondisi Kosong
                Expanded(child: _buildPlantList()),
              ],
            ),
          ),
        ),
      ),
      // ✅ GANTI MENJADI:
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildPlantList() {
    if (_plants.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada data tanaman.\nTekan tombol Tambah untuk membuat baru.",
          textAlign: TextAlign.center,
        ),
      );
    }

    final isTablet = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

    Widget buildPlantCard(int index) {
      final plant = _plants[index];
      return PlantCard(
        plant: plant,
        margin: EdgeInsets.only(bottom: isTablet ? 0 : 14),
        onTapDetail: () async {
          final bool? shouldDelete = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantDetailPage(plant: plant),
            ),
          );
          if (shouldDelete == true) {
            setState(() {
              _plants.removeAt(index);
            });
          }
        },
      );
    }

    if (isTablet) {
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _plants.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 200,
        ),
        itemBuilder: (context, index) => buildPlantCard(index),
      );
    }

    return ListView.builder(
      itemCount: _plants.length,
      itemBuilder: (context, index) => buildPlantCard(index),
    );
  }
}

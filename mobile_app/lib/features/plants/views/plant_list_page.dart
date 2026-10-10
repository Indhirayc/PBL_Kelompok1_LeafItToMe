import 'package:flutter/material.dart';

// Import halaman dan widget
import 'add_plant_page.dart';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tanamanku",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Pantau setiap tanaman berdasarkan ID.",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      // Buka halaman tambah dan tunggu hasil return-nya
                      final newPlant = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddPlantPage()),
                      );
                      if (newPlant != null && newPlant is Plant) {
                        setState(() {
                          _plants.add(newPlant);
                        });
                      }
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Tambah"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Card Ringkasan Statistik
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "$totalCount\nTanaman",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$healthyCount Sehat",
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$attentionCount Perlu perhatian",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';
import '../widgets/plant_card.dart';
import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';

class PlantListPage extends ConsumerWidget {
  const PlantListPage({super.key});

  String _generateNextPlantId(List<Plant> plants) {
    int maxNum = 0;
    for (final plant in plants) {
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

  Widget _buildPlantsContent(
    BuildContext context,
    WidgetRef ref,
    List<Plant> plants,
  ) {
    final totalCount = plants.length;
    final healthyCount = plants
        .where((p) => p.status.toLowerCase() == 'sehat')
        .length;
    final attentionCount = totalCount - healthyCount;

    return Column(
      children: [
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
        Expanded(child: _buildPlantList(context, ref, plants)),
      ],
    );
  }

  Widget _buildPlantState(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantProvider);
    return plantsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2F7D4A)),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tanaman belum dapat dimuat. Silakan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF75857B), fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.read(plantProvider.notifier).refreshPlants(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
      data: (plants) => _buildPlantsContent(context, ref, plants),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantProvider);
    final plants = plantsAsync.value ?? initialPlants;

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
                          onPressed: plantsAsync.hasValue
                              ? () => context.pushNamed(
                                  'add-plant',
                                  extra: _generateNextPlantId(plants),
                                )
                              : null,
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
                Expanded(child: _buildPlantState(context, ref)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildPlantList(
    BuildContext context,
    WidgetRef ref,
    List<Plant> plants,
  ) {
    if (plants.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada data tanaman.\nTekan tombol Tambah untuk membuat baru.",
          textAlign: TextAlign.center,
        ),
      );
    }

    final isTablet = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

    Widget buildPlantCard(Plant plant) {
      return PlantCard(
        plant: plant,
        margin: EdgeInsets.only(bottom: isTablet ? 0 : 14),
        onTapDetail: () {
          context.pushNamed(
            'plant-detail',
            pathParameters: {'plantId': plant.id},
          );
        },
      );
    }

    if (isTablet) {
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: plants.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 200,
        ),
        itemBuilder: (context, index) => buildPlantCard(plants[index]),
      );
    }

    return ListView.builder(
      itemCount: plants.length,
      itemBuilder: (context, index) => buildPlantCard(plants[index]),
    );
  }
}

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

  Future<void> _openAddPlant(BuildContext context, WidgetRef ref) async {
    try {
      final nextId = await ref.read(plantProvider.notifier).nextPlantId();
      if (context.mounted) {
        context.pushNamed('add-plant', extra: nextId);
      }
    } catch (error, stackTrace) {
      debugPrint('Gagal menyiapkan ID tanaman: $error\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form tambah tanaman belum dapat dibuka.'),
          ),
        );
      }
    }
  }

  Widget _buildStatItem(
    String count,
    String label,
    Color countColor, {
    Color bgColor = Colors.white,
    Color borderColor = const Color(0xFFE3EAE4),
  }) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
                bgColor: const Color(0xFFF6FAF7),
                borderColor: const Color(0xFFD8EADC),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                '$healthyCount',
                'Kondisi Sehat',
                const Color(0xFF2E7D32),
                bgColor: const Color(0xFFF1F9F3),
                borderColor: const Color(0xFFC7E6CD),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                '$attentionCount',
                'Perlu Perhatian',
                const Color(0xFFED6C02),
                bgColor: const Color(0xFFFFF7ED),
                borderColor: const Color(0xFFFFDEC0),
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tanamanku",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF1F3826),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Pantau setiap tanaman berdasarkan ID.",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF75857B),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F7D4A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 1,
                            shadowColor: const Color(0xFF2F7D4A).withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: plantsAsync.hasValue
                              ? () => _openAddPlant(context, ref)
                              : null,
                          icon: const Icon(Icons.add_rounded, size: 16),
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
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC8E6C9),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.yard_outlined,
                  size: 34,
                  color: Color(0xFF2F7D4A),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Belum ada data tanaman.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF183E2D),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Tekan tombol Tambah untuk membuat baru dan mulai memantau tanaman tomatmu.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF75857B),
                  height: 1.4,
                ),
              ),
            ],
          ),
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

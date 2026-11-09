import '../../models/plant.dart';

abstract interface class PlantRepository {
  Future<List<Plant>> getRemotePlants();
  Future<Plant> getRemotePlantById(String id);
  Future<Plant> createRemotePlant(Plant plant);
  Future<Plant> updateRemotePlant(Plant plant);
  Future<void> deleteRemotePlant(String id);
}

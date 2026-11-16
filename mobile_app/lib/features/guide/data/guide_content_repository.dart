import '../../../data/datasources/local/app_database.dart';
import '../../../data/models/guide_content_model.dart';

class GuideContentRepository {
  GuideContentRepository({AppDatabase? localDb})
    : _localDb = localDb ?? AppDatabase.instance;

  final AppDatabase _localDb;

  Future<List<GuideContentModel>> getGuideContents() {
    return _localDb.getGuideContents();
  }
}
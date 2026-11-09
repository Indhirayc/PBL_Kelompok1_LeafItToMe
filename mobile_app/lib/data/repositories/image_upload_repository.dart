import '../datasources/remote/cloudinary_source.dart';

class ImageUploadRepository {
  final CloudinarySource _cloudinarySource;

  ImageUploadRepository({CloudinarySource? cloudinarySource})
    : _cloudinarySource = cloudinarySource ?? CloudinarySource();

  /// Upload gambar scan dan mengembalikan URL publik serta public_id
  Future<Map<String, String>> uploadScanPhoto({
    required String userId,
    required String localPath,
  }) async {
    return await _cloudinarySource.uploadScanImage(
      userId: userId,
      localPath: localPath,
    );
  }
}

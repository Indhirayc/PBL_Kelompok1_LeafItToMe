class GuideContentModel {
  const GuideContentModel({
    required this.id,
    required this.category,
    required this.title,
    this.description,
    this.steps,
    this.image,
    this.videoUrl,
    this.createdAt,
  });

  final String id;
  final String category;
  final String title;
  final String? description;
  final String? steps;
  final String? image;
  final String? videoUrl;
  final String? createdAt;

  factory GuideContentModel.fromMap(Map<String, Object?> map) {
    return GuideContentModel(
      id: map['id_panduan'] as String,
      category: map['kategori'] as String,
      title: map['judul'] as String,
      description: map['deskripsi'] as String?,
      steps: map['langkah_langkah'] as String?,
      image: map['gambar'] as String?,
      videoUrl: map['video_url'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}
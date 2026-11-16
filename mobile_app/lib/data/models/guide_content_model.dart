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
      id: map['id'] as String,
      category: (map['category'] as String?) ?? '',
      title: map['title'] as String,
      description: map['description'] as String?,
      steps: map['content'] as String?,
      image: map['image_path'] as String?,
      videoUrl: map['video_url'] as String?,
      createdAt: map['updated_at'] as String?,
    );
  }
}
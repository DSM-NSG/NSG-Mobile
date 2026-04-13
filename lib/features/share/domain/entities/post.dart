class Post {
  final String id;
  final String title;
  final String content;
  final String category;
  final int likes;
  final int comments;

  final String? locationName;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final String? subCategory;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.likes,
    required this.comments,
    this.locationName,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.subCategory,
  });

  bool get hasLocation => latitude != null && longitude != null;
}

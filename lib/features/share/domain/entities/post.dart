enum PostBoard { share, major }

class Post {
  final String id;
  final String title;
  final String content;
  final String category;
  final int likes;
  final int comments;
  final PostBoard board;

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
    this.board = PostBoard.share,
    this.locationName,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.subCategory,
  });

  bool get hasLocation => latitude != null && longitude != null;

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    int? likes,
    int? comments,
    PostBoard? board,
    String? locationName,
    String? locationAddress,
    double? latitude,
    double? longitude,
    String? subCategory,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      board: board ?? this.board,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      subCategory: subCategory ?? this.subCategory,
    );
  }
}

import 'package:nsg_mobile/features/share/domain/entities/comment.dart';

class PostDetail {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorName;
  final String? generation;
  final bool isOwn;
  final int likes;
  final String? imagePath;
  final List<Comment> commentList;

  final String? locationName;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final String? subCategory;

  const PostDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorName,
    this.generation,
    this.isOwn = false,
    required this.likes,
    this.imagePath,
    this.commentList = const [],
    this.locationName,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.subCategory,
  });
}

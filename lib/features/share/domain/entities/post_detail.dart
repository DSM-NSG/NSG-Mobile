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
  final List<String> imagePaths;
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
    this.imagePaths = const [],
    this.commentList = const [],
    this.locationName,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.subCategory,
  });

  PostDetail copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? authorName,
    Object? generation = _sentinel,
    bool? isOwn,
    int? likes,
    Object? imagePath = _sentinel,
    List<String>? imagePaths,
    List<Comment>? commentList,
    Object? locationName = _sentinel,
    Object? locationAddress = _sentinel,
    Object? latitude = _sentinel,
    Object? longitude = _sentinel,
    Object? subCategory = _sentinel,
  }) {
    return PostDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      authorName: authorName ?? this.authorName,
      generation: generation == _sentinel
          ? this.generation
          : generation as String?,
      isOwn: isOwn ?? this.isOwn,
      likes: likes ?? this.likes,
      imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
      imagePaths: imagePaths ?? this.imagePaths,
      commentList: commentList ?? this.commentList,
      locationName: locationName == _sentinel
          ? this.locationName
          : locationName as String?,
      locationAddress: locationAddress == _sentinel
          ? this.locationAddress
          : locationAddress as String?,
      latitude: latitude == _sentinel ? this.latitude : latitude as double?,
      longitude: longitude == _sentinel ? this.longitude : longitude as double?,
      subCategory: subCategory == _sentinel
          ? this.subCategory
          : subCategory as String?,
    );
  }

  List<String> get allImagePaths {
    if (imagePaths.isNotEmpty) return imagePaths;
    if (imagePath != null && imagePath!.isNotEmpty) return [imagePath!];
    return const [];
  }
}

const _sentinel = Object();

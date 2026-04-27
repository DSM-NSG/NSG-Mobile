import 'package:nsg_mobile/features/share/domain/entities/comment.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';
import 'package:nsg_mobile/features/share/domain/entities/post_detail.dart';

// ── Author helper ────────────────────────────────────────────────────────────

String _parseAuthor(dynamic raw, [String fallback = '알 수 없음']) {
  if (raw is String) return raw.isNotEmpty ? raw : fallback;
  if (raw is Map<String, dynamic>) {
    return (raw['name'] as String?) ?? (raw['username'] as String?) ?? fallback;
  }
  return fallback;
}

// ── Category helpers ────────────────────────────────────────────────────────

String apiCategoryToApp(String api) =>
    const {
      'PLACE': '장소',
      'DORMITORY': '기숙사',
      'SCHOOL': '대마고',
      'ETC': '기타',
    }[api] ??
    '기타';

String appCategoryToApi(String app) =>
    const {
      '장소': 'PLACE',
      '기숙사': 'DORMITORY',
      '대마고': 'SCHOOL',
      '기타': 'ETC',
    }[app] ??
    'ETC';

/// WritePostScreen.type → API category string
String writeTypeToApiCategory(String type) => switch (type) {
  'place' => 'PLACE',
  'dormitory' => 'DORMITORY',
  'school' => 'SCHOOL',
  _ => 'ETC',
};

// ── List item ───────────────────────────────────────────────────────────────

class TipsPostModel {
  final String id;
  final String author; // plain string name from server
  final String title;
  final String apiCategory; // PLACE | DORMITORY | SCHOOL | ETC
  final int likeCount;
  final int commentCount;
  final bool hasImages;
  final String createdAt;

  const TipsPostModel({
    required this.id,
    required this.author,
    required this.title,
    required this.apiCategory,
    required this.likeCount,
    required this.commentCount,
    required this.hasImages,
    required this.createdAt,
  });

  factory TipsPostModel.fromJson(Map<String, dynamic> json) => TipsPostModel(
    id: json['id'] as String,
    author: _parseAuthor(json['author']),
    title: json['title'] as String? ?? '',
    apiCategory: json['category'] as String? ?? 'ETC',
    likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
    hasImages: json['has_images'] == true,
    createdAt: json['created_at'] as String? ?? '',
  );

  Post toPost() => Post(
    id: id,
    title: title,
    content: '',
    category: apiCategoryToApp(apiCategory),
    likes: likeCount,
    comments: commentCount,
  );
}

// ── Comment ─────────────────────────────────────────────────────────────────

class TipsCommentModel {
  final String id;
  final String author;
  final String content;
  final bool isAnonymous;
  final String? parentId;

  const TipsCommentModel({
    required this.id,
    required this.author,
    required this.content,
    required this.isAnonymous,
    this.parentId,
  });

  factory TipsCommentModel.fromJson(Map<String, dynamic> json) =>
      TipsCommentModel(
        id: json['id'] as String? ?? '',
        author: _parseAuthor(json['author']),
        content: json['content'] as String? ?? '',
        isAnonymous: json['is_anonymous'] == true,
        parentId: json['parent_id'] as String?,
      );

  Comment toComment() => Comment(
    id: id,
    authorName: isAnonymous ? '익명' : author,
    content: content,
    parentId: parentId,
  );
}

// ── Detail ──────────────────────────────────────────────────────────────────

class TipsPostDetailModel {
  final String id;
  final String author;
  final String title;
  final String body;
  final String apiCategory;
  final Map<String, dynamic>? place;
  final bool isAnonymous;
  final int likeCount;
  final bool isLiked;
  final List<Map<String, dynamic>> images;
  final List<TipsCommentModel> comments;
  final String createdAt;

  const TipsPostDetailModel({
    required this.id,
    required this.author,
    required this.title,
    required this.body,
    required this.apiCategory,
    this.place,
    required this.isAnonymous,
    required this.likeCount,
    required this.isLiked,
    required this.images,
    required this.comments,
    required this.createdAt,
  });

  factory TipsPostDetailModel.fromJson(Map<String, dynamic> json) {
    final rawComments = json['comments'];
    final comments = rawComments is List
        ? rawComments
              .whereType<Map<String, dynamic>>()
              .map(TipsCommentModel.fromJson)
              .toList()
        : <TipsCommentModel>[];

    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    final rawPlace = json['place'];
    final place = rawPlace is Map<String, dynamic> ? rawPlace : null;

    return TipsPostDetailModel(
      id: json['id'] as String,
      author: _parseAuthor(json['author']),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      apiCategory: json['category'] as String? ?? 'ETC',
      place: place,
      isAnonymous: json['is_anonymous'] == true,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] == true,
      images: images,
      comments: comments,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  String? get firstImageUrl =>
      images.isNotEmpty ? images.first['url'] as String? : null;

  List<String> get imageUrls => images
      .map((image) => image['url'] as String?)
      .whereType<String>()
      .where((url) => url.isNotEmpty)
      .toList();

  /// [isOwn] should be true only when the current user just created this post.
  PostDetail toPostDetail({bool isOwn = false}) => PostDetail(
    id: id,
    title: title,
    content: body,
    category: apiCategoryToApp(apiCategory),
    authorName: isAnonymous ? '익명' : author,
    isOwn: isOwn,
    likes: likeCount,
    imagePath: firstImageUrl,
    imagePaths: imageUrls,
    commentList: comments.map((c) => c.toComment()).toList(),
    locationName: place?['name'] as String?,
    locationAddress: place?['address'] as String?,
    latitude: (place?['latitude'] as num?)?.toDouble(),
    longitude: (place?['longitude'] as num?)?.toDouble(),
  );
}

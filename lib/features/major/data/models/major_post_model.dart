import 'package:nsg_mobile/features/share/domain/entities/comment.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';
import 'package:nsg_mobile/features/share/domain/entities/post_detail.dart';

// ── List item ────────────────────────────────────────────────────────────────

class MajorPostModel {
  final String id;
  final String author; // plain string name
  final String title;
  final String majors; // display label for the major(s)
  final int likeCount;
  final int commentCount;
  final String createdAt;

  const MajorPostModel({
    required this.id,
    required this.author,
    required this.title,
    required this.majors,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory MajorPostModel.fromJson(Map<String, dynamic> json) => MajorPostModel(
    id: json['id'] as String,
    author: json['author'] as String? ?? '알 수 없음',
    title: json['title'] as String? ?? '',
    majors: json['majors'] as String? ?? '',
    likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
    createdAt: json['created_at'] as String? ?? '',
  );

  Post toPost() => Post(
    id: id,
    title: title,
    content: '',
    category: majors.isNotEmpty ? majors : '전공',
    likes: likeCount,
    comments: commentCount,
    board: PostBoard.major,
  );
}

// ── Comment ──────────────────────────────────────────────────────────────────

class MajorCommentModel {
  final String id;
  final String author;
  final String content;
  final bool isAnonymous;
  final String? parentId;

  const MajorCommentModel({
    required this.id,
    required this.author,
    required this.content,
    required this.isAnonymous,
    this.parentId,
  });

  factory MajorCommentModel.fromJson(Map<String, dynamic> json) =>
      MajorCommentModel(
        id: json['id'] as String? ?? '',
        author: json['author'] as String? ?? '알 수 없음',
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

// ── Detail ───────────────────────────────────────────────────────────────────

class MajorPostDetailModel {
  final String id;
  final String author;
  final String title;
  final String body;
  final String majors;
  final bool isAnonymous;
  final int likeCount;
  final bool isLiked;
  final List<Map<String, dynamic>> images;
  final List<MajorCommentModel> comments;
  final String createdAt;

  const MajorPostDetailModel({
    required this.id,
    required this.author,
    required this.title,
    required this.body,
    required this.majors,
    required this.isAnonymous,
    required this.likeCount,
    required this.isLiked,
    required this.images,
    required this.comments,
    required this.createdAt,
  });

  factory MajorPostDetailModel.fromJson(Map<String, dynamic> json) {
    final rawComments = json['comments'];
    final comments = rawComments is List
        ? rawComments
              .whereType<Map<String, dynamic>>()
              .map(MajorCommentModel.fromJson)
              .toList()
        : <MajorCommentModel>[];

    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    return MajorPostDetailModel(
      id: json['id'] as String,
      author: json['author'] as String? ?? '알 수 없음',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      majors: json['majors'] as String? ?? '',
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

  PostDetail toPostDetail({bool isOwn = false}) => PostDetail(
    id: id,
    title: title,
    content: body,
    category: majors.isNotEmpty ? majors : '전공',
    authorName: isAnonymous ? '익명' : author,
    isOwn: isOwn,
    likes: likeCount,
    imagePath: firstImageUrl,
    imagePaths: imageUrls,
    commentList: comments.map((c) => c.toComment()).toList(),
  );
}

import 'package:nsg_mobile/core/network/api_client.dart';
import 'package:nsg_mobile/core/network/api_endpoints.dart';
import 'package:nsg_mobile/features/share/domain/entities/comment.dart';

class CommentService {
  /// POST /posts/{post_id}/comments/
  static Future<Comment> createComment({
    required String postId,
    required String content,
    bool isAnonymous = false,
  }) async {
    final response = await ApiClient.dio.post(
      ApiEndpoints.createComment(postId),
      data: {'content': content, 'is_anonymous': isAnonymous},
    );
    return _commentFromJson(
      response.data as Map<String, dynamic>,
      parentId: null,
    );
  }

  /// POST /posts/{post_id}/comments/{comment_id}/replies/
  static Future<Comment> createReply({
    required String postId,
    required String commentId,
    required String content,
    bool isAnonymous = false,
  }) async {
    final response = await ApiClient.dio.post(
      ApiEndpoints.replyComment(postId, commentId),
      data: {'content': content, 'is_anonymous': isAnonymous},
    );
    return _commentFromJson(
      response.data as Map<String, dynamic>,
      parentId: commentId, // wire up the parent so the UI nests it correctly
    );
  }

  static Comment _commentFromJson(
    Map<String, dynamic> data, {
    required String? parentId,
  }) {
    final isAnonymous = data['is_anonymous'] == true;
    return Comment(
      id: data['id'] as String,
      authorName: isAnonymous ? '익명' : (data['author'] as String? ?? '익명'),
      generation: null, // server doesn't return generation
      content: data['content'] as String? ?? '',
      parentId: parentId,
    );
  }
}

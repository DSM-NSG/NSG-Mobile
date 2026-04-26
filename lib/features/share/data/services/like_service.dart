import 'package:nsg_mobile/core/network/api_client.dart';
import 'package:nsg_mobile/core/network/api_endpoints.dart';

typedef LikeResult = ({bool isLiked, int likeCount});

class LikeService {
  /// POST /posts/{post_id}/like/
  /// Returns the authoritative like state from the server.
  static Future<LikeResult> toggleLike(String postId) async {
    final response = await ApiClient.dio.post(
      ApiEndpoints.toggleLike(postId),
    );
    final data = response.data as Map<String, dynamic>;
    return (
      isLiked: data['is_liked'] == true,
      likeCount: (data['like_count'] as num?)?.toInt() ?? 0,
    );
  }
}

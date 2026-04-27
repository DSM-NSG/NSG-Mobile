import 'package:nsg_mobile/core/network/api_client.dart';
import 'package:nsg_mobile/core/network/api_endpoints.dart';
import 'package:nsg_mobile/features/share/data/models/tips_post_model.dart';

class TipsService {
  /// GET /posts/tips/
  static Future<List<TipsPostModel>> getPosts({
    String? category,
    int page = 1,
    String? search,
  }) async {
    final response = await ApiClient.dio.get(
      ApiEndpoints.tipsPosts,
      queryParameters: {
        if (category != null) 'category': category,
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final data = response.data;
    final List<dynamic> items;
    if (data is List) {
      items = data;
    } else if (data is Map<String, dynamic> && data.containsKey('results')) {
      items = data['results'] as List<dynamic>;
    } else {
      items = [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(TipsPostModel.fromJson)
        .toList();
  }

  /// GET /posts/tips/{id}/
  static Future<TipsPostDetailModel> getPostDetail(String id) async {
    final response = await ApiClient.dio.get(ApiEndpoints.tipsPostDetail(id));
    return TipsPostDetailModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// DELETE /posts/tips/{id}/delete/
  static Future<void> deletePost(String id) async {
    await ApiClient.dio.delete(ApiEndpoints.deleteTipsPost(id));
  }

  /// POST /posts/tips/create/
  static Future<TipsPostDetailModel> createPost({
    required String title,
    required String body,
    required String category,
    bool isAnonymous = false,
    String? placeId,
    List<String> imageUrls = const [],
  }) async {
    final response = await ApiClient.dio.post(
      ApiEndpoints.createTipsPost,
      data: {
        'title': title,
        'body': body,
        'category': category,
        'is_anonymous': isAnonymous,
        if (placeId != null) 'place_id': placeId,
        'image_urls': imageUrls,
      },
    );
    return TipsPostDetailModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}

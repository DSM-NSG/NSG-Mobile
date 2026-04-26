import 'package:nsg_mobile/core/network/api_client.dart';
import 'package:nsg_mobile/core/network/api_endpoints.dart';
import 'package:nsg_mobile/features/major/data/models/major_category_model.dart';
import 'package:nsg_mobile/features/major/data/models/major_post_model.dart';

class MajorService {
  /// GET /majors/
  static Future<List<MajorCategory>> getMajors() async {
    final response = await ApiClient.dio.get(ApiEndpoints.majors);
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
        .map(MajorCategory.fromJson)
        .toList();
  }

  /// GET /posts/major/
  static Future<List<MajorPostModel>> getPosts({
    String? majorId,
    int page = 1,
    String? search,
  }) async {
    final response = await ApiClient.dio.get(
      ApiEndpoints.majorPosts,
      queryParameters: {
        if (majorId != null) 'major_id': majorId,
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
        .map(MajorPostModel.fromJson)
        .toList();
  }

  /// GET /posts/major/{id}/
  static Future<MajorPostDetailModel> getPostDetail(String id) async {
    final response =
        await ApiClient.dio.get(ApiEndpoints.majorPostDetail(id));
    return MajorPostDetailModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// DELETE /posts/major/{id}/delete/
  static Future<void> deletePost(String id) async {
    await ApiClient.dio.delete(ApiEndpoints.deleteMajorPost(id));
  }

  /// POST /posts/major/create/
  static Future<MajorPostDetailModel> createPost({
    required String title,
    required String body,
    List<String> majorIds = const [],
    bool isAnonymous = false,
    List<String> imageUrls = const [],
  }) async {
    final response = await ApiClient.dio.post(
      ApiEndpoints.createMajorPost,
      data: {
        'title': title,
        'body': body,
        'major_ids': majorIds,
        'is_anonymous': isAnonymous,
        'image_urls': imageUrls,
      },
    );
    return MajorPostDetailModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}

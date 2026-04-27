import 'dart:developer';

import 'package:nsg_mobile/core/network/api_client.dart';
import 'package:nsg_mobile/core/network/api_endpoints.dart';
import 'package:nsg_mobile/features/map/data/models/place_model.dart';

class PlaceService {
  /// GET / — list all places, optionally filtered by API category string.
  static Future<List<PlaceModel>> getPlaces({String? category}) async {
    final response = await ApiClient.dio.get(
      ApiEndpoints.places,
      queryParameters: {
        if (category != null && category.isNotEmpty) 'category': category,
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
        .map(PlaceModel.fromJson)
        .toList();
  }

  /// POST / — register a new place on the map.
  static Future<PlaceModel> createPlace({
    required String title,
    required String description,
    required String category, // API value e.g. 'CAFE'
    required double latitude,
    required double longitude,
    String naverMapUrl = '',
    bool isAnonymous = false,
  }) async {
    log(
      '장소 등록 요청: title=$title, category=$category, lat=$latitude, lon=$longitude',
      name: 'PlaceService',
    );
    final response = await ApiClient.dio.post(
      ApiEndpoints.places,
      data: {
        'title': title,
        'description': description,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        if (naverMapUrl.isNotEmpty) 'naver_map_url': naverMapUrl,
        'is_anonymous': isAnonymous,
      },
    );
    log('장소 등록 응답: ${response.statusCode} ${response.data}', name: 'PlaceService');
    return PlaceModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /{id}/ — delete a place.
  static Future<void> deletePlace(String id) async {
    await ApiClient.dio.delete(ApiEndpoints.placeDelete(id));
  }
}

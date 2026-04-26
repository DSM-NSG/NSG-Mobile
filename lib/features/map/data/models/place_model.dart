import 'package:nsg_mobile/features/share/domain/entities/post.dart';

// ── Category helpers ──────────────────────────────────────────────────────────

String _apiCategoryToApp(String api) =>
    const {
      'CAFE': '카페',
      'PC_CAFE': 'PC방',
      'KARAOKE': '노래방',
      'RESTAURANT': '맛집',
      'ETC': '기타',
    }[api] ??
    '기타';

/// Converts the app-side sub-category label to the Places API category string.
String appCategoryToPlaceApi(String app) =>
    const {
      '카페': 'CAFE',
      'PC방': 'PC_CAFE',
      '노래방': 'KARAOKE',
      '맛집': 'RESTAURANT',
      '기타': 'ETC',
    }[app] ??
    'ETC';

// ── Model ─────────────────────────────────────────────────────────────────────

class PlaceModel {
  final String id;
  final String author;
  final String title;
  final String description;
  final String category; // API value: CAFE / PC_CAFE / KARAOKE / RESTAURANT / ETC
  final double latitude;
  final double longitude;
  final String? naverMapUrl;
  final bool isAnonymous;
  final String createdAt;

  const PlaceModel({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.naverMapUrl,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
        id: json['id'] as String,
        author: json['author'] as String? ?? '익명',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'ETC',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        naverMapUrl: json['naver_map_url'] as String?,
        isAnonymous: json['is_anonymous'] == true,
        createdAt: json['created_at'] as String? ?? '',
      );

  /// Maps to the shared [Post] domain entity used by the map providers.
  Post toPost() => Post(
        id: id,
        title: title,
        content: description,
        category: '장소',
        subCategory: _apiCategoryToApp(category),
        locationName: title,
        locationAddress: naverMapUrl ?? '',
        latitude: latitude,
        longitude: longitude,
        likes: 0,
        comments: 0,
      );
}
